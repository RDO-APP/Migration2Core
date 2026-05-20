Write-Host "=== TESTE LOGIN SIMPLES ===" -ForegroundColor Green

# Parar processos
Get-Process -Name "dotnet" -ErrorAction SilentlyContinue | Stop-Process -Force

# Ir para projeto
Set-Location "RDO-NET8-Migration/RdoApp.Core"

# Iniciar aplicacao
Write-Host "Iniciando aplicacao..." -ForegroundColor Yellow
Start-Process -FilePath "dotnet" -ArgumentList "run" -WindowStyle Normal

Write-Host ""
Write-Host "AGUARDE 10 SEGUNDOS E TESTE:" -ForegroundColor Cyan
Write-Host "1. Abra janela incognita/anonima" -ForegroundColor White
Write-Host "2. Acesse: http://localhost:5031/Auth/Login" -ForegroundColor White
Write-Host "3. Se branco: F12 > Console > veja erros" -ForegroundColor White
Write-Host "4. Se branco: F12 > Network > recarregue pagina" -ForegroundColor White
Write-Host ""
Write-Host "CREDENCIAIS:" -ForegroundColor Green
Write-Host "CPF: 567.065.455-20" -ForegroundColor White
Write-Host "Senha: RXL8DjdYj6Y=" -ForegroundColor White