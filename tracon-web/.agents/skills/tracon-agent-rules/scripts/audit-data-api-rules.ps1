[CmdletBinding()]
param(
    [string]$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..\..\..")),
    [string[]]$Paths,
    [switch]$FailOnWarning
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path -LiteralPath $ProjectRoot).Path
$warnings = [System.Collections.Generic.List[string]]::new()
$violations = [System.Collections.Generic.List[string]]::new()

function Add-WarningMessage([string]$Message) {
    [void]$warnings.Add($Message)
    Write-Output "WARNING $Message"
}

function Add-Violation([string]$Message) {
    [void]$violations.Add($Message)
    Write-Output "VIOLATION $Message"
}

function Get-RelativePath([string]$Path) {
    $full = [System.IO.Path]::GetFullPath($Path)
    if ($full.StartsWith($root, [System.StringComparison]::OrdinalIgnoreCase)) {
        return $full.Substring($root.Length).TrimStart('\', '/').Replace('\', '/')
    }
    return $full
}

function Get-TargetFiles {
    $requested = if ($Paths -and $Paths.Count -gt 0) {
        @($Paths)
    } else {
        @('backend/core-api/src', 'services', 'mobile/lib')
    }

    $extensions = @('.java', '.kt', '.go', '.dart', '.sql', '.graphql', '.graphqls', '.yml', '.yaml')
    $files = [System.Collections.Generic.List[System.IO.FileInfo]]::new()
    foreach ($requestedPath in $requested) {
        $candidate = if ([System.IO.Path]::IsPathRooted($requestedPath)) {
            $requestedPath
        } else {
            Join-Path $root ($requestedPath -replace '/', '\')
        }
        if (-not (Test-Path -LiteralPath $candidate)) {
            continue
        }
        $item = Get-Item -LiteralPath $candidate
        if ($item -is [System.IO.DirectoryInfo]) {
            Get-ChildItem -LiteralPath $item.FullName -Recurse -File |
                Where-Object { $_.Extension.ToLowerInvariant() -in $extensions } |
                ForEach-Object { [void]$files.Add($_) }
        } elseif ($item.Extension.ToLowerInvariant() -in $extensions) {
            [void]$files.Add($item)
        }
    }
    @($files | Sort-Object FullName -Unique)
}

foreach ($file in @(Get-TargetFiles)) {
    $relative = Get-RelativePath $file.FullName
    $raw = Get-Content -LiteralPath $file.FullName -Raw -Encoding UTF8
    $lines = @(Get-Content -LiteralPath $file.FullName -Encoding UTF8)

    # These two patterns are unequivocally unsafe at an API/data boundary.
    if ($raw -match '(?is)@RequestBody\s+(?:final\s+)?[\w<>, ?]*\b\w*Entity\b') {
        Add-Violation "REQUEST_ENTITY_BINDING $relative"
    }
    if ($raw -match '(?im)\b(?:SELECT|INSERT|UPDATE|DELETE)\b[^\r\n;]*\+[^\r\n;]*(?:request|input|param|userId|objectId|query|sort|limit|filter|id)') {
        Add-Violation "UNSAFE_SQL_CONCAT $relative"
    }

    # The following are review warnings. A regex cannot prove intent safely.
    if ($raw -match '(?im)@RestController' -and $raw -match '(?im)\b(?:public\s+)?[\w<>?, ]+\b\w*Entity\b\s+\w+\s*\(') {
        Add-WarningMessage "ENTITY_API_RETURN $relative"
    }
    if ($raw -match '(?im)@GetMapping' -and $raw -match '(?im)\bList<[^>]+>\s+\w+\s*\(' -and $raw -notmatch '(?im)Pageable|PageRequest|cursor|limit|max[A-Z]') {
        Add-WarningMessage "UNBOUNDED_COLLECTION_REVIEW $relative"
    }
    if ($raw -match '(?im)@QueryMapping|DataFetcher' -and $raw -notmatch '(?im)DataLoader|BatchMapping|complexity|depth|maxPage|max[A-Z].*(?:limit|amount)') {
        Add-WarningMessage "GRAPHQL_LIMIT_OR_BATCH_REVIEW $relative"
    }
    if ($raw -match '(?im)webhook' -and $raw -notmatch '(?im)signature|hmac|verify|raw body|rawBody') {
        Add-WarningMessage "WEBHOOK_SIGNATURE_REVIEW $relative"
    }
    if ($raw -match '(?im)ManagedChannel|newBlockingStub|newFutureStub' -and $raw -notmatch '(?im)withDeadline|deadlineAfter|deadline') {
        Add-WarningMessage "GRPC_DEADLINE_REVIEW $relative"
    }
    if ($raw -match '(?im)newCachedThreadPool|newSingleThreadExecutor|newFixedThreadPool' -and $raw -notmatch '(?im)bounded|queue|capacity|backpressure') {
        Add-WarningMessage "EXECUTOR_BOUND_REVIEW $relative"
    }
    if ($raw -match '(?im)\bjava\.sql\.Statement\b|\bStatement\s+\w+\s*=') {
        Add-WarningMessage "RAW_STATEMENT_REVIEW $relative"
    }
    if ($raw -match '(?im)fetch\s*=\s*FetchType\.EAGER|fetch\s*=\s*EAGER') {
        Add-WarningMessage "EAGER_COLLECTION_REVIEW $relative"
    }
    if ($raw -match '(?im)\.findAll\s*\(') {
        Add-WarningMessage "FIND_ALL_GROWING_TABLE_REVIEW $relative"
    }
}

Write-Output "DATA_API_RULE_AUDIT files=$(@(Get-TargetFiles).Count) warnings=$($warnings.Count) violations=$($violations.Count)"
if ($violations.Count -gt 0 -or ($FailOnWarning -and $warnings.Count -gt 0)) {
    exit 1
}
exit 0
