#!/usr/bin/env pwsh

Write-Host "=== HTML OUTPUT ANALYSIS ===" -ForegroundColor Cyan
Write-Host "Analyzing actual HTML output to find asset path discrepancies" -ForegroundColor Yellow

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
    
    Write-Host "`n2. Analyzing CSS References in HTML..." -ForegroundColor Green
    
    # Extract all CSS link tags
    $cssMatches = [regex]::Matches($html, '<link[^>]*rel=["\']stylesheet["\'][^>]*>')
    
    Write-Host "Found CSS References:" -ForegroundColor White
    foreach ($match in $cssMatches) {
        $linkTag = $match.Value
        Write-Host "  $linkTag" -ForegroundColor Cyan
        
        # Extract href attribute
        if ($linkTag -match 'href=["\']([^"\']*)["\']') {
            $href = $matches[1]
            Write-Host "    → URL: $href" -ForegroundColor Yellow
            
            # Test this specific URL
            try {
                $fullUrl = if ($href.StartsWith('http')) { $href } else { "http://localhost:5000$href" }
                $testResponse = Invoke-WebRequest -Uri $fullUrl -TimeoutSec 5 -UseBasicParsing
                Write-Host "    ✅ Status: $($testResponse.StatusCode)" -ForegroundColor Green
            }
            catch {
                Write-Host "    ❌ ERROR: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    }
    
    Write-Host "`n3. Analyzing Image References in HTML..." -ForegroundColor Green
    
    # Extract all img tags
    $imgMatches = [regex]::Matches($html, '<img[^>]*src=["\']([^"\']*)["\'][^>]*>')
    
    Write-Host "Found Image References:" -ForegroundColor White
    foreach ($match in $imgMatches) {
        $imgTag = $match.Value
        $src = $match.Groups[1].Value
        Write-Host "  $imgTag" -ForegroundColor Cyan
        Write-Host "    → URL: $src" -ForegroundColor Yellow
        
        # Test this specific URL
        try {
            $fullUrl = if ($src.StartsWith('http')) { $src } else { "http://localhost:5000$src" }
            $testResponse = Invoke-WebRequest -Uri $fullUrl -TimeoutSec 5 -UseBasicParsing
            Write-Host "    ✅ Status: $($testResponse.StatusCode)" -ForegroundColor Green
        }
        catch {
            Write-Host "    ❌ ERROR: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    Write-Host "`n4. Checking for Blazor Component Rendering..." -ForegroundColor Green
    
    # Check if UnifiedRdoHeader component is rendered
    if ($html -match 'rdo-header') {
        Write-Host "✅ UnifiedRdoHeader component appears to be rendered" -ForegroundColor Green
    } else {
        Write-Host "❌ UnifiedRdoHeader component NOT found in HTML" -ForegroundColor Red
    }
    
    # Check for specific icon classes
    $iconClasses = @('icon-logo', 'fa fa-bar-chart', 'fa fa-plus')
    foreach ($iconClass in $iconClasses) {
        if ($html -match $iconClass) {
            Write-Host "✅ Icon class '$iconClass' found in HTML" -ForegroundColor Green
        } else {
            Write-Host "❌ Icon class '$iconClass' NOT found in HTML" -ForegroundColor Red
        }
    }
    
    Write-Host "`n5. Saving HTML for Manual Inspection..." -ForegroundColor Green
    $html | Out-File -FilePath "debug-login-page.html" -Encoding UTF8
    Write-Host "✅ HTML saved to debug-login-page.html" -ForegroundColor Green
    
    Write-Host "`n6. Testing Obra Selection Page..." -ForegroundColor Green
    
    # We need to login first to access obra selection
    Write-Host "Note: Obra selection requires authentication - testing login redirect" -ForegroundColor Yellow
    try {
        $obraResponse = Invoke-WebRequest -Uri "http://localhost:5000/Obra/Escolher" -TimeoutSec 5 -UseBasicParsing
        Write-Host "✅ Obra page accessible: Status $($obraResponse.StatusCode)" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Obra page: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "   This is expected if authentication is required" -ForegroundColor Yellow
    }
}
finally {
    Write-Host "`nStopping server..." -ForegroundColor Yellow
    if ($process -and !$process.HasExited) {
        $process.Kill()
    }
    Get-Process -Name "dotnet" -ErrorAction SilentlyContinue | Stop-Process -Force
}

Write-Host "`n=== HTML ANALYSIS COMPLETE ===" -ForegroundColor Cyan
Write-Host "Check debug-login-page.html for detailed HTML inspection" -ForegroundColor Yellow