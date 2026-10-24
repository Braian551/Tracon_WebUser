[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$audit = Join-Path $PSScriptRoot 'audit-production-safety.ps1'
$module = Join-Path $PSScriptRoot 'FlywaySafety.psm1'
$snapshotWriter = Join-Path $PSScriptRoot 'capture-flyway-safety-snapshot.ps1'
$runDir = Join-Path (Join-Path $env:TEMP 'tracon-agent') ('flyway-safety-test-{0}' -f [guid]::NewGuid().ToString('N'))
$passed = New-Object System.Collections.Generic.List[string]

function Assert-True([bool]$Condition, [string]$Message) {
    if (-not $Condition) { throw "ASSERTION_FAILED: $Message" }
}

function Mark([string]$Id, [scriptblock]$Action) {
    & $Action
    [void]$passed.Add($Id)
}

function Invoke-AuditFixture([string]$Path, [string]$SnapshotPath) {
    $output = ''
    try {
        $output = (& $audit -ProjectRoot $runDir -Paths $Path -Operation Validate -FlywaySafetySnapshotPath $SnapshotPath 2>&1 6>&1 | Out-String)
        return [pscustomobject]@{ Passed = $true; Output = $output }
    } catch {
        return [pscustomobject]@{ Passed = $false; Output = ($output + [Environment]::NewLine + $_.Exception.Message) }
    }
}

New-Item -ItemType Directory -Force -Path $runDir | Out-Null
try {
    Import-Module $module -Force
    $migrationDir = Join-Path $runDir 'backend/core-api/src/main/resources/db/migration'
    New-Item -ItemType Directory -Force -Path $migrationDir | Out-Null

    $historicalDelete = Join-Path $migrationDir 'V036__historical_delete.sql'
    $historicalDrop = Join-Path $migrationDir 'V102__historical_drop.sql'
    $failedDelete = Join-Path $migrationDir 'V103__failed_delete.sql'
    $newDelete = Join-Path $migrationDir 'V200__new_delete.sql'
    $newSafe = Join-Path $migrationDir 'V201__new_safe.sql'
    $allowlistedName = Join-Path $migrationDir 'V036__allowlisted_name.sql'

    Set-Content -LiteralPath $historicalDelete -Encoding UTF8 -Value 'DELETE FROM content.post_votes WHERE value = 1;'
    Set-Content -LiteralPath $historicalDrop -Encoding UTF8 -Value 'DROP TABLE legacy.example;'
    Set-Content -LiteralPath $failedDelete -Encoding UTF8 -Value 'DELETE FROM legacy.example;'
    Set-Content -LiteralPath $newDelete -Encoding UTF8 -Value 'DELETE FROM legacy.example;'
    Set-Content -LiteralPath $newSafe -Encoding UTF8 -Value 'CREATE TABLE additive_example (id bigint PRIMARY KEY);'
    Set-Content -LiteralPath $allowlistedName -Encoding UTF8 -Value 'SELECT 1;'

    $snapshotPath = Join-Path $runDir 'flyway-safety-snapshot.json'
    $rows = @(
        [pscustomobject]@{ version = '036'; checksum = (Get-FlywayMigrationChecksum $historicalDelete); success = 't' }
        [pscustomobject]@{ version = '102'; checksum = (Get-FlywayMigrationChecksum $historicalDrop); success = 't' }
        [pscustomobject]@{ version = '103'; checksum = (Get-FlywayMigrationChecksum $failedDelete); success = 'f' }
    )
    $snapshot = New-FlywaySafetySnapshot -HistoryRows $rows -Environment 'local-fixture' -CapturedAt ([DateTimeOffset]'2026-09-03T00:00:00Z')
    Write-FlywaySafetySnapshot -Snapshot $snapshot -Path $snapshotPath

    Mark 'FLYSAFE-01' {
        $result = Invoke-AuditFixture $historicalDelete $snapshotPath
        Assert-True $result.Passed 'DELETE histórico con checksum coincidente debe pasar.'
        Assert-True ($result.Output -match 'HISTORICAL_APPLIED_IMMUTABLE') 'Debe reportar el resultado informativo histórico.'
    }

    Mark 'FLYSAFE-02' {
        Set-Content -LiteralPath $historicalDelete -Encoding UTF8 -Value 'DELETE FROM content.post_votes WHERE value = 2;'
        $result = Invoke-AuditFixture $historicalDelete $snapshotPath
        Assert-True (-not $result.Passed) 'Una migración aplicada con checksum cambiado debe fallar.'
        Assert-True ($result.Output -match 'APPLIED_MIGRATION_MUTATED') 'Debe clasificar APPLIED_MIGRATION_MUTATED.'
        Set-Content -LiteralPath $historicalDelete -Encoding UTF8 -Value 'DELETE FROM content.post_votes WHERE value = 1;'
    }

    Mark 'FLYSAFE-03' {
        $result = Invoke-AuditFixture $newDelete $snapshotPath
        Assert-True (-not $result.Passed) 'DELETE de migración no aplicada debe fallar.'
        Assert-True ($result.Output -match 'DESTRUCTIVE_NEW_MIGRATION') 'Debe clasificar DESTRUCTIVE_NEW_MIGRATION.'
    }

    Mark 'FLYSAFE-04' {
        $result = Invoke-AuditFixture $newSafe $snapshotPath
        Assert-True $result.Passed 'Migración nueva aditiva debe pasar.'
    }

    Mark 'FLYSAFE-05' {
        $result = Invoke-AuditFixture $historicalDrop $snapshotPath
        Assert-True $result.Passed 'DROP histórico con checksum coincidente debe ser informativo.'
        Assert-True ($result.Output -match 'HISTORICAL_APPLIED_IMMUTABLE') 'Debe reportar DROP histórico como inmutable.'
    }

    Mark 'FLYSAFE-06' {
        $result = Invoke-AuditFixture $allowlistedName $snapshotPath
        Assert-True (-not $result.Passed) 'El nombre de archivo no puede autorizar checksum incompatible.'
        Assert-True ($result.Output -match 'APPLIED_MIGRATION_MUTATED') 'La identidad debe depender de versión y checksum.'
    }

    Mark 'FLYSAFE-07' {
        $tamperedPath = Join-Path $runDir 'tampered-snapshot.json'
        Copy-Item -LiteralPath $snapshotPath -Destination $tamperedPath
        $tampered = Get-Content -LiteralPath $tamperedPath -Raw -Encoding UTF8
        $tampered = $tampered.Replace(('"036": ' + $rows[0].checksum), ('"036": ' + ([int]$rows[0].checksum + 1)))
        [IO.File]::WriteAllText($tamperedPath, $tampered, [Text.UTF8Encoding]::new($false))
        $result = Invoke-AuditFixture $newSafe $tamperedPath
        Assert-True (-not $result.Passed) 'Snapshot manipulado debe ser rechazado.'
        Assert-True ($result.Output -match 'FLYWAY_SAFETY_SNAPSHOT_INVALID|snapshotHash') 'Debe explicar el rechazo de integridad.'
    }

    Mark 'FLYSAFE-08' {
        $result = Invoke-AuditFixture $failedDelete $snapshotPath
        Assert-True (-not $result.Passed) 'Fila Flyway fallida no cuenta como aplicada.'
        Assert-True ($result.Output -match 'DESTRUCTIVE_NEW_MIGRATION') 'Una migración fallida destructiva debe bloquear.'
    }

    Mark 'FLYSAFE-09' {
        $writerText = Get-Content -LiteralPath $snapshotWriter -Raw -Encoding UTF8
        Assert-True ($writerText -notmatch '(?i)\b(psql|invoke-sqlcmd|docker\s+compose\s+exec)\b') 'El escritor de snapshot no debe conectarse ni escribir en producción.'
        Assert-True ($writerText -notmatch '(?i)\b(insert|update|delete|drop|truncate)\b') 'El escritor de snapshot no debe contener SQL mutante.'
        $rowsPath = Join-Path $runDir 'history-rows.json'
        $writerOutputPath = Join-Path $runDir 'writer-output.json'
        @($rows) | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $rowsPath -Encoding UTF8
        & $snapshotWriter -HistoryRowsPath $rowsPath -OutputPath $writerOutputPath -Environment 'local-fixture' | Out-Null
        [void](Read-FlywaySafetySnapshot -Path $writerOutputPath)
    }

    Mark 'FLYSAFE-10' {
        $snapshotText = Get-Content -LiteralPath $snapshotPath -Raw -Encoding UTF8
        Assert-True ($snapshotText -notmatch '(?i)(password|secret|token|connectionstring|jdbc:|postgres(?:ql)?://)') 'El snapshot no debe persistir secretos.'
        [void](Read-FlywaySafetySnapshot -Path $snapshotPath)
    }

    Write-Host ("FLYSAFE TESTS PASS: $($passed.Count)/10")
    $passed | ForEach-Object { Write-Host "PASS $_" }
} finally {
    if (Test-Path -LiteralPath $runDir) {
        Remove-Item -LiteralPath $runDir -Recurse -Force
    }
}
