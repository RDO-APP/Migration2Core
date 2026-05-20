# ABRIR VISUAL STUDIO - RDO HOMOLOG

Write-Host "=== ABRINDO VISUAL STUDIO ===" -ForegroundColor Green

$projectPath = "rdoappProject\rdoappProject.csproj"

if (Test-Path $projectPath) {
    Write-Host "Projeto encontrado: $projectPath" -ForegroundColor Green
    Write-Host "Abrindo Visual Studio..." -ForegroundColor Yellow
    
    # Abrir projeto
    Start-Process -FilePath $projectPath
    
    Write-Host "Visual Studio abrindo..." -ForegroundColor Green
    Write-Host ""
    Write-Host "PROXIMOS PASSOS:" -ForegroundColor Cyan
    Write-Host "1. Aguarde carregar"
    Write-Host "2. Pressione F5"
    Write-Host "3. Teste: http://localhost:[porta]/teste-ok.aspx"
    Write-Host ""
    Write-Host "CREDENCIAIS:" -ForegroundColor Yellow
    Write-Host "CPF: 567.065.455-20"
    Write-Host "Senha: 1234"
    
} else {
    Write-Host "ERRO: Projeto nao encontrado!" -ForegroundColor Red
    Write-Host "Abra manualmente:" -ForegroundColor Yellow
    Write-Host "1. Menu Iniciar > Visual Studio"
    Write-Host "2. File > Open > Project"
    Write-Host "3. Navegue ate: rdoappProject\rdoappProject.csproj"
}