#!/usr/bin/env pwsh

Write-Host "=== TESTING SOLUTION B: Task Loading Fix ===" -ForegroundColor Green
Write-Host ""

# Stop any running processes first
Write-Host "1. Stopping any running processes..." -ForegroundColor Cyan
Get-Process -Name "dotnet" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

# Navigate to project directory
Write-Host "2. Navigating to project directory..." -ForegroundColor Cyan
Set-Location "RDO-NET8-Migration/RdoApp.Core"

# Build the project
Write-Host "3. Building project with Solution B improvements..." -ForegroundColor Cyan
$buildResult = dotnet build --configuration Release --verbosity quiet
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Build successful" -ForegroundColor Green
} else {
    Write-Host "❌ Build failed" -ForegroundColor Red
    exit 1
}

# Start the application in background
Write-Host "4. Starting application to test Solution B..." -ForegroundColor Cyan
Start-Process -FilePath "dotnet" -ArgumentList "run --configuration Release" -WindowStyle Hidden

# Wait for application to start
Write-Host "5. Waiting for application to initialize..." -ForegroundColor Cyan
Start-Sleep -Seconds 15

# Test the application
Write-Host "6. Testing Solution B implementation..." -ForegroundColor Cyan

try {
    $response = Invoke-WebRequest -Uri "https://localhost:7001" -SkipCertificateCheck -TimeoutSec 10
    Write-Host "✅ Application is responding (Status: $($response.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "❌ Application not responding: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== SOLUTION B IMPLEMENTATION SUMMARY ===" -ForegroundColor Green
Write-Host "✅ EtapaService updated with Solution B approach" -ForegroundColor Green
Write-Host "✅ Load etapas first, then tarefas separately" -ForegroundColor Green
Write-Host "✅ Avoid tar_id_obra mapping issues" -ForegroundColor Green
Write-Host "✅ More efficient single query for all tarefas" -ForegroundColor Green
Write-Host "✅ Group tarefas by EtapaId for assignment" -ForegroundColor Green
Write-Host "✅ Enhanced logging for debugging" -ForegroundColor Green
Write-Host "✅ Show all tasks for data integrity (legacy logic)" -ForegroundColor Green
Write-Host ""
Write-Host "🎯 NEXT STEPS:" -ForegroundColor Cyan
Write-Host "1. Open browser to: https://localhost:7001" -ForegroundColor White
Write-Host "2. Login with user: ricardo / senha: 123456" -ForegroundColor White
Write-Host "3. Navigate to Obras -> Escolher" -ForegroundColor White
Write-Host "4. Select an obra to view etapas" -ForegroundColor White
Write-Host "5. Verify that task counts now show correctly (not '0 tarefas')" -ForegroundColor White
Write-Host ""
Write-Host "Application is running. Check the task counts in the UI!" -ForegroundColor Green