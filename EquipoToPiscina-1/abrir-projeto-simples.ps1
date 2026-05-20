# Script simples para abrir o projeto RdoApp.Core
Write-Host "Abrindo projeto RdoApp.Core..." -ForegroundColor Green

$projectPath = ".\RDO-NET8-Migration\RdoApp.Core\RdoApp.Core.csproj"

if (Test-Path $projectPath) {
    Write-Host "Projeto encontrado: $projectPath" -ForegroundColor Green
    Write-Host "Abrindo Visual Studio..." -ForegroundColor Yellow
    Start-Process $projectPath
    Write-Host "Visual Studio deve abrir em alguns segundos..." -ForegroundColor Green
} else {
    Write-Host "ERRO: Projeto nao encontrado em: $projectPath" -ForegroundColor Red
    Write-Host "Verificando pastas..." -ForegroundColor Yellow
    Get-ChildItem . -Directory | Select-Object Name
}

Write-Host "Script concluido!" -ForegroundColor Blue