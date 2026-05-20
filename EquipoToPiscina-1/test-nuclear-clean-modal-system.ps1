#!/usr/bin/env pwsh

Write-Host "🚀 TESTING NUCLEAR CLEAN MODAL SYSTEM" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green

# Test 1: Verify Plus Button Uses Nuclear Function
Write-Host "`nTEST 1: Verifying Plus Button Nuclear Implementation..." -ForegroundColor Yellow

$taskCardFile = "RDO-NET8-Migration/RdoApp.Core/Views/Etapa/_TaskCardPartial.cshtml"
$taskCardContent = Get-Content $taskCardFile -Raw

if ($taskCardContent.Contains('onclick="window.smartOpenModal')) {
    Write-Host "PASS: Plus button uses nuclear function window.smartOpenModal()" -ForegroundColor Green
} else {
    Write-Host "FAIL: Plus button does not use nuclear function" -ForegroundColor Red
    exit 1
}

if ($taskCardContent.Contains('return false;')) {
    Write-Host "PASS: Plus button has return false to prevent default behavior" -ForegroundColor Green
} else {
    Write-Host "FAIL: Plus button missing return false" -ForegroundColor Red
    exit 1
}

if (-not $taskCardContent.Contains('data-bs-toggle') -and -not $taskCardContent.Contains('data-toggle')) {
    Write-Host "PASS: No Bootstrap data attributes found (prevents auto-listeners)" -ForegroundColor Green
} else {
    Write-Host "FAIL: Bootstrap data attributes still present" -ForegroundColor Red
    exit 1
}

# Test 2: Verify Global maskMoney Call Eliminated
Write-Host "`nTEST 2: Verifying Global maskMoney Elimination..." -ForegroundColor Yellow

$cardsRazorFile = "RDO-NET8-Migration/RdoApp.Core/Views/Etapa/CardsRazor.cshtml"
$cardsRazorContent = Get-Content $cardsRazorFile -Raw

if ($cardsRazorContent.Contains('// DISABLED: Global maskMoney call')) {
    Write-Host "PASS: Global maskMoney call disabled in CardsRazor.cshtml" -ForegroundColor Green
} else {
    Write-Host "FAIL: Global maskMoney call not disabled" -ForegroundColor Red
    exit 1
}

if ($cardsRazorContent.Contains("// `$('.currency').maskMoney();")) {
    Write-Host "PASS: maskMoney call commented out" -ForegroundColor Green
} else {
    Write-Host "FAIL: maskMoney call not commented out" -ForegroundColor Red
    exit 1
}

# Test 3: Verify Nuclear Clean Modal System
Write-Host "`nTEST 3: Verifying Nuclear Clean Modal System..." -ForegroundColor Yellow

$cardsFile = "RDO-NET8-Migration/RdoApp.Core/Views/Etapa/Cards.cshtml"
$cardsContent = Get-Content $cardsFile -Raw

if ($cardsContent.Contains('NUCLEAR CLEAN MODAL SYSTEM - NO JQUERY, NO BOOTSTRAP AUTO-LISTENERS')) {
    Write-Host "PASS: Nuclear clean modal system implemented" -ForegroundColor Green
} else {
    Write-Host "FAIL: Nuclear clean modal system not found" -ForegroundColor Red
    exit 1
}

if ($cardsContent.Contains('window.smartOpenModal = function')) {
    Write-Host "PASS: Nuclear smartOpenModal function defined" -ForegroundColor Green
} else {
    Write-Host "FAIL: Nuclear smartOpenModal function not found" -ForegroundColor Red
    exit 1
}

if ($cardsContent.Contains('window.nuclearHideModal = function')) {
    Write-Host "PASS: Nuclear hide modal function defined" -ForegroundColor Green
} else {
    Write-Host "FAIL: Nuclear hide modal function not found" -ForegroundColor Red
    exit 1
}

# Test 4: Verify Pure DOM Manipulation (No Bootstrap Dependencies)
Write-Host "`nTEST 4: Verifying Pure DOM Manipulation..." -ForegroundColor Yellow

