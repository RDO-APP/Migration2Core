#!/usr/bin/env pwsh

Write-Host "🎯 TESTING ACCORDION EXPANSION FIX" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green

# Stop any running processes
Write-Host "1. Stopping any running processes..." -ForegroundColor Yellow
Get-Process -Name "dotnet" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Get-Process -Name "RdoApp.Core" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

# Navigate to project directory
Set-Location "RDO-NET8-Migration/RdoApp.Core"

Write-Host "2. Building project..." -ForegroundColor Yellow
dotnet build --configuration Release --no-restore

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Build failed!" -ForegroundColor Red
    exit 1
}

Write-Host "3. Starting application..." -ForegroundColor Yellow
Start-Process -FilePath "dotnet" -ArgumentList "run --configuration Release --no-build" -NoNewWindow

# Wait for startup
Write-Host "4. Waiting for application startup..." -ForegroundColor Yellow
Start-Sleep -Seconds 8

# Test the accordion functionality
Write-Host "5. Testing accordion expansion..." -ForegroundColor Yellow

# Open browser to test page
$url = "https://localhost:7001/Tarefa/Cards?obraId=1"
Write-Host "Opening: $url" -ForegroundColor Cyan

try {
    Start-Process $url
    Write-Host "✅ Browser opened successfully" -ForegroundColor Green
    Write-Host ""
    Write-Host "🔍 MANUAL TEST CHECKLIST:" -ForegroundColor Yellow
    Write-Host "1. ✅ Cards display with proper styling (blue headers)" -ForegroundColor White
    Write-Host "2. ✅ Click on 'LIMPEZA' card - should expand/collapse" -ForegroundColor White
    Write-Host "3. ✅ Click on 'MANUTENÇÃO' card - should expand/collapse" -ForegroundColor White
    Write-Host "4. ✅ Check browser console for Bootstrap errors" -ForegroundColor White
    Write-Host "5. ✅ Verify accordion IDs match in HTML source" -ForegroundColor White
    Write-Host ""
    Write-Host "🎯 EXPECTED BEHAVIOR:" -ForegroundColor Green
    Write-Host "- Cards should have blue headers with hand icons" -ForegroundColor White
    Write-Host "- Clicking cards should expand/collapse smoothly" -ForegroundColor White
    Write-Host "- Only one card should be expanded at a time" -ForegroundColor White
    Write-Host "- No JavaScript errors in console" -ForegroundColor White
    Write-Host ""
    Write-Host "Press any key to stop the server..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
} catch {
    Write-Host "❌ Failed to open browser: $($_.Exception.Message)" -ForegroundColor Red
}

# Stop the server
Write-Host "6. Stopping server..." -ForegroundColor Yellow
Get-Process -Name "dotnet" -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -eq "dotnet" } | Stop-Process -Force -ErrorAction SilentlyContinue

Write-Host "✅ Test completed!" -ForegroundColor Green