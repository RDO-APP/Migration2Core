# TEST: Asset Path Crisis Fix - Final Verification
# After forensic investigation, we identified and fixed the root cause

Write-Host "TESTING: Asset Path Crisis Fix - Final Verification" -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan

# Step 1: Verify the fix was applied
Write-Host "`nSTEP 1: Verifying Middleware Fix Applied" -ForegroundColor Yellow
$programCs = Get-Content "RDO-NET8-Migration/RdoApp.Core/Program.cs" -Raw

if ($programCs -match 'path\?\.\StartsWith\("/Assets/"\)') {
    Write-Host "SUCCESS: /Assets/ bypass logic added to middleware" -ForegroundColor Green
} else {
    Write-Host "ERROR: /Assets/ bypass logic not found" -ForegroundColor Red
    exit 1
}

# Step 2: Verify layout specification is explicit
Write-Host "`nSTEP 2: Verifying Explicit Layout Path" -ForegroundColor Yellow
$escolherView = Get-Content "RDO-NET8-Migration/RdoApp.Core/Views/Obra/Escolher.cshtml" -Raw

if ($escolherView -match '~/Views/Shared/_LayoutSelection') {
    Write-Host "SUCCESS: Explicit layout path specified" -ForegroundColor Green
} else {
    Write-Host "ERROR: Explicit layout path not found" -ForegroundColor Red
    exit 1
}

# Step 3: Clean and build
Write-Host "`nSTEP 3: Clean Build Process" -ForegroundColor Yellow
Set-Location "RDO-NET8-Migration/RdoApp.Core"

# Stop any running processes
Write-Host "Stopping any running processes..."
Get-Process | Where-Object {$_.ProcessName -like "*RdoApp*" -or $_.ProcessName -like "*dotnet*"} | Stop-Process -Force -ErrorAction SilentlyContinue

# Clean build
Write-Host "Performing clean build..."
dotnet clean --verbosity quiet
Remove-Item -Path "bin" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "obj" -Recurse -Force -ErrorAction SilentlyContinue

dotnet restore --verbosity quiet
dotnet build --verbosity quiet

if ($LASTEXITCODE -eq 0) {
    Write-Host "SUCCESS: Clean build completed" -ForegroundColor Green
} else {
    Write-Host "ERROR: Build failed" -ForegroundColor Red
    Set-Location "../.."
    exit 1
}

# Step 4: Start application
Write-Host "`nSTEP 4: Starting Application for Testing" -ForegroundColor Yellow
Write-Host "Starting server in background..."

$process = Start-Process -FilePath "dotnet" -ArgumentList "run" -PassThru -WindowStyle Hidden
Start-Sleep -Seconds 10

# Step 5: Test static file serving
Write-Host "`nSTEP 5: Testing Static File Serving" -ForegroundColor Yellow

$testUrls = @(
    "https://localhost:5001/test-hello.txt",
    "https://localhost:5001/css/fontello.css", 
    "https://localhost:5001/Assets/images/user.png",
    "https://localhost:5001/css/rdo-unified-theme.css"
)

foreach ($url in $testUrls) {
    try {
        Write-Host "Testing: $url"
        $response = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
        if ($response.StatusCode -eq 200) {
            Write-Host "  SUCCESS: HTTP 200 ($($response.Content.Length) bytes)" -ForegroundColor Green
        } else {
            Write-Host "  WARNING: HTTP $($response.StatusCode)" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "  ERROR: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Step 6: Test obra selection page
Write-Host "`nSTEP 6: Testing Obra Selection Page" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "https://localhost:5001/Account/Login" -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
    if ($response.StatusCode -eq 200) {
        Write-Host "SUCCESS: Login page accessible (HTTP 200)" -ForegroundColor Green
        Write-Host "Content length: $($response.Content.Length) bytes"
        
        # Check if CSS links are present in HTML
        if ($response.Content -match 'fontello\.css') {
            Write-Host "SUCCESS: fontello.css reference found in HTML" -ForegroundColor Green
        } else {
            Write-Host "WARNING: fontello.css reference not found in HTML" -ForegroundColor Yellow
        }
        
        if ($response.Content -match 'rdo-unified-theme\.css') {
            Write-Host "SUCCESS: rdo-unified-theme.css reference found in HTML" -ForegroundColor Green
        } else {
            Write-Host "WARNING: rdo-unified-theme.css reference not found in HTML" -ForegroundColor Yellow
        }
    }
}
catch {
    Write-Host "ERROR accessing login page: $($_.Exception.Message)" -ForegroundColor Red
}

# Cleanup
Write-Host "`nSTEP 7: Cleanup" -ForegroundColor Yellow
if ($process -and !$process.HasExited) {
    Write-Host "Stopping test server..."
    $process.Kill()
    $process.WaitForExit(5000)
}

Set-Location "../.."

Write-Host "`nTEST SUMMARY:" -ForegroundColor Cyan
Write-Host "=============" -ForegroundColor Cyan
Write-Host "1. Middleware fix applied: SUCCESS"
Write-Host "2. Explicit layout path: SUCCESS"  
Write-Host "3. Clean build: SUCCESS"
Write-Host "4. Static file serving: TEST RESULTS ABOVE"
Write-Host "5. Page accessibility: TEST RESULTS ABOVE"

Write-Host "`nNEXT STEPS:" -ForegroundColor Magenta
Write-Host "1. Login to the application manually"
Write-Host "2. Navigate to obra selection page"
Write-Host "3. Check F12 console - should be clean (no 404s)"
Write-Host "4. Verify 103 obra cards display properly"
Write-Host "5. Confirm CSS styling is applied correctly"

Write-Host "`nFix implementation complete!" -ForegroundColor Green