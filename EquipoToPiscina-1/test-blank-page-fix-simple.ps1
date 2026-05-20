# SIMPLE TEST FOR BLANK PAGE FIX
# Test the implemented Blazor component parameter fix

Write-Host "=== TESTING BLANK PAGE FIX ===" -ForegroundColor Cyan
Write-Host "Testing the implemented component parameter type fix" -ForegroundColor Yellow

# Step 1: Start the application
Write-Host "`n1. STARTING APPLICATION..." -ForegroundColor Green
Push-Location "RDO-NET8-Migration/RdoApp.Core"

try {
    # Kill any existing processes
    Get-Process -Name "dotnet" -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -eq "dotnet" } | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
    
    # Start application
    Write-Host "   Starting server..." -ForegroundColor Yellow
    $process = Start-Process -FilePath "dotnet" -ArgumentList "run" -PassThru -WindowStyle Hidden
    
    Write-Host "   Waiting for startup (15 seconds)..." -ForegroundColor Yellow
    Start-Sleep -Seconds 15
    
    # Step 2: Test connectivity
    Write-Host "`n2. TESTING CONNECTIVITY..." -ForegroundColor Green
    $baseUrl = "http://localhost:5031"
    
    try {
        $loginTest = Invoke-WebRequest -Uri "$baseUrl/Account/Login" -UseBasicParsing -TimeoutSec 10
        Write-Host "   ✅ Server is running (Status: $($loginTest.StatusCode))" -ForegroundColor Green
    } catch {
        Write-Host "   ❌ Server not accessible: $($_.Exception.Message)" -ForegroundColor Red
        return
    }
    
    # Step 3: Test static files
    Write-Host "`n3. TESTING STATIC FILES..." -ForegroundColor Green
    
    $staticFiles = @(
        "/css/fontello.css",
        "/css/rdo-unified-theme.css", 
        "/css/site.css",
        "/_content/RdoApp.Core/RdoApp.Core.styles.css",
        "/_framework/blazor.server.js"
    )
    
    foreach ($file in $staticFiles) {
        try {
            $fileTest = Invoke-WebRequest -Uri "$baseUrl$file" -UseBasicParsing -TimeoutSec 5
            Write-Host "   ✅ $file (Status: $($fileTest.StatusCode))" -ForegroundColor Green
        } catch {
            Write-Host "   ❌ $file FAILED" -ForegroundColor Red
        }
    }
    
    # Step 4: Manual testing instructions
    Write-Host "`n4. MANUAL TESTING REQUIRED..." -ForegroundColor Green
    Write-Host "   🌐 Application URL: $baseUrl" -ForegroundColor Cyan
    Write-Host "   🔑 Login: ricardo / 123456" -ForegroundColor Cyan
    Write-Host "   📋 Target: $baseUrl/Obra/Escolher" -ForegroundColor Cyan
    Write-Host "" -ForegroundColor White
    Write-Host "   CRITICAL TEST STEPS:" -ForegroundColor Yellow
    Write-Host "   1. Open browser to the URL above" -ForegroundColor White
    Write-Host "   2. Login with ricardo/123456" -ForegroundColor White
    Write-Host "   3. Check ESCOLHER OBRA page for:" -ForegroundColor White
    Write-Host "      ✅ Green debug message: 'Found 103 obras in Model'" -ForegroundColor Green
    Write-Host "      ✅ Grid of obra cards visible below" -ForegroundColor Green
    Write-Host "      ❌ If blank page, check F12 Console for errors" -ForegroundColor Red
    Write-Host "" -ForegroundColor White
    Write-Host "   Press CTRL+C when done testing" -ForegroundColor Yellow
    
    # Wait for user input
    Read-Host "Press Enter when you have completed the manual test"
    
} catch {
    Write-Host "   ❌ Error: $($_.Exception.Message)" -ForegroundColor Red
} finally {
    # Clean up
    if ($process -and !$process.HasExited) {
        $process.Kill()
        Write-Host "   🛑 Server stopped" -ForegroundColor Yellow
    }
    Pop-Location
}

Write-Host "`n=== TEST COMPLETE ===" -ForegroundColor Cyan
Write-Host "If the debug message appeared and cards are visible, the fix worked!" -ForegroundColor Green