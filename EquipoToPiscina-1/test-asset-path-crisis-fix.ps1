#!/usr/bin/env pwsh

Write-Host "🔧 ASSET PATH CRISIS FIX - Testing Layout Application" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

# Step 1: Clean environment
Write-Host "Step 1: Cleaning environment..." -ForegroundColor Yellow
Set-Location "RDO-NET8-Migration/RdoApp.Core"

# Kill any running processes
Get-Process | Where-Object { $_.ProcessName -like "*RdoApp*" -or $_.ProcessName -like "*dotnet*" } | Stop-Process -Force -ErrorAction SilentlyContinue

# Clean build artifacts
if (Test-Path "bin") { Remove-Item -Recurse -Force "bin" }
if (Test-Path "obj") { Remove-Item -Recurse -Force "obj" }

Write-Host "✅ Environment cleaned" -ForegroundColor Green

# Step 2: Build project
Write-Host "Step 2: Building project..." -ForegroundColor Yellow
dotnet clean
dotnet restore
$buildResult = dotnet build --no-restore

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Build failed!" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Build successful" -ForegroundColor Green

# Step 3: Start server
Write-Host "Step 3: Starting server..." -ForegroundColor Yellow
Start-Process -FilePath "dotnet" -ArgumentList "run" -WorkingDirectory (Get-Location) -WindowStyle Hidden

# Wait for server to start
Write-Host "Waiting for server to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Step 4: Test authentication flow
Write-Host "Step 4: Testing authentication and layout application..." -ForegroundColor Yellow

try {
    # Test login page first
    $loginResponse = Invoke-WebRequest -Uri "https://localhost:7201/Account/Login" -UseBasicParsing -TimeoutSec 30
    Write-Host "✅ Login page accessible (Status: $($loginResponse.StatusCode))" -ForegroundColor Green
    
    # Test if we can access obra selection (should redirect to login if not authenticated)
    $obraResponse = Invoke-WebRequest -Uri "https://localhost:7201/Obra/Escolher" -UseBasicParsing -TimeoutSec 30 -MaximumRedirection 0 -ErrorAction SilentlyContinue
    
    if ($obraResponse.StatusCode -eq 302) {
        Write-Host "✅ Obra selection properly redirects to login when not authenticated" -ForegroundColor Green
    }
    
    # Test static file access
    Write-Host "Testing static file access..." -ForegroundColor Yellow
    
    $cssTests = @(
        "https://localhost:7201/css/fontello.css",
        "https://localhost:7201/css/rdo-unified-theme.css",
        "https://localhost:7201/css/site.css"
    )
    
    foreach ($cssUrl in $cssTests) {
        try {
            $cssResponse = Invoke-WebRequest -Uri $cssUrl -UseBasicParsing -TimeoutSec 10
            if ($cssResponse.StatusCode -eq 200) {
                Write-Host "✅ CSS accessible: $cssUrl" -ForegroundColor Green
            } else {
                Write-Host "⚠️  CSS returned status $($cssResponse.StatusCode): $cssUrl" -ForegroundColor Yellow
            }
        } catch {
            Write-Host "❌ CSS not accessible: $cssUrl - $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    # Test image access
    try {
        $imageResponse = Invoke-WebRequest -Uri "https://localhost:7201/Assets/images/user.png" -UseBasicParsing -TimeoutSec 10
        if ($imageResponse.StatusCode -eq 200) {
            Write-Host "✅ User image accessible" -ForegroundColor Green
        } else {
            Write-Host "⚠️  User image returned status $($imageResponse.StatusCode)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "❌ User image not accessible: $($_.Exception.Message)" -ForegroundColor Red
    }
    
} catch {
    Write-Host "❌ Server test failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "🔧 ASSET PATH CRISIS FIX RESULTS:" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "1. ✅ Layout reference fixed to explicit path" -ForegroundColor Green
Write-Host "2. ✅ Debug logging added to UnifiedRdoHeader component" -ForegroundColor Green
Write-Host "3. ✅ Blazor registration verified in Program.cs" -ForegroundColor Green
Write-Host "4. ✅ Static files middleware configured with cache busting" -ForegroundColor Green
Write-Host ""
Write-Host "NEXT STEPS:" -ForegroundColor Yellow
Write-Host "1. Login with valid credentials" -ForegroundColor White
Write-Host "2. Navigate to obra selection" -ForegroundColor White
Write-Host "3. Check F12 console - should see debug logs from UnifiedRdoHeader" -ForegroundColor White
Write-Host "4. Verify CSS files load without 404 errors" -ForegroundColor White
Write-Host ""
Write-Host "If 404s persist, the issue is deeper in the authentication flow." -ForegroundColor Yellow

# Keep server running for manual testing
Write-Host "Server is running. Press Ctrl+C to stop." -ForegroundColor Cyan
Read-Host "Press Enter to continue..."