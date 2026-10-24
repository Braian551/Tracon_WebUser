function Get-OpenCodeConfigPaths {
    param([Parameter(Mandatory = $true)][string]$ProjectRoot)

    $candidates = New-Object System.Collections.Generic.List[string]
    foreach ($name in @("opencode.json", "opencode.jsonc")) {
        $path = Join-Path $ProjectRoot $name
        if (Test-Path -LiteralPath $path -PathType Leaf) {
            $candidates.Add([System.IO.Path]::GetFullPath($path))
        }
    }

    $opencodeDirectory = Join-Path $ProjectRoot ".opencode"
    if (Test-Path -LiteralPath $opencodeDirectory -PathType Container) {
        Get-ChildItem -LiteralPath $opencodeDirectory -Recurse -Force -File |
            Where-Object { $_.Name -in @("opencode.json", "opencode.jsonc") } |
            ForEach-Object { $candidates.Add($_.FullName) }
    }

    @($candidates | Sort-Object -Unique)
}

function Read-OpenCodeConfig {
    param([Parameter(Mandatory = $true)][string]$Path)

    $text = Get-Content -LiteralPath $Path -Raw -Encoding UTF8
    if ([System.IO.Path]::GetExtension($Path) -eq ".jsonc") {
        $text = [regex]::Replace($text, "(?m)^\s*//.*$", "")
        $text = [regex]::Replace($text, "(?s)/\*.*?\*/", "")
    }
    $text | ConvertFrom-Json
}

function Get-ObjectPropertyValue {
    param(
        [Parameter(Mandatory = $false)]$Object,
        [Parameter(Mandatory = $true)][string]$Name
    )

    if ($null -eq $Object) {
        return $null
    }
    $property = @($Object.PSObject.Properties | Where-Object { $_.Name -eq $Name }) | Select-Object -First 1
    if ($null -eq $property) {
        return $null
    }
    $property.Value
}

function Get-BashPermission {
    param([Parameter(Mandatory = $true)]$Config)

    $permission = Get-ObjectPropertyValue -Object $Config -Name "permission"
    if ($null -eq $permission) {
        return [PSCustomObject]@{ Mode = "missing"; Rules = @() }
    }
    if ($permission -is [string]) {
        return [PSCustomObject]@{ Mode = [string]$permission; Rules = @() }
    }

    $bash = Get-ObjectPropertyValue -Object $permission -Name "bash"
    if ($null -eq $bash) {
        return [PSCustomObject]@{ Mode = "missing"; Rules = @() }
    }
    if ($bash -is [string]) {
        return [PSCustomObject]@{ Mode = [string]$bash; Rules = @() }
    }

    $rules = @(
        $bash.PSObject.Properties | ForEach-Object {
            [PSCustomObject]@{
                Pattern = [string]$_.Name
                Action = [string]$_.Value
            }
        }
    )
    [PSCustomObject]@{ Mode = "object"; Rules = $rules }
}

function Get-AgentBashPermissions {
    param([Parameter(Mandatory = $true)]$Config)

    $agentRoot = Get-ObjectPropertyValue -Object $Config -Name "agent"
    if ($null -eq $agentRoot) {
        return @()
    }

    @(
        $agentRoot.PSObject.Properties | ForEach-Object {
            $permission = Get-ObjectPropertyValue -Object $_.Value -Name "permission"
            if ($null -eq $permission) {
                [PSCustomObject]@{ Name = [string]$_.Name; Mode = "missing"; Rules = @() }
            } else {
                $bash = Get-BashPermission -Config ([PSCustomObject]@{ permission = $permission })
                [PSCustomObject]@{ Name = [string]$_.Name; Mode = $bash.Mode; Rules = @($bash.Rules) }
            }
        }
    )
}

function Test-OpenCodePattern {
    param(
        [Parameter(Mandatory = $true)][string]$Value,
        [Parameter(Mandatory = $true)][string]$Pattern
    )

    $wildcard = New-Object System.Management.Automation.WildcardPattern($Pattern, [System.Management.Automation.WildcardOptions]::IgnoreCase)
    $wildcard.IsMatch($Value)
}

function Resolve-BashPermission {
    param(
        [Parameter(Mandatory = $true)]$Permission,
        [Parameter(Mandatory = $true)][string]$Command,
        [Parameter(Mandatory = $false)]$Override
    )

    $resolved = $null
    if ($Permission.Mode -ne "object") {
        if ($Permission.Mode -in @("allow", "ask", "deny")) {
            $resolved = $Permission.Mode
        }
    } else {
        foreach ($rule in @($Permission.Rules)) {
            if (Test-OpenCodePattern -Value $Command -Pattern $rule.Pattern) {
                $resolved = $rule.Action
            }
        }
    }

    if ($null -ne $Override) {
        if ($Override.Mode -in @("allow", "ask", "deny")) {
            $resolved = $Override.Mode
        } elseif ($Override.Mode -eq "object") {
            foreach ($rule in @($Override.Rules)) {
                if (Test-OpenCodePattern -Value $Command -Pattern $rule.Pattern) {
                    $resolved = $rule.Action
                }
            }
        }
    }
    $resolved
}

