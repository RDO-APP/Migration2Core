# Test Current Login State - .NET 8 RDO Project
# Date: December 28, 2025

Write-Host "🔍 TESTING CURRENT LOGIN STATE" -ForegroundColor Yellow
Write-Host "==============================" -ForegroundColor Yellow

$projectPath = "RDO-NET8-Migration\RdoApp.Core"

if (Test-Path $projectPath) {
    Set-Location $projectPath
    
    Write-Host "`n🚀 STARTING APPLICATION..." -ForegroundColor Cyan
    
    # Start the application in background
    $process = Start-Process -FilePath "dotnet" -ArgumentList "run" -PassThru -WindowStyle Hidden
    
    Write-Host "✅ Application started (PID: $($process.Id))" -ForegroundColor Green
    Write-Host "⏳ Waiting 10 seconds for startup..." -ForegroundColor Yellow
    Start-Sleep -Seconds 10
    
    try {
        # Test home page
        Write-Host "`n🔍 TESTING HOME PAGE:" -ForegroundColor Yellow
        try {
            $homeResponse = Invoke-WebRequest -Uri "http://localhost:5031/" -Method GET -TimeoutSec 5 -ErrorAction Stop
            Write-Host "✅ Home page status: $($homeResponse.StatusCode)" -ForegroundColor Green
        } catch {
            Write-Host "❌ Home page failed: $($_.Exception.Message)" -ForegroundColor Red
        }
        
        # Test login page
        Write-Host "`n🔍 TESTING LOGIN PAGE:" -ForegroundColor Yellow
        try {
            $loginResponse = Invoke-WebRequest -Uri "http://localhost:5031/Auth/Login" -Method GET -TimeoutSec 5 -ErrorAction Stop
            Write-Host "✅ Login page status: $($loginResponse.StatusCode)" -ForegroundColor Green
            
            if ($loginResponse.Content -match "RDO") {
                Write-Host "✅ Login page contains RDO branding" -ForegroundColor Green
            } else {
                Write-Host "⚠️  Login page might not be loading correctly" -ForegroundColor Yellow
            }
        } catch {
            Write-Host "❌ Login page failed: $($_.Exception.Message)" -ForegroundColor Red
        }
        
        # Test database connection via API
        Write-Host "`n🔍 TESTING DATABASE CONNECTION:" -ForegroundColor Yellow
        try {
            $dbResponse = Invoke-WebRequest -Uri "http://localhost:5031/api/teste/conexao" -Method GET -TimeoutSec 5 -ErrorAction Stop
            Write-Host "✅ Database connection status: $($dbResponse.StatusCode)" -ForegroundColor Green
            Write-Host "Response: $($dbResponse.Content)" -ForegroundColor White
        } catch {
            Write-Host "❌ Database connection failed: $($_.Exception.Message)" -ForegroundColor Red
        }
        
        # Test user verification
        Write-Host "`n🔍 TESTING USER VERIFICATION:" -ForegroundColor Yellow
        try {
            $userResponse = Invoke-WebRequest -Uri "http://localhost:5031/api/TestUsuario/verificar-usuario-teste" -Method GET -TimeoutSec 5 -ErrorAction Stop
            Write-Host "✅ User verification status: $($userResponse.StatusCode)" -ForegroundColor Green
            Write-Host "Response: $($userResponse.Content)" -ForegroundColor White
        } catch {
            Write-Host "❌ User verification failed: $($_.Exception.Message)" -ForegroundColor Red
        }
        
        # Test login API endpoint
        Write-Host "`n🔍 TESTING LOGIN API:" -ForegroundColor Yellow
        try {
            $loginData = @{
                Cpf = "567.065.455-20"
                Senha = "RXL8DjdYj6Y="
                LembrarMe = $false
            } | ConvertTo-Json
            
            $apiResponse = Invoke-WebRequest -Uri "http://localhost:5031/api/auth/login" -Method POST -Body $loginData -ContentType "application/json" -TimeoutSec 5 -ErrorAction Stop
            Write-Host "✅ Login API status: $($apiResponse.StatusCode)" -ForegroundColor Green
            Write-Host "Response: $($apiResponse.Content)" -ForegroundColor White
        } catch {
            Write-Host "❌ Login API failed: $($_.Exception.Message)" -ForegroundColor Red
            if ($_.Exception.Response) {
                $errorResponse = $_.Exception.Response.GetResponseStream()
                $reader = New-Object System.IO.StreamReader($errorResponse)
                $errorContent = $reader.ReadToEnd()
                Write-Host "Error details: $errorContent" -ForegroundColor Red
            }
        }
        
        Write-Host "`n📋 SUMMARY:" -ForegroundColor Yellow
        Write-Host "Application is running on http://localhost:5031" -ForegroundColor White
        Write-Host "You can now test login manually in your browser" -ForegroundColor White
        Write-Host "Use credentials: CPF 567.065.455-20, Password RXL8DjdYj6Y=" -ForegroundColor White
        
    } finally {
        Write-Host "`n🛑 STOPPING APPLICATION..." -ForegroundColor Yellow
        Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
        Write-Host "✅ Application stopped" -ForegroundColor Green
    }
    
} else {
    Write-Host "❌ Project directory not found: $projectPath" -ForegroundColor Red
}

Write-Host "`n🏁 Test completed" -ForegroundColor Cyan