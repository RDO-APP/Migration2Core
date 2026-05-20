# ESCOLHER OBRA - REQUEST FLOW DIAGNOSTIC
# This script will help diagnose why the page is blank

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "ESCOLHER OBRA - REQUEST FLOW DIAGNOSTIC" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "CRITICAL FINDING FROM CODE REVIEW:" -ForegroundColor Yellow
Write-Host "- Backend logs show: 'Filtered to 103 obras'" -ForegroundColor Green
Write-Host "- Nuclear test logs NOT appearing in backend" -ForegroundColor Red
Write-Host "- This means: Request is NOT reaching ObraController.EscolherNuclear" -ForegroundColor Red
Write-Host ""

Write-Host "HYPOTHESIS:" -ForegroundColor Yellow
Write-Host "Browser is being redirected BEFORE reaching the controller action" -ForegroundColor Yellow
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "DIAGNOSTIC STEPS TO PERFORM:" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "STEP 1: Check Browser Network Tab" -ForegroundColor Green
Write-Host "--------------------------------------" -ForegroundColor Gray
Write-Host "1. Open browser (Chrome/Edge)" -ForegroundColor White
Write-Host "2. Press F12 to open DevTools" -ForegroundColor White
Write-Host "3. Go to Network tab" -ForegroundColor White
Write-Host "4. Navigate to: https://localhost:7201/Obra/EscolherNuclear" -ForegroundColor White
Write-Host "5. Look for:" -ForegroundColor White
Write-Host "   - Initial request to /Obra/EscolherNuclear" -ForegroundColor Cyan
Write-Host "   - Status code (200, 302, 404, 500?)" -ForegroundColor Cyan
Write-Host "   - Any redirects (302 status)" -ForegroundColor Cyan
Write-Host "   - Response content (HTML, empty, error?)" -ForegroundColor Cyan
Write-Host ""

Write-Host "STEP 2: View Page Source" -ForegroundColor Green
Write-Host "--------------------------------------" -ForegroundColor Gray
Write-Host "1. While on blank page, press Ctrl+U" -ForegroundColor White
Write-Host "2. Check if ANY HTML is present" -ForegroundColor White
Write-Host "3. Look for:" -ForegroundColor White
Write-Host "   - Yellow background styles" -ForegroundColor Cyan
Write-Host "   - 'NUCLEAR TEST' text" -ForegroundColor Cyan
Write-Host "   - Empty page (just <html></html>)" -ForegroundColor Cyan
Write-Host ""

Write-Host "STEP 3: Check Backend Logs" -ForegroundColor Green
Write-Host "--------------------------------------" -ForegroundColor Gray
Write-Host "1. Look for these log entries:" -ForegroundColor White
Write-Host "   - '=== NUCLEAR TEST ==='" -ForegroundColor Cyan
Write-Host "   - 'NUCLEAR TEST: Got X obras'" -ForegroundColor Cyan
Write-Host "2. If NOT present:" -ForegroundColor White
Write-Host "   - Request never reached controller" -ForegroundColor Red
Write-Host "   - Middleware or routing is blocking" -ForegroundColor Red
Write-Host "3. If present:" -ForegroundColor White
Write-Host "   - Controller executed successfully" -ForegroundColor Green
Write-Host "   - Problem is in view rendering or browser" -ForegroundColor Yellow
Write-Host ""

