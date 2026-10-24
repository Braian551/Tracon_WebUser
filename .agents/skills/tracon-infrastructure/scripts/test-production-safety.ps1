[CmdletBinding()]
param(
    [string]$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..\..\..")),
    [string]$CandidateRoot = (Join-Path $env:LOCALAPPDATA 'Tracon\release-coordinator\batches\bootstrap-bootstrap-20260902-approval-001-recovery-001\candidate')
)

$ErrorActionPreference = 'Stop'
$audit = Join-Path $PSScriptRoot 'audit-production-safety.ps1'
$releaseModule = Join-Path $PSScriptRoot '..\..\..\..\ops\release\ReleaseCoordinator.psm1'
$runDir = Join-Path (Join-Path $env:TEMP 'tracon-agent') ('production-safety-test-{0}' -f [guid]::NewGuid().ToString('N'))
$passed = New-Object System.Collections.Generic.List[string]

function Assert-True([bool]$Condition, [string]$Message) {
    if (-not $Condition) { throw "ASSERTION_FAILED: $Message" }
}

function Mark([string]$Id, [scriptblock]$Action) {
    & $Action
    [void]$passed.Add($Id)
}

function Invoke-ExpectedFailure([string]$Path) {
    try {
        & $audit -ProjectRoot $runDir -Paths $Path -Operation Validate | Out-Null
    } catch {
        return
    }
    throw "El fixture inseguro pasó el guard: $Path"
}

function Invoke-ExpectedPass([string]$Path) {
    try {
        & $audit -ProjectRoot $runDir -Paths $Path -Operation Validate | Out-Null
    } catch {
        throw "El fixture seguro fue bloqueado por el guard: $Path; $($_.Exception.Message)"
    }
}

