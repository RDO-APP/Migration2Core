# Quick Login Diagnosis
Write-Host "Quick Login Diagnosis" -ForegroundColor Yellow

# Check if we can reach the login page
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5031/Auth/Login" -Method GET -TimeoutSec 3
    Write-Host "Login page: OK ($($response.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "Login page: FAILED - $($_.Exception.Message)" -ForegroundColor Red
}

# Test database connection
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5031/api/teste/conexao" -Method GET -TimeoutSec 3
    Write-Host "Database: OK - $($response.Content)" -ForegroundColor Green
} catch {
    Write-Host "Database: FAILED - $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "Manual test: Open browser to http://localhost:5031/Auth/Login" -ForegroundColor Cyan
Write-Host "Use CPF: 567.065.455-20 and Password: RXL8DjdYj6Y=" -ForegroundColor Cyan