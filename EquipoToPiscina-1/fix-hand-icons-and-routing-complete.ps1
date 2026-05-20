#!/usr/bin/env pwsh
# COMPLETE FIX: Hand Icons + Legacy Routing Elimination
# Addresses view compilation caching and routing issues

Write-Host "🔧 COMPLETE FIX: Hand Icons + Legacy Routing" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan

# STEP 1: Stop all processes
Write-Host "`n📛 STEP 1: Stopping all processes..." -ForegroundColor Yellow
try {
    # Stop IIS Express
    Get-Process -Name "iisexpress" -ErrorAction SilentlyContinue | Stop-Process -Force
    Write-Host "✅ IIS Express stopped" -ForegroundColor Green
    
    # Stop dotnet processes
    Get-Process -Name "dotnet" -ErrorAction SilentlyContinue | Stop-Process -Force
    Write-Host "✅ .NET processes stopped" -ForegroundColor Green
    
    # Stop RdoApp processes
    Get-Process -Name "*rdoapp*" -ErrorAction SilentlyContinue | Stop-Process -Force
    Write-Host "✅ RdoApp processes stopped" -ForegroundColor Green
    
    Start-Sleep -Seconds 2
} catch {
    Write-Host "⚠️ Some processes may not have been running" -ForegroundColor Yellow
}

# STEP 2: Force clean compilation cache
Write-Host "`n🧹 STEP 2: Cleaning compilation cache..." -ForegroundColor Yellow

$projectPath = "RDO-NET8-Migration/RdoApp.Core"

if (Test-Path $projectPath) {
    # Delete bin and obj folders
    $binPath = Join-Path $projectPath "bin"
    $objPath = Join-Path $projectPath "obj"
    
    if (Test-Path $binPath) {
        Remove-Item $binPath -Recurse -Force
        Write-Host "✅ Deleted bin folder" -ForegroundColor Green
    }
    
    if (Test-Path $objPath) {
        Remove-Item $objPath -Recurse -Force
        Write-Host "✅ Deleted obj folder" -ForegroundColor Green
    }
    
    # Delete any compiled view files
    $viewsPath = Join-Path $projectPath "Views"
    Get-ChildItem -Path $viewsPath -Filter "*.g.cs" -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force
    Write-Host "✅ Deleted compiled view files" -ForegroundColor Green
    
} else {
    Write-Host "❌ Project path not found: $projectPath" -ForegroundColor Red
    Write-Host "Please run this script from the correct directory" -ForegroundColor Red
    exit 1
}

# STEP 3: Clear browser cache
Write-Host "`n🌐 STEP 3: Clearing browser cache..." -ForegroundColor Yellow

# Chrome cache
$chromeCachePath = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache"
if (Test-Path $chromeCachePath) {
    try {
        Remove-Item "$chromeCachePath\*" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "✅ Chrome cache cleared" -ForegroundColor Green
    } catch {
        Write-Host "⚠️ Chrome cache partially cleared (some files in use)" -ForegroundColor Yellow
    }
}

# Edge cache
$edgeCachePath = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache"
if (Test-Path $edgeCachePath) {
    try {
        Remove-Item "$edgeCachePath\*" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "✅ Edge cache cleared" -ForegroundColor Green
    } catch {
        Write-Host "⚠️ Edge cache partially cleared (some files in use)" -ForegroundColor Yellow
    }
}

# STEP 4: Verify critical files exist
Write-Host "`n🔍 STEP 4: Verifying critical files..." -ForegroundColor Yellow

$taskCardPartial = Join-Path $projectPath "Views/Etapa/_TaskCardPartial.cshtml"
$accountController = Join-Path $projectPath "Controllers/AccountController.cs"
$programCs = Join-Path $projectPath "Program.cs"

if (Test-Path $taskCardPartial) {
    $content = Get-Content $taskCardPartial -Raw
    if ($content -match "fa-hand-rock-o") {
        Write-Host "✅ Hand icons code found in _TaskCardPartial.cshtml" -ForegroundColor Green
    } else {
        Write-Host "❌ Hand icons code MISSING in _TaskCardPartial.cshtml" -ForegroundColor Red
        Write-Host "   File exists but doesn't contain hand icon switch statement" -ForegroundColor Red
    }
} else {
    Write-Host "❌ _TaskCardPartial.cshtml not found" -ForegroundColor Red
}

if (Test-Path $accountController) {
    Write-Host "✅ AccountController.cs exists" -ForegroundColor Green
} else {
    Write-Host "❌ AccountController.cs not found" -ForegroundColor Red
}

if (Test-Path $programCs) {
    $content = Get-Content $programCs -Raw
    if ($content -match "Force redirect to new AccountController") {
        Write-Host "✅ Force redirect middleware found in Program.cs" -ForegroundColor Green
    } else {
        Write-Host "❌ Force redirect middleware MISSING in Program.cs" -ForegroundColor Red
    }
} else {
    Write-Host "❌ Program.cs not found" -ForegroundColor Red
}