function Resolve-OpenCodePathPermission {
    param(
        [Parameter(Mandatory = $false)]$Permission,
        [Parameter(Mandatory = $true)][string]$Path
    )

    if ($null -eq $Permission) {
        return $null
    }
    if ($Permission -is [string]) {
        return [string]$Permission
    }
    $resolved = $null
    foreach ($rule in @($Permission.PSObject.Properties)) {
        if (Test-OpenCodePattern -Value $Path -Pattern ([string]$rule.Name)) {
            $resolved = [string]$rule.Value
        }
    }
    $resolved
}

function Get-WorktreeIntegrityCases {
    @(
        [PSCustomObject]@{ Name = "git stash"; Command = "git stash"; Expected = "deny" }
        [PSCustomObject]@{ Name = "git stash push"; Command = "git stash push -u"; Expected = "deny" }
        [PSCustomObject]@{ Name = "git stash keep-index"; Command = "git stash --keep-index --include-untracked"; Expected = "deny" }
        [PSCustomObject]@{ Name = "git stash pop"; Command = "git stash pop"; Expected = "deny" }
        [PSCustomObject]@{ Name = "git reset hard"; Command = "git reset --hard HEAD"; Expected = "deny" }
        [PSCustomObject]@{ Name = "git reset head"; Command = "git reset HEAD~1"; Expected = "deny" }
        [PSCustomObject]@{ Name = "git restore file"; Command = "git restore file.dart"; Expected = "deny" }
        [PSCustomObject]@{ Name = "git restore all"; Command = "git restore ."; Expected = "deny" }
        [PSCustomObject]@{ Name = "git clean"; Command = "git clean -fd"; Expected = "deny" }
        [PSCustomObject]@{ Name = "git checkout discard"; Command = "git checkout -- file.dart"; Expected = "deny" }
        [PSCustomObject]@{ Name = "git switch"; Command = "git switch main"; Expected = "deny" }
        [PSCustomObject]@{ Name = "git rebase"; Command = "git rebase main"; Expected = "deny" }
        [PSCustomObject]@{ Name = "git merge"; Command = "git merge main"; Expected = "deny" }
        [PSCustomObject]@{ Name = "git cherry-pick"; Command = "git cherry-pick abc123"; Expected = "deny" }
        [PSCustomObject]@{ Name = "git revert"; Command = "git revert abc123"; Expected = "deny" }
        [PSCustomObject]@{ Name = "git -C stash"; Command = "git -C C:\Flutter\tracon stash"; Expected = "deny" }
        [PSCustomObject]@{ Name = "PowerShell wrapper"; Command = "powershell -Command git stash"; Expected = "deny" }
        [PSCustomObject]@{ Name = "cmd wrapper"; Command = "cmd /c git stash"; Expected = "deny" }
        [PSCustomObject]@{ Name = "Python wrapper"; Command = "python -c subprocess git stash"; Expected = "deny" }
        [PSCustomObject]@{ Name = "chained command"; Command = "git status; git stash"; Expected = "deny" }
        [PSCustomObject]@{ Name = "git status"; Command = "git status"; Expected = "allow" }
        [PSCustomObject]@{ Name = "git diff"; Command = "git diff"; Expected = "allow" }
        [PSCustomObject]@{ Name = "git diff cached"; Command = "git diff --cached"; Expected = "allow" }
        [PSCustomObject]@{ Name = "git log"; Command = "git log"; Expected = "allow" }
        [PSCustomObject]@{ Name = "git show"; Command = "git show"; Expected = "allow" }
        [PSCustomObject]@{ Name = "git rev-parse"; Command = "git rev-parse HEAD"; Expected = "allow" }
    )
}

function Get-OpenCodeAgentMarkdownPaths {
    param([Parameter(Mandatory = $true)][string]$ProjectRoot)

    $paths = New-Object System.Collections.Generic.List[string]
    foreach ($relative in @(".opencode\agents", "agents")) {
        $directory = Join-Path $ProjectRoot $relative
        if (Test-Path -LiteralPath $directory -PathType Container) {
            Get-ChildItem -LiteralPath $directory -Recurse -Force -File -Filter *.md |
                ForEach-Object { $paths.Add($_.FullName) }
        }
    }
    @($paths | Sort-Object -Unique)
}
