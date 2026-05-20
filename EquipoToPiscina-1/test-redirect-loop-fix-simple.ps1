# Test Redirect Loop Fix - Simple Version
Write-Host "=== TESTING REDIRECT LOOP FIX ===" -ForegroundColor Green

Write-Host "1. Opening root path (should redirect to login)..." -ForegroundColor Yellow
Start-Process "https://localhost:5001/"

Start-Sleep -Seconds 2

Write-Host "2. Opening direct login..." -ForegroundColor Yellow  
Start-Process "https://localhost:5001/Account/Login"

Write-Host "3. Key Changes Applied:" -ForegroundColor Cyan
Write-Host "   - AccountController redirects to Obra/Escolher (not Home)" -ForegroundColor White
Write-Host "   - Middleware allows /obra/escolher path" -ForegroundColor White
Write-Host "   - Fixed redirect loop issue" -ForegroundColor White

Write-Host "=== TEST COMPLETE ===" -ForegroundColor Green