New-Item -ItemType Directory -Force -Path $runDir | Out-Null
try {
    $safe = Join-Path $runDir 'safe.sql'
    $badSql = Join-Path $runDir 'bad.sql'
    $badR2 = Join-Path $runDir 'bad-r2.sh'
    $badCompose = Join-Path $runDir 'bad-compose.sh'
    $badFlyway = Join-Path $runDir 'bad-flyway.sh'
    $badRedis = Join-Path $runDir 'bad-redis.sh'
    $docs = Join-Path $runDir 'docs/README.md'
    $scannerFixture = Join-Path $runDir '.agents/skills/tracon-infrastructure/scripts/audit-production-safety.ps1'
    $markedFixture = Join-Path $runDir 'tests/fixtures/safety/scanner-fixture.ps1'
    $commentOnly = Join-Path $runDir 'comment-only.sh'
    $shellCommand = Join-Path $runDir 'actual-shell.sh'
    $powerShellCommand = Join-Path $runDir 'actual-powershell.ps1'
    $testFixtureCommand = Join-Path $runDir 'ops/release/test-fixture.ps1'
    $productDelete = Join-Path $runDir 'backend/core-api/src/main/java/AccountDelete.java'
    $smoke = Join-Path $runDir 'ops/release/authenticated-smoke.sh'
    New-Item -ItemType Directory -Force -Path (Split-Path $docs), (Split-Path $scannerFixture), (Split-Path $markedFixture), (Split-Path $commentOnly), (Split-Path $shellCommand), (Split-Path $testFixtureCommand), (Split-Path $productDelete), (Split-Path $smoke) | Out-Null
    Set-Content -LiteralPath $safe -Encoding UTF8 -Value 'SELECT 1;'
    Set-Content -LiteralPath $badSql -Encoding UTF8 -Value 'TRUNCATE TABLE identity.users;'
    Set-Content -LiteralPath $badR2 -Encoding UTF8 -Value 'aws s3 rm s3://bucket/key'
    Set-Content -LiteralPath $badCompose -Encoding UTF8 -Value 'docker compose down --volumes'
    Set-Content -LiteralPath $badFlyway -Encoding UTF8 -Value 'flyway clean'
    Set-Content -LiteralPath $badRedis -Encoding UTF8 -Value 'redis-cli FLUSHALL'
    Set-Content -LiteralPath $docs -Encoding UTF8 -Value 'Documentación: NO ejecutar flyway clean.'
    Copy-Item -LiteralPath $audit -Destination $scannerFixture
    Set-Content -LiteralPath $markedFixture -Encoding UTF8 -Value @('# TRACON_SAFETY_SCANNER_FIXTURE', '# docker compose down --volumes is intentionally documented here.')
    Set-Content -LiteralPath $commentOnly -Encoding UTF8 -Value @('# NO ejecutar flyway clean', '# docker compose down -v')
    Set-Content -LiteralPath $shellCommand -Encoding UTF8 -Value 'docker compose down -v'
    Set-Content -LiteralPath $powerShellCommand -Encoding UTF8 -Value '& docker compose down --volumes'
    Set-Content -LiteralPath $testFixtureCommand -Encoding UTF8 -Value "`$sql = 'DELETE FROM public.test_rows;'"
    Set-Content -LiteralPath $smoke -Encoding UTF8 -Value @('# TRACON_SYNTHETIC_TEARDOWN_OK', 'DELETE FROM identity.users WHERE id = $user_id;')
    Set-Content -LiteralPath $productDelete -Encoding UTF8 -Value 'class AccountDelete { String sql = "DELETE FROM identity.users"; }'

    Invoke-ExpectedPass $safe
    Invoke-ExpectedFailure $badSql
    Invoke-ExpectedFailure $badR2
    Invoke-ExpectedPass $smoke
    Invoke-ExpectedPass $productDelete

    Mark 'SAFE-01' { Invoke-ExpectedFailure $badCompose }
    Mark 'SAFE-02' { Invoke-ExpectedFailure $badFlyway }
    Mark 'SAFE-03' { Invoke-ExpectedFailure $badRedis }
    Mark 'SAFE-04' { Invoke-ExpectedPass $docs }
    Mark 'SAFE-05' { Invoke-ExpectedPass '.agents/skills/tracon-infrastructure/scripts/audit-production-safety.ps1' }
    Mark 'SAFE-06' { Invoke-ExpectedPass 'tests/fixtures/safety/scanner-fixture.ps1' }
    Mark 'SAFE-07' { Invoke-ExpectedPass $commentOnly }
    Mark 'SAFE-08' { Invoke-ExpectedFailure $shellCommand }
    Mark 'SAFE-09' { Invoke-ExpectedFailure $powerShellCommand }

    Mark 'SAFE-10' {
        Import-Module -Name (Resolve-Path $releaseModule) -Force -DisableNameChecking
        $hashRoot = $CandidateRoot
        $synthetic = $false
        if (-not (Test-Path -LiteralPath $hashRoot -PathType Container)) {
            $hashRoot = Join-Path $runDir 'candidate-hash-fixture'
            New-Item -ItemType Directory -Force -Path $hashRoot | Out-Null
            Set-Content -LiteralPath (Join-Path $hashRoot 'candidate.txt') -Encoding UTF8 -Value 'candidate fixture'
            $synthetic = $true
        }
        $before = (Get-TreeManifest $hashRoot).sourceHash
        try {
            & $audit -ProjectRoot $hashRoot -Paths (if ($synthetic) { 'candidate.txt' } else { 'ops/release' }) -Operation Validate | Out-Null
        } catch { }
        $after = (Get-TreeManifest $hashRoot).sourceHash
        Assert-True ($before -eq $after) 'el guard no modifica el árbol auditado ni su hash'
    }

    Mark 'SAFE-11' { Invoke-ExpectedPass 'ops/release/test-fixture.ps1' }

    Write-Host ("SAFE TESTS PASS: $($passed.Count)/11")
    $passed | ForEach-Object { Write-Host "PASS $_" }
} finally {
    if (Test-Path -LiteralPath $runDir) {
        Remove-Item -LiteralPath $runDir -Recurse -Force
    }
}
