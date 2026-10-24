Set-StrictMode -Version Latest

$script:FlywayCrc32Table = $null

function ConvertTo-FlywayVersionKey {
    param([Parameter(Mandatory)][string]$Version)

    if ($Version -notmatch '^\d+$') {
        throw "Versión Flyway inválida: $Version"
    }

    return ([int]$Version).ToString('000', [Globalization.CultureInfo]::InvariantCulture)
}

function Get-FlywayMigrationVersion {
    param([Parameter(Mandatory)][string]$Path)

    $match = [regex]::Match(($Path -replace '\\', '/'), '(?:^|/)V(?<version>\d+)__[^/]+\.sql$')
    if (-not $match.Success) {
        return $null
    }

    return ConvertTo-FlywayVersionKey -Version $match.Groups['version'].Value
}

function Get-FlywayCrc32Table {
    if ($null -ne $script:FlywayCrc32Table) {
        return $script:FlywayCrc32Table
    }

    $polynomial = [Convert]::ToUInt32('EDB88320', 16)
    $table = New-Object 'uint32[]' 256
    for ($n = 0; $n -lt 256; $n++) {
        [uint32]$crc = [uint32]$n
        for ($bit = 0; $bit -lt 8; $bit++) {
            if (($crc -band [uint32]1) -ne 0) {
                $crc = [uint32](($polynomial) -bxor ($crc -shr 1))
            } else {
                $crc = [uint32]($crc -shr 1)
            }
        }
        $table[$n] = $crc
    }

    $script:FlywayCrc32Table = $table
    return $table
}

function Get-FlywayMigrationChecksum {
    param([Parameter(Mandatory)][string]$Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Migración Flyway no encontrada: $Path"
    }

    # Mirrors Flyway's ChecksumCalculator: read logical lines, remove line
    # endings and a possible UTF-8 BOM from the first line, then CRC32 each
    # line's UTF-8 bytes. The signed Int32 representation is what Flyway stores.
    $encoding = [Text.UTF8Encoding]::new($false)
    $lines = [IO.File]::ReadAllLines($Path, $encoding)
    $table = Get-FlywayCrc32Table
    [uint32]$crc = [Convert]::ToUInt32('FFFFFFFF', 16)
    $first = $true
    foreach ($lineValue in $lines) {
        $line = $lineValue
        if ($first) {
            $line = $line.TrimStart([char]0xFEFF)
            $first = $false
        }

        foreach ($byte in $encoding.GetBytes($line)) {
            $mix = ([int64]$crc) -bxor ([int64][uint32]$byte)
            $index = [int]($mix -band 255)
            $crc = [uint32]((([int64]$table[$index]) -bxor ([int64]([uint32]$crc -shr 8))))
        }
    }

    $crc = [uint32]((([int64]$crc) -bxor ([int64][Convert]::ToUInt32('FFFFFFFF', 16))))
    return [BitConverter]::ToInt32([BitConverter]::GetBytes($crc), 0)
}

function ConvertTo-FlywaySnapshotCanonicalObject {
    param([Parameter(Mandatory)]$Snapshot)

    $capturedAtValue = [DateTimeOffset]::MinValue
    if ($Snapshot.capturedAt -is [DateTime]) {
        $capturedAtValue = [DateTimeOffset]$Snapshot.capturedAt
    } elseif (-not [DateTimeOffset]::TryParse([string]$Snapshot.capturedAt, [Globalization.CultureInfo]::InvariantCulture, [Globalization.DateTimeStyles]::AssumeUniversal, [ref]$capturedAtValue)) {
        throw 'capturedAt no es una fecha UTC válida.'
    }

    $appliedVersions = @($Snapshot.appliedVersions | ForEach-Object {
        ConvertTo-FlywayVersionKey -Version ([string]$_)
    } | Sort-Object -Unique)
    $successfulVersions = @($Snapshot.successfulVersions | ForEach-Object {
        ConvertTo-FlywayVersionKey -Version ([string]$_)
    } | Sort-Object -Unique)
    $checksums = [ordered]@{}
    foreach ($property in @($Snapshot.checksums.PSObject.Properties | Sort-Object Name)) {
        $checksums[(ConvertTo-FlywayVersionKey -Version $property.Name)] = [int]$property.Value
    }

    return [ordered]@{
        schemaVersion = [int]$Snapshot.schemaVersion
        capturedAt = $capturedAtValue.ToUniversalTime().ToString('o')
        environment = [string]$Snapshot.environment
        appliedVersions = $appliedVersions
        successfulVersions = $successfulVersions
        checksums = $checksums
        currentVersion = (ConvertTo-FlywayVersionKey -Version ([string]$Snapshot.currentVersion))
    }
}

