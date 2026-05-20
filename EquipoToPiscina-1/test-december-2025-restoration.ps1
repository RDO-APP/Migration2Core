# TEST DECEMBER 2025 ESCOLHER RESTORATION
# Diagnostic test only - NO FIXES without permission

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "DECEMBER 2025 ESCOLHER RESTORATION TEST" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Navigate to project directory
Set-Location "RDO-NET8-Migration/RdoApp.Core"

Write-Host "1. CHECKING FILE RESTORATION..." -ForegroundColor Yellow
Write-Host ""

# Check if file was restored
$escolherPath = "Views/Obra/Escolher.cshtml"
$backupPath = "Views/Obra/Escolher.cshtml.jan20-backup"

if (Test-Path $escolherPath) {
    $content = Get-Content $escolherPath -Raw
    $lineCount = ($content -split "`n").Count
    
    Write-Host "✓ Escolher.cshtml exists" -ForegroundColor Green
    Write-Host "  Line count: $lineCount" -ForegroundColor Gray
    
    # Check for key features
    $hasBlueHeader = $content -match "top-nav"
    $hasFilters = $content -match "filtroUnidade"
    $hasJavaScript = $content -match "function escolherObra"
    $hasUserDisplay = $content -match "ViewBag.UsuarioNome"
    $hasFontello = $content -match "fontello"
    
    Write-Host ""
    Write-Host "FEATURE VERIFICATION:" -ForegroundColor Yellow
    Write-Host "  Blue Header: $(if($hasBlueHeader){'✓ PRESENT'}else{'✗ MISSING'})" -ForegroundColor $(if($hasBlueHeader){'Green'}else{'Red'})
    Write-Host "  Filter Inputs: $(if($hasFilters){'✓ PRESENT'}else{'✗ MISSING'})" -ForegroundColor $(if($hasFilters){'Green'}else{'Red'})
    Write-Host "  JavaScript: $(if($hasJavaScript){'✓ PRESENT'}else{'✗ MISSING'})" -ForegroundColor $(if($hasJavaScript){'Green'}else{'Red'})
    Write-Host "  User Display: $(if($hasUserDisplay){'✓ PRESENT'}else{'✗ MISSING'})" -ForegroundColor $(if($hasUserDisplay){'Green'}else{'Red'})
    Write-Host "  Fontello Icons: $(if($hasFontello){'✓ PRESENT'}else{'✗ MISSING'})" -ForegroundColor $(if($hasFontello){'Green'}else{'Red'})
} else {
    Write-Host "✗ Escolher.cshtml NOT FOUND" -ForegroundColor Red
}

Write-Host ""

if (Test-Path $backupPath) {
    Write-Host "✓ Backup created: $backupPath" -ForegroundColor Green
} else {
    Write-Host "✗ Backup NOT created" -ForegroundColor Red
}

Write-Host ""
Write-Host "2. COMPILATION CHECK..." -ForegroundColor Yellow
Write-Host ""

# Try to build
$buildOutput = dotnet build --no-restore 2>&1
$buildSuccess = $LASTEXITCODE -eq 0

if ($buildSuccess) {
    Write-Host "✓ BUILD SUCCESSFUL" -ForegroundColor Green
} else {
    Write-Host "✗ BUILD FAILED" -ForegroundColor Red
    Write-Host ""
    Write-Host "Build errors:" -ForegroundColor Red
    $buildOutput | Select-String "error" | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
}

Write-Host ""
Write-Host "3. STARTING APPLICATION..." -ForegroundColor Yellow
Write-Host ""

# Kill any existing processes
Get-Process -Name "RdoApp.Core" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2

# Start application in background
$process = Start-Process -FilePath "dotnet" -ArgumentList "run" -PassThru -NoNewWindow -RedirectStandardOutput "test-output.log" -RedirectStandardError "test-error.log"

Write-Host "Application starting (PID: $($process.Id))..." -ForegroundColor Gray
Write-Host "Waiting 10 seconds for startup..." -ForegroundColor Gray
Start-Sleep -Seconds 10

Write-Host ""
Write-Host "4. TESTING ENDPOINTS..." -ForegroundColor Yellow
Write-Host ""

# Test login page
try {
    $loginResponse = Invoke-WebRequest -Uri "https://localhost:5001/Account/Login" -UseBasicParsing -SkipCertificateCheck -TimeoutSec 5
    Write-Host "✓ Login page accessible (Status: $($loginResponse.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "✗ Login page failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "5. BROWSER TEST INSTRUCTIONS..." -ForegroundColor Yellow
Write-Host ""
Write-Host "MANUAL TESTING REQUIRED:" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Open browser to: https://localhost:5001" -ForegroundColor White
Write-Host "2. Login with valid credentials" -ForegroundColor White
Write-Host "3. Should redirect to Escolher page" -ForegroundColor White
Write-Host ""
Write-Host "VERIFY THESE FEATURES:" -ForegroundColor Cyan
Write-Host "  ✓ Blue header with 'rdo Piscinas' logo" -ForegroundColor White
Write-Host "  ✓ User name in top-right corner" -ForegroundColor White
Write-Host "  ✓ Filter inputs for 'Unidade escolar' and 'Município'" -ForegroundColor White
Write-Host "  ✓ White obra cards with helmet icons" -ForegroundColor White
Write-Host "  ✓ Progress bars with percentages" -ForegroundColor White
Write-Host "  ✓ Typing in filters hides/shows cards" -ForegroundColor White
Write-Host "  ✓ Clicking card navigates to task cards" -ForegroundColor White
Write-Host "  ✓ Legend section at bottom" -ForegroundColor White
Write-Host ""
Write-Host "PRESS F12 TO CHECK:" -ForegroundColor Cyan
Write-Host "  - Console for JavaScript errors" -ForegroundColor White
Write-Host "  - Network tab for 404 errors" -ForegroundColor White
Write-Host "  - Elements tab to inspect HTML structure" -ForegroundColor White
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "TEST SUMMARY" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "File Restored: $(if(Test-Path $escolherPath){'YES'}else{'NO'})" -ForegroundColor $(if(Test-Path $escolherPath){'Green'}else{'Red'})
Write-Host "Backup Created: $(if(Test-Path $backupPath){'YES'}else{'NO'})" -ForegroundColor $(if(Test-Path $backupPath){'Green'}else{'Red'})
Write-Host "Build Status: $(if($buildSuccess){'SUCCESS'}else{'FAILED'})" -ForegroundColor $(if($buildSuccess){'Green'}else{'Red'})
Write-Host "Application: RUNNING (PID: $($process.Id))" -ForegroundColor Green
Write-Host ""
Write-Host "NEXT STEPS:" -ForegroundColor Yellow
Write-Host "1. Test in browser manually" -ForegroundColor White
Write-Host "2. Report any issues found" -ForegroundColor White
Write-Host "3. NO FIXES will be applied without permission" -ForegroundColor Red
Write-Host ""
Write-Host "To stop application: Stop-Process -Id $($process.Id)" -ForegroundColor Gray
Write-Host ""
