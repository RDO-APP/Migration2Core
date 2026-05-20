# EMERGENCY BLANK PAGE DIAGNOSIS
# This will help us understand what's happening

Write-Host "========================================" -ForegroundColor Red
Write-Host "EMERGENCY BLANK PAGE DIAGNOSIS" -ForegroundColor Red
Write-Host "========================================" -ForegroundColor Red
Write-Host ""

# Step 1: Start the server
Write-Host "Step 1: Starting server..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd 'RDO-NET8-Migration/RdoApp.Core'; dotnet run"
Write-Host "✓ Server starting in new window" -ForegroundColor Green
Write-Host ""

Write-Host "Waiting 15 seconds for server to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

# Step 2: Test if server is responding
Write-Host "Step 2: Testing server response..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5031" -Method GET -UseBasicParsing -TimeoutSec 5
    Write-Host "✓ Server is responding (Status: $($response.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "✗ Server not responding: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Check the server window for errors!" -ForegroundColor Yellow
}
Write-Host ""

# Step 3: Instructions
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "CRITICAL QUESTIONS:" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. ARE YOU LOGGED IN?" -ForegroundColor Yellow
Write-Host "   - If you see a blank page, you might not be logged in" -ForegroundColor White
Write-Host "   - Try: http://localhost:5031/Account/Login" -ForegroundColor White
Write-Host ""
Write-Host "2. WHAT URL ARE YOU USING?" -ForegroundColor Yellow
Write-Host "   - Correct: http://localhost:5031/Obra/Escolher" -ForegroundColor Green
Write-Host "   - Wrong: https://localhost:7201/Obra/Escolher" -ForegroundColor Red
Write-Host ""
Write-Host "3. WHAT DO YOU SEE?" -ForegroundColor Yellow
Write-Host "   - Completely blank white page?" -ForegroundColor White
Write-Host "   - Login page?" -ForegroundColor White
Write-Host "   - Error message?" -ForegroundColor White
Write-Host "   - Something else?" -ForegroundColor White
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "TESTING STEPS:" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Step A: Test Login" -ForegroundColor Yellow
Write-Host "   URL: http://localhost:5031/Account/Login" -ForegroundColor White
Write-Host "   Username: ricardo" -ForegroundColor White
Write-Host "   Password: (your password)" -ForegroundColor White
Write-Host ""
Write-Host "Step B: After Login, Test Escolher" -ForegroundColor Yellow
Write-Host "   URL: http://localhost:5031/Obra/Escolher" -ForegroundColor White
Write-Host ""
Write-Host "Step C: If Still Blank, Test Debug Version" -ForegroundColor Yellow
Write-Host "   URL: http://localhost:5031/Obra/EscolherDebug" -ForegroundColor White
Write-Host ""
Write-Host "Step D: If Still Blank, Test Nuclear Version" -ForegroundColor Yellow
Write-Host "   URL: http://localhost:5031/Obra/EscolherNuclear" -ForegroundColor White
Write-Host ""
Write-Host "========================================" -ForegroundColor Red
Write-Host "PLEASE TELL ME:" -ForegroundColor Red
Write-Host "========================================" -ForegroundColor Red
Write-Host ""
Write-Host "1. Are you logged in? (Yes/No)" -ForegroundColor White
Write-Host "2. What URL are you using?" -ForegroundColor White
Write-Host "3. What do you see on the page?" -ForegroundColor White
Write-Host "4. Can you take a screenshot?" -ForegroundColor White
Write-Host ""
