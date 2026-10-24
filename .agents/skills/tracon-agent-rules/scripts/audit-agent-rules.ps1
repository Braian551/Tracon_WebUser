param(
    [string]$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..\..\..")),
    [switch]$FailOnWarning
)

$ErrorActionPreference = "Stop"
$warnings = New-Object System.Collections.Generic.List[string]
$violations = New-Object System.Collections.Generic.List[string]
$policyScript = Join-Path $PSScriptRoot "worktree-integrity-policy.ps1"

if (-not (Test-Path -LiteralPath $policyScript -PathType Leaf)) {
    Write-Error "AGENT SAFETY VIOLATION: falta worktree-integrity-policy.ps1"
    exit 1
}
. $policyScript

function Add-WarningMessage([string]$Message) {
    [void]$warnings.Add($Message)
    Write-Warning $Message
}

function Add-Violation([string]$Message) {
    [void]$violations.Add($Message)
}

$agentsFile = Join-Path $ProjectRoot "AGENTS.md"
$skillsRoot = Join-Path $ProjectRoot ".agents\skills"
$canonicalReference = Join-Path $skillsRoot "tracon-agent-rules\references\worktree-integrity.md"
$dataApiReference = Join-Path $skillsRoot "tracon-agent-rules\references\backend-data-api-scalability-safety.md"

if (-not (Test-Path -LiteralPath $agentsFile -PathType Leaf)) {
    Add-Violation "Falta AGENTS.md en la raíz."
}
if (-not (Test-Path -LiteralPath $skillsRoot -PathType Container)) {
    Add-Violation "Falta .agents/skills."
}
if (-not (Test-Path -LiteralPath $canonicalReference -PathType Leaf)) {
    Add-Violation "Falta la fuente canónica references/worktree-integrity.md."
}
if (-not (Test-Path -LiteralPath $dataApiReference -PathType Leaf)) {
    Add-Violation "Falta la referencia transversal de backend/datos/API."
}

if (Test-Path -LiteralPath $agentsFile -PathType Leaf) {
    $agentsRaw = Get-Content -LiteralPath $agentsFile -Raw -Encoding UTF8
    if ($agentsRaw -notmatch "(?im)WORKTREE INTEGRITY.*HARD INVARIANT") {
        Add-Violation "AGENTS.md no contiene el hard invariant WORKTREE INTEGRITY."
    }
    if ($agentsRaw -notmatch "references[\\/]+worktree-integrity\.md") {
        Add-Violation "AGENTS.md no enruta a la fuente canónica de integridad."
    }
    if ($agentsRaw -notmatch "backend-data-api-scalability-safety\.md") {
        Add-Violation "AGENTS.md no enruta a la referencia transversal de backend/datos/API."
    }
}

$skillFiles = New-Object System.Collections.Generic.List[object]
if (Test-Path -LiteralPath $skillsRoot -PathType Container) {
    foreach ($directory in @(Get-ChildItem -LiteralPath $skillsRoot -Directory)) {
        $skillPath = Join-Path $directory.FullName "SKILL.md"
        if (-not (Test-Path -LiteralPath $skillPath -PathType Leaf)) {
            Add-WarningMessage "Falta SKILL.md en $($directory.FullName)"
            continue
        }

        $raw = Get-Content -LiteralPath $skillPath -Raw -Encoding UTF8
        $nameMatch = [regex]::Match($raw, "(?ms)^---\s*.*?^name:\s*([^\r\n]+)")
        $descriptionMatch = [regex]::Match($raw, "(?ms)^---\s*.*?^description:\s*([^\r\n]+)")
        if (-not $nameMatch.Success) {
            Add-WarningMessage "Frontmatter sin name: $skillPath"
        } else {
            $declared = $nameMatch.Groups[1].Value.Trim()
            if ($declared -ne $directory.Name) {
                Add-WarningMessage "El name '$declared' no coincide con el directorio '$($directory.Name)'."
            }
            if ($declared -notmatch "^[a-z0-9]+(-[a-z0-9]+)*$") {
                Add-WarningMessage "Nombre de skill no portable: $declared"
            }
        }
        if (-not $descriptionMatch.Success) {
            Add-WarningMessage "Frontmatter sin description: $skillPath"
        }
        $lineCount = (Get-Content -LiteralPath $skillPath -Encoding UTF8).Count
        if ($lineCount -gt 240) {
            Add-WarningMessage "SKILL.md grande ($lineCount líneas): $skillPath"
        }
        $skillFiles.Add([PSCustomObject]@{ Name = $directory.Name; Path = $skillPath; Raw = $raw })
    }
}

