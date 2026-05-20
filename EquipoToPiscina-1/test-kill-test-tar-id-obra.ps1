#!/usr/bin/env pwsh

Write-Host "=== KILL TEST: Testing tar_id_obra Issue Resolution ===" -ForegroundColor Yellow
Write-Host "OBJETIVO: Verificar se as 4 etapas aparecem SEM o .Include(e => e.Tarefas)" -ForegroundColor Cyan
Write-Host ""

# Test the application
$baseUrl = "http://localhost:5031"

try {
    Write-Host "1. Testing application startup..." -ForegroundColor Green
    $response = Invoke-WebRequest -Uri $baseUrl -UseBasicParsing -TimeoutSec 10
    Write-Host "✅ Application is running on $baseUrl" -ForegroundColor Green
    
    Write-Host ""
    Write-Host "2. Testing login page..." -ForegroundColor Green
    $loginUrl = "$baseUrl/Auth/Login"
    $loginResponse = Invoke-WebRequest -Uri $loginUrl -UseBasicParsing -TimeoutSec 10
    Write-Host "✅ Login page accessible" -ForegroundColor Green
    
    Write-Host ""
    Write-Host "3. KILL TEST INSTRUCTIONS:" -ForegroundColor Yellow
    Write-Host "   - Open browser to: $loginUrl" -ForegroundColor White
    Write-Host "   - Login with: ricardo / 123456" -ForegroundColor White
    Write-Host "   - Select any obra" -ForegroundColor White
    Write-Host "   - Check if 4 etapas (880, 881, 883, 884) appear in the UI" -ForegroundColor White
    Write-Host ""
    Write-Host "4. EXPECTED RESULT:" -ForegroundColor Yellow
    Write-Host "   - If 4 etapas appear: tar_id_obra column mapping is the ONLY issue" -ForegroundColor Green
    Write-Host "   - If still empty: there's another issue beyond tar_id_obra" -ForegroundColor Red
    Write-Host ""
    Write-Host "5. Opening browser automatically..." -ForegroundColor Green
    Start-Process $loginUrl
    
    Write-Host ""
    Write-Host "=== KILL TEST READY ===" -ForegroundColor Yellow
    Write-Host "Check the browser and report results!" -ForegroundColor Cyan
    
} catch {
    Write-Host "❌ Error testing application: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Make sure the application is running with 'dotnet run'" -ForegroundColor Yellow
}