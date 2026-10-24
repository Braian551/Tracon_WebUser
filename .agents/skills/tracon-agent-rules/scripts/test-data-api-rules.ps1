[CmdletBinding()]
param(
    [string]$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..\..\.."))
)

$ErrorActionPreference = 'Stop'
$audit = Join-Path $PSScriptRoot 'audit-data-api-rules.ps1'
$runDir = Join-Path (Join-Path $env:TEMP 'tracon-agent') ('data-api-rule-test-{0}' -f [guid]::NewGuid().ToString('N'))

function Invoke-ExpectedFailure([string]$Path, [switch]$FailOnWarning) {
    if ($FailOnWarning) {
        & $audit -ProjectRoot $runDir -Paths $Path -FailOnWarning
    } else {
        & $audit -ProjectRoot $runDir -Paths $Path
    }
    if ($LASTEXITCODE -eq 0) {
        throw "El fixture inseguro pasó el guard: $Path"
    }
}

New-Item -ItemType Directory -Force -Path $runDir | Out-Null
try {
    $badHard = Join-Path $runDir 'bad-hard.java'
    $badWarning = Join-Path $runDir 'bad-warning.java'
    $safe = Join-Path $runDir 'safe.java'

    Set-Content -LiteralPath $badHard -Encoding UTF8 -Value @(
        '@RestController'
        'class BadController {'
        '  @PostMapping void update(@RequestBody UserEntity user) {}'
        '  String find(String request) { return "SELECT * FROM users WHERE id = " + request; }'
        '}'
    )
    Set-Content -LiteralPath $badWarning -Encoding UTF8 -Value @(
        '@RestController'
        'class WarningController {'
        '  @GetMapping List<User> users() { return repository.findAll(); }'
        '  @QueryMapping List<User> usersQuery() { return repository.findAll(); }'
        '  @PostMapping("/provider-webhook") void webhook(String body) {}'
        '  ManagedChannel channel = ManagedChannelBuilder.forAddress("host", 443).build();'
        '}'
    )
    Set-Content -LiteralPath $safe -Encoding UTF8 -Value @(
        '@RestController'
        'class SafeController {'
        '  @GetMapping List<UserSummary> users(Pageable pageable) { return repository.findPage(pageable); }'
        '  @QueryMapping List<UserSummary> usersQuery(DataLoader loader) { return loader.load("users"); }'
        '  @PostMapping("/provider-webhook") void webhook(String rawBody, String signature) { verify(rawBody, signature); }'
        '  ManagedChannel channel = ManagedChannelBuilder.forAddress("host", 443).build();'
        '  ClientCall call = stub.withDeadlineAfter(200, TimeUnit.MILLISECONDS);'
        '  String sql = "SELECT id FROM users WHERE id = :id";'
        '}'
    )

    Invoke-ExpectedFailure $badHard
    Invoke-ExpectedFailure $badWarning -FailOnWarning
    & $audit -ProjectRoot $runDir -Paths $safe -FailOnWarning
    if ($LASTEXITCODE -ne 0) {
        throw 'El fixture seguro fue rechazado por el guard.'
    }
    Write-Host '[OK] data/API scalability fixtures'
} finally {
    if (Test-Path -LiteralPath $runDir) {
        Remove-Item -LiteralPath $runDir -Recurse -Force
    }
}
