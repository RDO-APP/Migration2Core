Write-Host "=== TESTING LOGIN PAGE ===" -ForegroundColor Green

Start-Sleep -Seconds 5

try {
    $response = Invoke-WebRequest -Uri "https://localhost:7139/Auth/Login" -SkipCertificateCheck -TimeoutSec 10
    
    if ($response.StatusCode -eq 200) {
        Write-Host "LOGIN PAGE IS WORKING!" -ForegroundColor Green
        Write-Host "Status: 200 OK" -ForegroundColor Green
        Write-Host "You can now login with: ricardo / 123456" -ForegroundColor Yellow
    }
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}