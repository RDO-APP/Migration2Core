#!/usr/bin/env pwsh

Write-Host "=== FULL USER FLOW TEST (Login → Obra Selection) ===" -ForegroundColor Cyan
Write-Host "Testing the complete flow to identify where CSS 404 errors occur" -ForegroundColor Yellow

Set-Location "RDO-NET8-Migration/RdoApp.Core"

# Kill any existing processes
Get-Process -Name "dotnet" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2

Write-Host "`nStarting server..." -ForegroundColor Green
$process = Start-Process -FilePath "dotnet" -ArgumentList "run", "--urls=http://localhost:5000" -PassThru -NoNewWindow

Write-Host "Waiting for server to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

try {
    # Create a web session to maintain cookies
    $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
    
    Write-Host "`n1. Testing Login Page (should work fine)..." -ForegroundColor Green
    try {
        $loginResponse = Invoke-WebRequest -Uri "http://localhost:5000/Account/Login" -WebSession $session -TimeoutSec 10 -UseBasicParsing
        Write-Host "✅ Login page: Status $($loginResponse.StatusCode)" -ForegroundColor Green
        
        # Save login HTML
        $loginResponse.Content | Out-File -FilePath "debug-login-flow.html" -Encoding UTF8
        
        # Check if login form exists
        if ($loginResponse.Content -match 'form.*action.*Login') {
            Write-Host "✅ Login form found in HTML" -ForegroundColor Green
        } else {
            Write-Host "❌ Login form NOT found" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "❌ Login page error: $($_.Exception.Message)" -ForegroundColor Red
        return
    }
    
    Write-Host "`n2. Attempting to access Obra Selection (should redirect to login)..." -ForegroundColor Green
    try {
        $obraResponse = Invoke-WebRequest -Uri "http://localhost:5000/Obra/Escolher" -WebSession $session -TimeoutSec 10 -UseBasicParsing
        Write-Host "✅ Obra page accessible: Status $($obraResponse.StatusCode)" -ForegroundColor Green
        
        # Save obra HTML
        $obraResponse.Content | Out-File -FilePath "debug-obra-flow.html" -Encoding UTF8
        
        # Check for CSS references in obra page
        Write-Host "`n3. Analyzing Obra Page HTML..." -ForegroundColor Green
        
        if ($obraResponse.Content -match "fontello\.css") {
            Write-Host "✅ fontello.css reference found in Obra HTML" -ForegroundColor Green
        } else {
            Write-Host "❌ fontello.css reference NOT found in Obra HTML" -ForegroundColor Red
        }
        
        if ($obraResponse.Content -match "rdo-unified-theme\.css") {
            Write-Host "✅ rdo-unified-theme.css reference found in Obra HTML" -ForegroundColor Green
        } else {
            Write-Host "❌ rdo-unified-theme.css reference NOT found in Obra HTML" -ForegroundColor Red
        }
        
        if ($obraResponse.Content -match "user\.png") {
            Write-Host "✅ user.png reference found in Obra HTML" -ForegroundColor Green
        } else {
            Write-Host "❌ user.png reference NOT found in Obra HTML" -ForegroundColor Red
        }
        
        if ($obraResponse.Content -match "rdo-header") {
            Write-Host "✅ UnifiedRdoHeader component rendered" -ForegroundColor Green
        } else {
            Write-Host "❌ UnifiedRdoHeader component NOT rendered" -ForegroundColor Red
        }
        
        if ($obraResponse.Content -match "icon-logo") {
            Write-Host "✅ icon-logo class found" -ForegroundColor Green
        } else {
            Write-Host "❌ icon-logo class NOT found" -ForegroundColor Red
        }
        
        # Check for obra cards
        if ($obraResponse.Content -match "obra.*card" -or $obraResponse.Content -match "103.*obra") {
            Write-Host "✅ Obra cards content found" -ForegroundColor Green
        } else {
            Write-Host "❌ Obra cards content NOT found" -ForegroundColor Red
        }
        
        Write-Host "`n4. Testing CSS URLs from Obra Page..." -ForegroundColor Green
        
        # Test the CSS files that should be referenced
        $cssUrls = @(
            "http://localhost:5000/css/fontello.css",
            "http://localhost:5000/css/rdo-unified-theme.css",
            "http://localhost:5000/css/site.css"
        )
        
        foreach ($cssUrl in $cssUrls) {
            try {
                $cssResponse = Invoke-WebRequest -Uri $cssUrl -TimeoutSec 5 -UseBasicParsing
                Write-Host "✅ $cssUrl - Status: $($cssResponse.StatusCode), Size: $($cssResponse.Content.Length)" -ForegroundColor Green
            }
            catch {
                Write-Host "❌ $cssUrl - ERROR: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
        
        Write-Host "`n5. Testing Image URLs from Obra Page..." -ForegroundColor Green
        
        $imageUrls = @(
            "http://localhost:5000/Assets/images/user.png"
        )
        
        foreach ($imageUrl in $imageUrls) {
            try {
                $imgResponse = Invoke-WebRequest -Uri $imageUrl -TimeoutSec 5 -UseBasicParsing
                Write-Host "✅ $imageUrl - Status: $($imgResponse.StatusCode), Size: $($imgResponse.Content.Length)" -ForegroundColor Green
            }
            catch {
                Write-Host "❌ $imageUrl - ERROR: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
        
    }
    catch {
        Write-Host "❌ Obra page error: $($_.Exception.Message)" -ForegroundColor Red
        
        # This might be expected if authentication is required
        if ($_.Exception.Message -match "redirect" -or $_.Exception.Message -match "401" -or $_.Exception.Message -match "403") {
            Write-Host "   This is expected - authentication required" -ForegroundColor Yellow
            Write-Host "   The real test will be after successful login" -ForegroundColor Yellow
        }
    }
    
    Write-Host "`n6. Summary..." -ForegroundColor Green
    Write-Host "Files saved:" -ForegroundColor White
    Write-Host "  - debug-login-flow.html (Login page HTML)" -ForegroundColor Cyan
    if (Test-Path "debug-obra-flow.html") {
        Write-Host "  - debug-obra-flow.html (Obra selection page HTML)" -ForegroundColor Cyan
    }
    
    Write-Host "`nNext steps:" -ForegroundColor White
    Write-Host "  1. Check the HTML files to see actual layout usage" -ForegroundColor Yellow
    Write-Host "  2. If Obra page is accessible, check why CSS references might be missing" -ForegroundColor Yellow
    Write-Host "  3. Test with actual user credentials if needed" -ForegroundColor Yellow
}
finally {
    Write-Host "`nStopping server..." -ForegroundColor Yellow
    if ($process -and !$process.HasExited) {
        $process.Kill()
    }
    Get-Process -Name "dotnet" -ErrorAction SilentlyContinue | Stop-Process -Force
}

Write-Host "`n=== FULL FLOW TEST COMPLETE ===" -ForegroundColor Cyan