function Get-FlywaySafetySnapshotHash {
    param([Parameter(Mandatory)]$Snapshot)

    $canonical = ConvertTo-FlywaySnapshotCanonicalObject -Snapshot $Snapshot
    $json = $canonical | ConvertTo-Json -Compress -Depth 20
    $bytes = [Text.UTF8Encoding]::new($false).GetBytes($json)
    $digest = [Security.Cryptography.SHA256]::Create().ComputeHash($bytes)
    return ([BitConverter]::ToString($digest) -replace '-', '').ToLowerInvariant()
}

function Read-FlywaySafetySnapshot {
    param([Parameter(Mandatory)][string]$Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Flyway safety snapshot no encontrado: $Path"
    }

    $raw = [IO.File]::ReadAllText($Path, [Text.UTF8Encoding]::new($false))
    if ($raw -match '(?i)(password|secret|token|connectionstring|jdbc:|postgres(?:ql)?://)') {
        throw "Flyway safety snapshot rechazado: contiene material sensible."
    }

    try {
        $snapshot = $raw | ConvertFrom-Json
    } catch {
        throw "Flyway safety snapshot inválido: JSON no parseable."
    }

    foreach ($required in @('schemaVersion', 'capturedAt', 'environment', 'appliedVersions', 'successfulVersions', 'checksums', 'currentVersion', 'snapshotHash')) {
        if ($null -eq $snapshot.PSObject.Properties[$required]) {
            throw "Flyway safety snapshot inválido: falta $required."
        }
    }
    if ([int]$snapshot.schemaVersion -ne 1) {
        throw "Flyway safety snapshot inválido: schemaVersion no soportado."
    }
    if ([string]$snapshot.environment -notin @('production-read-only', 'local-fixture')) {
        throw "Flyway safety snapshot inválido: environment no autorizado."
    }
    $capturedAt = [DateTimeOffset]::MinValue
    if (-not [DateTimeOffset]::TryParse([string]$snapshot.capturedAt, [Globalization.CultureInfo]::InvariantCulture, [Globalization.DateTimeStyles]::AssumeUniversal, [ref]$capturedAt)) {
        throw "Flyway safety snapshot inválido: capturedAt no es UTC válido."
    }
    if ($null -eq $snapshot.appliedVersions -or $null -eq $snapshot.successfulVersions) {
        throw "Flyway safety snapshot inválido: listas de versiones ausentes."
    }

    $canonicalHash = Get-FlywaySafetySnapshotHash -Snapshot $snapshot
    if ([string]$snapshot.snapshotHash -notmatch '^[0-9a-fA-F]{64}$' -or
        -not [string]::Equals([string]$snapshot.snapshotHash, $canonicalHash, [StringComparison]::OrdinalIgnoreCase)) {
        throw "Flyway safety snapshot rechazado: snapshotHash no coincide."
    }

    $applied = @($snapshot.appliedVersions | ForEach-Object { ConvertTo-FlywayVersionKey -Version ([string]$_) } | Sort-Object -Unique)
    $successful = @($snapshot.successfulVersions | ForEach-Object { ConvertTo-FlywayVersionKey -Version ([string]$_) } | Sort-Object -Unique)
    $appliedSet = @{}
    foreach ($version in $applied) { $appliedSet[$version] = $true }
    foreach ($version in $successful) {
        if (-not $appliedSet.ContainsKey($version)) {
            throw "Flyway safety snapshot inválido: successfulVersions contiene $version fuera de appliedVersions."
        }
    }

    $normalizedChecksums = [ordered]@{}
    foreach ($property in @($snapshot.checksums.PSObject.Properties)) {
        $version = ConvertTo-FlywayVersionKey -Version $property.Name
        if (-not $appliedSet.ContainsKey($version)) {
            throw "Flyway safety snapshot inválido: checksum fuera de appliedVersions ($version)."
        }
        $checksum = 0
        if (-not [int]::TryParse([string]$property.Value, [Globalization.NumberStyles]::Integer, [Globalization.CultureInfo]::InvariantCulture, [ref]$checksum)) {
            throw "Flyway safety snapshot inválido: checksum no entero ($version)."
        }
        $normalizedChecksums[$version] = $checksum
    }
    foreach ($version in $successful) {
        if (-not $normalizedChecksums.Contains($version)) {
            throw "Flyway safety snapshot inválido: falta checksum de versión exitosa ($version)."
        }
    }

    return [pscustomobject]@{
        schemaVersion = 1
        capturedAt = $capturedAt.ToUniversalTime().ToString('o')
        environment = [string]$snapshot.environment
        appliedVersions = $applied
        successfulVersions = $successful
        checksums = $normalizedChecksums
        currentVersion = ConvertTo-FlywayVersionKey -Version ([string]$snapshot.currentVersion)
        snapshotHash = $canonicalHash
    }
}