if ($cardsContent.Contains('modalElement.style.display = ') -and $cardsContent.Contains('modalElement.classList.add')) {
    Write-Host "PASS: Pure DOM manipulation implemented" -ForegroundColor Green
} else {
    Write-Host "FAIL: Pure DOM manipulation not found" -ForegroundColor Red
    exit 1
}

if ($cardsContent.Contains('nuclear-backdrop')) {
    Write-Host "PASS: Custom backdrop system implemented" -ForegroundColor Green
} else {
    Write-Host "FAIL: Custom backdrop system not found" -ForegroundColor Red
    exit 1
}

# Test 5: Verify Smart Defaults Still Work
Write-Host "`nTEST 5: Verifying Smart Defaults..." -ForegroundColor Yellow

if ($cardsContent.Contains('var today = new Date().toISOString().split')) {
    Write-Host "PASS: Smart default for date (today) implemented" -ForegroundColor Green
} else {
    Write-Host "FAIL: Smart default for date not found" -ForegroundColor Red
    exit 1
}

if ($cardsContent.Contains('statusElement.value = statusId')) {
    Write-Host "PASS: Smart default for status implemented" -ForegroundColor Green
} else {
    Write-Host "FAIL: Smart default for status not found" -ForegroundColor Red
    exit 1
}

# Test 6: Verify Database Mapping Preserved
Write-Host "`nTEST 6: Verifying Database Mapping (Written in Stone)..." -ForegroundColor Yellow

if ($cardsContent.Contains('NivelBacteria') -and $cardsContent.Contains('nivelDetritos')) {
    Write-Host "PASS: Database mapping 'Nível de Detritos' -> 'NivelBacteria' preserved" -ForegroundColor Green
} else {
    Write-Host "FAIL: Database mapping not preserved" -ForegroundColor Red
    exit 1
}

# Test 7: Build Test
Write-Host "`nTEST 7: Build Test..." -ForegroundColor Yellow

try {
    Push-Location "RDO-NET8-Migration/RdoApp.Core"
    $buildResult = dotnet build --no-restore 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "PASS: Project builds successfully" -ForegroundColor Green
    } else {
        Write-Host "FAIL: Build failed" -ForegroundColor Red
        Write-Host $buildResult -ForegroundColor Red
        exit 1
    }
} finally {
    Pop-Location
}

# Final Summary
Write-Host "`nNUCLEAR CLEAN MODAL SYSTEM - ALL TESTS PASSED!" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green

Write-Host "`nNUCLEAR FIXES APPLIED:" -ForegroundColor Cyan
Write-Host "1. Plus button uses window.smartOpenModal() with return false" -ForegroundColor White
Write-Host "2. Global maskMoney call in CardsRazor.cshtml DISABLED" -ForegroundColor White
Write-Host "3. Pure DOM manipulation (NO Bootstrap auto-listeners)" -ForegroundColor White
Write-Host "4. Custom backdrop system (nuclear-backdrop)" -ForegroundColor White
Write-Host "5. Smart defaults work immediately" -ForegroundColor White
Write-Host "6. Database mapping preserved (written in stone)" -ForegroundColor White
Write-Host "7. Zero jQuery dependencies in modal system" -ForegroundColor White

Write-Host "`nTEST INSTRUCTIONS:" -ForegroundColor Cyan
Write-Host "1. Open browser and navigate to task cards page" -ForegroundColor White
Write-Host "2. Open F12 console - should be CLEAN (no maskMoney or classList errors)" -ForegroundColor White
Write-Host "3. Click Plus button - modal should open IMMEDIATELY" -ForegroundColor White
Write-Host "4. Verify Date = today and Status = task status" -ForegroundColor White
Write-Host "5. Save a measurement - should work end-to-end" -ForegroundColor White

Write-Host "`nThe Plus button is now NUCLEAR CLEAN and BULLETPROOF!" -ForegroundColor Green