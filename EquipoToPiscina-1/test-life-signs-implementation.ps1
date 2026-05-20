# TEST LIFE SIGNS IMPLEMENTATION
# Tests Phase 1 (DNA Cleaning) + Phase 2 (Life Signs Logging)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "LIFE SIGNS IMPLEMENTATION TEST" -ForegroundColor Cyan
Write-Host "Phase 1: DNA Cleaning Complete" -ForegroundColor Cyan
Write-Host "Phase 2: Life Signs Logging Active" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Verify DNA Cleaning
Write-Host "STEP 1: Verifying DNA Cleaning..." -ForegroundColor Yellow
Write-Host ""

$layoutFile = "RDO-NET8-Migration/RdoApp.Core/Views/Shared/_LayoutSelection.cshtml"
$content = Get-Content $layoutFile -Raw

if ($content -match "rdo-login\.css") {
    Write-Host "FAILED: rdo-login.css still present in layout" -ForegroundColor Red
} else {
    Write-Host "PASS: rdo-login.css removed from layout" -ForegroundColor Green
}

if ($content -match "rdo-login\.js") {
    Write-Host "FAILED: rdo-login.js still present in layout" -ForegroundColor Red
} else {
    Write-Host "PASS: rdo-login.js removed from layout" -ForegroundColor Green
}

Write-Host ""

# Step 2: Verify Life Signs Implementation
Write-Host "STEP 2: Verifying Life Signs Implementation..." -ForegroundColor Yellow
Write-Host ""

if ($content -match "LIFE SIGN 4") {
    Write-Host "PASS: Life Sign 4 (Client-Side HTML Check) implemented" -ForegroundColor Green
} else {
    Write-Host "FAILED: Life Sign 4 not found" -ForegroundColor Red
}

if ($content -match "LIFE SIGN 5") {
    Write-Host "PASS: Life Sign 5 (Blazor Circuit Check) implemented" -ForegroundColor Green
} else {
    Write-Host "FAILED: Life Sign 5 not found" -ForegroundColor Red
}

$componentFile = "RDO-NET8-Migration/RdoApp.Core/Components/RdoObraCards.razor"
$componentContent = Get-Content $componentFile -Raw

if ($componentContent -match "LIFE SIGN 1") {
    Write-Host "PASS: Life Sign 1 (Component Activation) implemented" -ForegroundColor Green
} else {
    Write-Host "FAILED: Life Sign 1 not found" -ForegroundColor Red
}

if ($componentContent -match "LIFE SIGN 2") {
    Write-Host "PASS: Life Sign 2 (Filtering Process) implemented" -ForegroundColor Green
} else {
    Write-Host "FAILED: Life Sign 2 not found" -ForegroundColor Red
}

if ($componentContent -match "LIFE SIGN 3") {
    Write-Host "PASS: Life Sign 3 (Rendering Trigger) implemented" -ForegroundColor Green
} else {
    Write-Host "FAILED: Life Sign 3 not found" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "NEXT STEPS: MANUAL TESTING REQUIRED" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "1. Start application in Visual Studio (F5)" -ForegroundColor White
Write-Host "2. Login as Ricardo Freire:" -ForegroundColor White
Write-Host "   CPF: 567.065.455-20" -ForegroundColor Yellow
Write-Host "   Password: 123456" -ForegroundColor Yellow
Write-Host ""
Write-Host "3. CHECK VISUAL STUDIO OUTPUT WINDOW:" -ForegroundColor White
Write-Host "   Look for server-side logs" -ForegroundColor White
Write-Host ""
Write-Host "4. OPEN F12 CONSOLE IN BROWSER:" -ForegroundColor White
Write-Host "   Look for client-side logs" -ForegroundColor White
Write-Host ""
Write-Host "5. ANALYZE RESULTS USING DIAGNOSTIC MATRIX" -ForegroundColor White
Write-Host "   See EXECUTION-PLAN document Section 3.5" -ForegroundColor Yellow
Write-Host ""
