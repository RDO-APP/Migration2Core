# Diagnose White Screen on Escolher Obra Page
# Step-by-step forensic analysis

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "WHITE SCREEN FORENSIC ANALYSIS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "SYMPTOM: Ricardo authenticated, 103 obras found, but WHITE SCREEN" -ForegroundColor Yellow
Write-Host ""

# Test 1: Check Escolher.cshtml layout
Write-Host "TEST 1: Verify Escolher.cshtml uses _LayoutSelection..." -ForegroundColor Yellow
$escolherPath = "RDO-NET8-Migration/RdoApp.Core/Views/Obra/Escolher.cshtml"
$escolherContent = Get-Content $escolherPath -Raw
if ($escolherContent -match 'Layout = "~/Views/Shared/_LayoutSelection.cshtml"') {
    Write-Host "  ✅ PASS: Escolher uses _LayoutSelection.cshtml" -ForegroundColor Green
} else {
    Write-Host "  ❌ FAIL: Escolher NOT using _LayoutSelection.cshtml" -ForegroundColor Red
}

# Test 2: Check _LayoutSelection has Blazor script
Write-Host "TEST 2: Verify _LayoutSelection has Blazor Server script..." -ForegroundColor Yellow
$layoutSelectionPath = "RDO-NET8-Migration/RdoApp.Core/Views/Shared/_LayoutSelection.cshtml"
$layoutSelectionContent = Get-Content $layoutSelectionPath -Raw
if ($layoutSelectionContent -match 'blazor\.server\.js') {
    Write-Host "  ✅ PASS: Blazor Server script present" -ForegroundColor Green
} else {
    Write-Host "  ❌ FAIL: Blazor Server script MISSING" -ForegroundColor Red
}

# Test 3: Check for legacy script references
Write-Host "TEST 3: Check for legacy script references in _LayoutSelection..." -ForegroundColor Yellow
$hasJQuery = $layoutSelectionContent -match 'jquery'
$hasBootstrap = $layoutSelectionContent -match 'bootstrap'
$hasDatepicker = $layoutSelectionContent -match 'datepicker'
$hasMaskMoney = $layoutSelectionContent -match 'maskMoney'

if ($hasJQuery -or $hasBootstrap -or $hasDatepicker -or $hasMaskMoney) {
    Write-Host "  ⚠️  WARNING: Legacy scripts found:" -ForegroundColor Yellow
    if ($hasJQuery) { Write-Host "    - jQuery" -ForegroundColor Yellow }
    if ($hasBootstrap) { Write-Host "    - Bootstrap" -ForegroundColor Yellow }
    if ($hasDatepicker) { Write-Host "    - Datepicker" -ForegroundColor Yellow }
    if ($hasMaskMoney) { Write-Host "    - MaskMoney" -ForegroundColor Yellow }
} else {
    Write-Host "  ✅ PASS: No legacy scripts found" -ForegroundColor Green
}

# Test 4: Check UnifiedRdoHeader has error handling
Write-Host "TEST 4: Verify UnifiedRdoHeader has error handling..." -ForegroundColor Yellow
$headerPath = "RDO-NET8-Migration/RdoApp.Core/Components/UnifiedRdoHeader.razor"
$headerContent = Get-Content $headerPath -Raw
if ($headerContent -match 'try.*catch.*Exception') {
    Write-Host "  ✅ PASS: UnifiedRdoHeader has error handling" -ForegroundColor Green
} else {
    Write-Host "  ❌ FAIL: UnifiedRdoHeader lacks error handling" -ForegroundColor Red
}

# Test 5: Check RdoObraCards has error handling
Write-Host "TEST 5: Verify RdoObraCards has error handling..." -ForegroundColor Yellow
$cardsPath = "RDO-NET8-Migration/RdoApp.Core/Components/RdoObraCards.razor"
$cardsContent = Get-Content $cardsPath -Raw
if ($cardsContent -match 'try.*catch.*Exception') {
    Write-Host "  ✅ PASS: RdoObraCards has error handling" -ForegroundColor Green
} else {
    Write-Host "  ❌ FAIL: RdoObraCards lacks error handling" -ForegroundColor Red
}

# Test 6: Check for base href
Write-Host "TEST 6: Verify base href in _LayoutSelection..." -ForegroundColor Yellow
if ($layoutSelectionContent -match '<base href="~/"') {
    Write-Host "  ✅ PASS: Base href present" -ForegroundColor Green
} else {
    Write-Host "  ❌ FAIL: Base href MISSING" -ForegroundColor Red
}

# Test 7: Check for fontello.css
Write-Host "TEST 7: Verify fontello.css reference..." -ForegroundColor Yellow
if ($layoutSelectionContent -match 'fontello\.css') {
    Write-Host "  ✅ PASS: Fontello CSS referenced" -ForegroundColor Green
} else {
    Write-Host "  ❌ FAIL: Fontello CSS MISSING" -ForegroundColor Red
}

# Test 8: Check if fontello.css exists
Write-Host "TEST 8: Verify fontello.css file exists..." -ForegroundColor Yellow
$fontelloPath = "RDO-NET8-Migration/RdoApp.Core/wwwroot/css/fontello.css"
if (Test-Path $fontelloPath) {
    Write-Host "  ✅ PASS: fontello.css file exists" -ForegroundColor Green
} else {
    Write-Host "  ❌ FAIL: fontello.css file MISSING" -ForegroundColor Red
}

