Write-Host "=== TESTE LOGIN CORRIGIDO - INCOGNITO ===" -ForegroundColor Green

# Parar processos
Get-Process -Name "dotnet" -ErrorAction SilentlyContinue | Stop-Process -Force

# Ir para projeto
Set-Location "RDO-NET8-Migration/RdoApp.Core"

# Backup do login atual
Write-Host "Fazendo backup..." -ForegroundColor Yellow
Copy-Item "Views/Auth/Login.cshtml" "Views/Auth/Login-Backup.cshtml" -Force

# Usar versao corrigida
Write-Host "Aplicando versao corrigida..." -ForegroundColor Yellow
Copy-Item "Views/Auth/Login-Fixed.cshtml" "Views/Auth/Login.cshtml" -Force

# Iniciar aplicacao
Write-Host "Iniciando aplicacao..." -ForegroundColor Yellow
Start-Process -FilePath "dotnet" -ArgumentList "run" -WindowStyle Normal

Write-Host ""
Write-Host "VERSAO CORRIGIDA ATIVA!" -ForegroundColor Green
Write-Host ""
Write-Host "MUDANCAS:" -ForegroundColor Cyan
Write-Host "- Removido Bootstrap CDN externo" -ForegroundColor White
Write-Host "- Removido jQuery CDN externo" -ForegroundColor White
Write-Host "- CSS inline puro" -ForegroundColor White
Write-Host "- JavaScript puro para mascara CPF" -ForegroundColor White
Write-Host "- Icons Unicode em vez de Bootstrap Icons" -ForegroundColor White
Write-Host ""
Write-Host "TESTE:" -ForegroundColor Cyan
Write-Host "1. Aguarde 10 segundos" -ForegroundColor White
Write-Host "2. Abra janela INCOGNITA/ANONIMA" -ForegroundColor White
Write-Host "3. Acesse: http://localhost:5031/Auth/Login" -ForegroundColor White
Write-Host ""
Write-Host "SE FUNCIONAR:" -ForegroundColor Green
Write-Host "- O problema era CDN externo bloqueado" -ForegroundColor White
Write-Host "- Manteremos esta versao" -ForegroundColor White
Write-Host ""
Write-Host "SE NAO FUNCIONAR:" -ForegroundColor Red
Write-Host "- Problema e no controller/roteamento" -ForegroundColor White
Write-Host "- F12 > Console para ver erros" -ForegroundColor White
Write-Host ""
Write-Host "CREDENCIAIS:" -ForegroundColor Cyan
Write-Host "CPF: 567.065.455-20" -ForegroundColor White
Write-Host "Senha: RXL8DjdYj6Y=" -ForegroundColor White
Write-Host ""
Write-Host "Pressione ENTER para restaurar backup..." -ForegroundColor Yellow
Read-Host

# Restaurar backup
Write-Host "Restaurando backup..." -ForegroundColor Yellow
Copy-Item "Views/Auth/Login-Backup.cshtml" "Views/Auth/Login.cshtml" -Force
Write-Host "Backup restaurado!" -ForegroundColor Green