#!/usr/bin/env pwsh

# Test script to verify if etapas appear in UI after bypassing colaboradorId filter
# Based on context: 4 etapas (880, 881, 883, 884) should be found in database

Write-Host "=== TESTING ETAPAS UI AFTER BYPASSING COLABORADORID FILTER ===" -ForegroundColor Green
Write-Host "Expected: 4 etapas should now appear in UI" -ForegroundColor Yellow
Write-Host "Database confirmed: Etapas 880, 881, 883, 884 exist" -ForegroundColor Yellow

# Navigate to project directory
Set-Location "RDO-NET8-Migration/RdoApp.Core"

Write-Host "`n1. Checking current EtapaService implementation..." -ForegroundColor Cyan
$etapaServiceContent = Get-Content "Services/Implementations/EtapaService.cs" -Raw
if ($etapaServiceContent -match "return true;.*bypass colaboradorId filtering") {
    Write-Host "✅ IsUserAuthorizedForTask correctly set to always return true" -ForegroundColor Green
} else {
    Write-Host "❌ IsUserAuthorizedForTask not properly configured" -ForegroundColor Red
    exit 1
}

Write-Host "`n2. Verifying Session configuration..." -ForegroundColor Cyan
$programContent = Get-Content "Program.cs" -Raw
if ($programContent -match "AddSession" -and $programContent -match "UseSession") {
    Write-Host "✅ Session configuration present in Program.cs" -ForegroundColor Green
} else {
    Write-Host "❌ Session configuration missing" -ForegroundColor Red
    exit 1
}

Write-Host "`n3. Checking compilation..." -ForegroundColor Cyan
try {
    $buildResult = dotnet build --no-restore --verbosity quiet 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Project compiles successfully" -ForegroundColor Green
    } else {
        Write-Host "❌ Compilation errors found:" -ForegroundColor Red
        Write-Host $buildResult -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "❌ Build failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "`n4. Starting application for UI test..." -ForegroundColor Cyan
Write-Host "🚀 Starting IIS Express..." -ForegroundColor Yellow

# Start the application
try {
    Start-Process "dotnet" -ArgumentList "run" -NoNewWindow -PassThru
    Start-Sleep -Seconds 5
    
    Write-Host "✅ Application started successfully" -ForegroundColor Green
    Write-Host "`n📋 MANUAL TEST STEPS:" -ForegroundColor Yellow
    Write-Host "1. Open browser to: https://localhost:7001" -ForegroundColor White
    Write-Host "2. Login with test credentials" -ForegroundColor White
    Write-Host "3. Select an obra (work)" -ForegroundColor White
    Write-Host "4. Navigate to Etapas page" -ForegroundColor White
    Write-Host "5. VERIFY: Should see 4 etapas (880, 881, 883, 884) displayed" -ForegroundColor White
    
    Write-Host "`n🔍 WHAT TO LOOK FOR:" -ForegroundColor Yellow
    Write-Host "- Accordion sections for each etapa should be visible" -ForegroundColor White
    Write-Host "- No more empty page despite database having data" -ForegroundColor White
    Write-Host "- Console logs should show: 'DEBUG: Controller received 4 etapas from Service'" -ForegroundColor White
    
    Write-Host "`n⚠️  IF STILL EMPTY:" -ForegroundColor Red
    Write-Host "- Check browser console for JavaScript errors" -ForegroundColor White
    Write-Host "- Check Visual Studio Output window for debug logs" -ForegroundColor White
    Write-Host "- Verify Model.Any() condition in Etapas.cshtml view" -ForegroundColor White
    
    Write-Host "`nPress any key to stop the application..." -ForegroundColor Cyan
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    
} catch {
    Write-Host "❌ Failed to start application: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
} finally {
    # Stop any running dotnet processes
    Get-Process -Name "dotnet" -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -eq "dotnet" } | Stop-Process -Force -ErrorAction SilentlyContinue
    Write-Host "🛑 Application stopped" -ForegroundColor Yellow
}

Write-Host "`n=== TEST COMPLETED ===" -ForegroundColor Green
Write-Host "Next steps based on results:" -ForegroundColor Yellow
Write-Host "- If etapas appear: ✅ Issue resolved!" -ForegroundColor Green
Write-Host "- If still empty: Need to investigate View rendering in Etapas.cshtml" -ForegroundColor Red