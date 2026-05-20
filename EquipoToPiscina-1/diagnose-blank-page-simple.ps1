# SIMPLE BLANK PAGE DIAGNOSTIC
# Phase 1: Diagnostic Verification - Task 1.1

Write-Host "=== BLANK PAGE CRISIS DIAGNOSTIC ===" -ForegroundColor Cyan
Write-Host "Starting diagnostic verification..." -ForegroundColor Yellow

# Step 1: Start the application
Write-Host "`n1. STARTING APPLICATION..." -ForegroundColor Green
Push-Location "RDO-NET8-Migration/RdoApp.Core"

try {
    # Kill any existing processes
    Get-Process -Name "dotnet" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
    
    # Start application
    Write-Host "   Starting dotnet run..." -ForegroundColor Yellow
    $process = Start-Process -FilePath "dotnet" -ArgumentList "run" -PassThru -WindowStyle Hidden
    
    Write-Host "   Waiting for startup (15 seconds)..." -ForegroundColor Yellow
    Start-Sleep -Seconds 15
    
    # Step 2: Test connectivity
    Write-Host "`n2. TESTING CONNECTIVITY..." -ForegroundColor Green
    $baseUrl = "https://localhost:7001"
    
    try {
        $loginTest = Invoke-WebRequest -Uri "$baseUrl/Account/Login" -UseBasicParsing -TimeoutSec 10 -SkipCertificateCheck
        Write-Host "   Login page accessible (Status: $($loginTest.StatusCode))" -ForegroundColor Green
    } catch {
        Write-Host "   HTTPS failed, trying HTTP..." -ForegroundColor Yellow
        $baseUrl = "http://localhost:5000"
        try {
            $loginTest = Invoke-WebRequest -Uri "$baseUrl/Account/Login" -UseBasicParsing -TimeoutSec 10
            Write-Host "   Login page accessible via HTTP (Status: $($loginTest.StatusCode))" -ForegroundColor Green
        } catch {
            Write-Host "   Both HTTPS and HTTP failed: $($_.Exception.Message)" -ForegroundColor Red
            return
        }
    }
    
    # Step 3: Test static files
    Write-Host "`n3. TESTING CRITICAL CSS FILES..." -ForegroundColor Green
    
    $cssFiles = @(
        "/css/fontello.css",
        "/css/rdo-unified-theme.css", 
        "/css/site.css",
        "/_content/RdoApp.Core/RdoApp.Core.styles.css"
    )
    
    foreach ($file in $cssFiles) {
        try {
            $fileTest = Invoke-WebRequest -Uri "$baseUrl$file" -UseBasicParsing -TimeoutSec 5 -SkipCertificateCheck
            Write-Host "   $file - OK (Size: $($fileTest.Content.Length) bytes)" -ForegroundColor Green
        } catch {
            Write-Host "   $file - FAILED: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    # Step 4: Test Blazor Server script
    Write-Host "`n4. TESTING BLAZOR SERVER SCRIPT..." -ForegroundColor Green
    try {
        $blazorTest = Invoke-WebRequest -Uri "$baseUrl/_framework/blazor.server.js" -UseBasicParsing -TimeoutSec 5 -SkipCertificateCheck
        Write-Host "   Blazor Server script - OK (Size: $($blazorTest.Content.Length) bytes)" -ForegroundColor Green
    } catch {
        Write-Host "   Blazor Server script - FAILED: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    # Step 5: Manual testing instructions
    Write-Host "`n5. MANUAL TESTING REQUIRED..." -ForegroundColor Green
    Write-Host "   Application URL: $baseUrl" -ForegroundColor Cyan
    Write-Host "   Login: ricardo / 123456" -ForegroundColor Cyan
    Write-Host "" -ForegroundColor White
    Write-Host "   INSTRUCTIONS:" -ForegroundColor Yellow
    Write-Host "   1. Open $baseUrl in your browser" -ForegroundColor White
    Write-Host "   2. Login with ricardo/123456" -ForegroundColor White
    Write-Host "   3. Check ESCOLHER OBRA page for:" -ForegroundColor White
    Write-Host "      - Green debug message: 'Found 103 obras in Model'" -ForegroundColor Green
    Write-Host "      - Obra cards grid below the message" -ForegroundColor Green
    Write-Host "   4. If blank, open F12 and check:" -ForegroundColor White
    Write-Host "      - Network tab for 404 errors (red entries)" -ForegroundColor Red
    Write-Host "      - Console tab for JavaScript errors" -ForegroundColor Red
    Write-Host "   5. Right-click -> View Page Source" -ForegroundColor White
    Write-Host "      - Save as 'escolher-authenticated-source.html'" -ForegroundColor White
    Write-Host "" -ForegroundColor White
    Write-Host "   Press ENTER when done testing..." -ForegroundColor Yellow
    Read-Host
    
} catch {
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
} finally {
    # Clean up
    if ($process -and !$process.HasExited) {
        $process.Kill()
        Write-Host "   Server stopped" -ForegroundColor Yellow
    }
    Pop-Location
}

Write-Host "`n=== DIAGNOSTIC COMPLETE ===" -ForegroundColor Cyan
Write-Host "Next: Run html-source-analyzer.ps1 with captured HTML" -ForegroundColor Green