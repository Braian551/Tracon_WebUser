param(
    [string]$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..\..\.."))
)

$ErrorActionPreference = "Stop"
$policyScript = Join-Path $PSScriptRoot "worktree-integrity-policy.ps1"
if (-not (Test-Path -LiteralPath $policyScript -PathType Leaf)) {
    Write-Error "Static worktree test cannot find worktree-integrity-policy.ps1."
    exit 1
}
. $policyScript

$failures = New-Object System.Collections.Generic.List[string]
$configPaths = @(Get-OpenCodeConfigPaths -ProjectRoot $ProjectRoot)
if ($configPaths.Count -ne 1) {
    [void]$failures.Add("expected exactly one repository OpenCode config, found $($configPaths.Count)")
} else {
    try {
        $config = Read-OpenCodeConfig -Path $configPaths[0]
        $permission = Get-BashPermission -Config $config
        $permissionRoot = Get-ObjectPropertyValue -Object $config -Name "permission"
        $editPermission = Get-ObjectPropertyValue -Object $permissionRoot -Name "edit"
        foreach ($protectedPath in @("opencode.json", "AGENTS.md", ".agents/skills/tracon-agent-rules/SKILL.md", ".agents/skills/tracon-agent-rules/references/worktree-integrity.md")) {
            $editAction = Resolve-OpenCodePathPermission -Permission $editPermission -Path $protectedPath
            if ($editAction -ne "deny") {
                [void]$failures.Add("protected edit path '$protectedPath' resolved '$editAction', expected 'deny'")
            }
        }
        if ($permission.Mode -ne "object") {
            [void]$failures.Add("permission.bash is not granular")
        } else {
            $cases = @(Get-WorktreeIntegrityCases)
            foreach ($case in $cases) {
                $resolved = Resolve-BashPermission -Permission $permission -Command $case.Command
                if ($resolved -ne $case.Expected) {
                    [void]$failures.Add("$($case.Name): resolved '$resolved', expected '$($case.Expected)'")
                }
            }

            $unknownGit = Resolve-BashPermission -Permission $permission -Command "git fetch origin"
            if ($unknownGit -ne "deny") {
                [void]$failures.Add("unknown Git command resolved '$unknownGit', expected 'deny'")
            }

            $agentOverrides = @(Get-AgentBashPermissions -Config $config)
            foreach ($agent in $agentOverrides) {
                foreach ($case in @($cases | Where-Object { $_.Expected -eq "deny" })) {
                    $resolved = Resolve-BashPermission -Permission $permission -Command $case.Command -Override $agent
                    if ($resolved -ne "deny") {
                        [void]$failures.Add("agent '$($agent.Name)' reopens $($case.Name) as '$resolved'")
                    }
                }
            }
        }
    } catch {
        [void]$failures.Add("configuration parse or evaluation failed: $($_.Exception.Message)")
    }
}

Write-Host "Static worktree integrity cases: $(@(Get-WorktreeIntegrityCases).Count)"
Write-Host "Static failures: $($failures.Count)"
if ($failures.Count -gt 0) {
    foreach ($failure in $failures) {
        Write-Host "WORKTREE INTEGRITY TEST FAILURE: $failure" -ForegroundColor Red
    }
    exit 1
}
Write-Host "WORKTREE INTEGRITY STATIC TEST PASS" -ForegroundColor Green
exit 0
