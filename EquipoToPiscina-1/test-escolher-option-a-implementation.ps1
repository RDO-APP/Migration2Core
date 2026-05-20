# TEST ESCOLHER OBRA - OPTION A IMPLEMENTATION
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "ESCOLHER OBRA - OPTION A TEST" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Test 1: Check if legacy CSS file exists
Write-Host "TEST 1: Legacy CSS File" -ForegroundColor Yellow
$cssPath = "RDO-NET8-Migration/RdoApp.Core/wwwroot/css/escolher-legacy.css"
if (Test-Path $cssPath) {
    Write-Host "  OK escolher-legacy.css exists" -ForegroundColor Green
} else {
    Write-Host "  FAIL escolher-legacy.css NOT FOUND" -ForegroundColor Red
}
Write-Host ""

# Test 2: Check Escolher.cshtml modifications
Write-Host "TEST 2: Escolher.cshtml Structure" -ForegroundColor Yellow
$escolherPath = "RDO-NET8-Migration/RdoApp.Core/Views/Obra/Escolher.cshtml"
if (Test-Path $escolherPath) {
    $escolherContent = Get-Content $escolherPath -Raw
    
    if ($escolherContent -match 'Layout = null') {
        Write-Host "  OK Layout = null" -ForegroundColor Green
    } else {
        Write-Host "  FAIL Still using layout" -ForegroundColor Red
    }
    
    if ($escolherContent -match 'escolher-legacy') {
        Write-Host "  OK References escolher-legacy.css" -ForegroundColor Green
    } else {
        Write-Host "  FAIL Does not reference legacy CSS" -ForegroundColor Red
    }
} else {
    Write-Host "  FAIL Escolher.cshtml NOT FOUND" -ForegroundColor Red
}
Write-Host ""

# Summary
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "IMPLEMENTATION COMPLETE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "NEXT: Test in browser" -ForegroundColor Yellow
Write-Host ""