Write-Host "STEP 4: Test Direct URL Navigation" -ForegroundColor Green
Write-Host "--------------------------------------" -ForegroundColor Gray
Write-Host "1. Login first: https://localhost:7201/Account/Login" -ForegroundColor White
Write-Host "2. After login, IMMEDIATELY type in address bar:" -ForegroundColor White
Write-Host "   https://localhost:7201/Obra/EscolherNuclear" -ForegroundColor Cyan
Write-Host "3. Press Enter" -ForegroundColor White
Write-Host "4. Observe:" -ForegroundColor White
Write-Host "   - Does URL change? (redirect?)" -ForegroundColor Cyan
Write-Host "   - Does page stay blank?" -ForegroundColor Cyan
Write-Host "   - Any flash of content before blank?" -ForegroundColor Cyan
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "EXPECTED RESULTS:" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "SCENARIO A: Nuclear Test Works (Yellow Page)" -ForegroundColor Green
Write-Host "--------------------------------------" -ForegroundColor Gray
Write-Host "- Network tab shows: 200 OK for /Obra/EscolherNuclear" -ForegroundColor White
Write-Host "- Page source shows: Yellow background HTML" -ForegroundColor White
Write-Host "- Backend logs show: '=== NUCLEAR TEST ==='" -ForegroundColor White
Write-Host "- DIAGNOSIS: Regular Escolher.cshtml has CSS/JS issue" -ForegroundColor Yellow
Write-Host ""

Write-Host "SCENARIO B: Nuclear Test Blank (No Yellow)" -ForegroundColor Red
Write-Host "--------------------------------------" -ForegroundColor Gray
Write-Host "- Network tab shows: 302 redirect OR 200 with empty body" -ForegroundColor White
Write-Host "- Page source shows: Empty or minimal HTML" -ForegroundColor White
Write-Host "- Backend logs show: NO '=== NUCLEAR TEST ===' entry" -ForegroundColor White
Write-Host "- DIAGNOSIS: Request not reaching controller" -ForegroundColor Red
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "POSSIBLE ROOT CAUSES:" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "1. AUTHENTICATION REDIRECT LOOP" -ForegroundColor Yellow
Write-Host "   - Middleware redirects to login" -ForegroundColor Gray
Write-Host "   - Login redirects to Escolher" -ForegroundColor Gray
Write-Host "   - Escolher redirects to login" -ForegroundColor Gray
Write-Host "   - Result: Blank page" -ForegroundColor Gray
Write-Host ""

Write-Host "2. MIDDLEWARE BLOCKING REQUEST" -ForegroundColor Yellow
Write-Host "   - Custom middleware intercepts /Obra/ routes" -ForegroundColor Gray
Write-Host "   - Returns empty response" -ForegroundColor Gray
Write-Host "   - Controller never executes" -ForegroundColor Gray
Write-Host ""

Write-Host "3. ROUTING CONFLICT" -ForegroundColor Yellow
Write-Host "   - Route matches different controller/action" -ForegroundColor Gray
Write-Host "   - Wrong action executes (returns empty)" -ForegroundColor Gray
Write-Host "   - Logs show different action name" -ForegroundColor Gray
Write-Host ""

Write-Host "4. SESSION/COOKIE ISSUE" -ForegroundColor Yellow
Write-Host "   - Session expired between login and navigation" -ForegroundColor Gray
Write-Host "   - Cookie not being sent" -ForegroundColor Gray
Write-Host "   - Authentication fails silently" -ForegroundColor Gray
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "NEXT ACTIONS:" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "1. Run the diagnostic steps above" -ForegroundColor White
Write-Host "2. Report findings:" -ForegroundColor White
Write-Host "   - Does yellow page appear? YES/NO" -ForegroundColor Cyan
Write-Host "   - What's in Network tab? (status codes, redirects)" -ForegroundColor Cyan
Write-Host "   - What's in page source? (HTML or empty)" -ForegroundColor Cyan
Write-Host "   - What's in backend logs? (nuclear test entry?)" -ForegroundColor Cyan
Write-Host ""

Write-Host "3. Based on findings, we'll:" -ForegroundColor White
Write-Host "   - Fix authentication redirect loop" -ForegroundColor Cyan
Write-Host "   - Fix middleware blocking" -ForegroundColor Cyan
Write-Host "   - Fix routing conflict" -ForegroundColor Cyan
Write-Host "   - Fix session/cookie issue" -ForegroundColor Cyan
Write-Host ""

Write-Host "========================================" -ForegroundColor Green
Write-Host "READY TO DIAGNOSE!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Follow the steps above and report what you see." -ForegroundColor Yellow
Write-Host ""
