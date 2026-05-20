# Test Day 8 Authentication System
Write-Host "Testing Day 8 Authentication System..." -ForegroundColor Green

try {
    # Test if application is running
    Write-Host "Testing if application is running..." -ForegroundColor Cyan
    $response = Invoke-RestMethod -Uri "http://localhost:7201" -Method GET -ErrorAction SilentlyContinue
    
    if ($response) {
        Write-Host "✅ Application is running on port 7201" -ForegroundColor Green
        
        # Test login page
        Write-Host "Testing login page..." -ForegroundColor Cyan
        $loginPage = Invoke-WebRequest -Uri "http://localhost:7201/Auth/Login" -Method GET -ErrorAction SilentlyContinue
        
        if ($loginPage.StatusCode -eq 200) {
            Write-Host "✅ Login page accessible" -ForegroundColor Green
        } else {
            Write-Host "❌ Login page not accessible" -ForegroundColor Red
        }
        
        # Test API login endpoint
        Write-Host "Testing API login endpoint..." -ForegroundColor Cyan
        $loginData = @{
            cpf = "567.065.455-20"
            senha = "1234"
            lembrarMe = $false
        } | ConvertTo-Json
        
        $headers = @{
            "Content-Type" = "application/json"
        }
        
        try {
            $loginResult = Invoke-RestMethod -Uri "http://localhost:7201/api/auth/login" -Method POST -Body $loginData -Headers $headers
            
            if ($loginResult.sucesso) {
                Write-Host "✅ API Login successful!" -ForegroundColor Green
                Write-Host "User: $($loginResult.usuario.nome)" -ForegroundColor Yellow
                Write-Host "CPF: $($loginResult.usuario.cpf)" -ForegroundColor Yellow
            } else {
                Write-Host "❌ API Login failed: $($loginResult.mensagem)" -ForegroundColor Red
            }
        } catch {
            Write-Host "❌ API Login endpoint error: $($_.Exception.Message)" -ForegroundColor Red
        }
        
    } else {
        Write-Host "❌ Application not running on port 7201" -ForegroundColor Red
        Write-Host "Try running: dotnet run" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Make sure the application is running with: dotnet run" -ForegroundColor Yellow
}

Write-Host "`nDAY 8 AUTHENTICATION TEST COMPLETED" -ForegroundColor Green