# Abrir RdoApp.Core no Visual Studio Community
Write-Host "Abrindo RdoApp.Core no Visual Studio..." -ForegroundColor Green

$projectPath = "RDO-NET8-Migration\RdoApp.Core\RdoApp.Core.csproj"

if (Test-Path $projectPath) {
    Write-Host "Projeto encontrado: $projectPath" -ForegroundColor Cyan
    
    # Tentar abrir com Visual Studio
    try {
        Start-Process $projectPath
        Write-Host "Visual Studio iniciando..." -ForegroundColor Green
        Write-Host "COMPILE COM: Build > Build Solution (Ctrl+Shift+B)" -ForegroundColor Yellow
        Write-Host "EXECUTE COM: Debug > Start Without Debugging (Ctrl+F5)" -ForegroundColor Yellow
    }
    catch {
        Write-Host "Erro ao abrir VS. Tentando comando direto..." -ForegroundColor Yellow
        & $projectPath
    }
} else {
    Write-Host "ERRO: Projeto não encontrado em $projectPath" -ForegroundColor Red
}