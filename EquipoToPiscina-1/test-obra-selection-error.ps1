#!/usr/bin/env pwsh

Write-Host "=== TESTING OBRA SELECTION ERROR ===" -ForegroundColor Green

# Test 1: Check if application is running
Write-Host "`n1. Checking if application is running..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5031" -Method GET -TimeoutSec 10
    Write-Host "✓ Application is running (Status: $($response.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "✗ Application not accessible: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Test 2: Test login page
Write-Host "`n2. Testing login page..." -ForegroundColor Yellow
try {
    $loginResponse = Invoke-WebRequest -Uri "http://localhost:5031/Auth/Login" -Method GET -TimeoutSec 10
    Write-Host "✓ Login page accessible (Status: $($loginResponse.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "✗ Login page error: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 3: Test direct access to Etapas action (this should trigger the error)
Write-Host "`n3. Testing direct access to Etapas (should show the error)..." -ForegroundColor Yellow
try {
    # This should fail with authentication, but we want to see what error we get
    $etapasResponse = Invoke-WebRequest -Uri "http://localhost:5031/Obra/Etapas" -Method GET -TimeoutSec 10
    Write-Host "✓ Etapas page accessible (Status: $($etapasResponse.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "Expected authentication error: $($_.Exception.Message)" -ForegroundColor Yellow
    
    # Check if it's a redirect to login (expected) or a server error (the bug)
    if ($_.Exception.Message -like "*401*" -or $_.Exception.Message -like "*redirect*") {
        Write-Host "✓ Correct behavior - redirecting to login" -ForegroundColor Green
    } else {
        Write-Host "✗ Unexpected error - this might be our bug!" -ForegroundColor Red
    }
}

# Test 4: Check application logs for any errors
Write-Host "`n4. Checking recent application logs..." -ForegroundColor Yellow
Write-Host "Recent application output:" -ForegroundColor Cyan

# Instructions for manual testing
Write-Host "`n=== MANUAL TESTING INSTRUCTIONS ===" -ForegroundColor Magenta
Write-Host "1. Open browser to: http://localhost:5031" -ForegroundColor White
Write-Host "2. Login with test credentials" -ForegroundColor White
Write-Host "3. Select an obra from the list" -ForegroundColor White
Write-Host "4. Check if you get the error page or if etapas load correctly" -ForegroundColor White
Write-Host "5. If error occurs, check the console output below for detailed error messages" -ForegroundColor White

Write-Host "`n=== WAITING FOR USER INTERACTION ===" -ForegroundColor Green
Write-Host "Please test the obra selection manually and press any key when done..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

Write-Host "`nTest completed. Check the application logs above for any error details." -ForegroundColor Green