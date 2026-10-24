[CmdletBinding()]
param(
    [string]$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..\..\..")),
    [ValidateSet('Validate', 'Build', 'Deploy', 'Rollback', 'Cleanup', 'Recovery', 'Delete')]
    [string]$Operation = 'Validate',
    [string[]]$Paths,
    [string]$FlywaySafetySnapshotPath,
    [switch]$EnforceAuthorization
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path -LiteralPath $ProjectRoot).Path
$repositoryRoot = Test-Path -LiteralPath (Join-Path $root 'AGENTS.md') -PathType Leaf
$violations = New-Object System.Collections.Generic.List[string]
$flywaySafetySnapshot = $null

function Add-Violation([string]$Message) {
    [void]$violations.Add($Message)
}

function Test-ProductionSafetyScanPath([string]$RelativePath) {
    # Test fixtures can contain literal destructive SQL as input data. They are
    # not executed by the production runner and must not be classified as
    # production operations by this source scanner.
    return $RelativePath -notmatch '^ops/release/test-[^/]+\.ps1$'
}

if (-not [string]::IsNullOrWhiteSpace($FlywaySafetySnapshotPath)) {
    try {
        Import-Module (Join-Path $PSScriptRoot 'FlywaySafety.psm1') -Force
        $flywaySafetySnapshot = Read-FlywaySafetySnapshot -Path $FlywaySafetySnapshotPath
    } catch {
        Add-Violation "FLYWAY_SAFETY_SNAPSHOT_INVALID: $($_.Exception.Message)"
    }
}
if ($flywaySafetySnapshot -and $Operation -eq 'Deploy' -and $flywaySafetySnapshot.environment -ne 'production-read-only') {
    Add-Violation 'FLYWAY_SAFETY_ENVIRONMENT_INVALID: Deploy requiere snapshot production-read-only; local-fixture solo sirve para pruebas.'
}

if ($EnforceAuthorization) {
    if ($Operation -eq 'Deploy' -and [string]::IsNullOrWhiteSpace($env:TRACON_DEPLOY_AUTHORIZATION)) {
        Add-Violation 'Deploy requiere TRACON_DEPLOY_AUTHORIZATION; no se acepta autorización implícita.'
    }
    if ($Operation -eq 'Delete' -and [string]::IsNullOrWhiteSpace($env:TRACON_DELETION_AUTHORIZATION)) {
        Add-Violation 'Delete requiere TRACON_DELETION_AUTHORIZATION separado.'
    }
    if ($Operation -eq 'Recovery' -and [string]::IsNullOrWhiteSpace($env:TRACON_RECOVERY_AUTHORIZATION)) {
        Add-Violation 'Recovery requiere TRACON_RECOVERY_AUTHORIZATION separado.'
    }
}

if (-not [string]::IsNullOrWhiteSpace($env:TRACON_DEPLOY_AUTHORIZATION) -and
    -not [string]::IsNullOrWhiteSpace($env:TRACON_DELETION_AUTHORIZATION) -and
    $env:TRACON_DEPLOY_AUTHORIZATION -eq $env:TRACON_DELETION_AUTHORIZATION) {
    Add-Violation 'La autorización de deploy y la de borrado no pueden ser el mismo valor.'
}

$defaultPaths = @(
    'ops/release',
    'ops/infrastructure',
    'compose.yaml',
    'compose.prod.yaml'
)
$requestedPaths = if ($Paths -and $Paths.Count -gt 0) { @($defaultPaths + $Paths) } else { $defaultPaths }
$fileSet = New-Object System.Collections.Generic.List[System.IO.FileInfo]

