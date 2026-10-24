[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$HistoryRowsPath,
    [Parameter(Mandatory)][string]$OutputPath,
    [string]$Environment = 'production-read-only'
)

$ErrorActionPreference = 'Stop'
$modulePath = Join-Path $PSScriptRoot 'FlywaySafety.psm1'
Import-Module $modulePath -Force

if (-not (Test-Path -LiteralPath $HistoryRowsPath -PathType Leaf)) {
    throw "Historial Flyway no encontrado: $HistoryRowsPath"
}

try {
    $document = Get-Content -LiteralPath $HistoryRowsPath -Raw -Encoding UTF8 | ConvertFrom-Json
} catch {
    throw 'Historial Flyway inválido: JSON no parseable.'
}

$rows = if ($document -is [Array]) {
    @($document)
} elseif ($document.PSObject.Properties.Name -contains 'rows') {
    @($document.rows)
} else {
    @($document)
}
if ($rows.Count -eq 0) {
    throw 'Historial Flyway vacío.'
}

$snapshot = New-FlywaySafetySnapshot -HistoryRows $rows -Environment $Environment
Write-FlywaySafetySnapshot -Snapshot $snapshot -Path $OutputPath
$verified = Read-FlywaySafetySnapshot -Path $OutputPath

Write-Host "Flyway safety snapshot persisted: $OutputPath"
Write-Host "environment=$($verified.environment) currentVersion=$($verified.currentVersion) appliedVersions=$(@($verified.appliedVersions).Count) successfulVersions=$(@($verified.successfulVersions).Count)"
Write-Host "snapshotHash=$($verified.snapshotHash)"
