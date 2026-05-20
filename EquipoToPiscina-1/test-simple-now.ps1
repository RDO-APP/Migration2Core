Write-Host "=== TESTING LOGIN AND OBRA SELECTION ===" -ForegroundColor Green

# Test 1: Check if application is running
Write-Host "1. Testing application..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5031" -UseBasicParsing -TimeoutSec 5
    Write-Host "   Application is responding (Status: $($response.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "   Application error: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 2: Check login page
Write-Host "2. Testing login page..." -ForegroundColor Yellow
try {
    $loginResponse = Invoke-WebRequest -Uri "http://localhost:5031/Auth/Login" -UseBasicParsing -TimeoutSec 5
    Write-Host "   Login page accessible (Status: $($loginResponse.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "   Login page error: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 3: Test obra API
Write-Host "3. Testing Obra API..." -ForegroundColor Yellow
try {
    $headers = @{ 'Content-Type' = 'application/json' }
    $body = @{} | ConvertTo-Json
    
    $apiResponse = Invoke-WebRequest -Uri "http://localhost:5031/api/ObraApi/ObterObras" -Method POST -Body $body -Headers $headers -UseBasicParsing -TimeoutSec 10
    
    if ($apiResponse.StatusCode -eq 200) {
        $obras = $apiResponse.Content | ConvertFrom-Json
        if ($obras -is [array] -and $obras.Count -gt 0) {
            Write-Host "   API returned $($obras.Count) obras successfully" -ForegroundColor Green
        } else {
            Write-Host "   API returned empty result" -ForegroundColor Yellow
        }
    }
} catch {
    Write-Host "   API error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "MANUAL TEST: Open http://localhost:5031/Auth/Login" -ForegroundColor Green
Write-Host "Login: ricardo / 123456" -ForegroundColor Green

# Open browser
Start-Process "http://localhost:5031/Auth/Login"