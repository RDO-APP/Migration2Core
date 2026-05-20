# TEST ESCOLHER OBRA - BOTH FIXES
# Tests: 1) Yellow debug box removed, 2) Cards layout fixed (5 per row)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "ESCOLHER OBRA - TESTING BOTH FIXES" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Test 1: Check if debug code is removed from Escolher.cshtml
Write-Host "TEST 1: Checking for debug code in Escolher.cshtml..." -ForegroundColor Yellow
$escolherPath = "RDO-NET8-Migration/RdoApp.Core/Views/Obra/Escolher.cshtml"
$escolherContent = Get-Content $escolherPath -Raw

if ($escolherContent -match "DEBUG|debug|Model count|View rendering") {
    Write-Host "  ❌ FAIL: Debug code still present!" -ForegroundColor Red
} else {
    Write-Host "  ✅ PASS: No debug code found" -ForegroundColor Green
}

# Test 2: Check if CSS has correct flex value for 5 cards per row
Write-Host ""
Write-Host "TEST 2: Checking CSS for 5 cards per row..." -ForegroundColor Yellow
$cssPath = "RDO-NET8-Migration/RdoApp.Core/wwwroot/css/escolher-legacy.css"
$cssContent = Get-Content $cssPath -Raw

if ($cssContent -match "flex:\s*0\s*0\s*calc\(20%\s*-\s*20px\)") {
    Write-Host "  ✅ PASS: CSS configured for 5 cards per row" -ForegroundColor Green
} else {
    Write-Host "  ❌ FAIL: CSS not configured correctly" -ForegroundColor Red
}

# Test 3: Check if old flex-basis: 100% is removed
Write-Host ""
Write-Host "TEST 3: Checking if old flex-basis: 100% is removed..." -ForegroundColor Yellow

if ($cssContent -match "flex-basis:\s*100%") {
    Write-Host "  ❌ FAIL: Old flex-basis: 100% still present!" -ForegroundColor Red
} else {
    Write-Host "  ✅ PASS: Old flex-basis removed" -ForegroundColor Green
}

# Test 4: Verify header component exists
Write-Host ""
Write-Host "TEST 4: Checking header component..." -ForegroundColor Yellow
$headerPath = "RDO-NET8-Migration/RdoApp.Core/Components/UnifiedRdoHeader.razor"

if (Test-Path $headerPath) {
    Write-Host "  ✅ PASS: Header component exists" -ForegroundColor Green
    
    $headerContent = Get-Content $headerPath -Raw
    if ($headerContent -match "string\.IsNullOrEmpty\(ObraNome\)") {
        Write-Host "  ✅ PASS: Header has conditional logic for ESCOLHER mode" -ForegroundColor Green
    } else {
        Write-Host "  ❌ FAIL: Header missing conditional logic" -ForegroundColor Red
    }
} else {
    Write-Host "  ❌ FAIL: Header component not found!" -ForegroundColor Red
}

# Summary
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "SUMMARY" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Files Modified:" -ForegroundColor White
Write-Host "  1. Escolher.cshtml - Rewritten (no debug code)" -ForegroundColor Gray
Write-Host "  2. escolher-legacy.css - Fixed (5 cards per row)" -ForegroundColor Gray
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor White
Write-Host "  1. Run the application" -ForegroundColor Gray
Write-Host "  2. Navigate to /Obra/Escolher" -ForegroundColor Gray
Write-Host "  3. Verify NO yellow debug box" -ForegroundColor Gray
Write-Host "  4. Verify 5 cards per row" -ForegroundColor Gray
Write-Host ""
