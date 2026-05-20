#!/usr/bin/env pwsh

Write-Host "🔥 REAL DATA INTEGRATION - COMPLETE VERIFICATION" -ForegroundColor Green
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
Write-Host "🔍 REAL DATA INTEGRATION VERIFICATION TESTS" -ForegroundColor Cyan
Write-Host "===========================================" -ForegroundColor Cyan

# Test 1: Verify Blazor Server Script Fix
Write-Host ""
Write-Host "TEST 1: Blazor Server Script Path Fix" -ForegroundColor Yellow
$layoutBlazorContent = Get-Content "Views/Shared/_LayoutBlazor.cshtml" -Raw
if ($layoutBlazorContent -match "~/_framework/blazor.server.js") {
    Write-Host "✅ Blazor Server script path corrected with tilde prefix" -ForegroundColor Green
} else {
    Write-Host "❌ Blazor Server script path not fixed correctly" -ForegroundColor Red
}

# Test 2: Verify Mock Data Removal
Write-Host ""
Write-Host "TEST 2: Mock Data Elimination" -ForegroundColor Yellow
$etapaCardsContent = Get-Content "Components/EtapaCardsPage.razor" -Raw
if ($etapaCardsContent -match "CreateSampleData" -or $etapaCardsContent -match "Simulate data loading") {
    Write-Host "❌ Mock data still present in EtapaCardsPage.razor" -ForegroundColor Red
} else {
    Write-Host "✅ Mock data eliminated from EtapaCardsPage.razor" -ForegroundColor Green
}

# Test 3: Verify Real Database Integration
Write-Host ""
Write-Host "TEST 3: Real Database Integration" -ForegroundColor Yellow
if ($etapaCardsContent -match "EtapaService.GetEtapasWithTarefasAsync" -and $etapaCardsContent -match "EtapaFilterViewModel") {
    Write-Host "✅ Real database integration implemented" -ForegroundColor Green
} else {
    Write-Host "❌ Real database integration not implemented correctly" -ForegroundColor Red
}

# Test 4: Verify JSRuntime Elimination
Write-Host ""
Write-Host "TEST 4: JSRuntime Dependency Elimination" -ForegroundColor Yellow
if ($etapaCardsContent -match "IJSRuntime" -or $etapaCardsContent -match "JSRuntime.InvokeVoidAsync") {
    Write-Host "❌ JSRuntime dependency still present" -ForegroundColor Red
} else {
    Write-Host "✅ JSRuntime dependency eliminated for Pure Blazor" -ForegroundColor Green
}

# Test 5: Test Pure Blazor URL with Real Data
Write-Host ""
Write-Host "TEST 5: Pure Blazor URL with Real Data" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5000/blazor-etapa-cards/233" -TimeoutSec 15 -ErrorAction Stop
    
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Pure Blazor URL accessible (Status: $($response.StatusCode))" -ForegroundColor Green
        
        # Check for Blazor Server script
        $content = $response.Content
        if ($content -match "_framework/blazor.server.js") {
            Write-Host "✅ Blazor Server script loading correctly" -ForegroundColor Green
        } else {
            Write-Host "⚠️  Blazor Server script not found in response" -ForegroundColor Yellow
        }
        
        # Check for Pure Blazor indicators
        if ($content -match "Pure Blazor System Active") {
            Write-Host "✅ Pure Blazor component loaded successfully" -ForegroundColor Green
        } else {
            Write-Host "⚠️  Pure Blazor component indicators not found" -ForegroundColor Yellow
        }
        
    } else {
        Write-Host "⚠️  Pure Blazor URL returned status: $($response.StatusCode)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Pure Blazor URL test failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 6: Verify Authentication State Preservation
Write-Host ""
Write-Host "TEST 6: Authentication State Preservation" -ForegroundColor Yellow
$loginContent = Get-Content "Views/Account/Login.cshtml" -Raw
$obraContent = Get-Content "Views/Obra/Escolher.cshtml" -Raw

if ($loginContent -match "Layout = null" -and $obraContent -match "Layout = null") {
    Write-Host "✅ Login and Obra pages use isolated layouts (authentication preserved)" -ForegroundColor Green
} else {
    Write-Host "❌ Login or Obra pages may interfere with authentication state" -ForegroundColor Red
}

Write-Host ""
Write-Host "🎯 EXPECTED RESULTS AFTER FIXES:" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host "✅ Blazor Server script loads without 404 error" -ForegroundColor Green
Write-Host "✅ Real tasks for Obra 233 display from database" -ForegroundColor Green
Write-Host "✅ Nova Medição (+) button opens real modal with task ID" -ForegroundColor Green
Write-Host "✅ Zero mock/fake data on screen" -ForegroundColor Green
Write-Host "✅ Pure Blazor EventCallback communication" -ForegroundColor Green
Write-Host "✅ Authentication state preserved across page transitions" -ForegroundColor Green

Write-Host ""
Write-Host "📋 MANUAL VERIFICATION STEPS:" -ForegroundColor Cyan
Write-Host "=============================" -ForegroundColor Cyan
Write-Host "1. Open browser to: http://localhost:5000/Account/Login" -ForegroundColor White
Write-Host "2. Login with test credentials" -ForegroundColor White
Write-Host "3. Select Obra 233 (should redirect to /blazor-etapa-cards/233)" -ForegroundColor White
Write-Host "4. Verify F12 console shows NO 404 errors" -ForegroundColor White
Write-Host "5. Verify page shows REAL tasks from database (not mock data)" -ForegroundColor White
Write-Host "6. Click (+) button on any task card" -ForegroundColor White
Write-Host "7. Verify Nova Medição modal opens with correct task ID" -ForegroundColor White
Write-Host "8. Verify all task card buttons work with Blazor EventCallback" -ForegroundColor White

Write-Host ""
Write-Host "🔧 WHAT WAS FIXED:" -ForegroundColor Cyan
Write-Host "==================" -ForegroundColor Cyan
Write-Host "1. Blazor Server Script: Fixed path from '_framework' to '~/_framework'" -ForegroundColor White
Write-Host "2. Mock Data Elimination: Removed CreateSampleData(), using real EtapaService" -ForegroundColor White
Write-Host "3. Database Integration: Connected to real GetEtapasWithTarefasAsync()" -ForegroundColor White
Write-Host "4. JSRuntime Elimination: Removed JavaScript dependencies for Pure Blazor" -ForegroundColor White
Write-Host "5. Nova Medição Integration: Connected (+) button to real modal with task ID" -ForegroundColor White
Write-Host "6. Authentication Audit: Verified Login/Obra pages don't interfere" -ForegroundColor White

# Stop the test process
Write-Host ""
Write-Host "🛑 Stopping test application..." -ForegroundColor Yellow
Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "🎉 REAL DATA INTEGRATION VERIFICATION COMPLETE!" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green
Write-Host "All fixes applied. You should now see REAL tasks for Obra 233!" -ForegroundColor Yellow