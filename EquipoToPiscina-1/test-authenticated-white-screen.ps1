#!/usr/bin/env pwsh

Write-Host "AUTHENTICATED WHITE SCREEN TEST" -ForegroundColor Cyan
Write-Host "===============================" -ForegroundColor Cyan

Write-Host "`nStarting application..." -ForegroundColor Yellow
Set-Location "RDO-NET8-Migration/RdoApp.Core"

# Start the application
$process = Start-Process -FilePath "dotnet" -ArgumentList "run" -PassThru -NoNewWindow
Write-Host "Application started with PID: $($process.Id)" -ForegroundColor Green

# Wait for startup
Write-Host "Waiting 15 seconds for application startup..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

try {
    Write-Host "`nTesting authentication flow..." -ForegroundColor Cyan
    
    # Create a session to maintain cookies
    $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
    
    # Step 1: Get login page
    Write-Host "1. Getting login page..." -ForegroundColor Yellow
    $loginResponse = Invoke-WebRequest -Uri "http://localhost:5031/Account/Login" -UseBasicParsing -SessionVariable session
    Write-Host "Login page status: $($loginResponse.StatusCode)" -ForegroundColor Green
    
    # Step 2: Try to access obra/escolher directly (should redirect to login)
    Write-Host "2. Testing obra/escolher without auth..." -ForegroundColor Yellow
    try {
        $obraResponse = Invoke-WebRequest -Uri "http://localhost:5031/obra/escolher" -UseBasicParsing -WebSession $session
        Write-Host "Obra page status: $($obraResponse.StatusCode)" -ForegroundColor Green
        Write-Host "Response length: $($obraResponse.Content.Length) characters" -ForegroundColor Green
        
        # Check what we got
        $isLoginPage = $obraResponse.Content -match "Account/Login" -or $obraResponse.Content -match "Entrar"
        $isObraPage = $obraResponse.Content -match "ESCOLHA UMA DAS UNIDADES"
        $hasBlazorLayout = $obraResponse.Content -match "_LayoutBlazor"
        $hasRenderBody = $obraResponse.Content -match "container-fluid"
        
        Write-Host "`nPAGE ANALYSIS:" -ForegroundColor Yellow
        Write-Host "Is Login Page: $isLoginPage" -ForegroundColor $(if($isLoginPage) {"Yellow"} else {"Green"})
        Write-Host "Is Obra Page: $isObraPage" -ForegroundColor $(if($isObraPage) {"Green"} else {"Red"})
        Write-Host "Has Blazor Layout: $hasBlazorLayout" -ForegroundColor $(if($hasBlazorLayout) {"Green"} else {"Red"})
        Write-Host "Has Container: $hasRenderBody" -ForegroundColor $(if($hasRenderBody) {"Green"} else {"Red"})
        
        # Save response for inspection
        $obraResponse.Content | Out-File -FilePath "debug-obra-response.html" -Encoding UTF8
        Write-Host "`nResponse saved to debug-obra-response.html" -ForegroundColor Cyan
        
    } catch {
        Write-Host "Error accessing obra page: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host "`nMANUAL TESTING INSTRUCTIONS:" -ForegroundColor Green
    Write-Host "1. Open browser to: http://localhost:5031" -ForegroundColor White
    Write-Host "2. Login with valid credentials" -ForegroundColor White
    Write-Host "3. Navigate to: http://localhost:5031/obra/escolher" -ForegroundColor White
    Write-Host "4. Check if you see 103 obras or white screen" -ForegroundColor White
    Write-Host "5. Press F12 and check Console for errors" -ForegroundColor White
    
    Write-Host "`nPress any key to stop the application..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    
} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
} finally {
    # Stop the application
    if ($process -and !$process.HasExited) {
        $process.Kill()
        Write-Host "`nApplication stopped" -ForegroundColor Yellow
    }
}

Write-Host "`nTEST COMPLETE" -ForegroundColor Green