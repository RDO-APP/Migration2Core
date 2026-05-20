#!/usr/bin/env pwsh

Write-Host "=== FONTELLO 404 FIX - COMPLETE TEST ===" -ForegroundColor Cyan
Write-Host ""

# Step 1: Verify Assets Structure
Write-Host "STEP 1: Verifying Assets Structure..." -ForegroundColor Yellow
$assetsPath = "RDO-NET8-Migration/RdoApp.Core/wwwroot/Assets/images"
if (Test-Path $assetsPath) {
    Write-Host "✅ Assets folder structure created" -ForegroundColor Green
    
    if (Test-Path "$assetsPath/user.png") {
        Write-Host "✅ user.png copied successfully" -ForegroundColor Green
    } else {
        Write-Host "❌ user.png missing" -ForegroundColor Red
    }
} else {
    Write-Host "❌ Assets folder structure missing" -ForegroundColor Red
}

# Step 2: Verify fontello.css exists
Write-Host ""
Write-Host "STEP 2: Verifying fontello.css..." -ForegroundColor Yellow
$fontelloCssPath = "RDO-NET8-Migration/RdoApp.Core/wwwroot/css/fontello.css"
if (Test-Path $fontelloCssPath) {
    Write-Host "✅ fontello.css exists in correct location" -ForegroundColor Green
} else {
    Write-Host "❌ fontello.css missing" -ForegroundColor Red
}

# Step 3: Verify Layout Reference
Write-Host ""
Write-Host "STEP 3: Verifying Layout Reference..." -ForegroundColor Yellow
$layoutPath = "RDO-NET8-Migration/RdoApp.Core/Views/Shared/_LayoutSelection.cshtml"
$layoutContent = Get-Content $layoutPath -Raw
if ($layoutContent -match 'href="~/css/fontello\.css"') {
    Write-Host "✅ Layout references correct fontello.css path" -ForegroundColor Green
} else {
    Write-Host "❌ Layout has wrong fontello.css path" -ForegroundColor Red
}

# Step 4: Clean and Build
Write-Host ""
Write-Host "STEP 4: Clean Build..." -ForegroundColor Yellow
Set-Location "RDO-NET8-Migration/RdoApp.Core"

# Stop any running processes
Get-Process | Where-Object {$_.ProcessName -like "*rdoapp*" -or $_.ProcessName -like "*dotnet*" -and $_.MainWindowTitle -like "*RdoApp*"} | Stop-Process -Force -ErrorAction SilentlyContinue

# Clean build
Remove-Item "bin" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "obj" -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "Building project..." -ForegroundColor Cyan
dotnet clean --verbosity quiet
dotnet restore --verbosity quiet
$buildResult = dotnet build --verbosity quiet --no-restore

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Build successful" -ForegroundColor Green
} else {
    Write-Host "❌ Build failed" -ForegroundColor Red
    Write-Host $buildResult -ForegroundColor Red
    Set-Location "../.."
    exit 1
}

# Step 5: Start Server
Write-Host ""
Write-Host "STEP 5: Starting Server..." -ForegroundColor Yellow
Write-Host "🚀 Starting RDO App server..." -ForegroundColor Cyan
Write-Host ""
Write-Host "EXPECTED RESULTS:" -ForegroundColor Green
Write-Host "✅ No 404 errors in F12 console" -ForegroundColor Green
Write-Host "✅ Header displays horizontally (not vertical list)" -ForegroundColor Green
Write-Host "✅ All icons visible: Chart, Plus, Hamburger, Logo" -ForegroundColor Green
Write-Host "✅ User avatar displays correctly" -ForegroundColor Green
Write-Host "✅ 103 obra cards render properly" -ForegroundColor Green
Write-Host ""
Write-Host "🌐 Opening browser to test..." -ForegroundColor Cyan

# Start the server
Start-Process "dotnet" -ArgumentList "run" -NoNewWindow

# Wait for server to start
Start-Sleep -Seconds 5

# Open browser
Start-Process "https://localhost:7001/Account/Login"

Write-Host ""
Write-Host "=== TEST INSTRUCTIONS ===" -ForegroundColor Magenta
Write-Host "1. Login with test credentials" -ForegroundColor White
Write-Host "2. Navigate to Obra Selection page" -ForegroundColor White
Write-Host "3. Open F12 Developer Tools" -ForegroundColor White
Write-Host "4. Check Console tab for 404 errors" -ForegroundColor White
Write-Host "5. Verify header displays horizontally" -ForegroundColor White
Write-Host "6. Verify all icons are visible" -ForegroundColor White
Write-Host "7. Verify user avatar displays" -ForegroundColor White
Write-Host "8. Verify obra cards render properly" -ForegroundColor White
Write-Host ""
Write-Host "Press Ctrl+C to stop server when testing is complete" -ForegroundColor Yellow

Set-Location "../.."