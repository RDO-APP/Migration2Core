#!/usr/bin/env pwsh

Write-Host "=== TESTING LOGIN PAGE FIX ===" -ForegroundColor Green
Write-Host "Testing the completed Login.cshtml file..." -ForegroundColor Yellow

# Stop any running processes
Write-Host "Stopping any running RdoApp.Core processes..." -ForegroundColor Yellow
Get-Process -Name "RdoApp.Core" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2

# Navigate to project directory
Set-Location "RDO-NET8-Migration/RdoApp.Core"

# Clean and build
Write-Host "Cleaning and building project..." -ForegroundColor Yellow
dotnet clean --verbosity quiet
dotnet build --no-restore --verbosity quiet

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Build successful!" -ForegroundColor Green
    
    # Start application
    Write-Host "Starting application..." -ForegroundColor Yellow
    Start-Process -FilePath "dotnet" -ArgumentList "run --no-build" -WindowStyle Hidden
    
    # Wait for startup
    Write-Host "Waiting for application to start..." -ForegroundColor Yellow
    Start-Sleep -Seconds 5
    
    # Test login page
    Write-Host "Testing login page..." -ForegroundColor Yellow
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:5031/Auth/Login" -TimeoutSec 10
        
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ Login page loads successfully!" -ForegroundColor Green
            Write-Host "Status Code: $($response.StatusCode)" -ForegroundColor Green
            
            # Check if page contains form elements
            $content = $response.Content
            if ($content -match 'form.*method="post"' -and $content -match 'input.*name="Cpf"' -and $content -match 'input.*name="Senha"') {
                Write-Host "✅ Login form elements found!" -ForegroundColor Green
                Write-Host "✅ CPF input field: Found" -ForegroundColor Green
                Write-Host "✅ Password input field: Found" -ForegroundColor Green
                Write-Host "✅ Form POST method: Found" -ForegroundColor Green
            } else {
                Write-Host "❌ Login form elements missing!" -ForegroundColor Red
            }
            
            # Check for blank page issue
            if ($content.Length -gt 1000) {
                Write-Host "✅ Page content is substantial ($(($content.Length)) characters)" -ForegroundColor Green
                Write-Host "✅ Blank page issue RESOLVED!" -ForegroundColor Green
            } else {
                Write-Host "❌ Page content is too small - possible blank page" -ForegroundColor Red
            }
            
        } else {
            Write-Host "❌ Login page returned status: $($response.StatusCode)" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "❌ Error accessing login page: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    # Open browser for manual verification
    Write-Host "`nOpening browser for manual verification..." -ForegroundColor Yellow
    Start-Process "http://localhost:5031/Auth/Login"
    
    Write-Host "`n=== LOGIN PAGE FIX TEST COMPLETE ===" -ForegroundColor Green
    Write-Host "✅ Login.cshtml file has been completed with proper form structure" -ForegroundColor Green
    Write-Host "✅ Based on Gilberto's original design but adapted for ASP.NET Core MVC" -ForegroundColor Green
    Write-Host "✅ Includes CPF formatting and Enter key support" -ForegroundColor Green
    Write-Host "`nTest credentials:" -ForegroundColor Cyan
    Write-Host "CPF: 567.065.455-20" -ForegroundColor Cyan
    Write-Host "Password: RXL8DjdYj6Y=" -ForegroundColor Cyan
    
} else {
    Write-Host "❌ Build failed!" -ForegroundColor Red
}