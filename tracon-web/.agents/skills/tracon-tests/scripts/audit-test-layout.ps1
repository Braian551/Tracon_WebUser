[CmdletBinding()]
param(
  [string]$RepositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../../..')).Path
)

$ErrorActionPreference = 'Stop'
$mobileTestRoot = Join-Path $RepositoryRoot 'mobile/test'
$backendTestRoot = Join-Path $RepositoryRoot 'backend/core-api/src/test/java'
$violations = [System.Collections.Generic.List[string]]::new()

if (Test-Path -LiteralPath $mobileTestRoot) {
  Get-ChildItem -LiteralPath $mobileTestRoot -File -Filter '*_test.dart' |
    ForEach-Object { $violations.Add("FLUTTER_ROOT $($_.FullName)") }
}

$javaFiles = @()
if (Test-Path -LiteralPath $backendTestRoot) {
  $javaFiles = @(Get-ChildItem -LiteralPath $backendTestRoot -Recurse -File -Filter '*.java')
}

foreach ($file in $javaFiles) {
  $relative = $file.FullName.Substring($backendTestRoot.Length).TrimStart('\', '/')
  $pathParts = $relative -split '[\\/]'
  if ($pathParts.Length -eq 1) {
    $violations.Add("JAVA_ROOT $($file.FullName)")
  }

  $source = Get-Content -LiteralPath $file.FullName -Raw
  $packageMatch = [regex]::Match($source, '(?m)^package\s+([^;]+);')
  if (-not $packageMatch.Success) {
    $violations.Add("JAVA_NO_PACKAGE $($file.FullName)")
    continue
  }

  $expected = (($packageMatch.Groups[1].Value.Trim() -replace '\.', '\') + '\' + $file.Name)
  if (-not $relative.Replace('/', '\').EndsWith($expected)) {
    $violations.Add("JAVA_PACKAGE_MISMATCH $($file.FullName) => $($packageMatch.Groups[1].Value.Trim())")
  }
}

$duplicateBasenames = @(
  Get-ChildItem -LiteralPath $mobileTestRoot -Recurse -File -Filter '*_test.dart' -ErrorAction SilentlyContinue |
    Group-Object Name | Where-Object Count -gt 1
)
foreach ($group in $duplicateBasenames) {
  $paths = ($group.Group.FullName -join '; ')
  $violations.Add("DUPLICATE_DART_BASENAME $($group.Name) => $paths")
}

if ($violations.Count -eq 0) {
  Write-Output 'TEST_LAYOUT_OK'
  exit 0
}

$violations | Sort-Object
Write-Output "TEST_LAYOUT_VIOLATIONS=$($violations.Count)"
exit 1
