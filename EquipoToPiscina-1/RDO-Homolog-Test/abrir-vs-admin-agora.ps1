# ABRIR VISUAL STUDIO COMO ADMINISTRADOR - AGORA!

Write-Host "=== ABRINDO VISUAL STUDIO COMO ADMINISTRADOR ===" -ForegroundColor Yellow
Write-Host ""

# Tentar encontrar Visual Studio Community 2022
$vsPath = ""
$possiblePaths = @(
    "${env:ProgramFiles}\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe",
    "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe",
    "${env:ProgramFiles}\Microsoft Visual Studio\2019\Community\Common7\IDE\devenv.exe",
    "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\Community\Common7\IDE\devenv.exe"
)

Write-Host "Procurando Visual Studio..." -ForegroundColor Cyan
foreach ($path in $possiblePaths) {
    if (Test-Path $path) {
        $vsPath = $path
        Write-Host "   Encontrado: $path" -ForegroundColor Green
        break
    }
}

if ($vsPath -eq "") {
    Write-Host "Visual Studio nao encontrado nos caminhos padrao!" -ForegroundColor Red
    Write-Host ""
    Write-Host "ABRA MANUALMENTE:" -ForegroundColor Yellow
    Write-Host "1. Pressione Windows" -ForegroundColor White
    Write-Host "2. Digite 'Visual Studio'" -ForegroundColor White
    Write-Host "3. Clique direito em 'Visual Studio Community 2022'" -ForegroundColor White
    Write-Host "4. Selecione 'Executar como administrador'" -ForegroundColor White
    Write-Host "5. Clique 'Sim' no UAC" -ForegroundColor White
    exit 1
}

# Caminho do projeto
$projectPath = (Get-Location).Path + "\rdoappProject\rdoappProject.sln"

Write-Host ""
Write-Host "Abrindo Visual Studio como Administrador..." -ForegroundColor Cyan
Write-Host "Projeto: $projectPath" -ForegroundColor White

try {
    # Abrir Visual Studio como administrador com o projeto
    Start-Process -FilePath $vsPath -ArgumentList "`"$projectPath`"" -Verb RunAs -Wait:$false
    
    Write-Host ""
    Write-Host "=== VISUAL STUDIO ABERTO COMO ADMINISTRADOR ===" -ForegroundColor Green
    Write-Host ""
    Write-Host "VERIFIQUE NA BARRA DE TITULO:" -ForegroundColor Yellow
    Write-Host "Deve mostrar: 'Microsoft Visual Studio Community 2022 (Administrador)'" -ForegroundColor White
    Write-Host ""
    Write-Host "SE NAO MOSTRAR '(Administrador)':" -ForegroundColor Red
    Write-Host "- Feche o Visual Studio" -ForegroundColor White
    Write-Host "- Execute este script novamente" -ForegroundColor White
    Write-Host ""
    Write-Host "PROXIMOS PASSOS NO VISUAL STUDIO:" -ForegroundColor Yellow
    Write-Host "1. Aguarde o projeto carregar completamente" -ForegroundColor White
    Write-Host "2. Menu: Compilar > Limpar Solucao" -ForegroundColor White
    Write-Host "3. Menu: Compilar > Recompilar Solucao" -ForegroundColor White
    Write-Host "4. Aguarde completar 100% (pode demorar alguns minutos)" -ForegroundColor White
    Write-Host "5. Verifique se nao ha erros na 'Lista de Erros'" -ForegroundColor White
    Write-Host "6. Pressione F5 para executar" -ForegroundColor White
    Write-Host ""
    Write-Host "TESTE FINAL:" -ForegroundColor Yellow
    Write-Host "- Login: 567.065.455-20 / 1234" -ForegroundColor White
    Write-Host "- Nova medicao > Preencher campos > Salvar" -ForegroundColor White
    Write-Host "- F12 Console deve mostrar logs do BACKEND" -ForegroundColor White
    
} catch {
    Write-Host "Erro ao abrir Visual Studio!" -ForegroundColor Red
    Write-Host "Erro: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "ABRA MANUALMENTE:" -ForegroundColor Yellow
    Write-Host "1. Pressione Windows + R" -ForegroundColor White
    Write-Host "2. Digite: $vsPath" -ForegroundColor White
    Write-Host "3. Pressione Ctrl+Shift+Enter (para executar como admin)" -ForegroundColor White
    Write-Host "4. Depois abra o projeto: $projectPath" -ForegroundColor White
}