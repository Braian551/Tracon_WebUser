[CmdletBinding()]
param(
    [string]$RepositoryRoot = (Get-Location).Path
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $RepositoryRoot -PathType Container)) {
    throw "No existe el repositorio: $RepositoryRoot"
}

Push-Location $RepositoryRoot
try {
    $inside = git rev-parse --is-inside-work-tree 2>$null
    if ($LASTEXITCODE -ne 0 -or $inside -ne 'true') {
        throw "La ruta no es un repositorio Git: $RepositoryRoot"
    }

    Write-Host "=== Estado corto ==="
    git status --short

    Write-Host "`n=== Archivos modificados ==="
    $changed = @(
        git diff --name-only
        git diff --cached --name-only
        git ls-files --others --exclude-standard
    ) | Where-Object { $_ } | Sort-Object -Unique

    if ($changed.Count -eq 0) {
        Write-Host "No hay archivos modificados."
        exit 0
    }

    $changed | ForEach-Object { Write-Host $_ }

    Write-Host "`n=== Resumen por ámbito ==="
    $groups = [ordered]@{
        mobile = @($changed | Where-Object { $_ -like 'mobile/*' })
        backend = @($changed | Where-Object { $_ -like 'backend/*' })
        services = @($changed | Where-Object { $_ -like 'services/*' })
        infra = @($changed | Where-Object { $_ -like 'infra/*' -or $_ -like 'compose*.yaml' })
        database = @($changed | Where-Object { $_ -like 'database/*' -or $_ -match 'db/migration/' })
        docs_legal = @($changed | Where-Object { $_ -like 'docs/*' -or $_ -like 'legal/*' })
        agent_rules = @($changed | Where-Object { $_ -eq 'AGENTS.md' -or $_ -like '.agents/*' })
    }

    foreach ($entry in $groups.GetEnumerator()) {
        Write-Host ("{0}: {1}" -f $entry.Key, $entry.Value.Count)
    }

    Write-Host "`n=== Diff check ==="
    git diff --check
    if ($LASTEXITCODE -ne 0) {
        throw "git diff --check encontró errores."
    }

    Write-Host "`nInventario completado sin modificar archivos."
}
finally {
    Pop-Location
}
