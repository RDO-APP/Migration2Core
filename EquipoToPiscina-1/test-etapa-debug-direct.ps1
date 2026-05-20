#!/usr/bin/env pwsh

Write-Host "=== TESTING ETAPA DEBUG LOGGING DIRECTLY ===" -ForegroundColor Green
Write-Host "This will start the application and you can manually test the etapas page" -ForegroundColor Yellow

# Stop any running processes first
Get-Process | Where-Object {$_.ProcessName -like "*dotnet*" -or $_.ProcessName -like "*RdoApp*"} | Stop-Process -Force -ErrorAction SilentlyContinue

# Navigate to project directory
Set-Location "RDO-NET8-Migration/RdoApp.Core"

Write-Host "`nStarting application..." -ForegroundColor Cyan
Write-Host "Once started, go to: http://localhost:5000/Auth/Login" -ForegroundColor Yellow
Write-Host "Login with: CPF=12345678901, Senha=123456" -ForegroundColor Yellow
Write-Host "Then go to: http://localhost:5000/Obra/Etapas/1" -ForegroundColor Yellow
Write-Host "" -ForegroundColor White
Write-Host "Watch the console output for debug messages from:" -ForegroundColor Cyan
Write-Host "  - ObraController.Etapas method" -ForegroundColor White
Write-Host "  - EtapaService.ObterEtapasViewModelAsync method" -ForegroundColor White
Write-Host "" -ForegroundColor White
Write-Host "Press Ctrl+C to stop when done testing." -ForegroundColor Yellow

# Start the application
dotnet run