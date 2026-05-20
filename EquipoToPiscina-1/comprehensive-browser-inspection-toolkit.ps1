# COMPREHENSIVE BROWSER INSPECTION TOOLKIT
# Automated tools to gather HTML output and resource loading evidence

Write-Host "=== COMPREHENSIVE BROWSER INSPECTION TOOLKIT ===" -ForegroundColor Cyan
Write-Host "Gathering evidence for blank page diagnosis" -ForegroundColor Yellow

# Step 1: Start the application and capture startup logs
Write-Host "`n1. STARTING APPLICATION WITH DETAILED LOGGING..." -ForegroundColor Green
Push-Location "RDO-NET8-Migration/RdoApp.Core"

try {
    # Kill any existing processes first
    Get-Process -Name "dotnet" -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -eq "dotnet" } | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
    
    # Start application with detailed logging
    Write-Host "   Starting dotnet run with enhanced logging..." -ForegroundColor Yellow
    $process = Start-Process -FilePath "dotnet" -ArgumentList "run", "--environment", "Development" -PassThru -WindowStyle Hidden -RedirectStandardOutput -RedirectStandardError
    
    Write-Host "   ⏳ Waiting for application startup (15 seconds)..." -ForegroundColor Yellow
    Start-Sleep -Seconds 15
    
    # Step 2: Test basic connectivity
    Write-Host "`n2. TESTING BASIC CONNECTIVITY..." -ForegroundColor Green
    $baseUrl = "https://localhost:7001"
    
    try {
        $loginTest = Invoke-WebRequest -Uri "$baseUrl/Account/Login" -UseBasicParsing -TimeoutSec 10 -SkipCertificateCheck
        Write-Host "   ✅ Login page accessible (Status: $($loginTest.StatusCode))" -ForegroundColor Green
        Write-Host "   📄 Content Length: $($loginTest.Content.Length) bytes" -ForegroundColor Gray
    } catch {
        Write-Host "   ❌ Login page failed: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "   🔄 Trying HTTP instead..." -ForegroundColor Yellow
        $baseUrl = "http://localhost:5000"
        try {
            $loginTest = Invoke-WebRequest -Uri "$baseUrl/Account/Login" -UseBasicParsing -TimeoutSec 10
            Write-Host "   ✅ Login page accessible via HTTP (Status: $($loginTest.StatusCode))" -ForegroundColor Green
        } catch {
            Write-Host "   ❌ Both HTTPS and HTTP failed" -ForegroundColor Red
            return
        }
    }
    
    # Step 3: Capture HTML output from ESCOLHER OBRA page (unauthenticated)
    Write-Host "`n3. TESTING UNAUTHENTICATED ESCOLHER OBRA ACCESS..." -ForegroundColor Green
    try {
        $escolherTest = Invoke-WebRequest -Uri "$baseUrl/Obra/Escolher" -UseBasicParsing -TimeoutSec 10 -SkipCertificateCheck
        Write-Host "   📊 Status: $($escolherTest.StatusCode)" -ForegroundColor Gray
        Write-Host "   📄 Content Length: $($escolherTest.Content.Length) bytes" -ForegroundColor Gray
        
        # Save the HTML output for analysis
        $escolherTest.Content | Out-File -FilePath "escolher-unauthenticated-output.html" -Encoding UTF8
        Write-Host "   💾 HTML saved to: escolher-unauthenticated-output.html" -ForegroundColor Green
        
        # Analyze the content
        if ($escolherTest.Content -match "login|Login|LOGIN") {
            Write-Host "   🔄 REDIRECTED TO LOGIN (as expected for unauthenticated)" -ForegroundColor Yellow
        } elseif ($escolherTest.Content.Length -lt 100) {
            Write-Host "   ⚠️  VERY SHORT RESPONSE - Possible blank page" -ForegroundColor Red
        } else {
            Write-Host "   ✅ Got substantial content" -ForegroundColor Green
        }
    } catch {
        Write-Host "   ❌ Escolher page failed: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    # Step 4: Test static file accessibility
    Write-Host "`n4. TESTING STATIC FILE ACCESSIBILITY..." -ForegroundColor Green
    
    $staticFiles = @(
        "/css/fontello.css",
        "/css/rdo-unified-theme.css", 
        "/css/site.css",
        "/_content/RdoApp.Core/RdoApp.Core.styles.css",
        "/_framework/blazor.server.js"
    )
    
    foreach ($file in $staticFiles) {
        try {
            $fileTest = Invoke-WebRequest -Uri "$baseUrl$file" -UseBasicParsing -TimeoutSec 5 -SkipCertificateCheck
            Write-Host "   ✅ $file (Status: $($fileTest.StatusCode), Size: $($fileTest.Content.Length) bytes)" -ForegroundColor Green
        } catch {
            Write-Host "   ❌ $file FAILED: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    # Step 5: Create a simple authentication session and test ESCOLHER OBRA
    Write-Host "`n5. ATTEMPTING AUTHENTICATED ACCESS SIMULATION..." -ForegroundColor Green
    Write-Host "   ⚠️  Note: This requires manual login in browser for full test" -ForegroundColor Yellow
    Write-Host "   📋 Manual Steps Required:" -ForegroundColor White
    Write-Host "      1. Open browser to: $baseUrl" -ForegroundColor Gray
    Write-Host "      2. Login with: ricardo / 123456" -ForegroundColor Gray
    Write-Host "      3. Navigate to ESCOLHER OBRA page" -ForegroundColor Gray
    Write-Host "      4. Right-click → View Page Source" -ForegroundColor Gray
    Write-Host "      5. Copy HTML and save as 'escolher-authenticated-source.html'" -ForegroundColor Gray
    Write-Host "      6. Open F12 → Network tab → Reload page" -ForegroundColor Gray
    Write-Host "      7. Check for any red (failed) requests" -ForegroundColor Gray
    
    # Step 6: Analyze server logs (if accessible)
    Write-Host "`n6. CHECKING FOR SERVER LOGS..." -ForegroundColor Green
    
    # Look for common log locations
    $logPaths = @(
        "bin/Debug/net8.0/logs",
        "logs",
        "Logs"
    )
    
    foreach ($logPath in $logPaths) {
        if (Test-Path $logPath) {
            Write-Host "   📁 Found log directory: $logPath" -ForegroundColor Green
            $logFiles = Get-ChildItem -Path $logPath -Filter "*.log" -ErrorAction SilentlyContinue
            foreach ($logFile in $logFiles) {
                Write-Host "   📄 Log file: $($logFile.Name) (Size: $($logFile.Length) bytes)" -ForegroundColor Gray
            }
        }
    }
    
    # Step 7: Generate diagnostic report
    Write-Host "`n7. GENERATING DIAGNOSTIC REPORT..." -ForegroundColor Green
    
    $report = @"
# BROWSER INSPECTION DIAGNOSTIC REPORT
Generated: $(Get-Date)

## Application Status
- Base URL: $baseUrl
- Process ID: $($process.Id)
- Status: Running

## Connectivity Tests
- Login Page: Accessible
- Static Files: See individual results above

## Next Steps Required
1. **Manual Browser Test**: 
   - Open $baseUrl in browser
   - Login with ricardo/123456
   - Navigate to ESCOLHER OBRA
   - Check if debug message appears: "Found X obras in Model"
   - Check if any cards are visible

2. **F12 Network Analysis**:
   - Open F12 Developer Tools
   - Go to Network tab
   - Reload ESCOLHER OBRA page
   - Look for any red (404/500) requests
   - Check if _content/RdoApp.Core/RdoApp.Core.styles.css loads

3. **F12 Console Analysis**:
   - Check Console tab for JavaScript errors
   - Look for Blazor Server connection messages
   - Check for component initialization errors

4. **Page Source Analysis**:
   - Right-click → View Page Source
   - Search for "Found" to see if debug message is in HTML
   - Search for "rdo-obra-cards-container" to see if component markup exists
   - Check if layout structure is complete

## Files Created
- escolher-unauthenticated-output.html (for analysis)

## Critical Questions to Answer
1. Does the debug message appear in browser?
2. Are there any 404 errors in Network tab?
3. Is the Blazor Server script loading?
4. Does the page source contain component markup?
"@
    
    $report | Out-File -FilePath "browser-inspection-report.md" -Encoding UTF8
    Write-Host "   💾 Report saved to: browser-inspection-report.md" -ForegroundColor Green
    
    # Step 8: Keep server running for manual testing
    Write-Host "`n8. SERVER READY FOR MANUAL TESTING..." -ForegroundColor Green
    Write-Host "   🌐 Application URL: $baseUrl" -ForegroundColor Cyan
    Write-Host "   🔑 Login Credentials: ricardo / 123456" -ForegroundColor Cyan
    Write-Host "   📋 Target Page: $baseUrl/Obra/Escolher" -ForegroundColor Cyan
    Write-Host "" -ForegroundColor White
    Write-Host "   MANUAL TESTING INSTRUCTIONS:" -ForegroundColor Yellow
    Write-Host "   1. Open the URL above in your browser" -ForegroundColor White
    Write-Host "   2. Login with the credentials above" -ForegroundColor White
    Write-Host "   3. You should be redirected to ESCOLHER OBRA" -ForegroundColor White
    Write-Host "   4. Check if you see:" -ForegroundColor White
    Write-Host "      - Green debug message: 'Found 103 obras in Model'" -ForegroundColor Green
    Write-Host "      - Grid of obra cards below the message" -ForegroundColor Green
    Write-Host "   5. If page is blank, open F12 and check:" -ForegroundColor White
    Write-Host "      - Network tab for failed requests (red entries)" -ForegroundColor Red
    Write-Host "      - Console tab for JavaScript errors" -ForegroundColor Red
    Write-Host "   6. Right-click → View Page Source and check:" -ForegroundColor White
    Write-Host "      - If debug message HTML exists" -ForegroundColor White
    Write-Host "      - If component markup exists" -ForegroundColor White
    Write-Host "" -ForegroundColor White
    Write-Host "   Press CTRL+C when done testing to stop the server" -ForegroundColor Yellow
    
    # Wait for user to finish testing
    try {
        while (!$process.HasExited) {
            Start-Sleep -Seconds 5
        }
    } catch {
        Write-Host "`n   Server stopped by user" -ForegroundColor Green
    }
    
} catch {
    Write-Host "   ❌ Error during testing: $($_.Exception.Message)" -ForegroundColor Red
} finally {
    # Clean up
    if ($process -and !$process.HasExited) {
        $process.Kill()
        Write-Host "   🛑 Server stopped" -ForegroundColor Yellow
    }
    Pop-Location
}

Write-Host "`n=== BROWSER INSPECTION COMPLETE ===" -ForegroundColor Cyan
Write-Host "Check the generated files for analysis results" -ForegroundColor Green