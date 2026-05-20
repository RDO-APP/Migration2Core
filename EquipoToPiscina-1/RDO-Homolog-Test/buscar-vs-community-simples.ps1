# Busca simples por Visual Studio Community
Write-Host "Procurando Visual Studio Community..." -ForegroundColor Yellow

$paths = @(
    "C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe",
    "C:\Program Files (x86)\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe"
)

$found = $false
foreach ($path in $paths) {
    if (Test-Path $path) {
        Write-Host "✅ VS Community encontrado: $path" -ForegroundColor Green
        Start-Process $path
        $found = $true
        break
    }
}

if (-not $found) {
    Write-Host "❌ VS Community não encontrado" -ForegroundColor Red
    Write-Host "Tente:" -ForegroundColor Yellow
    Write-Host "1. Menu Iniciar > Digite 'Visual Studio Community'" -ForegroundColor White
    Write-Host "2. Ou use o Visual Studio que já abriu" -ForegroundColor White
}