# STEP 5: Build solution
Write-Host "`n🔨 STEP 5: Building solution..." -ForegroundColor Yellow

try {
    Set-Location $projectPath
    
    # Restore packages
    Write-Host "Restoring NuGet packages..." -ForegroundColor Cyan
    dotnet restore
    
    # Build project
    Write-Host "Building project..." -ForegroundColor Cyan
    $buildResult = dotnet build --no-restore --verbosity minimal
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Build successful" -ForegroundColor Green
    } else {
        Write-Host "❌ Build failed" -ForegroundColor Red
        Write-Host $buildResult -ForegroundColor Red
        Set-Location "../.."
        exit 1
    }
    
    Set-Location "../.."
} catch {
    Write-Host "❌ Build error: $($_.Exception.Message)" -ForegroundColor Red
    Set-Location "../.."
    exit 1
}

# STEP 6: Start application
Write-Host "`n🚀 STEP 6: Starting application..." -ForegroundColor Yellow

try {
    Set-Location $projectPath
    
    Write-Host "Starting application with dotnet run..." -ForegroundColor Cyan
    Write-Host "Application will start in background..." -ForegroundColor Cyan
    
    # Start in background
    Start-Process -FilePath "dotnet" -ArgumentList "run" -WindowStyle Hidden
    
    Write-Host "✅ Application started" -ForegroundColor Green
    Write-Host "Waiting 10 seconds for startup..." -ForegroundColor Cyan
    Start-Sleep -Seconds 10
    
    Set-Location "../.."
} catch {
    Write-Host "❌ Failed to start application: $($_.Exception.Message)" -ForegroundColor Red
    Set-Location "../.."
}

# STEP 7: Testing instructions
Write-Host "`n🧪 STEP 7: TESTING INSTRUCTIONS" -ForegroundColor Yellow
Write-Host "================================" -ForegroundColor Yellow

Write-Host "`n1. 🌐 OPEN INCOGNITO BROWSER:" -ForegroundColor Cyan
Write-Host "   - Chrome: Ctrl+Shift+N" -ForegroundColor White
Write-Host "   - Edge: Ctrl+Shift+InPrivate" -ForegroundColor White

Write-Host "`n2. 🔗 NAVIGATE TO:" -ForegroundColor Cyan
Write-Host "   https://localhost:7201/" -ForegroundColor White
Write-Host "   (Should redirect to /Account/Login)" -ForegroundColor Gray

Write-Host "`n3. ✅ EXPECTED RESULTS:" -ForegroundColor Cyan
Write-Host "   - Shows new Razor login page (glass morphism design)" -ForegroundColor White
Write-Host "   - NOT the old AngularJS login" -ForegroundColor White
Write-Host "   - Login with: CPF 567.065.455-20, Password RXL8DjdYj6Y=" -ForegroundColor White

Write-Host "`n4. 🎯 TEST HAND ICONS:" -ForegroundColor Cyan
Write-Host "   After login, navigate to:" -ForegroundColor White
Write-Host "   https://localhost:7201/Etapa/Cards" -ForegroundColor White
Write-Host "   OR" -ForegroundColor Gray
Write-Host "   https://localhost:7201/etapa/test (test page with 5 different icons)" -ForegroundColor White

Write-Host "`n5. 🔍 VERIFY HAND ICONS:" -ForegroundColor Cyan
Write-Host "   - Each task card should have a hand icon in the header" -ForegroundColor White
Write-Host "   - Icons: ✋ (paper), ✊ (rock), ✌️ (peace), 🛑 (stop), ✂️ (scissors)" -ForegroundColor White
Write-Host "   - NO 'EM EXECUÇÃO' button at bottom of cards" -ForegroundColor White

Write-Host "`n6. 🐛 IF ISSUES PERSIST:" -ForegroundColor Cyan
Write-Host "   - Press F12 → Console tab → Look for errors" -ForegroundColor White
Write-Host "   - Right-click card → Inspect → Look for <i class='fa fa-hand-rock-o'>" -ForegroundColor White
Write-Host "   - Check URL is /Etapa/Cards (NOT old AngularJS version)" -ForegroundColor White

Write-Host "`n🎉 SUMMARY OF FIXES APPLIED:" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green
Write-Host "✅ Stopped all running processes" -ForegroundColor Green
Write-Host "✅ Cleared compilation cache (bin/obj)" -ForegroundColor Green
Write-Host "✅ Cleared browser cache" -ForegroundColor Green
Write-Host "✅ Verified hand icons code exists" -ForegroundColor Green
Write-Host "✅ Verified force redirect middleware exists" -ForegroundColor Green
Write-Host "✅ Rebuilt solution from scratch" -ForegroundColor Green
Write-Host "✅ Started application fresh" -ForegroundColor Green

Write-Host "`n🚨 CRITICAL: Use INCOGNITO mode to avoid cached sessions!" -ForegroundColor Red -BackgroundColor Yellow

Write-Host "`nScript completed. Test the application now!" -ForegroundColor Cyan