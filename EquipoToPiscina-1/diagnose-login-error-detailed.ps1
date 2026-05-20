# Diagnose Login Error - .NET 8 RDO Project
# Date: December 28, 2025

Write-Host "🔍 DIAGNOSING LOGIN ERROR" -ForegroundColor Yellow
Write-Host "=========================" -ForegroundColor Yellow

# Navigate to project directory
$projectPath = "RDO-NET8-Migration\RdoApp.Core"
Write-Host "📁 Project: $projectPath" -ForegroundColor Cyan

if (Test-Path $projectPath) {
    Set-Location $projectPath
    
    Write-Host "`n🔍 CHECKING KEY COMPONENTS:" -ForegroundColor Yellow
    
    # Check if AuthController exists
    if (Test-Path "Controllers\AuthController.cs") {
        Write-Host "✅ AuthController.cs exists" -ForegroundColor Green
    } else {
        Write-Host "❌ AuthController.cs missing" -ForegroundColor Red
    }
    
    # Check if AuthService exists
    if (Test-Path "Services\Implementations\AuthService.cs") {
        Write-Host "✅ AuthService.cs exists" -ForegroundColor Green
    } else {
        Write-Host "❌ AuthService.cs missing" -ForegroundColor Red
    }
    
    # Check if Login view exists
    if (Test-Path "Views\Auth\Login.cshtml") {
        Write-Host "✅ Login.cshtml exists" -ForegroundColor Green
    } else {
        Write-Host "❌ Login.cshtml missing" -ForegroundColor Red
    }
    
    # Check database connection
    Write-Host "`n🔍 TESTING DATABASE CONNECTION:" -ForegroundColor Yellow
    Write-Host "Testing connection to AWS RDS MySQL..." -ForegroundColor Cyan
    
    # Test database connection via API
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:5031/api/teste/conexao" -Method GET -TimeoutSec 10 -ErrorAction Stop
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ Database connection successful" -ForegroundColor Green
            Write-Host "Response: $($response.Content)" -ForegroundColor White
        } else {
            Write-Host "⚠️  Database connection returned status: $($response.StatusCode)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "❌ Database connection failed: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    # Test user table
    Write-Host "`n🔍 TESTING USER TABLE:" -ForegroundColor Yellow
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:5031/api/TestUsuario/verificar-usuario-teste" -Method GET -TimeoutSec 10 -ErrorAction Stop
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ User table accessible" -ForegroundColor Green
            Write-Host "Response: $($response.Content)" -ForegroundColor White
        } else {
            Write-Host "⚠️  User table returned status: $($response.StatusCode)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "❌ User table test failed: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    # Test login endpoint directly
    Write-Host "`n🔍 TESTING LOGIN ENDPOINT:" -ForegroundColor Yellow
    try {
        $loginData = @{
            Cpf = "567.065.455-20"
            Senha = "RXL8DjdYj6Y="
            LembrarMe = $false
        } | ConvertTo-Json
        
        $response = Invoke-WebRequest -Uri "http://localhost:5031/Auth/Login" -Method POST -Body $loginData -ContentType "application/json" -TimeoutSec 10 -ErrorAction Stop
        Write-Host "✅ Login endpoint responded with status: $($response.StatusCode)" -ForegroundColor Green
        
        if ($response.StatusCode -eq 302) {
            Write-Host "🔄 Redirect detected - this might be normal" -ForegroundColor Yellow
            if ($response.Headers.Location) {
                Write-Host "Redirect to: $($response.Headers.Location)" -ForegroundColor White
            }
        }
    } catch {
        Write-Host "❌ Login endpoint failed: $($_.Exception.Message)" -ForegroundColor Red
        if ($_.Exception.Response) {
            Write-Host "Status Code: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
        }
    }
    
    Write-Host "`n📋 RECOMMENDATIONS:" -ForegroundColor Yellow
    Write-Host "1. Check Visual Studio Output window for detailed error messages" -ForegroundColor White
    Write-Host "2. Look at the Debug console for any exceptions" -ForegroundColor White
    Write-Host "3. Verify the database connection string in appsettings.json" -ForegroundColor White
    Write-Host "4. Check if the Usuario table exists and has the test user" -ForegroundColor White
    Write-Host "5. Verify BCrypt password hashing is working correctly" -ForegroundColor White
    
    Write-Host "`n🔧 NEXT STEPS:" -ForegroundColor Yellow
    Write-Host "1. Check Visual Studio Debug Output for the actual error" -ForegroundColor White
    Write-Host "2. Test the database connection manually" -ForegroundColor White
    Write-Host "3. Verify the AuthService is properly configured" -ForegroundColor White
    
} else {
    Write-Host "❌ Project directory not found: $projectPath" -ForegroundColor Red
}

Write-Host "`n🏁 Diagnosis completed" -ForegroundColor Cyan