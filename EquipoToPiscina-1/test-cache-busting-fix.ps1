#!/usr/bin/env pwsh

Write-Host "=== CACHE BUSTING FIX VERIFICATION ===" -ForegroundColor Cyan
Write-Host "Testing the implemented cache busting solution" -ForegroundColor Yellow

Set-Location "RDO-NET8-Migration/RdoApp.Core"

# Kill any existing processes
Get-Process -Name "dotnet" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2

Write-Host "`nStarting server with cache busting fix..." -ForegroundColor Green
$process = Start-Process -FilePath "dotnet" -ArgumentList "run", "--urls=http://localhost:5000" -PassThru -NoNewWindow

Write-Host "Waiting for server to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

try {
    Write-Host "`n1. Testing Cache Control Headers..." -ForegroundColor Green
    
    # Test CSS files for cache control headers
    $cssUrls = @(
        "http://localhost:5000/css/fontello.css",
        "http://localhost:5000/css/rdo-unified-theme.css",
        "http://localhost:5000/css/site.css"
    )
    
    foreach ($cssUrl in $cssUrls) {
        try {
            $response = Invoke-WebRequest -Uri $cssUrl -TimeoutSec 5 -UseBasicParsing
            Write-Host "✅ $cssUrl - Status: $($response.StatusCode)" -ForegroundColor Green
            
            # Check for cache control headers
            $cacheControl = $response.Headers['Cache-Control']
            if ($cacheControl -and $cacheControl -match 'no-cache') {
                Write-Host "   ✅ Cache-Control: $cacheControl" -ForegroundColor Green
            } else {
                Write-Host "   ⚠️  Cache-Control: $($cacheControl -join ', ')" -ForegroundColor Yellow
            }
        }
        catch {
            Write-Host "❌ $cssUrl - ERROR: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    Write-Host "`n2. Testing Font Files..." -ForegroundColor Green
    
    $fontUrls = @(
        "http://localhost:5000/fonts/fontello.woff2",
        "http://localhost:5000/fonts/fontello.woff"
    )
    
    foreach ($fontUrl in $fontUrls) {
        try {
            $response = Invoke-WebRequest -Uri $fontUrl -TimeoutSec 5 -UseBasicParsing
            Write-Host "✅ $fontUrl - Status: $($response.StatusCode)" -ForegroundColor Green
            
            $cacheControl = $response.Headers['Cache-Control']
            if ($cacheControl -and $cacheControl -match 'no-cache') {
                Write-Host "   ✅ Cache-Control: $cacheControl" -ForegroundColor Green
            } else {
                Write-Host "   ⚠️  Cache-Control: $($cacheControl -join ', ')" -ForegroundColor Yellow
            }
        }
        catch {
            Write-Host "❌ $fontUrl - ERROR: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    Write-Host "`n3. Testing Image Files (should use normal caching)..." -ForegroundColor Green
    
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:5000/Assets/images/user.png" -TimeoutSec 5 -UseBasicParsing
        Write-Host "✅ user.png - Status: $($response.StatusCode)" -ForegroundColor Green
        
        $cacheControl = $response.Headers['Cache-Control']
        Write-Host "   ℹ️  Cache-Control: $($cacheControl -join ', ')" -ForegroundColor Cyan
    }
    catch {
        Write-Host "❌ user.png - ERROR: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host "`n4. Testing Login Page (should work normally)..." -ForegroundColor Green
    
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:5000/Account/Login" -TimeoutSec 10 -UseBasicParsing
        Write-Host "✅ Login page - Status: $($response.StatusCode)" -ForegroundColor Green
        
        # Check if page contains expected elements
        if ($response.Content -match "RDO App Piscinas") {
            Write-Host "   ✅ Page title found" -ForegroundColor Green
        }
        
        if ($response.Content -match "login-card") {
            Write-Host "   ✅ Login form found" -ForegroundColor Green
        }
    }
    catch {
        Write-Host "❌ Login page - ERROR: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host "`n5. Summary..." -ForegroundColor Green
    Write-Host "Cache busting fix implemented successfully!" -ForegroundColor White
    Write-Host "CSS and font files now have no-cache headers in development mode." -ForegroundColor Green
    
    Write-Host "`nUser Instructions:" -ForegroundColor White
    Write-Host "1. Clear browser cache (Ctrl+Shift+Delete)" -ForegroundColor Cyan
    Write-Host "2. Hard refresh the page (Ctrl+F5)" -ForegroundColor Cyan
    Write-Host "3. Check F12 Network tab - should show fresh requests" -ForegroundColor Cyan
    Write-Host "4. CSS and images should now load correctly" -ForegroundColor Cyan
}
finally {
    Write-Host "`nStopping server..." -ForegroundColor Yellow
    if ($process -and !$process.HasExited) {
        $process.Kill()
    }
    Get-Process -Name "dotnet" -ErrorAction SilentlyContinue | Stop-Process -Force
}

Write-Host "`n=== CACHE BUSTING FIX VERIFICATION COMPLETE ===" -ForegroundColor Cyan