function New-FlywaySafetySnapshot {
    param(
        [Parameter(Mandatory)][object[]]$HistoryRows,
        [Parameter(Mandatory)][string]$Environment,
        [DateTimeOffset]$CapturedAt = [DateTimeOffset]::UtcNow
    )

    if ([string]::IsNullOrWhiteSpace($Environment) -or $Environment -match '(?i)(password|secret|token|connectionstring|jdbc:|postgres(?:ql)?://)') {
        throw 'Environment de snapshot inválido o sensible.'
    }

    $history = [ordered]@{}
    foreach ($row in $HistoryRows) {
        $version = ConvertTo-FlywayVersionKey -Version ([string]$row.version)
        $checksum = 0
        if (-not [int]::TryParse([string]$row.checksum, [Globalization.NumberStyles]::Integer, [Globalization.CultureInfo]::InvariantCulture, [ref]$checksum)) {
            throw "Checksum Flyway inválido en $version."
        }
        $successText = ([string]$row.success).Trim().ToLowerInvariant()
        if ($successText -notin @('t', 'true', '1', 'f', 'false', '0')) {
            throw "Estado success Flyway inválido en $version."
        }
        $history[$version] = [pscustomobject]@{
            checksum = $checksum
            success = $successText -in @('t', 'true', '1')
        }
    }
    if ($history.Count -eq 0) {
        throw 'No se puede crear un snapshot Flyway vacío.'
    }

    $applied = @($history.Keys | Sort-Object { [int]$_ })
    $successful = @($applied | Where-Object { $history[$_].success })
    if ($successful.Count -eq 0) {
        throw 'No se puede determinar currentVersion: no hay migraciones exitosas.'
    }
    $checksums = [ordered]@{}
    foreach ($version in $applied) { $checksums[$version] = [int]$history[$version].checksum }
    $snapshot = [pscustomobject]@{
        schemaVersion = 1
        capturedAt = $CapturedAt.ToUniversalTime().ToString('o')
        environment = $Environment
        appliedVersions = $applied
        successfulVersions = $successful
        checksums = [pscustomobject]$checksums
        currentVersion = ($successful | Sort-Object { [int]$_ } | Select-Object -Last 1)
    }
    $snapshot | Add-Member -NotePropertyName snapshotHash -NotePropertyValue (Get-FlywaySafetySnapshotHash -Snapshot $snapshot)
    return $snapshot
}

function Write-FlywaySafetySnapshot {
    param(
        [Parameter(Mandatory)]$Snapshot,
        [Parameter(Mandatory)][string]$Path
    )

    $parent = Split-Path -Parent $Path
    if (-not [string]::IsNullOrWhiteSpace($parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }
    $json = $Snapshot | ConvertTo-Json -Depth 20
    $temporary = "$Path.tmp-$([guid]::NewGuid().ToString('N'))"
    try {
        [IO.File]::WriteAllText($temporary, $json, [Text.UTF8Encoding]::new($false))
        Move-Item -LiteralPath $temporary -Destination $Path -Force
    } finally {
        if (Test-Path -LiteralPath $temporary) {
            Remove-Item -LiteralPath $temporary -Force
        }
    }
}

Export-ModuleMember -Function ConvertTo-FlywayVersionKey, Get-FlywayMigrationVersion, Get-FlywayMigrationChecksum, Get-FlywaySafetySnapshotHash, Read-FlywaySafetySnapshot, New-FlywaySafetySnapshot, Write-FlywaySafetySnapshot