foreach ($requested in @($requestedPaths | Sort-Object -Unique)) {
    $candidate = if ([System.IO.Path]::IsPathRooted($requested)) {
        $requested
    } else {
        Join-Path $root ($requested -replace '/', '\')
    }
    if (-not (Test-Path -LiteralPath $candidate)) {
        continue
    }
    $item = Get-Item -LiteralPath $candidate
    if ($item -is [System.IO.DirectoryInfo]) {
        Get-ChildItem -LiteralPath $item.FullName -Recurse -File |
            Where-Object {
                $relative = $_.FullName.Substring($root.Length).TrimStart('\', '/').Replace('\', '/')
                $_.Extension.ToLowerInvariant() -in @('.sh', '.ps1', '.sql', '.yml', '.yaml') -and
                (-not $repositoryRoot -or $_.FullName.Substring($root.Length).TrimStart('\', '/').Replace('\', '/') -match
                    '^(ops/|compose(?:\.|$)|services/[^/]+/compose(?:\.|$)|backend/core-api/src/main/resources/db/migration/)') -and
                (Test-ProductionSafetyScanPath $relative)
            } |
            ForEach-Object { $fileSet.Add($_) }
    } elseif ($item.Extension.ToLowerInvariant() -in @('.sh', '.ps1', '.sql', '.yml', '.yaml')) {
        $relativeCandidate = $item.FullName.Substring($root.Length).TrimStart('\', '/').Replace('\', '/')
        if (-not $repositoryRoot -or $relativeCandidate -match
            '^(ops/|compose(?:\.|$)|services/[^/]+/compose(?:\.|$)|backend/core-api/src/main/resources/db/migration/)' -and
            (Test-ProductionSafetyScanPath $relativeCandidate)) {
            $fileSet.Add($item)
        }
    }
}

$dropToken = 'DROP'
$databaseToken = 'DATABASE'
$schemaToken = 'SCHEMA'
$tableToken = 'TABLE'
$truncateToken = 'TRUN' + 'CATE'
$deleteToken = 'DELETE'
$fromToken = 'FROM'
$postgresRestoreToken = 'pg' + '_restore'
$flushToken = 'FLUSH'
$dockerToken = 'docker'
$composeToken = 'compose'
$downToken = 'down'
$volumeToken = 'volume'
$shortVolumesOption = '-' + 'v'
$longVolumesOption = '--' + 'volumes'
$pruneToken = 'prune'
$removeToken = 'rm'
$awsS3RemoveToken = 'aws s3 ' + 'rm'
$rcloneDeleteToken = 'rclone ' + 'delete'
$mcRemoveToken = 'mc ' + 'rm'
$deleteObjectToken = 'Delete' + 'Object'
$deleteObjectsToken = 'Delete' + 'Objects'

# Keep the signatures composable so this scanner does not report its own
# pattern definitions as executable operations. The resulting regexes are
# unchanged, and the scanner still fails closed on real matches.
$patterns = @(
    [PSCustomObject]@{ Name = 'SQL destructive DDL'; Regex = "(?i)\b$dropToken\s+($databaseToken|$schemaToken|$tableToken)\b"; Kind = 'destructive' }
    [PSCustomObject]@{ Name = 'SQL truncation'; Regex = "(?i)\b$truncateToken(?:\s+$tableToken)?\b"; Kind = 'destructive' }
    [PSCustomObject]@{ Name = 'SQL row deletion'; Regex = "(?i)\b$deleteToken\s+$fromToken\b"; Kind = 'delete' }
    [PSCustomObject]@{ Name = 'PostgreSQL restore'; Regex = "(?i)\b$postgresRestoreToken\b"; Kind = 'restore' }
    [PSCustomObject]@{ Name = 'Redis flush'; Regex = "(?i)\b$flushToken(?:ALL|DB)\b"; Kind = 'destructive' }
    [PSCustomObject]@{ Name = 'Compose volume teardown'; Regex = "(?i)\b(?:$dockerToken\s+$composeToken|$composeToken)\s+$downToken\b[^\r\n#]*\s(?:$shortVolumesOption|$longVolumesOption)\b"; Kind = 'destructive' }
    [PSCustomObject]@{ Name = 'Docker global prune'; Regex = "(?i)\b$dockerToken\s+(system|$volumeToken|network)\s+$pruneToken\b"; Kind = 'destructive' }
    [PSCustomObject]@{ Name = 'Docker volume deletion'; Regex = "(?i)\b$dockerToken\s+$volumeToken\s+$removeToken\b"; Kind = 'destructive' }
    [PSCustomObject]@{ Name = 'R2 object deletion'; Regex = "(?i)\b(?:$awsS3RemoveToken|$rcloneDeleteToken|$mcRemoveToken|$deleteObjectToken|$deleteObjectsToken)\b"; Kind = 'r2-delete' }
    [PSCustomObject]@{ Name = 'Flyway destructive cleanup'; Regex = '(?i)\bflyway\s+clean\b'; Kind = 'destructive' }
)

foreach ($file in @($fileSet | Sort-Object FullName -Unique)) {
    $relative = $file.FullName.Substring($root.Length).TrimStart('\', '/').Replace('\', '/')
    $migrationVersion = if ($flywaySafetySnapshot) { Get-FlywayMigrationVersion -Path $relative } else { $null }
    if ($flywaySafetySnapshot -and $migrationVersion -and
        @($flywaySafetySnapshot.successfulVersions) -contains $migrationVersion) {
        $expectedChecksum = [int]$flywaySafetySnapshot.checksums[$migrationVersion]
        $actualChecksum = Get-FlywayMigrationChecksum -Path $file.FullName
        if ($actualChecksum -ne $expectedChecksum) {
            Add-Violation "APPLIED_MIGRATION_MUTATED: $relative (version=$migrationVersion expectedChecksum=$expectedChecksum actualChecksum=$actualChecksum)"
        } else {
            Write-Host "HISTORICAL_APPLIED_IMMUTABLE: $relative (version=$migrationVersion checksum=$actualChecksum)" -ForegroundColor DarkGray
        }
        continue
    }
    $raw = Get-Content -LiteralPath $file.FullName -Raw -Encoding UTF8
    $syntheticTeardown = $relative -eq 'ops/release/authenticated-smoke.sh' -and
        $raw -match '(?im)TRACON_SYNTHETIC_TEARDOWN_OK'
    $lineNumber = 0
    foreach ($line in @(Get-Content -LiteralPath $file.FullName -Encoding UTF8)) {
        $lineNumber++
        $trimmed = $line.TrimStart()
        if ([string]::IsNullOrWhiteSpace($trimmed) -or $trimmed.StartsWith('#') -or $trimmed.StartsWith('--')) {
            continue
        }
        foreach ($pattern in $patterns) {
            if ($line -notmatch $pattern.Regex) {
                continue
            }
            # A derived search document is rebuildable state, not canonical
            # product data. Its migration invalidation is the only DELETE
            # allowed here, and the target is intentionally exact.
            if ($pattern.Kind -eq 'delete' -and
                $relative -eq 'backend/core-api/src/main/resources/db/migration/V073__postgres_derived_search_projection.sql' -and
                $line -match '(?i)^\s*DELETE\s+FROM\s+discovery\.search_documents\b') {
                continue
            }
            if ($syntheticTeardown -and $pattern.Kind -eq 'delete') {
                continue
            }
            if ($flywaySafetySnapshot -and $migrationVersion) {
                Add-Violation "DESTRUCTIVE_NEW_MIGRATION: $relative`:$lineNumber ($($pattern.Name))"
            } else {
                Add-Violation "$($pattern.Name): $relative`:$lineNumber"
            }
        }
    }
}

Write-Host "Production safety audit: operation=$Operation files=$(@($fileSet | Sort-Object FullName -Unique).Count)"
Write-Host "Deploy authorization present: $(-not [string]::IsNullOrWhiteSpace($env:TRACON_DEPLOY_AUTHORIZATION))"
Write-Host "Deletion authorization present: $(-not [string]::IsNullOrWhiteSpace($env:TRACON_DELETION_AUTHORIZATION))"
Write-Host "Recovery authorization present: $(-not [string]::IsNullOrWhiteSpace($env:TRACON_RECOVERY_AUTHORIZATION))"
if ($flywaySafetySnapshot) {
    Write-Host "Flyway safety mode: production-aware snapshot=$FlywaySafetySnapshotPath currentVersion=$($flywaySafetySnapshot.currentVersion)"
} else {
    Write-Host 'Flyway safety mode: static scan (no history snapshot supplied)'
}

if ($violations.Count -gt 0) {
    foreach ($violation in $violations) {
        Write-Host "PRODUCTION SAFETY VIOLATION: $violation" -ForegroundColor Red
    }
    throw "Production safety audit failed with $($violations.Count) violation(s): $($violations -join ' | ')"
}

Write-Host '[OK] production safety audit'