$knownSkills = @($skillFiles | ForEach-Object { $_.Name })
# Directorio reservado para temporales del runner; no es una skill.
$knownNonSkillIdentifiers = @("tracon-agent", "tracon-delivery")
$allMarkdown = New-Object System.Collections.Generic.List[object]
if (Test-Path -LiteralPath $agentsFile -PathType Leaf) {
    $allMarkdown.Add((Get-Item -LiteralPath $agentsFile))
}
if (Test-Path -LiteralPath $skillsRoot -PathType Container) {
    foreach ($markdown in @(Get-ChildItem -LiteralPath $skillsRoot -Recurse -File -Filter *.md)) {
        $allMarkdown.Add($markdown)
    }
}
foreach ($file in $allMarkdown) {
    $raw = Get-Content -LiteralPath $file.FullName -Raw -Encoding UTF8
    foreach ($match in [regex]::Matches($raw, "\b(tracon-[a-z0-9-]+)\b")) {
        $reference = $match.Groups[1].Value
        if ($reference -notin $knownSkills -and $reference -notin $knownNonSkillIdentifiers) {
            Add-WarningMessage "Referencia a skill inexistente '$reference' en $($file.FullName)"
        }
    }
}

$requiredDataApiSkillLinks = @(
    "tracon-agent-rules/SKILL.md",
    "tracon-architecture/SKILL.md",
    "tracon-backend/SKILL.md",
    "tracon-infrastructure/SKILL.md",
    "tracon-mobile/SKILL.md",
    "tracon-social-engagement/SKILL.md",
    "tracon-notifications/SKILL.md",
    "tracon-media/SKILL.md",
    "tracon-quality/SKILL.md",
    "tracon-tests/SKILL.md",
    "tracon-release/SKILL.md"
)
foreach ($relativeSkillPath in $requiredDataApiSkillLinks) {
    $skillPath = Join-Path $skillsRoot ($relativeSkillPath -replace '/', '\')
    if (-not (Test-Path -LiteralPath $skillPath -PathType Leaf)) {
        Add-Violation "Falta skill requerida para enlace transversal: $relativeSkillPath"
        continue
    }
    $skillRaw = Get-Content -LiteralPath $skillPath -Raw -Encoding UTF8
    if ($skillRaw -notmatch "backend-data-api-scalability-safety\.md") {
        Add-Violation "Skill sin enlace a la referencia transversal: $relativeSkillPath"
    }
}

$occurrences = @{}
foreach ($file in $allMarkdown) {
    foreach ($line in @(Get-Content -LiteralPath $file.FullName -Encoding UTF8)) {
        $normalized = ($line.Trim().ToLowerInvariant() -replace "\s+", " ")
        if ($normalized.Length -lt 80 -or $normalized.StartsWith("#") -or $line.TrimStart().StartsWith(([char]96).ToString())) {
            continue
        }
        if (-not $occurrences.ContainsKey($normalized)) {
            $occurrences[$normalized] = New-Object System.Collections.Generic.List[string]
        }
        $occurrences[$normalized].Add($file.FullName)
    }
}
foreach ($entry in $occurrences.GetEnumerator()) {
    $unique = @($entry.Value | Sort-Object -Unique)
    if ($unique.Count -gt 1) {
        Add-WarningMessage "Posible regla duplicada en $($unique.Count) archivos: '$($entry.Key.Substring(0, [Math]::Min(120, $entry.Key.Length)))...'"
    }
}

$integrityCases = @(Get-WorktreeIntegrityCases)
$configPaths = @(Get-OpenCodeConfigPaths -ProjectRoot $ProjectRoot)
if ($configPaths.Count -eq 0) {
    Add-Violation "No existe configuración OpenCode del repositorio."
}
if ($configPaths.Count -gt 1) {
    Add-Violation "Configuraciones OpenCode duplicadas o potencialmente contradictorias: $($configPaths -join ', ')"
}

$configAudits = New-Object System.Collections.Generic.List[object]
foreach ($configPath in $configPaths) {
    try {
        $config = Read-OpenCodeConfig -Path $configPath
    } catch {
        Add-Violation "Configuración OpenCode inválida: $configPath ($($_.Exception.Message))"
        continue
    }

    $bash = Get-BashPermission -Config $config
    if ($bash.Mode -ne "object") {
        Add-Violation "OpenCode bash permission no es un objeto granular en $configPath."
        continue
    }

    $rules = @($bash.Rules)
    $defaultDeny = @($rules | Where-Object { $_.Pattern -eq "*" -and $_.Action -eq "deny" })
    if ($defaultDeny.Count -eq 0) {
        Add-Violation "OpenCode no tiene '* = deny' para Bash en $configPath."
    }
    $permissionRoot = Get-ObjectPropertyValue -Object $config -Name "permission"
    $editPermission = Get-ObjectPropertyValue -Object $permissionRoot -Name "edit"
    foreach ($protectedPath in @("opencode.json", "AGENTS.md", ".agents/skills/tracon-agent-rules/SKILL.md", ".agents/skills/tracon-agent-rules/references/worktree-integrity.md")) {
        $editAction = Resolve-OpenCodePathPermission -Permission $editPermission -Path $protectedPath
        if ($editAction -ne "deny") {
            Add-Violation "AGENT SAFETY VIOLATION: edit of '$protectedPath' resolves to '$editAction' in $configPath."
        }
    }
    $configAudits.Add([PSCustomObject]@{ Path = $configPath; Config = $config; Bash = $bash })

    foreach ($case in $integrityCases) {
        $action = Resolve-BashPermission -Permission $bash -Command $case.Command
        if ($action -ne $case.Expected) {
            Add-Violation "AGENT SAFETY VIOLATION: $($case.Name) resolves to '$action' in $configPath; expected '$($case.Expected)'."
        }
    }

    foreach ($rule in $rules) {
        if ($rule.Action -in @("allow", "ask") -and $rule.Pattern -in @("*", "git *", "*git*")) {
            Add-Violation "AGENT SAFETY VIOLATION: broad Bash rule '$($rule.Pattern) = $($rule.Action)' in $configPath."
        }
        if ($rule.Action -in @("allow", "ask")) {
            foreach ($case in @($integrityCases | Where-Object { $_.Expected -eq "deny" })) {
                if (Test-OpenCodePattern -Value $case.Command -Pattern $rule.Pattern) {
                    Add-Violation "AGENT SAFETY VIOLATION: rule '$($rule.Pattern) = $($rule.Action)' covers $($case.Name) in $configPath."
                }
            }
        }
    }

    foreach ($agent in @(Get-AgentBashPermissions -Config $config)) {
        if ($agent.Mode -in @("allow", "ask")) {
            Add-Violation "AGENT SAFETY VIOLATION: agent '$($agent.Name)' sets Bash to '$($agent.Mode)' in $configPath."
            continue
        }
        foreach ($case in @($integrityCases | Where-Object { $_.Expected -eq "deny" })) {
            $action = Resolve-BashPermission -Permission $bash -Command $case.Command -Override $agent
            if ($action -ne "deny") {
                Add-Violation "AGENT SAFETY VIOLATION: $($case.Name) is '$action' for agent '$($agent.Name)' in $configPath."
            }
        }
        foreach ($rule in @($agent.Rules)) {
            if ($rule.Action -in @("allow", "ask") -and $rule.Pattern -in @("*", "git *", "*git*")) {
                Add-Violation "AGENT SAFETY VIOLATION: agent '$($agent.Name)' reopens '$($rule.Pattern) = $($rule.Action)' in $configPath."
            }
            if ($rule.Action -in @("allow", "ask")) {
                foreach ($case in @($integrityCases | Where-Object { $_.Expected -eq "deny" })) {
                    if (Test-OpenCodePattern -Value $case.Command -Pattern $rule.Pattern) {
                        Add-Violation "AGENT SAFETY VIOLATION: agent '$($agent.Name)' rule '$($rule.Pattern) = $($rule.Action)' covers $($case.Name)."
                    }
                }
            }
        }
    }
}

foreach ($agentMarkdown in @(Get-OpenCodeAgentMarkdownPaths -ProjectRoot $ProjectRoot)) {
    $raw = Get-Content -LiteralPath $agentMarkdown -Raw -Encoding UTF8
    if ($raw -match "(?im)^\s*bash\s*:\s*(allow|ask)\s*$") {
        Add-Violation "AGENT SAFETY VIOLATION: agent Markdown '$agentMarkdown' reopens Bash."
    }
    $dangerousOverride = "(?im)^\s*[""']?(?:git\s+\*|\*git\*|git\s+(?:stash|reset|restore|clean|checkout|switch|rebase|merge|cherry-pick|revert)\b|powershell\s+\*|pwsh\s+\*|cmd(?:\.exe)?\s+\*|python(?:3)?\s+\*)[""']?\s*:\s*[""']?(?:allow|ask)\b"
    if ($raw -match $dangerousOverride) {
        Add-Violation "AGENT SAFETY VIOLATION: agent Markdown '$agentMarkdown' reopens destructive Git or a wrapper."
    }
}

if (Test-Path -LiteralPath $agentsFile -PathType Leaf) {
    $agentsLines = (Get-Content -LiteralPath $agentsFile -Encoding UTF8).Count
    $agentsBytes = (Get-Item -LiteralPath $agentsFile).Length
    Write-Host "AGENTS.md: $agentsLines líneas, $agentsBytes bytes"
    if ($agentsLines -gt 220 -or $agentsBytes -gt 12288) {
        Add-WarningMessage "AGENTS.md supera el objetivo de mantenimiento."
    }
}

Write-Host "Configuraciones OpenCode auditadas: $($configPaths.Count)"
Write-Host "Casos estáticos de integridad: $($integrityCases.Count)"
Write-Host "Advertencias: $($warnings.Count)"
Write-Host "Violaciones de seguridad: $($violations.Count)"

if ($violations.Count -gt 0) {
    foreach ($violation in $violations) {
        Write-Host "AGENT SAFETY VIOLATION: $violation" -ForegroundColor Red
    }
    exit 1
}
if ($FailOnWarning -and $warnings.Count -gt 0) {
    exit 1
}
exit 0
