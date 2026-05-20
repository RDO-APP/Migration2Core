#!/usr/bin/env pwsh

Write-Host "=== ASSET LOADING HTTP REQUEST TEST ===" -ForegroundColor Cyan
Write-Host "Testing actual HTTP requests to verify 404 errors" -ForegroundColor Yellow

# Start the application first
Write-Host "`n1. Starting RDO Application..." -ForegroundColor Green
Set-Location "RDO-NET8-Migration/RdoApp.Core"

# Kill any existing processes
Get-Process -Name "dotnet" -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -eq "dotnet" } | Stop-Process -Force
Start-Sleep -Seconds 2

# Start the server in background
$job = Start-Job -ScriptBlock {
    Set-Location "RDO-NET8-Migration/RdoApp.Core"
    dotnet run --urls="https://localhost:7001"
}

Write-Host "Waiting for server to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

try {
    Write-Host "`n2. Testing Asset HTTP Requests..." -ForegroundColor Green
    
    # Test fontello.css
    Write-Host "`nTesting: https://localhost:7001/css/fontello.css" -ForegroundColor White
    try {
        $response1 = Invoke-WebRequest -Uri "https://localhost:7001/css/fontello.css" -SkipCertificateCheck -TimeoutSec 10
        Write-Host "✅ fontello.css: Status $($response1.StatusCode) - Content Length: $($response1.Content.Length)" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ fontello.css: ERROR - $($_.Exception.Message)" -ForegroundColor Red
        if ($_.Exception.Response) {
            Write-Host "   Status Code: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
        }
    }
    
    # Test user.png
    Write-Host "`nTesting: https://localhost:7001/Assets/images/user.png" -ForegroundColor White
    try {
        $response2 = Invoke-WebRequest -Uri "https://localhost:7001/Assets/images/user.png" -SkipCertificateCheck -TimeoutSec 10
        Write-Host "✅ user.png: Status $($response2.StatusCode) - Content Length: $($response2.Content.Length)" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ user.png: ERROR - $($_.Exception.Message)" -ForegroundColor Red
        if ($_.Exception.Response) {
            Write-Host "   Status Code: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
        }
    }
    
    # Test fontello font files
    $fontFiles = @("fontello.woff2", "fontello.woff", "fontello.ttf", "fontello.eot")
    foreach ($font in $fontFiles) {
        Write-Host "`nTesting: https://localhost:7001/fonts/$font" -ForegroundColor White
        try {
            $response = Invoke-WebRequest -Uri "https://localhost:7001/fonts/$font" -SkipCertificateCheck -TimeoutSec 10
            Write-Host "✅ $font`: Status $($response.StatusCode) - Content Length: $($response.Content.Length)" -ForegroundColor Green
        }
        catch {
            Write-Host "❌ $font`: ERROR - $($_.Exception.Message)" -ForegroundColor Red
            if ($_.Exception.Response) {
                Write-Host "   Status Code: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
            }
        }
    }
    
    # Test main page to see if it loads
    Write-Host "`nTesting: https://localhost:7001/Account/Login" -ForegroundColor White
    try {
        $response3 = Invoke-WebRequest -Uri "https://localhost:7001/Account/Login" -SkipCertificateCheck -TimeoutSec 10
        Write-Host "✅ Login Page: Status $($response3.StatusCode) - Content Length: $($response3.Content.Length)" -ForegroundColor Green
        
        # Check if CSS references are in the HTML
        if ($response3.Content -match 'fontello\.css') {
            Write-Host "✅ fontello.css reference found in HTML" -ForegroundColor Green
        } else {
            Write-Host "❌ fontello.css reference NOT found in HTML" -ForegroundColor Red
        }
        
        if ($response3.Content -match 'user\.png') {
            Write-Host "✅ user.png reference found in HTML" -ForegroundColor Green
        } else {
            Write-Host "❌ user.png reference NOT found in HTML" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "❌ Login Page: ERROR - $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host "`n3. Physical File Verification..." -ForegroundColor Green
    
    # Check if files actually exist
    $files = @(
        "wwwroot/css/fontello.css",
        "wwwroot/Assets/images/user.png",
        "wwwroot/fonts/fontello.woff2",
        "wwwroot/fonts/fontello.woff",
        "wwwroot/fonts/fontello.ttf",
        "wwwroot/fonts/fontello.eot"
    )
    
    foreach ($file in $files) {
        if (Test-Path $file) {
            $size = (Get-Item $file).Length
            Write-Host "✅ $file exists ($size bytes)" -ForegroundColor Green
        } else {
            Write-Host "❌ $file MISSING" -ForegroundColor Red
        }
    }
    
    Write-Host "`n4. Program.cs Static Files Configuration Check..." -ForegroundColor Green
    $programContent = Get-Content "Program.cs" -Raw
    if ($programContent -match 'UseStaticFiles') {
        Write-Host "✅ UseStaticFiles() found in Program.cs" -ForegroundColor Green
    } else {
        Write-Host "❌ UseStaticFiles() NOT found in Program.cs" -ForegroundColor Red
    }
    
    Write-Host "`n=== ASSET LOADING TEST COMPLETE ===" -ForegroundColor Cyan
    Write-Host "Check the results above to identify the root cause of 404 errors" -ForegroundColor Yellow
}
finally {
    # Clean up
    Write-Host "`nStopping server..." -ForegroundColor Yellow
    Stop-Job $job -ErrorAction SilentlyContinue
    Remove-Job $job -ErrorAction SilentlyContinue
    Get-Process -Name "dotnet" -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -eq "dotnet" } | Stop-Process -Force
}