# Investigar por que VS Community sumiu
Write-Host "=== INVESTIGANDO VISUAL STUDIO COMMUNITY ===" -ForegroundColor Yellow
Write-Host ""

# Verificar todas as versões de Visual Studio instaladas
Write-Host "🔍 PROCURANDO TODAS AS VERSÕES DE VISUAL STUDIO..." -ForegroundColor Cyan
Write-Host ""

$allVSPaths = @(
    # VS 2022
    "${env:ProgramFiles}\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe",
    "${env:ProgramFiles}\Microsoft Visual Studio\2022\Professional\Common7\IDE\devenv.exe", 
    "${env:ProgramFiles}\Microsoft Visual Studio\2022\Enterprise\Common7\IDE\devenv.exe",
    "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe",
    "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2022\Professional\Common7\IDE\devenv.exe",
    "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2022\Enterprise\Common7\IDE\devenv.exe",
    
    # VS 2019
    "${env:ProgramFiles}\Microsoft Visual Studio\2019\Community\Common7\IDE\devenv.exe",
    "${env:ProgramFiles}\Microsoft Visual Studio\2019\Professional\Common7\IDE\devenv.exe",
    "${env:ProgramFiles}\Microsoft Visual Studio\2019\Enterprise\Common7\IDE\devenv.exe",
    "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\Community\Common7\IDE\devenv.exe",
    "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\Professional\Common7\IDE\devenv.exe",
    "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\Enterprise\Common7\IDE\devenv.exe"
)

$foundVersions = @()

foreach ($path in $allVSPaths) {
    if (Test-Path $path) {
        $version = ""
        if ($path -match "2022") { $version = "2022" }
        elseif ($path -match "2019") { $version = "2019" }
        
        $edition = ""
        if ($path -match "Community") { $edition = "Community" }
        elseif ($path -match "Professional") { $edition = "Professional" }
        elseif ($path -match "Enterprise") { $edition = "Enterprise" }
        
        $foundVersions += "✅ Visual Studio $version $edition - $path"
        Write-Host "✅ Visual Studio $version $edition" -ForegroundColor Green
        Write-Host "   📍 $path" -ForegroundColor Gray
    }
}

if ($foundVersions.Count -eq 0) {
    Write-Host "❌ Nenhuma versão do Visual Studio encontrada!" -ForegroundColor Red
} else {
    Write-Host ""
    Write-Host "📊 RESUMO:" -ForegroundColor Yellow
    foreach ($version in $foundVersions) {
        Write-Host $version -ForegroundColor White
    }
}

Write-Host ""
Write-Host "🔍 VERIFICANDO MENU INICIAR..." -ForegroundColor Cyan

# Verificar se existe no menu iniciar
$startMenuPaths = @(
    "$env:APPDATA\Microsoft\Windows\Start Menu\Programs",
    "$env:ProgramData\Microsoft\Windows\Start Menu\Programs"
)

foreach ($startPath in $startMenuPaths) {
    if (Test-Path $startPath) {
        $vsShortcuts = Get-ChildItem -Path $startPath -Recurse -Filter "*Visual Studio*" -ErrorAction SilentlyContinue
        if ($vsShortcuts) {
            Write-Host "📱 ATALHOS NO MENU INICIAR:" -ForegroundColor Green
            foreach ($shortcut in $vsShortcuts) {
                Write-Host "   - $($shortcut.Name)" -ForegroundColor White
            }
        }
    }
}

Write-Host ""
Write-Host "🤔 POSSÍVEIS MOTIVOS PARA O VS COMMUNITY TER 'SUMIDO':" -ForegroundColor Yellow
Write-Host "1. Atualização automática que mudou a localização" -ForegroundColor White
Write-Host "2. Desinstalação acidental" -ForegroundColor White  
Write-Host "3. Problema na instalação" -ForegroundColor White
Write-Host "4. Mudança de versão (2019 → 2022)" -ForegroundColor White
Write-Host ""

Write-Host "💡 ENQUANTO BAIXA O NOVO:" -ForegroundColor Cyan
Write-Host "Você pode usar o Visual Studio que abriu para testar!" -ForegroundColor White