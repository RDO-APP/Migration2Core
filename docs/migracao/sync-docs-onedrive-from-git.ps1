# Sync docs versionados: Migration2Core (Git) -> espelho OneDrive (Cursor workspace)
# Uso: apos commit+push ou git pull em C:\Dev\Migration2Core
# Nao apaga arquivos extras no OneDrive que nao existem no Git.

$ErrorActionPreference = 'Stop'

$RepoRoot = 'C:\Dev\Migration2Core'
$MirrorRoot = 'C:\Users\LUCIO\OneDrive\Documentos\RDO App\TI\Projetos\.Net Equipamentos\Cursor Jun2026\Equipamentos'

if (-not (Test-Path $RepoRoot)) {
    Write-Error "Clone Git nao encontrado: $RepoRoot"
}
if (-not (Test-Path $MirrorRoot)) {
    Write-Error "Espelho OneDrive nao encontrado: $MirrorRoot"
}

Push-Location $RepoRoot
try {
    $files = git ls-files 'docs/' 2>$null
    if (-not $files) {
        Write-Error 'Nenhum arquivo docs/ rastreado no Git.'
    }

    $copied = 0
    foreach ($rel in $files) {
        $src = Join-Path $RepoRoot $rel
        $dest = Join-Path $MirrorRoot $rel
        if (-not (Test-Path $src)) {
            Write-Warning "Ausente no disco (Git lista mas arquivo falta): $rel"
            continue
        }
        $destDir = Split-Path $dest -Parent
        if (-not (Test-Path $destDir)) {
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        }
        Copy-Item -Path $src -Destination $dest -Force
        $copied++
    }

    Write-Host "OK: $copied arquivo(s) docs/ copiados Git -> OneDrive."
}
finally {
    Pop-Location
}
