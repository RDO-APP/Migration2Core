#!/usr/bin/env pwsh

Write-Host "ROUTING CONFLICT FIX TEST" -ForegroundColor Cyan
Write-Host "Testing Pure Blazor routing vs MVC routing conflicts" -ForegroundColor Yellow
Write-Host ""

# Stop any running processes first
Write-Host "Stopping any running RDO processes..." -ForegroundColor Yellow
Get-Process | Where-Object { $_.ProcessName -like "*RdoApp*" -or $_.ProcessName -like "*dotnet*" -and $_.MainWindowTitle -like "*RdoApp*" } | Stop-Process -Force -ErrorAction SilentlyContinue

# Clean and build
Write-Host "Cleaning and building project..." -ForegroundColor Yellow
Set-Location "RDO-NET8-Migration/RdoApp.Core"

# Clean build artifacts
Remove-Item -Path "bin" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "obj" -Recurse -Force -ErrorAction SilentlyContinue

# Build project
dotnet build --configuration Debug --verbosity minimal

if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed! Cannot test routing." -ForegroundColor Red
    Set-Location "../.."
    exit 1
}

Write-Host "Build successful!" -ForegroundColor Green

# Start the application
Write-Host "Starting application..." -ForegroundColor Yellow
Start-Process -FilePath "dotnet" -ArgumentList "run --configuration Debug" -WindowStyle Hidden

# Wait for application to start
Write-Host "Waiting for application to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

Write-Host ""
Write-Host "MANUAL BROWSER TEST:" -ForegroundColor Cyan
Write-Host "1. Open browser to: https://localhost:5001/blazor-etapa-cards/233" -ForegroundColor Yellow
Write-Host "2. Check browser console for Pure Blazor messages" -ForegroundColor Yellow
Write-Host "3. Verify page shows Pure Blazor Layout Active indicator" -ForegroundColor Yellow
Write-Host "4. Test (+) button on task cards - should open modal without errors" -ForegroundColor Yellow

Write-Host ""
Write-Host "SUCCESS INDICATORS:" -ForegroundColor Green
Write-Host "- Pure Blazor Layout Active message appears" -ForegroundColor Green
Write-Host "- Blazor Server JavaScript loads" -ForegroundColor Green
Write-Host "- NO bootstrap-compatibility.js in Network tab" -ForegroundColor Green
Write-Host "- TaskCard buttons work without JavaScript errors" -ForegroundColor Green

Write-Host ""
Write-Host "FAILURE INDICATORS:" -ForegroundColor Red
Write-Host "- 404 errors for missing scripts" -ForegroundColor Red
Write-Host "- bootstrap-compatibility.js still loading" -ForegroundColor Red
Write-Host "- Missing Blazor Server JavaScript" -ForegroundColor Red

Set-Location "../.."
Write-Host ""
Write-Host "ROUTING CONFLICT FIX TEST COMPLETE" -ForegroundColor Cyan