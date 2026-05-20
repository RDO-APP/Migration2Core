# SIMPLE TEST: Check if Escolher page renders anything
# User reports: Blank page, F12 Console empty

Write-Host "=== ESCOLHER SIMPLE FIX TEST ===" -ForegroundColor Cyan
Write-Host ""

Write-Host "STEP 1: Check if application is running" -ForegroundColor Yellow
Write-Host "  Run this in Visual Studio (F5)" -ForegroundColor Gray
Write-Host ""

Write-Host "STEP 2: After login, navigate to:" -ForegroundColor Yellow
Write-Host "  https://localhost:7201/Obra/Escolher" -ForegroundColor Cyan
Write-Host ""

Write-Host "STEP 3: Press Ctrl+U (View Source)" -ForegroundColor Yellow
Write-Host "  Check if you see:" -ForegroundColor Gray
Write-Host "    - <!DOCTYPE html>" -ForegroundColor Gray
Write-Host "    - <body class='escolher-body'>" -ForegroundColor Gray
Write-Host "    - <div class='lista-obras'>" -ForegroundColor Gray
Write-Host ""

Write-Host "STEP 4: Press F12 (Developer Tools)" -ForegroundColor Yellow
Write-Host "  Check Console tab:" -ForegroundColor Gray
Write-Host "    - Any errors?" -ForegroundColor Gray
Write-Host "  Check Network tab:" -ForegroundColor Gray
Write-Host "    - Is escolher-legacy.css loading? (200 OK)" -ForegroundColor Gray
Write-Host "    - Any 404 errors?" -ForegroundColor Gray
Write-Host ""

Write-Host "STEP 5: Check Elements tab" -ForegroundColor Yellow
Write-Host "  Look for:" -ForegroundColor Gray
Write-Host "    - <section class='escolher-obra-section'>" -ForegroundColor Gray
Write-Host "    - <div class='lista-obras'>" -ForegroundColor Gray
Write-Host "    - <div class='item'> (should have 103 of these)" -ForegroundColor Gray
Write-Host ""

Write-Host "=== EXPECTED RESULTS ===" -ForegroundColor Cyan
Write-Host "  IF View Source shows HTML:" -ForegroundColor Yellow
Write-Host "    → HTML is rendering, CSS issue" -ForegroundColor Gray
Write-Host "    → Check Network tab for CSS 404" -ForegroundColor Gray
Write-Host ""
Write-Host "  IF View Source is empty:" -ForegroundColor Yellow
Write-Host "    → View not rendering at all" -ForegroundColor Gray
Write-Host "    → Check controller logs" -ForegroundColor Gray
Write-Host "    → Check for Razor syntax errors" -ForegroundColor Gray
Write-Host ""
Write-Host "  IF Elements tab shows content but invisible:" -ForegroundColor Yellow
Write-Host "    → CSS loaded but styles wrong" -ForegroundColor Gray
Write-Host "    → Check CSS selectors" -ForegroundColor Gray
Write-Host ""

Write-Host "=== REPORT BACK ===" -ForegroundColor Cyan
Write-Host "Please tell me:" -ForegroundColor Yellow
Write-Host "  1. What does View Source (Ctrl+U) show?" -ForegroundColor Gray
Write-Host "  2. What does F12 Console show?" -ForegroundColor Gray
Write-Host "  3. What does F12 Network tab show?" -ForegroundColor Gray
Write-Host "  4. What does F12 Elements tab show?" -ForegroundColor Gray
Write-Host ""
