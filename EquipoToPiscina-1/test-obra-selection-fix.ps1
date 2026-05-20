#!/usr/bin/env pwsh

Write-Host "=== TESTING OBRA SELECTION FIX ===" -ForegroundColor Green
Write-Host "Testing the fixed obra selection functionality" -ForegroundColor Yellow

# Test 1: Check if application is running
Write-Host "`n1. Checking if application is running..." -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5031" -Method GET -TimeoutSec 5
    Write-Host "✓ Application is running (Status: $($response.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "✗ Application is not running or not accessible" -ForegroundColor Red
    Write-Host "Please make sure the application is running on http://localhost:5031" -ForegroundColor Yellow
    exit 1
}

# Test 2: Test login page
Write-Host "`n2. Testing login page..." -ForegroundColor Cyan
try {
    $loginResponse = Invoke-WebRequest -Uri "http://localhost:5031/Auth/Login" -Method GET -TimeoutSec 10
    if ($loginResponse.StatusCode -eq 200) {
        Write-Host "✓ Login page loads successfully" -ForegroundColor Green
    }
} catch {
    Write-Host "✗ Login page failed to load: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 3: Test API endpoints
Write-Host "`n3. Testing API endpoints..." -ForegroundColor Cyan

# Test ObraApi endpoint (this will fail without authentication, but should not return 404)
try {
    $apiResponse = Invoke-WebRequest -Uri "http://localhost:5031/api/ObraApi/Etapas/1" -Method GET -TimeoutSec 10
    Write-Host "✓ API endpoint is accessible" -ForegroundColor Green
} catch {
    if ($_.Exception.Response.StatusCode -eq 401) {
        Write-Host "✓ API endpoint exists (returns 401 Unauthorized as expected)" -ForegroundColor Green
    } elseif ($_.Exception.Response.StatusCode -eq 404) {
        Write-Host "✗ API endpoint not found (404)" -ForegroundColor Red
    } else {
        Write-Host "? API endpoint returned: $($_.Exception.Response.StatusCode)" -ForegroundColor Yellow
    }
}

Write-Host "`n=== MANUAL TESTING INSTRUCTIONS ===" -ForegroundColor Magenta
Write-Host "1. Open browser to: http://localhost:5031/Auth/Login" -ForegroundColor White
Write-Host "2. Login with test credentials (ricardo / 123456)" -ForegroundColor White
Write-Host "3. Navigate to obras selection page" -ForegroundColor White
Write-Host "4. Click on an obra to test the etapas page" -ForegroundColor White
Write-Host "5. Verify that the page loads without the generic error" -ForegroundColor White

Write-Host "`n=== EXPECTED RESULTS ===" -ForegroundColor Magenta
Write-Host "- Login should work normally" -ForegroundColor White
Write-Host "- Obra selection should show available obras" -ForegroundColor White
Write-Host "- Clicking on an obra should load the etapas page" -ForegroundColor White
Write-Host "- No more generic 'Error occurred while processing your request' message" -ForegroundColor White
Write-Host "- Etapas and tarefas should display properly" -ForegroundColor White

Write-Host "`n=== TECHNICAL CHANGES MADE ===" -ForegroundColor Magenta
Write-Host "✓ Fixed ObraController.Etapas() method to properly parse API response" -ForegroundColor Green
Write-Host "✓ Added proper JSON deserialization to convert API objects to Etapa entities" -ForegroundColor Green
Write-Host "✓ Fixed view model type mismatch (was List<object>, now List<Etapa>)" -ForegroundColor Green
Write-Host "✓ Added proper error handling and logging" -ForegroundColor Green
Write-Host "✓ Maintained compatibility with existing view structure" -ForegroundColor Green

Write-Host "`nTest completed. Please perform manual testing as described above." -ForegroundColor Green