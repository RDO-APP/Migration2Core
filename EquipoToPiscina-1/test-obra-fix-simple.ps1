Write-Host "=== TESTING OBRA SELECTION FIX ===" -ForegroundColor Green

Write-Host "1. Checking if application is running..." -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5031" -Method GET -TimeoutSec 5
    Write-Host "Application is running (Status: $($response.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "Application is not running or not accessible" -ForegroundColor Red
    exit 1
}

Write-Host "2. Testing login page..." -ForegroundColor Cyan
try {
    $loginResponse = Invoke-WebRequest -Uri "http://localhost:5031/Auth/Login" -Method GET -TimeoutSec 10
    Write-Host "Login page loads successfully" -ForegroundColor Green
} catch {
    Write-Host "Login page failed to load" -ForegroundColor Red
}

Write-Host "`n=== MANUAL TESTING REQUIRED ===" -ForegroundColor Yellow
Write-Host "1. Open browser: http://localhost:5031/Auth/Login" -ForegroundColor White
Write-Host "2. Login with: ricardo / 123456" -ForegroundColor White
Write-Host "3. Click on an obra to test etapas page" -ForegroundColor White
Write-Host "4. Verify no generic error appears" -ForegroundColor White

Write-Host "`n=== CHANGES MADE ===" -ForegroundColor Magenta
Write-Host "- Fixed ObraController.Etapas() method" -ForegroundColor Green
Write-Host "- Added proper JSON deserialization" -ForegroundColor Green
Write-Host "- Fixed view model type mismatch" -ForegroundColor Green
Write-Host "- Added error handling and logging" -ForegroundColor Green

Write-Host "`nTest completed. Please perform manual testing." -ForegroundColor Green