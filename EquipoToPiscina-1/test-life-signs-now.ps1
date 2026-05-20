# TEST LIFE SIGNS - IMMEDIATE EXECUTION
# Date: January 17, 2026
# Purpose: Verify Life Signs are working in F12 Console

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "🔥 LIFE SIGNS TEST - EMERGENCY" -ForegroundColor Red
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "📋 INSTRUCTIONS:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. ✅ Life Signs have been added to Escolher.cshtml" -ForegroundColor Green
Write-Host "2. 🔄 Restart your application (Ctrl+C, then dotnet run)" -ForegroundColor Yellow
Write-Host "3. 🔐 Login with Ricardo:" -ForegroundColor Yellow
Write-Host "   - CPF: 567.065.455-20" -ForegroundColor White
Write-Host "   - Password: RXL8DjdYj6Y=" -ForegroundColor White
Write-Host "4. ⚡ IMMEDIATELY press F12 when page loads" -ForegroundColor Yellow
Write-Host "5. 📊 Go to Console tab" -ForegroundColor Yellow
Write-Host "6. 👀 Look for green circle emojis (🟢)" -ForegroundColor Yellow
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "🎯 WHAT TO LOOK FOR IN F12 CONSOLE:" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "SCENARIO A: All Life Signs Present" -ForegroundColor Green
Write-Host "-----------------------------------" -ForegroundColor Gray
Write-Host "🟢 LIFE SIGN 1: HTML HEAD LOADED" -ForegroundColor Green
Write-Host "🟢 LIFE SIGN 2: Escolher.cshtml is rendering" -ForegroundColor Green
Write-Host "🟢 LIFE SIGN 3: Model count = 103" -ForegroundColor Green
Write-Host "🟢 LIFE SIGN 4: BODY TAG OPENED" -ForegroundColor Green
Write-Host "🟢 LIFE SIGN 5: SECTION TAG OPENED" -ForegroundColor Green
Write-Host "🟢 LIFE SIGN 6: Model is null? false" -ForegroundColor Green
Write-Host "🟢 LIFE SIGN 7: Model.Any()? true" -ForegroundColor Green
Write-Host "🟢 LIFE SIGN 8: INSIDE IF BLOCK" -ForegroundColor Green
Write-Host "🟢 LIFE SIGN 9: LISTA-OBRAS DIV OPENED" -ForegroundColor Green
Write-Host "🟢 LIFE SIGN 10: Rendering obra ID 233 (repeats)" -ForegroundColor Green
Write-Host "🟢 LIFE SIGN 12: SECTION CLOSING" -ForegroundColor Green
Write-Host "🟢 LIFE SIGN 13: BODY CLOSING" -ForegroundColor Green
Write-Host "🎯 FINAL LIFE SIGN: Page fully rendered!" -ForegroundColor Green
Write-Host ""
Write-Host "→ DIAGNOSIS: CSS not loading (404 issue)" -ForegroundColor Yellow
Write-Host "→ FIX: Check static file middleware" -ForegroundColor Yellow
Write-Host ""

Write-Host "SCENARIO B: Life Signs Stop at #10" -ForegroundColor Yellow
Write-Host "-----------------------------------" -ForegroundColor Gray
Write-Host "🟢 LIFE SIGN 1-9: All present" -ForegroundColor Green
Write-Host "🟢 LIFE SIGN 10: Rendering obra ID 233" -ForegroundColor Green
Write-Host "❌ (STOPS HERE - no more logs)" -ForegroundColor Red
Write-Host ""
Write-Host "→ DIAGNOSIS: Razor crash in foreach loop" -ForegroundColor Yellow
Write-Host "→ FIX: Simplify obra card HTML" -ForegroundColor Yellow
Write-Host ""

Write-Host "SCENARIO C: Life Signs Stop at #3" -ForegroundColor Yellow
Write-Host "-----------------------------------" -ForegroundColor Gray
Write-Host "🟢 LIFE SIGN 1: HTML HEAD LOADED" -ForegroundColor Green
Write-Host "🟢 LIFE SIGN 2: Escolher.cshtml is rendering" -ForegroundColor Green
Write-Host "❌ (STOPS HERE - no more logs)" -ForegroundColor Red
Write-Host ""
Write-Host "→ DIAGNOSIS: Model.Count() crash" -ForegroundColor Yellow
Write-Host "→ FIX: Remove Model.Count() from Life Sign 3" -ForegroundColor Yellow
Write-Host ""

Write-Host "SCENARIO D: NO Life Signs" -ForegroundColor Red
Write-Host "-----------------------------------" -ForegroundColor Gray
Write-Host "❌ F12 Console is completely EMPTY" -ForegroundColor Red
Write-Host "❌ No logs at all" -ForegroundColor Red
Write-Host ""
Write-Host "→ DIAGNOSIS: View not rendering at all" -ForegroundColor Yellow
Write-Host "→ FIX: Check middleware/controller" -ForegroundColor Yellow
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "📝 REPORT BACK TO KIRO:" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Copy and paste the F12 Console output here:" -ForegroundColor Yellow
Write-Host ""
Write-Host "Example:" -ForegroundColor Gray
Write-Host "  'I see Life Signs 1-13, all green circles'" -ForegroundColor Gray
Write-Host "  'I see Life Signs 1-9, then it stops'" -ForegroundColor Gray
Write-Host "  'I see Life Signs 1-2, then nothing'" -ForegroundColor Gray
Write-Host "  'F12 Console is completely empty'" -ForegroundColor Gray
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "🚀 READY TO TEST!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Press any key to open browser..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# Open browser
Start-Process "https://localhost:7201/Account/Login"

Write-Host ""
Write-Host "✅ Browser opened!" -ForegroundColor Green
Write-Host "⏳ Waiting for your Life Signs report..." -ForegroundColor Yellow
Write-Host ""
