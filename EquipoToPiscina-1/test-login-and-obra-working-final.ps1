#!/usr/bin/env pwsh

Write-Host "=== TESTING LOGIN AND OBRA SELECTION - FINAL TEST ===" -ForegroundColor Green
Write-Host ""

# Test 1: Check if application is running
Write-Host "1. Testing if application is running..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5031" -UseBasicParsing -TimeoutSec 5
    Write-Host "   ✓ Application is responding (Status: $($response.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "   ✗ Application is not responding: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "   Please make sure the application is running on http://localhost:5031"
    exit 1
}

# Test 2: Check login page
Write-Host "2. Testing login page..." -ForegroundColor Yellow
try {
    $loginResponse = Invoke-WebRequest -Uri "http://localhost:5031/Auth/Login" -UseBasicParsing -TimeoutSec 5
    Write-Host "   ✓ Login page is accessible (Status: $($loginResponse.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "   ✗ Login page error: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 3: Test obra API (this should work with hardcoded user ID)
Write-Host "3. Testing Obra API..." -ForegroundColor Yellow
try {
    $headers = @{
        'Content-Type' = 'application/json'
    }
    $body = @{} | ConvertTo-Json
    
    $apiResponse = Invoke-WebRequest -Uri "http://localhost:5031/api/ObraApi/ObterObras" -Method POST -Body $body -Headers $headers -UseBasicParsing -TimeoutSec 10
    
    if ($apiResponse.StatusCode -eq 200) {
        $obras = $apiResponse.Content | ConvertFrom-Json
        if ($obras -is [array] -and $obras.Count -gt 0) {
            Write-Host "   ✓ API returned $($obras.Count) obras successfully" -ForegroundColor Green
            Write-Host "   First obra: $($obras[0].Descricao) - $($obras[0].CidadeEstado)" -ForegroundColor Cyan
        } else {
            Write-Host "   ⚠ API returned empty result" -ForegroundColor Yellow
        }
    }
} catch {
    Write-Host "   ✗ API error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== MANUAL TESTING INSTRUCTIONS ===" -ForegroundColor Green
Write-Host "1. Open browser to: http://localhost:5031/Auth/Login"
Write-Host "2. Login with: ricardo / 123456"
Write-Host "3. You should be redirected to the obra selection page"
Write-Host "4. The page should show obra cards with data"
Write-Host ""

# Open browser for manual testing
Write-Host "Opening browser for manual testing..." -ForegroundColor Yellow
Start-Process "http://localhost:5031/Auth/Login"

Write-Host "Test completed!" -ForegroundColor Green