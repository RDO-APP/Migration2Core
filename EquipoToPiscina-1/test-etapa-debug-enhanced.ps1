#!/usr/bin/env pwsh

Write-Host "=== TESTING ENHANCED ETAPA DEBUG LOGGING ===" -ForegroundColor Green
Write-Host "This will test the EtapaService with comprehensive debug logging to identify where data is being dropped" -ForegroundColor Yellow

# Stop any running processes first
Write-Host "`n1. Stopping any running processes..." -ForegroundColor Cyan
Get-Process | Where-Object {$_.ProcessName -like "*dotnet*" -or $_.ProcessName -like "*RdoApp*"} | Stop-Process -Force -ErrorAction SilentlyContinue

# Navigate to project directory
Set-Location "RDO-NET8-Migration/RdoApp.Core"

# Build the project
Write-Host "`n2. Building project..." -ForegroundColor Cyan
dotnet build --no-restore

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Build failed! Cannot test debug logging." -ForegroundColor Red
    exit 1
}

# Start the application in background
Write-Host "`n3. Starting application with debug logging..." -ForegroundColor Cyan
$process = Start-Process -FilePath "dotnet" -ArgumentList "run" -PassThru -WindowStyle Hidden

# Wait for application to start
Write-Host "Waiting 10 seconds for application to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Test the etapa endpoint that should trigger our debug logging
Write-Host "`n4. Testing etapa endpoint to trigger debug logging..." -ForegroundColor Cyan

# First, login to get session
Write-Host "Logging in as ricardo..." -ForegroundColor Yellow
$loginData = @{
    cpf = "12345678901"
    senha = "123456"
}

try {
    $loginResponse = Invoke-WebRequest -Uri "https://localhost:7001/Auth/Login" -Method POST -Body $loginData -SessionVariable session -SkipCertificateCheck
    Write-Host "✅ Login successful" -ForegroundColor Green
    
    # Now test the obra/etapas endpoint that should call ObterEtapasViewModelAsync
    Write-Host "Accessing obra etapas page..." -ForegroundColor Yellow
    $etapasResponse = Invoke-WebRequest -Uri "https://localhost:7001/Obra/Etapas/1" -WebSession $session -SkipCertificateCheck
    
    Write-Host "✅ Etapas page accessed successfully" -ForegroundColor Green
    Write-Host "Response length: $($etapasResponse.Content.Length) characters" -ForegroundColor Cyan
    
    # Check if page contains etapa data
    if ($etapasResponse.Content -match "etapa-accordion" -or $etapasResponse.Content -match "Etapa \d+") {
        Write-Host "✅ Page contains etapa elements" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Page does not contain expected etapa elements" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "❌ Error testing endpoints: $($_.Exception.Message)" -ForegroundColor Red
}

# Stop the application
Write-Host "`n5. Stopping application..." -ForegroundColor Cyan
if ($process -and !$process.HasExited) {
    $process.Kill()
    $process.WaitForExit(5000)
}

Write-Host "`n=== DEBUG TEST COMPLETED ===" -ForegroundColor Green
Write-Host "Check the console output above for debug messages from EtapaService.ObterEtapasViewModelAsync" -ForegroundColor Yellow
Write-Host "Look for:" -ForegroundColor Cyan
Write-Host "  - ObraId recebido: [value]" -ForegroundColor White
Write-Host "  - Etapas encontradas no banco: [count]" -ForegroundColor White
Write-Host "  - Any mapping errors or exceptions" -ForegroundColor White
Write-Host "  - RESULTADO FINAL: [count] etapas no ViewModel" -ForegroundColor White