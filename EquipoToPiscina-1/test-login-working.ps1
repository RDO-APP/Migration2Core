Write-Host "=== TESTING LOGIN PAGE ===" -ForegroundColor Green

# Wait a bit more for app to fully start
Start-Sleep -Seconds 5

try {
    # Test if login page is accessible
    $response = Invoke-WebRequest -Uri "https://localhost:7139/Auth/Login" -SkipCertificateCheck -TimeoutSec 10
    
    if ($response.StatusCode -eq 200) {
        Write-Host "✓ Login page is accessible (Status: 200)" -ForegroundColor Green
        
        # Check if it contains login form elements
        if ($response.Content -like "*password*" -and $response.Content -like "*login*") {
            Write-Host "✓ Login form elements found" -ForegroundColor Green
        } else {
            Write-Host "⚠ Login form elements not found in response" -ForegroundColor Yellow
        }
        
        Write-Host "`nLogin page is working!" -ForegroundColor Green
        Write-Host "You can now:" -ForegroundColor White
        Write-Host "1. Login with: ricardo / 123456" -ForegroundColor Yellow
        Write-Host "2. Access obra selection page after login" -ForegroundColor Yellow
        Write-Host "3. Select any obra to access Etapas/Tarefas" -ForegroundColor Yellow
        
    } else {
        Write-Host "❌ Login page returned status: $($response.StatusCode)" -ForegroundColor Red
    }
    
} catch {
    Write-Host "❌ Error accessing login page: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "The application might still be starting up..." -ForegroundColor Yellow
}