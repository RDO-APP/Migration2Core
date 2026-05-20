# Simple test to check if server is running without Exit Code -1
Write-Host "=== TESTING EXIT CODE -1 FIX ===" -ForegroundColor Cyan
Write-Host ""

Write-Host "Checking if server is running on https://localhost:7201..." -ForegroundColor Yellow

try {
    # Ignore certificate errors
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
    
    $response = Invoke-WebRequest -Uri "https://localhost:7201" -UseBasicParsing -ErrorAction Stop
    
    Write-Host "SUCCESS! Server is running!" -ForegroundColor Green
    Write-Host "Status Code: $($response.StatusCode)" -ForegroundColor Green
    Write-Host ""
    Write-Host "=== SERVER DID NOT CRASH WITH EXIT CODE -1 ===" -ForegroundColor Green
    Write-Host "The application started successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next step: Open browser and navigate to:" -ForegroundColor Cyan
    Write-Host "https://localhost:7201/Account/Login" -ForegroundColor White
    Write-Host ""
    Write-Host "Then login and navigate to:" -ForegroundColor Cyan
    Write-Host "https://localhost:7201/Obra/Escolher" -ForegroundColor White
    Write-Host ""
    Write-Host "If the page loads with 103 obra cards, the fix is COMPLETE!" -ForegroundColor Green
    
}
catch {
    Write-Host "FAILURE! Server is not responding!" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "The server may have crashed with Exit Code -1" -ForegroundColor Red
    exit 1
}
