#!/usr/bin/env pwsh

# Simple test to run the application and check if etapas appear
Write-Host "=== TESTING ETAPAS UI - SIMPLE VERSION ===" -ForegroundColor Green

# Navigate to project directory
Set-Location "RDO-NET8-Migration/RdoApp.Core"

Write-Host "Starting application..." -ForegroundColor Cyan
Write-Host "🚀 Running dotnet run..." -ForegroundColor Yellow

# Start the application in background
$process = Start-Process "dotnet" -ArgumentList "run" -PassThru -NoNewWindow

# Wait a moment for startup
Start-Sleep -Seconds 8

Write-Host "`n✅ Application should be running now" -ForegroundColor Green
Write-Host "`n📋 MANUAL TEST INSTRUCTIONS:" -ForegroundColor Yellow
Write-Host "1. Open browser to: https://localhost:7001" -ForegroundColor White
Write-Host "2. Login with test credentials" -ForegroundColor White  
Write-Host "3. Select an obra (work)" -ForegroundColor White
Write-Host "4. Navigate to Etapas page" -ForegroundColor White
Write-Host "5. Check if 4 etapas appear OR if you see 'Nenhuma etapa encontrada'" -ForegroundColor White

Write-Host "`n🔍 DEBUG LOGS TO WATCH:" -ForegroundColor Yellow
Write-Host "In Visual Studio Output window, look for:" -ForegroundColor White
Write-Host "- 'DEBUG: Controller received X etapas from Service'" -ForegroundColor Gray
Write-Host "- 'FORCE DEBUG: Model count = X'" -ForegroundColor Gray
Write-Host "- 'Etapas encontradas no banco: X'" -ForegroundColor Gray
Write-Host "- 'RESULTADO FINAL: X etapas no ViewModel'" -ForegroundColor Gray

Write-Host "`n⚠️  EXPECTED RESULTS:" -ForegroundColor Red
Write-Host "IF WORKING: You should see 4 etapas in accordion format" -ForegroundColor Green
Write-Host "IF BROKEN: You'll see 'Nenhuma etapa encontrada para esta obra'" -ForegroundColor Red

Write-Host "`nPress ENTER when you've completed the test..." -ForegroundColor Cyan
Read-Host

# Stop the application
if ($process -and !$process.HasExited) {
    $process.Kill()
    Write-Host "🛑 Application stopped" -ForegroundColor Yellow
}

Write-Host "`n=== TEST COMPLETED ===" -ForegroundColor Green
Write-Host "Please report the results!" -ForegroundColor Yellow