# Test 9: Check rdoObraCards JavaScript function
Write-Host "TEST 9: Verify rdoObraCards JavaScript function..." -ForegroundColor Yellow
if ($layoutSelectionContent -match 'window\.rdoObraCards') {
    Write-Host "  ✅ PASS: rdoObraCards JavaScript function present" -ForegroundColor Green
} else {
    Write-Host "  ❌ FAIL: rdoObraCards JavaScript function MISSING" -ForegroundColor Red
}

# Test 10: Check component render mode
Write-Host "TEST 10: Verify component render mode..." -ForegroundColor Yellow
if ($escolherContent -match 'render-mode="ServerPrerendered"') {
    Write-Host "  ✅ PASS: ServerPrerendered mode used" -ForegroundColor Green
} else {
    Write-Host "  ❌ FAIL: ServerPrerendered mode NOT used" -ForegroundColor Red
}

# Test 11: Check for diagnostic divs
Write-Host "TEST 11: Verify diagnostic divs in Escolher.cshtml..." -ForegroundColor Yellow
if ($escolherContent -match 'clean-layout-diagnostic') {
    Write-Host "  ✅ PASS: Diagnostic divs present" -ForegroundColor Green
} else {
    Write-Host "  ❌ FAIL: Diagnostic divs MISSING" -ForegroundColor Red
}

# Test 12: Check ObraController Escolher action
Write-Host "TEST 12: Verify ObraController Escolher action..." -ForegroundColor Yellow
$controllerPath = "RDO-NET8-Migration/RdoApp.Core/Controllers/ObraController.cs"
$controllerContent = Get-Content $controllerPath -Raw
if ($controllerContent -match 'public async Task<IActionResult> Escolher\(\)') {
    Write-Host "  ✅ PASS: Escolher action exists" -ForegroundColor Green
} else {
    Write-Host "  ❌ FAIL: Escolher action MISSING" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "CRITICAL CHECKS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Critical Check 1: Script load order
Write-Host "CRITICAL 1: Script load order in _LayoutSelection..." -ForegroundColor Yellow
$scriptOrder = @()
if ($layoutSelectionContent -match 'blazor\.server\.js') { $scriptOrder += "blazor.server.js" }
if ($layoutSelectionContent -match 'rdo-login\.js') { $scriptOrder += "rdo-login.js" }
Write-Host "  Script order: $($scriptOrder -join ' -> ')" -ForegroundColor White
if ($scriptOrder[0] -eq "blazor.server.js") {
    Write-Host "  ✅ CORRECT: Blazor loads first" -ForegroundColor Green
} else {
    Write-Host "  ❌ WRONG: Blazor should load first" -ForegroundColor Red
}

# Critical Check 2: Compare layouts
Write-Host ""
Write-Host "CRITICAL 2: Compare _LayoutSelection vs _Layout..." -ForegroundColor Yellow
$layoutPath = "RDO-NET8-Migration/RdoApp.Core/Views/Shared/_Layout.cshtml"
$layoutContent = Get-Content $layoutPath -Raw

$selectionHasBlazor = $layoutSelectionContent -match 'blazor\.server\.js'
$layoutHasBlazor = $layoutContent -match 'blazor\.server\.js'

Write-Host "  _LayoutSelection has Blazor: $selectionHasBlazor" -ForegroundColor White
Write-Host "  _Layout has Blazor: $layoutHasBlazor" -ForegroundColor White

if ($selectionHasBlazor -and -not $layoutHasBlazor) {
    Write-Host "  ✅ CORRECT: Only _LayoutSelection has Blazor" -ForegroundColor Green
} else {
    Write-Host "  ⚠️  WARNING: Layout configuration may be incorrect" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "DIAGNOSIS SUMMARY" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "LIKELY CAUSES OF WHITE SCREEN:" -ForegroundColor Yellow
Write-Host "1. Blazor circuit connection failure" -ForegroundColor White
Write-Host "2. Component initialization error (check browser console)" -ForegroundColor White
Write-Host "3. Missing CSS file (fontello.css 404)" -ForegroundColor White
Write-Host "4. JavaScript error in rdoObraCards function" -ForegroundColor White
Write-Host ""
Write-Host "NEXT STEPS:" -ForegroundColor Yellow
Write-Host "1. Open browser F12 Console and check for errors" -ForegroundColor White
Write-Host "2. Check Network tab for 404 errors on CSS/JS files" -ForegroundColor White
Write-Host "3. Look for Blazor circuit connection errors" -ForegroundColor White
Write-Host "4. Check if UnifiedRdoHeader is crashing during initialization" -ForegroundColor White
Write-Host ""
Write-Host "MANUAL TEST:" -ForegroundColor Yellow
Write-Host "1. Login as Ricardo" -ForegroundColor White
Write-Host "2. Open F12 Developer Tools BEFORE clicking ACESSAR" -ForegroundColor White
Write-Host "3. Go to Console tab" -ForegroundColor White
Write-Host "4. Click ACESSAR and watch for errors" -ForegroundColor White
Write-Host "5. Look for red error messages" -ForegroundColor White
Write-Host ""
