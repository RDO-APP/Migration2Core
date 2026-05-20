#!/usr/bin/env pwsh

Write-Host "=== TESTE LOGIN SIMPLES - MODO INCÓGNITO ===" -ForegroundColor Green

# Parar processos existentes
Write-Host "Parando processos..." -ForegroundColor Yellow
Get-Process -Name "RdoApp.Core", "dotnet" -ErrorAction SilentlyContinue | Stop-Process -Force

# Ir para projeto
Set-Location "RDO-NET8-Migration/RdoApp.Core"

# Fazer backup do Login.cshtml original
Write-Host "Fazendo backup do Login.cshtml original..." -ForegroundColor Yellow
Copy-Item "Views/Auth/Login.cshtml" "Views/Auth/Login-Original-Backup.cshtml" -Force

# Substituir pelo login simples
Write-Host "Usando login simples para teste..." -ForegroundColor Yellow
Copy-Item "Views/Auth/Login-Simple-Test.cshtml" "Views/Auth/Login.cshtml" -Force

Write-Host "Iniciando aplicação..." -ForegroundColor Yellow
$process = Start-Process -FilePath "dotnet" -ArgumentList "run --urls `"http://localhost:5031;https://localhost:7201`"" -PassThru -WindowStyle Normal

Write-Host ""
Write-Host "🔍 TESTE DIAGNÓSTICO ATIVO" -ForegroundColor Green
Write-Host ""
Write-Host "INSTRUÇÕES:" -ForegroundColor Cyan
Write-Host "1. Aguarde 5 segundos" -ForegroundColor White
Write-Host "2. Abra janela INCÓGNITA/ANÔNIMA" -ForegroundColor White
Write-Host "3. Acesse: http://localhost:5031/Auth/Login" -ForegroundColor White
Write-Host ""
Write-Host "SE FUNCIONAR:" -ForegroundColor Green
Write-Host "- O problema está no CSS/JavaScript complexo" -ForegroundColor White
Write-Host "- Vamos simplificar o login original" -ForegroundColor White
Write-Host ""
Write-Host "SE NÃO FUNCIONAR:" -ForegroundColor Red
Write-Host "- O problema é no roteamento/controller" -ForegroundColor White
Write-Host "- Pressione F12 e veja erros no console" -ForegroundColor White
Write-Host ""
Write-Host "CREDENCIAIS:" -ForegroundColor Cyan
Write-Host "CPF: 567.065.455-20" -ForegroundColor White
Write-Host "Senha: RXL8DjdYj6Y=" -ForegroundColor White
Write-Host ""
Write-Host "Pressione ENTER para restaurar o login original..." -ForegroundColor Yellow
Read-Host

# Restaurar login original
Write-Host "Restaurando login original..." -ForegroundColor Yellow
$process.Kill() -ErrorAction SilentlyContinue
Copy-Item "Views/Auth/Login-Original-Backup.cshtml" "Views/Auth/Login.cshtml" -Force

Write-Host "✅ Login original restaurado" -ForegroundColor Green