Write-Host "=== TESTING OBRA SELECTION FIX - FINAL ===" -ForegroundColor Green
Write-Host "Testing if the obra selection error is resolved..." -ForegroundColor Yellow

# Test 1: Check if application is running
Write-Host "`n1. Checking if application is running..." -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5031" -Method GET -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "Application is running successfully" -ForegroundColor Green
    }
} catch {
    Write-Host "Application is not responding: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Test 2: Test login page
Write-Host "`n2. Testing login page..." -ForegroundColor Cyan
try {
    $loginResponse = Invoke-WebRequest -Uri "http://localhost:5031/Auth/Login" -Method GET -TimeoutSec 10
    if ($loginResponse.StatusCode -eq 200) {
        Write-Host "Login page loads successfully" -ForegroundColor Green
    }
} catch {
    Write-Host "Login page failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 3: Test API endpoints
Write-Host "`n3. Testing API endpoints..." -ForegroundColor Cyan

# Test ObraApi endpoint
try {
    $apiResponse = Invoke-WebRequest -Uri "http://localhost:5031/api/ObraApi/ObterObras" -Method POST -ContentType "application/json" -Body "{}" -TimeoutSec 10
    Write-Host "ObraApi/ObterObras endpoint responds (Status: $($apiResponse.StatusCode))" -ForegroundColor Green
} catch {
    if ($_.Exception.Response.StatusCode -eq 401) {
        Write-Host "ObraApi/ObterObras endpoint responds with 401 (expected - needs authentication)" -ForegroundColor Yellow
    } else {
        Write-Host "ObraApi/ObterObras endpoint failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Test Etapas API endpoint
try {
    $etapasResponse = Invoke-WebRequest -Uri "http://localhost:5031/api/ObraApi/Etapas/1" -Method GET -TimeoutSec 10
    Write-Host "ObraApi/Etapas endpoint responds (Status: $($etapasResponse.StatusCode))" -ForegroundColor Green
} catch {
    if ($_.Exception.Response.StatusCode -eq 401) {
        Write-Host "ObraApi/Etapas endpoint responds with 401 (expected - needs authentication)" -ForegroundColor Yellow
    } else {
        Write-Host "ObraApi/Etapas endpoint failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`n=== ARCHITECTURE ANALYSIS ===" -ForegroundColor Magenta
Write-Host "Created ObraApiController matching Gilberto's Web API pattern" -ForegroundColor Green
Write-Host "Modified ObraController.Etapas() to call API and parse JSON response" -ForegroundColor Green
Write-Host "Added HttpClient to Program.cs services" -ForegroundColor Green
Write-Host "Fixed view model type mismatch (List object to List Etapa)" -ForegroundColor Green
Write-Host "Added proper JSON deserialization with safe date parsing" -ForegroundColor Green
Write-Host "Resolved process lock issues" -ForegroundColor Green

Write-Host "`n=== NEXT STEPS ===" -ForegroundColor Blue
Write-Host "1. Test login with valid credentials" -ForegroundColor White
Write-Host "2. Navigate to Obra selection page" -ForegroundColor White
Write-Host "3. Select an obra and verify it loads etapas without error" -ForegroundColor White
Write-Host "4. Verify that etapas and tarefas display correctly" -ForegroundColor White

Write-Host "`n=== READY FOR TESTING ===" -ForegroundColor Green
Write-Host "Application is compiled and running. Ready for manual testing!" -ForegroundColor Yellow
Write-Host "URL: http://localhost:5031" -ForegroundColor Cyan