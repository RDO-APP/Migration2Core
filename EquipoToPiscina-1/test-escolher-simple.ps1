# SIMPLE ESCOLHER TEST
Write-Host "=== TESTING ESCOLHER OBRA ACCESS ===" -ForegroundColor Cyan

$baseUrl = "http://localhost:5031"

# Test unauthenticated access (should redirect to login)
Write-Host "1. Testing unauthenticated access..." -ForegroundColor Green
try {
    $response = Invoke-WebRequest -Uri "$baseUrl/Obra/Escolher" -UseBasicParsing -TimeoutSec 10
    Write-Host "   Status: $($response.StatusCode), Size: $($response.Content.Length) bytes" -ForegroundColor Gray
    
    # Save for analysis
    $response.Content | Out-File -FilePath "escolher-unauthenticated.html" -Encoding UTF8
    Write-Host "   Saved to: escolher-unauthenticated.html" -ForegroundColor Gray
    
    if ($response.Content -match "login|Login") {
        Write-Host "   Result: Redirected to login (expected)" -ForegroundColor Yellow
    } else {
        Write-Host "   Result: Unexpected content" -ForegroundColor Red
    }
} catch {
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`nMANUAL TESTING REQUIRED:" -ForegroundColor Yellow
Write-Host "1. Open browser to: $baseUrl" -ForegroundColor White
Write-Host "2. Login with: ricardo / 123456" -ForegroundColor White
Write-Host "3. Navigate to ESCOLHER OBRA page" -ForegroundColor White
Write-Host "4. Check for:" -ForegroundColor White
Write-Host "   - Green debug message: 'Found X obras in Model'" -ForegroundColor Green
Write-Host "   - Grid of obra cards below" -ForegroundColor Green
Write-Host "5. If blank page, open F12 and check:" -ForegroundColor White
Write-Host "   - Network tab for 404 errors" -ForegroundColor Red
Write-Host "   - Console tab for JavaScript errors" -ForegroundColor Red
Write-Host "6. Right-click -> View Page Source" -ForegroundColor White
Write-Host "   - Save as 'escolher-authenticated-source.html'" -ForegroundColor White