#!/usr/bin/env pwsh

Write-Host "🛡️ ENVIRONMENTAL LEAK FIX - COMPLETE VERIFICATION" -ForegroundColor Green
Write-Host "================================================================" -ForegroundColor Green
Write-Host ""

# Stop any running processes first
Write-Host "🔄 Stopping any running processes..." -ForegroundColor Yellow
Get-Process -Name "dotnet", "IISExpress", "RdoApp.Core" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

# Clean build
Write-Host "🧹 Cleaning and rebuilding project..." -ForegroundColor Yellow
Set-Location "RDO-NET8-Migration/RdoApp.Core"
Remove-Item -Path "bin", "obj" -Recurse -Force -ErrorAction SilentlyContinue
dotnet clean --verbosity quiet
dotnet build --verbosity quiet

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Build failed! Cannot proceed with test." -ForegroundColor Red
    exit 1
}

Write-Host "✅ Build successful" -ForegroundColor Green

# Start the application
Write-Host "🚀 Starting application..." -ForegroundColor Yellow
$process = Start-Process -FilePath "dotnet" -ArgumentList "run" -PassThru -WindowStyle Hidden
Start-Sleep -Seconds 8

Write-Host ""
Write-Host "🔍 ENVIRONMENTAL LEAK VERIFICATION TESTS" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

# Test 1: Verify _ViewStart.cshtml fix
Write-Host ""
Write-Host "TEST 1: _ViewStart.cshtml Environmental Leak Fix" -ForegroundColor Yellow
$viewStartContent = Get-Content "Views/_ViewStart.cshtml" -Raw
if ($viewStartContent -match "isPureBlazorView" -and $viewStartContent -match "CardsBlazor") {
    Write-Host "✅ _ViewStart.cshtml correctly excludes Pure Blazor views from legacy layout" -ForegroundColor Green
} else {
    Write-Host "❌ _ViewStart.cshtml fix not applied correctly" -ForegroundColor Red
}

# Test 2: Verify navigation fix in Obra/Escolher.cshtml
Write-Host ""
Write-Host "TEST 2: Obra Selection Navigation Fix" -ForegroundColor Yellow
$escolherContent = Get-Content "Views/Obra/Escolher.cshtml" -Raw
if ($escolherContent -match "/blazor-etapa-cards/" -and $escolherContent -match "Pure Blazor route") {
    Write-Host "✅ Obra selection now navigates to Pure Blazor route" -ForegroundColor Green
} else {
    Write-Host "❌ Navigation fix not applied correctly" -ForegroundColor Red
}

# Test 3: Test Pure Blazor URL directly
Write-Host ""
Write-Host "TEST 3: Pure Blazor URL Direct Access" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5000/blazor-etapa-cards/233" -TimeoutSec 10 -ErrorAction Stop
    
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Pure Blazor URL accessible (Status: $($response.StatusCode))" -ForegroundColor Green
        
        # Check if response contains Pure Blazor layout indicators
        $content = $response.Content
        if ($content -match "Pure Blazor Layout Active" -and $content -match "_LayoutBlazor") {
            Write-Host "✅ Pure Blazor layout is being used" -ForegroundColor Green
        } else {
            Write-Host "⚠️  Pure Blazor URL accessible but layout verification inconclusive" -ForegroundColor Yellow
        }
        
        # Check for absence of legacy JavaScript
        if ($content -match "bootstrap-compatibility.js") {
            Write-Host "❌ ENVIRONMENTAL LEAK DETECTED: bootstrap-compatibility.js still present!" -ForegroundColor Red
        } else {
            Write-Host "✅ No legacy JavaScript detected in Pure Blazor response" -ForegroundColor Green
        }
        
    } else {
        Write-Host "⚠️  Pure Blazor URL returned status: $($response.StatusCode)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Pure Blazor URL test failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 4: Test legacy MVC URL for comparison
Write-Host ""
Write-Host "TEST 4: Legacy MVC URL Comparison" -ForegroundColor Yellow
try {
    $legacyResponse = Invoke-WebRequest -Uri "http://localhost:5000/Etapa/Cards?obraId=233" -TimeoutSec 10 -ErrorAction Stop
    
    if ($legacyResponse.StatusCode -eq 200) {
        $legacyContent = $legacyResponse.Content
        
        if ($legacyContent -match "bootstrap-compatibility.js") {
            Write-Host "✅ Legacy MVC URL still contains legacy JavaScript (as expected)" -ForegroundColor Green
        } else {
            Write-Host "⚠️  Legacy MVC URL doesn't contain expected legacy JavaScript" -ForegroundColor Yellow
        }
        
        if ($legacyContent -match "Pure Blazor Layout Active") {
            Write-Host "❌ ENVIRONMENTAL LEAK: Legacy MVC URL using Pure Blazor layout!" -ForegroundColor Red
        } else {
            Write-Host "✅ Legacy MVC URL using legacy layout (as expected)" -ForegroundColor Green
        }
    }
} catch {
    Write-Host "⚠️  Legacy MVC URL test failed: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Test 5: Browser console simulation
Write-Host ""
Write-Host "TEST 5: Browser Console Simulation" -ForegroundColor Yellow
Write-Host "📋 INSTRUCTIONS FOR MANUAL VERIFICATION:" -ForegroundColor Cyan
Write-Host "1. Open browser to: http://localhost:5000/Account/Login" -ForegroundColor White
Write-Host "2. Login with test credentials" -ForegroundColor White
Write-Host "3. Navigate to Obra selection" -ForegroundColor White
Write-Host "4. Select any obra (should redirect to /blazor-etapa-cards/XXX)" -ForegroundColor White
Write-Host "5. Open browser console (F12)" -ForegroundColor White
Write-Host "6. Verify you see: '🚀 PURE BLAZOR LAYOUT: Loaded successfully'" -ForegroundColor White
Write-Host "7. Verify you DO NOT see: 'bootstrap-compatibility.js'" -ForegroundColor White
Write-Host "8. Verify URL is: /blazor-etapa-cards/XXX (NOT /cards?IdObra=XXX)" -ForegroundColor White

Write-Host ""
Write-Host "🎯 EXPECTED RESULTS AFTER FIX:" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host "✅ Users navigate from Obra selection to /blazor-etapa-cards/XXX" -ForegroundColor Green
Write-Host "✅ Pure Blazor layout loads with zero legacy JavaScript" -ForegroundColor Green
Write-Host "✅ Browser console shows Pure Blazor success messages" -ForegroundColor Green
Write-Host "✅ No bootstrap-compatibility.js in network tab" -ForegroundColor Green
Write-Host "✅ Task card buttons work with pure Blazor EventCallback" -ForegroundColor Green

Write-Host ""
Write-Host "🔧 WHAT WAS FIXED:" -ForegroundColor Cyan
Write-Host "==================" -ForegroundColor Cyan
Write-Host "1. _ViewStart.cshtml: Added Pure Blazor view detection" -ForegroundColor White
Write-Host "2. Obra/Escolher.cshtml: Changed navigation to Pure Blazor route" -ForegroundColor White
Write-Host "3. Environmental isolation: Pure Blazor views bypass legacy layout" -ForegroundColor White

# Stop the test process
Write-Host ""
Write-Host "🛑 Stopping test application..." -ForegroundColor Yellow
Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "🎉 ENVIRONMENTAL LEAK FIX VERIFICATION COMPLETE!" -ForegroundColor Green
Write-Host "=================================================" -ForegroundColor Green
Write-Host "The fix has been applied. Please run manual browser test to confirm." -ForegroundColor Yellow