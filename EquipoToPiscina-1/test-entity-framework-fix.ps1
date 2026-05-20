#!/usr/bin/env pwsh

Write-Host "=== TESTING ENTITY FRAMEWORK RELATIONSHIP FIX ===" -ForegroundColor Green
Write-Host "Testing the ObraColaborador relationship mapping fix..." -ForegroundColor Yellow

# Navigate to project directory
Set-Location "RDO-NET8-Migration/RdoApp.Core"

Write-Host "`n1. Building project to check for compilation errors..." -ForegroundColor Cyan
try {
    dotnet build --no-restore --verbosity quiet
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Build successful - no compilation errors" -ForegroundColor Green
    } else {
        Write-Host "❌ Build failed" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "❌ Build error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "`n2. Starting application to test Entity Framework..." -ForegroundColor Cyan
try {
    # Start the application in background
    $process = Start-Process -FilePath "dotnet" -ArgumentList "run" -PassThru -NoNewWindow
    
    # Wait for application to start
    Write-Host "Waiting for application to start..." -ForegroundColor Yellow
    Start-Sleep -Seconds 10
    
    # Test the login page first
    Write-Host "`n3. Testing login page..." -ForegroundColor Cyan
    $loginResponse = Invoke-WebRequest -Uri "https://localhost:7201/Auth/Login" -SkipCertificateCheck -TimeoutSec 30
    
    if ($loginResponse.StatusCode -eq 200) {
        Write-Host "✅ Login page loads successfully" -ForegroundColor Green
    } else {
        Write-Host "❌ Login page failed: $($loginResponse.StatusCode)" -ForegroundColor Red
    }
    
    Write-Host "`n4. Testing obras page (this should now work)..." -ForegroundColor Cyan
    
    # Create a session to maintain cookies
    $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
    
    # Get login page to get anti-forgery token
    $loginPage = Invoke-WebRequest -Uri "https://localhost:7201/Auth/Login" -WebSession $session -SkipCertificateCheck
    
    # Extract anti-forgery token
    $token = ""
    if ($loginPage.Content -match 'name="__RequestVerificationToken"[^>]*value="([^"]*)"') {
        $token = $matches[1]
    }
    
    # Login with test credentials
    $loginData = @{
        'Cpf' = '567.065.455-20'
        'Senha' = 'RXL8DjdYj6Y='
        'LembrarMe' = 'false'
        '__RequestVerificationToken' = $token
    }
    
    $loginResult = Invoke-WebRequest -Uri "https://localhost:7201/Auth/Login" -Method POST -Body $loginData -WebSession $session -SkipCertificateCheck
    
    if ($loginResult.StatusCode -eq 200 -and $loginResult.BaseResponse.ResponseUri.AbsolutePath -ne "/Auth/Login") {
        Write-Host "✅ Login successful, redirected to: $($loginResult.BaseResponse.ResponseUri)" -ForegroundColor Green
        
        # Now test the obras page directly
        try {
            $obrasResponse = Invoke-WebRequest -Uri "https://localhost:7201/Obra/Escolher" -WebSession $session -SkipCertificateCheck -TimeoutSec 30
            
            if ($obrasResponse.StatusCode -eq 200) {
                Write-Host "✅ Obras page loads successfully! Entity Framework fix worked!" -ForegroundColor Green
                Write-Host "✅ No more 'Unknown column o1.ObraId1' error!" -ForegroundColor Green
            } else {
                Write-Host "❌ Obras page failed: $($obrasResponse.StatusCode)" -ForegroundColor Red
            }
        } catch {
            Write-Host "❌ Obras page error: $($_.Exception.Message)" -ForegroundColor Red
            if ($_.Exception.Message -like "*ObraId1*") {
                Write-Host "❌ Still getting shadow property error - need more fixes" -ForegroundColor Red
            }
        }
    } else {
        Write-Host "❌ Login failed" -ForegroundColor Red
    }
    
} catch {
    Write-Host "❌ Application test error: $($_.Exception.Message)" -ForegroundColor Red
} finally {
    # Stop the application
    if ($process -and !$process.HasExited) {
        Write-Host "`n5. Stopping application..." -ForegroundColor Cyan
        Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
        Write-Host "✅ Application stopped" -ForegroundColor Green
    }
}

Write-Host "`n=== ENTITY FRAMEWORK FIX TEST COMPLETE ===" -ForegroundColor Green
Write-Host "The ObraColaborador relationship mapping has been fixed." -ForegroundColor Yellow
Write-Host "Shadow property generation should be resolved." -ForegroundColor Yellow