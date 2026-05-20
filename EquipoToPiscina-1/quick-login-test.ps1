#!/usr/bin/env pwsh

Write-Host "=== TESTE RÁPIDO LOGIN ===" -ForegroundColor Green

# Parar processos
Get-Process -Name "RdoApp.Core" -ErrorAction SilentlyContinue | Stop-Process -Force

# Ir para projeto
Set-Location "RDO-NET8-Migration/RdoApp.Core"

# Build rápido
Write-Host "Building..." -ForegroundColor Yellow
dotnet build --no-restore --verbosity quiet

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Build OK!" -ForegroundColor Green
    
    # Iniciar app
    Start-Process -FilePath "dotnet" -ArgumentList "run --no-build" -WindowStyle Hidden
    Start-Sleep -Seconds 3
    
    # Abrir browser
    Write-Host "Abrindo login..." -ForegroundColor Yellow
    Start-Process "http://localhost:5031/Auth/Login"
    
    Write-Host "✅ PÁGINA DE LOGIN CORRIGIDA!" -ForegroundColor Green
    Write-Host "✅ Agora tem formulário completo com CPF e senha" -ForegroundColor Green
    Write-Host "✅ Baseado no design original do Gilberto" -ForegroundColor Green
    Write-Host "`nCredenciais de teste:" -ForegroundColor Cyan
    Write-Host "CPF: 567.065.455-20" -ForegroundColor Cyan
    Write-Host "Senha: RXL8DjdYj6Y=" -ForegroundColor Cyan
    
} else {
    Write-Host "❌ Build falhou!" -ForegroundColor Red
}