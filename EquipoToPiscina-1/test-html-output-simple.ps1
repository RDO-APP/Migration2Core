#!/usr/bin/env pwsh

Write-Host "=== HTML OUTPUT ANALYSIS ===" -ForegroundColor Cyan

Set-Location "RDO-NET8-Migration/RdoApp.Core"

# Kill any existing processes
Get-Process -Name "dotnet" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2

Write-Host "`nStarting server..." -ForegroundColor Green
$process = Start-Process -FilePath "dotnet" -ArgumentList "run", "--urls=http://localhost:5000" -PassThru -NoNewWindow

Write-Host "Waiting for server to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

try {
    Write-Host "`n1. Fetching Login Page HTML..." -ForegroundColor Green
    $response = Invoke-WebRequest -Uri "http://localhost:5000/Account/Login" -TimeoutSec 10 -UseBasicParsing
    $html = $response.Content
    
    Write-Host "✅ Login page fetched successfully" -ForegroundColor Green
    
    Write-Host "`n2. Saving HTML for inspection..." -ForegroundColor Green
    $html | Out-File -FilePath "debug-login-page.html" -Encoding UTF8
    Write-Host "✅ HTML saved to debug-login-page.html" -ForegroundColor Green
    
    Write-Host "`n3. Checking key elements in HTML..." -ForegroundColor Green
    
    # Check for CSS references
    if ($html -match "fontello\.css") {
        Write-Host "✅ fontello.css reference found in HTML" -ForegroundColor Green
    } else {
        Write-Host "❌ fontello.css reference NOT found in HTML" -ForegroundColor Red
    }
    
    if ($html -match "rdo-unified-theme\.css") {
        Write-Host "✅ rdo-unified-theme.css reference found in HTML" -ForegroundColor Green
    } else {
        Write-Host "❌ rdo-unified-theme.css reference NOT found in HTML" -ForegroundColor Red
    }
    
    # Check for image references
    if ($html -match "user\.png") {
        Write-Host "✅ user.png reference found in HTML" -ForegroundColor Green
    } else {
        Write-Host "❌ user.png reference NOT found in HTML" -ForegroundColor Red
    }
    
    # Check for Blazor component
    if ($html -match "rdo-header") {
        Write-Host "✅ rdo-header class found (UnifiedRdoHeader rendered)" -ForegroundColor Green
    } else {
        Write-Host "❌ rdo-header class NOT found" -ForegroundColor Red
    }
    
    # Check for icon classes
    if ($html -match "icon-logo") {
        Write-Host "✅ icon-logo class found" -ForegroundColor Green
    } else {
        Write-Host "❌ icon-logo class NOT found" -ForegroundColor Red
    }
    
    Write-Host "`n4. Testing specific asset URLs..." -ForegroundColor Green
    
    # Test the exact URLs that would be generated
    $testUrls = @(
        "http://localhost:5000/css/fontello.css",
        "http://localhost:5000/css/rdo-unified-theme.css", 
        "http://localhost:5000/Assets/images/user.png",
        "http://localhost:5000/fonts/fontello.woff2"
    )
    
    foreach ($url in $testUrls) {
        try {
            $testResponse = Invoke-WebRequest -Uri $url -TimeoutSec 5 -UseBasicParsing
            Write-Host "✅ $url - Status: $($testResponse.StatusCode)" -ForegroundColor Green
        }
        catch {
            Write-Host "❌ $url - ERROR: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    Write-Host "`n5. Content Analysis..." -ForegroundColor Green
    Write-Host "HTML Length: $($html.Length) characters" -ForegroundColor White
    
    # Show first few lines to verify structure
    $lines = $html -split "`n"
    Write-Host "First 10 lines of HTML:" -ForegroundColor White
    for ($i = 0; $i -lt [Math]::Min(10, $lines.Count); $i++) {
        Write-Host "  $($i+1): $($lines[$i].Trim())" -ForegroundColor Cyan
    }
}
finally {
    Write-Host "`nStopping server..." -ForegroundColor Yellow
    if ($process -and !$process.HasExited) {
        $process.Kill()
    }
    Get-Process -Name "dotnet" -ErrorAction SilentlyContinue | Stop-Process -Force
}

Write-Host "`n=== ANALYSIS COMPLETE ===" -ForegroundColor Cyan