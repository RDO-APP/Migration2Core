# Investigate Real Issue - No Auto-Selection
# This script helps investigate why etapas/tarefas shows "Nenhum registro encontrado" instead of redirecting to obra selection

Write-Host "=== INVESTIGATING REAL ETAPAS/TAREFAS ISSUE ===" -ForegroundColor Yellow
Write-Host ""

Write-Host "IMPORTANT: Auto-selection has been REMOVED" -ForegroundColor Red
Write-Host "The system correctly requires manual obra selection" -ForegroundColor Green
Write-Host ""

Write-Host "REAL ISSUE TO INVESTIGATE:" -ForegroundColor Cyan
Write-Host "- User logs in successfully"
Write-Host "- User navigates to etapas/tarefas page"
Write-Host "- Page shows 'Nenhum registro encontrado'"
Write-Host "- BUT should redirect to /obra/escolher if no obra selected"
Write-Host ""

Write-Host "TESTING STEPS:" -ForegroundColor Magenta
Write-Host ""

Write-Host "1. LOGIN AND CHECK REDIRECT BEHAVIOR:" -ForegroundColor Yellow
Write-Host "   - Login with CPF: 567.065.455-20 / Password: 1234"
Write-Host "   - Open browser F12 Developer Tools"
Write-Host "   - Go to Network tab"
Write-Host "   - Navigate to: http://localhost:5051/tarefa/cards"
Write-Host "   - Check if there's a redirect to /obra/escolher"
Write-Host ""

Write-Host "2. MANUAL OBRA SELECTION TEST:" -ForegroundColor Yellow
Write-Host "   - Navigate directly to: http://localhost:5051/obra/escolher"
Write-Host "   - Verify you see list of obras"
Write-Host "   - Select any obra from the list"
Write-Host "   - Check if redirected to /tarefa/cards"
Write-Host "   - Verify etapas/tarefas load correctly"
Write-Host ""

Write-Host "3. CHECK AUTHENTICATION STATE:" -ForegroundColor Yellow
Write-Host "   - In browser console, type: Auth.getUser()"
Write-Host "   - Check if user object exists"
Write-Host "   - Check if user.obra is null/undefined"
Write-Host "   - Check if user.usuario.id exists"
Write-Host ""

Write-Host "POSSIBLE CAUSES:" -ForegroundColor Cyan
Write-Host ""
Write-Host "A. Redirect Logic Not Working:"
Write-Host "   - TarefaController redirect to /obra/escolher fails"
Write-Host "   - JavaScript error preventing redirect"
Write-Host "   - Angular routing issue"
Write-Host ""
Write-Host "B. API Call Issues:"
Write-Host "   - /api/etapa/ObterEtapaTarefa called without idObra"
Write-Host "   - API returns empty result instead of error"
Write-Host "   - Frontend shows 'Nenhum registro encontrado'"
Write-Host ""
Write-Host "C. Session/Authentication Issues:"
Write-Host "   - User session not properly maintained"
Write-Host "   - Auth.getUser() returns incomplete data"
Write-Host "   - obra property not properly initialized"
Write-Host ""

Write-Host "DEBUGGING COMMANDS:" -ForegroundColor Green
Write-Host ""
Write-Host "In browser console, run these commands:"
Write-Host ""
Write-Host "// Check authentication state"
Write-Host "console.log('User:', Auth.getUser());"
Write-Host "console.log('User obra:', Auth.getUser().obra);"
Write-Host "console.log('User ID:', Auth.getUser().usuario.id);"
Write-Host ""
Write-Host "// Check current location"
Write-Host "console.log('Current path:', window.location.pathname);"
Write-Host ""
Write-Host "// Test manual redirect"
Write-Host "window.location.href = '/obra/escolher';"
Write-Host ""

Write-Host "EXPECTED BEHAVIOR:" -ForegroundColor Green
Write-Host "1. User logs in successfully"
Write-Host "2. User navigates to /tarefa/cards"
Write-Host "3. TarefaController checks Auth.getUser().obra"
Write-Host "4. If obra is null, redirects to /obra/escolher"
Write-Host "5. User sees obra selection page"
Write-Host "6. User selects obra"
Write-Host "7. System redirects to /tarefa/cards with selected obra"
Write-Host "8. Etapas/tarefas load correctly"
Write-Host ""

Write-Host "NEXT STEPS:" -ForegroundColor Magenta
Write-Host "1. Test the manual obra selection workflow"
Write-Host "2. Check browser console for JavaScript errors"
Write-Host "3. Monitor network requests during navigation"
Write-Host "4. Verify the redirect logic is working"
Write-Host ""

Write-Host "Press any key to start investigation..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")