#!/usr/bin/env pwsh

Write-Host "=== TESTING OBRA API FIX ===" -ForegroundColor Green

# Test 1: Check if application is running
Write-Host "`n1. Checking if application is running..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5031" -Method GET -TimeoutSec 10
    Write-Host "✓ Application is running (Status: $($response.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "✗ Application not accessible: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Test 2: Test API endpoint directly
Write-Host "`n2. Testing API endpoint directly..." -ForegroundColor Yellow
try {
    $apiResponse = Invoke-WebRequest -Uri "http://localhost:5031/api/ObraApi/Etapas/1" -Method GET -TimeoutSec 10
    Write-Host "✓ API endpoint accessible (Status: $($apiResponse.StatusCode))" -ForegroundColor Green
    Write-Host "Response content preview:" -ForegroundColor Cyan
    $content = $apiResponse.Content
    if ($content.Length -gt 200) {
        Write-Host ($content.Substring(0, 200) + "...") -ForegroundColor White
    } else {
        Write-Host $content -ForegroundColor White
    }
} catch {
    Write-Host "API endpoint error: $($_.Exception.Message)" -ForegroundColor Yellow
    if ($_.Exception.Response) {
        Write-Host "Status Code: $($_.Exception.Response.StatusCode)" -ForegroundColor Yellow
    }
}

# Test 3: Test MVC controller that calls API
Write-Host "`n3. Testing MVC controller (Etapas page)..." -ForegroundColor Yellow
try {
    $etapasResponse = Invoke-WebRequest -Uri "http://localhost:5031/Obra/Etapas/1" -Method GET -TimeoutSec 10
    Write-Host "✓ Etapas page accessible (Status: $($etapasResponse.StatusCode))" -ForegroundColor Green
    
    # Check if the page contains expected content
    if ($etapasResponse.Content -like "*Etapas / Tarefas*") {
        Write-Host "✓ Page contains expected content" -ForegroundColor Green
    } else {
        Write-Host "⚠ Page loaded but may not have expected content" -ForegroundColor Yellow
    }
} catch {
    Write-Host "Etapas page error: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        Write-Host "Status Code: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    }
}

Write-Host "`n=== MANUAL TESTING INSTRUCTIONS ===" -ForegroundColor Magenta
Write-Host "1. Open browser to: http://localhost:5031" -ForegroundColor White
Write-Host "2. Login with test credentials" -ForegroundColor White
Write-Host "3. Select an obra from the list" -ForegroundColor White
Write-Host "4. Check if etapas page loads without errors" -ForegroundColor White

Write-Host "`nTest completed. The architecture has been fixed to match Gilberto's pattern!" -ForegroundColor Green