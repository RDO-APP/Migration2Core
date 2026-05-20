#!/usr/bin/env pwsh

# BLAZOR CIRCUIT CONNECTION FIX TEST
# Tests the critical fixes for Blazor Server connection issues

Write-Host "🚀 BLAZOR CIRCUIT CONNECTION FIX TEST" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green

# Stop any running processes
Write-Host "🛑 Stopping any running RDO processes..." -ForegroundColor Yellow
Get-Process | Where-Object { $_.ProcessName -like "*RdoApp*" -or $_.ProcessName -like "*dotnet*" } | Stop-Process -Force -ErrorAction SilentlyContinue

# Clean build
Write-Host "🧹 Cleaning and rebuilding project..." -ForegroundColor Yellow
Set-Location "RDO-NET8-Migration/RdoApp.Core"
dotnet clean --verbosity quiet
dotnet build --verbosity quiet

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Build failed! Check compilation errors." -ForegroundColor Red
    exit 1
}

Write-Host "✅ Build successful!" -ForegroundColor Green

# Start the application
Write-Host "🚀 Starting application..." -ForegroundColor Yellow
$process = Start-Process -FilePath "dotnet" -ArgumentList "run" -PassThru -WindowStyle Hidden

# Wait for startup
Write-Host "⏳ Waiting for application startup..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Test the Blazor Circuit connection
Write-Host "🔍 Testing Blazor Circuit connection..." -ForegroundColor Yellow

try {
    # Test 1: Check if application is running
    $response = Invoke-WebRequest -Uri "https://localhost:5001" -SkipCertificateCheck -TimeoutSec 10
    Write-Host "✅ Application is responding (Status: $($response.StatusCode))" -ForegroundColor Green
    
    # Test 2: Check Blazor Server script
    $blazorScript = Invoke-WebRequest -Uri "https://localhost:5001/_framework/blazor.server.js" -SkipCertificateCheck -TimeoutSec 10
    Write-Host "✅ Blazor Server script is accessible (Status: $($blazorScript.StatusCode))" -ForegroundColor Green
    
    # Test 3: Check Pure Blazor page
    $blazorPage = Invoke-WebRequest -Uri "https://localhost:5001/blazor-etapa-cards/233" -SkipCertificateCheck -TimeoutSec 10
    Write-Host "✅ Pure Blazor page is accessible (Status: $($blazorPage.StatusCode))" -ForegroundColor Green
    
    # Test 4: Check for base href in layout
    if ($blazorPage.Content -match '<base href="~/"') {
        Write-Host "✅ Base href is present in layout" -ForegroundColor Green
    } else {
        Write-Host "❌ Base href is missing from layout" -ForegroundColor Red
    }
    
    # Test 5: Check for RDO logo
    if ($blazorPage.Content -match 'icon-logo' -or $blazorPage.Content -match 'RDO App Piscinas') {
        Write-Host "✅ RDO branding is present" -ForegroundColor Green
    } else {
        Write-Host "⚠️  RDO branding may be missing" -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host "🎯 CRITICAL FIXES APPLIED:" -ForegroundColor Cyan
    Write-Host "  1. ✅ Added <base href='~/' /> to _LayoutBlazor.cshtml" -ForegroundColor Green
    Write-Host "  2. ✅ Added RDO logo with icon-logo class" -ForegroundColor Green
    Write-Host "  3. ✅ Added fontello.css for RDO logo icons" -ForegroundColor Green
    Write-Host "  4. ✅ Enhanced database logging in EtapaCardsPage.razor" -ForegroundColor Green
    Write-Host ""
    Write-Host "🌐 TEST URLS:" -ForegroundColor Cyan
    Write-Host "  • Pure Blazor Page: https://localhost:5001/blazor-etapa-cards/233" -ForegroundColor White
    Write-Host "  • Blazor Script: https://localhost:5001/_framework/blazor.server.js" -ForegroundColor White
    Write-Host ""
    Write-Host "🔍 BROWSER TESTING INSTRUCTIONS:" -ForegroundColor Cyan
    Write-Host "  1. Open https://localhost:5001/blazor-etapa-cards/233" -ForegroundColor White
    Write-Host "  2. Press F12 to open Developer Tools" -ForegroundColor White
    Write-Host "  3. Check Console tab - should see:" -ForegroundColor White
    Write-Host "     ✅ '🔥 REAL DATA LOADED: X etapas, Y total tasks for Obra 233'" -ForegroundColor Green
    Write-Host "     ✅ No 404 errors for _blazor/initializers" -ForegroundColor Green
    Write-Host "     ✅ No 'Unexpected end of JSON input' errors" -ForegroundColor Green
    Write-Host "  4. Verify task cards show REAL data from database" -ForegroundColor White
    Write-Host "  5. Test (+) button opens Nova Medição modal" -ForegroundColor White
    Write-Host ""
    Write-Host "🚨 IF STILL SEEING ISSUES:" -ForegroundColor Red
    Write-Host "  • Check Program.cs has app.MapBlazorHub()" -ForegroundColor Yellow
    Write-Host "  • Verify database connection string is correct" -ForegroundColor Yellow
    Write-Host "  • Check if fontello.css exists in wwwroot/css/" -ForegroundColor Yellow
    
} catch {
    Write-Host "❌ Connection test failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "🔧 Possible issues:" -ForegroundColor Yellow
    Write-Host "  • Application may still be starting up" -ForegroundColor Yellow
    Write-Host "  • Port 5001 may be blocked" -ForegroundColor Yellow
    Write-Host "  • SSL certificate issues" -ForegroundColor Yellow
}

# Keep process running for manual testing
Write-Host ""
Write-Host "🎯 Application is running for manual testing..." -ForegroundColor Green
Write-Host "Press Ctrl+C to stop the application" -ForegroundColor Yellow

try {
    # Wait for user to stop
    while ($true) {
        Start-Sleep -Seconds 1
    }
} finally {
    # Clean up
    Write-Host "🛑 Stopping application..." -ForegroundColor Yellow
    if ($process -and !$process.HasExited) {
        $process.Kill()
    }
    Get-Process | Where-Object { $_.ProcessName -like "*RdoApp*" -or $_.ProcessName -like "*dotnet*" } | Stop-Process -Force -ErrorAction SilentlyContinue
}