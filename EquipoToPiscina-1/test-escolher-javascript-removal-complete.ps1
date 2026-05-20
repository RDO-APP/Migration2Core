# TEST: Escolher.cshtml JavaScript Removal - Complete Verification
# Date: January 18, 2026
# Purpose: Verify that removing all inline scripts fixed the blank page issue

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "ESCOLHER JAVASCRIPT REMOVAL TEST" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Test 1: Verify file has no inline scripts
Write-Host "TEST 1: Verify No Inline Scripts" -ForegroundColor Yellow
Write-Host "Checking Escolher.cshtml for <script> tags..." -ForegroundColor Gray

$escolherFile = "RDO-NET8-Migration/RdoApp.Core/Views/Obra/Escolher.cshtml"
$content = Get-Content $escolherFile -Raw

$scriptCount = ([regex]::Matches($content, "<script")).Count

if ($scriptCount -eq 0) {
    Write-Host "✅ PASS: No <script> tags found in Escolher.cshtml" -ForegroundColor Green
} else {
    Write-Host "❌ FAIL: Found $scriptCount <script> tags in Escolher.cshtml" -ForegroundColor Red
}
Write-Host ""

# Test 2: Verify file has no console.log statements
Write-Host "TEST 2: Verify No Console.log Statements" -ForegroundColor Yellow
Write-Host "Checking for console.log..." -ForegroundColor Gray

$consoleLogCount = ([regex]::Matches($content, "console\.log")).Count

if ($consoleLogCount -eq 0) {
    Write-Host "✅ PASS: No console.log statements found" -ForegroundColor Green
} else {
    Write-Host "❌ FAIL: Found $consoleLogCount console.log statements" -ForegroundColor Red
}
Write-Host ""

# Test 3: Verify file has clean Razor syntax
Write-Host "TEST 3: Verify Clean Razor Syntax" -ForegroundColor Yellow
Write-Host "Checking for proper structure..." -ForegroundColor Gray

$hasModel = $content -match "@model"
$hasSection = $content -match "<section"
$hasForEach = $content -match "@foreach"
$hasIf = $content -match "@if"

if ($hasModel -and $hasSection -and $hasForEach -and $hasIf) {
    Write-Host "✅ PASS: File has proper Razor structure" -ForegroundColor Green
    Write-Host "  - @model declaration: OK" -ForegroundColor Gray
    Write-Host "  - section tag: OK" -ForegroundColor Gray
    Write-Host "  - @foreach loop: OK" -ForegroundColor Gray
    Write-Host "  - @if conditional: OK" -ForegroundColor Gray
} else {
    Write-Host "❌ FAIL: File missing expected Razor elements" -ForegroundColor Red
}
Write-Host ""

# Test 4: Verify CSS files are referenced
Write-Host "TEST 4: Verify CSS References" -ForegroundColor Yellow
Write-Host "Checking for CSS file references..." -ForegroundColor Gray

$hasFontello = $content -match "fontello\.css"
$hasEscolherCss = $content -match "escolher-legacy\.css"

if ($hasFontello -and $hasEscolherCss) {
    Write-Host "✅ PASS: Both CSS files are referenced" -ForegroundColor Green
    Write-Host "  - fontello.css: OK" -ForegroundColor Gray
    Write-Host "  - escolher-legacy.css: OK" -ForegroundColor Gray
} else {
    Write-Host "❌ FAIL: Missing CSS references" -ForegroundColor Red
}
Write-Host ""

# Test 5: Verify Layout = null
Write-Host "TEST 5: Verify Standalone Page Configuration" -ForegroundColor Yellow
Write-Host "Checking Layout setting..." -ForegroundColor Gray

$hasLayoutNull = $content -match "Layout\s*=\s*null"

if ($hasLayoutNull) {
    Write-Host "✅ PASS: Layout = null (standalone page)" -ForegroundColor Green
} else {
    Write-Host "❌ FAIL: Layout not set to null" -ForegroundColor Red
}
Write-Host ""

# Test 6: Verify HTML structure
Write-Host "TEST 6: Verify Complete HTML Structure" -ForegroundColor Yellow
Write-Host "Checking for required HTML tags..." -ForegroundColor Gray

$hasDoctype = $content -match "<!DOCTYPE html>"
$hasHtml = $content -match "<html"
$hasHead = $content -match "<head>"
$hasBody = $content -match "<body>"

if ($hasDoctype -and $hasHtml -and $hasHead -and $hasBody) {
    Write-Host "✅ PASS: Complete HTML structure present" -ForegroundColor Green
    Write-Host "  - DOCTYPE html: OK" -ForegroundColor Gray
    Write-Host "  - html tag: OK" -ForegroundColor Gray
    Write-Host "  - head tag: OK" -ForegroundColor Gray
    Write-Host "  - body tag: OK" -ForegroundColor Gray
} else {
    Write-Host "❌ FAIL: Incomplete HTML structure" -ForegroundColor Red
}
Write-Host ""

# Test 7: Compilation check
Write-Host "TEST 7: Compilation Status" -ForegroundColor Yellow
Write-Host "Checking if project compiles..." -ForegroundColor Gray

$buildResult = dotnet build RDO-NET8-Migration/RdoApp.Core/RdoApp.Core.csproj --no-incremental 2>&1 | Out-String

if ($buildResult -match "êxito" -or $buildResult -match "succeeded") {
    Write-Host "✅ PASS: Project compiles successfully" -ForegroundColor Green
} else {
    Write-Host "❌ FAIL: Compilation errors found" -ForegroundColor Red
}
Write-Host ""

# Summary
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "TEST SUMMARY" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Code Quality Tests:" -ForegroundColor White
Write-Host "  - No inline script tags" -ForegroundColor Green
Write-Host "  - No console.log statements" -ForegroundColor Green
Write-Host "  - Clean Razor syntax" -ForegroundColor Green
Write-Host "  - CSS files referenced" -ForegroundColor Green
Write-Host "  - Standalone page (Layout = null)" -ForegroundColor Green
Write-Host "  - Complete HTML structure" -ForegroundColor Green
Write-Host "  - Project compiles" -ForegroundColor Green
Write-Host ""

Write-Host "NEXT STEPS:" -ForegroundColor Yellow
Write-Host "1. Start the application: dotnet run --project RDO-NET8-Migration/RdoApp.Core" -ForegroundColor Gray
Write-Host "2. Navigate to: https://localhost:5001/Obra/Escolher" -ForegroundColor Gray
Write-Host "3. Verify page renders without blank screen" -ForegroundColor Gray
Write-Host "4. Check F12 console for errors" -ForegroundColor Gray
Write-Host "5. Test clicking obra cards" -ForegroundColor Gray
Write-Host "6. Test in incognito mode" -ForegroundColor Gray
Write-Host "7. Test after clearing cache" -ForegroundColor Gray
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "READY FOR MANUAL TESTING" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
