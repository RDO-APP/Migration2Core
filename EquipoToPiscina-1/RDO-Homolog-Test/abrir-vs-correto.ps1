# ABRIR VISUAL STUDIO COMMUNITY CORRETO (NAO BLEND)

Write-Host "=== ABRINDO VISUAL STUDIO COMMUNITY CORRETO ===" -ForegroundColor Green
Write-Host ""

# Tentar encontrar Visual Studio Community
$vsPath = ""
$possiblePaths = @(
    "${env:ProgramFiles}\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe",
    "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe",
    "${env:ProgramFiles}\Microsoft Visual Studio\2019\Community\Common7\IDE\devenv.exe"
)

foreach ($path in $possiblePaths) {
    if (Test-Path $path) {
        $vsPath = $path
        break
    }
}

$projectPath = "rdoappProject\rdoappProject.csproj"

if ($vsPath -ne "" -and (Test-Path $projectPath)) {
    Write-Host "Visual Studio encontrado: $vsPath" -ForegroundColor Green
    Write-Host "Projeto encontrado: $projectPath" -ForegroundColor Green
    Write-Host ""
    Write-Host "Abrindo Visual Studio Community..." -ForegroundColor Yellow
    
    # Abrir Visual Studio Community com o projeto
    Start-Process -FilePath $vsPath -ArgumentList $projectPath
    
    Write-Host "Visual Studio Community abrindo..." -ForegroundColor Green
    
} else {
    Write-Host "ALTERNATIVA MANUAL:" -ForegroundColor Yellow
    Write-Host "1. Menu Iniciar > Digite 'Visual Studio Community'"
    Write-Host "2. Clique em 'Visual Studio Community 2022' (NAO Blend)"
    Write-Host "3. File > Open > Project/Solution"
    Write-Host "4. Navegue ate: rdoappProject\rdoappProject.csproj"
}

Write-Host ""
Write-Host "IMPORTANTE:" -ForegroundColor Red
Write-Host "- Use 'Visual Studio Community' (para codigo C#)"
Write-Host "- NAO use 'Blend for Visual Studio' (para design)"
Write-Host ""
Write-Host "PROXIMOS PASSOS:" -ForegroundColor Cyan
Write-Host "1. Aguarde carregar"
Write-Host "2. Pressione F5"
Write-Host "3. Teste: http://localhost:[porta]/teste-ok.aspx"