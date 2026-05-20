#!/usr/bin/env pwsh

Write-Host "=== DEBUGGING ETAPA EMPTY ISSUE ===" -ForegroundColor Green
Write-Host "DBeaver shows 4 etapas, but web app shows 0. Let's find out why." -ForegroundColor Yellow

# Stop any running processes first
Get-Process | Where-Object {$_.ProcessName -like "*dotnet*" -or $_.ProcessName -like "*RdoApp*"} | Stop-Process -Force -ErrorAction SilentlyContinue

# Navigate to project directory
Set-Location "RDO-NET8-Migration/RdoApp.Core"

Write-Host "`n1. Building project..." -ForegroundColor Cyan
dotnet build --no-restore

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Build failed!" -ForegroundColor Red
    exit 1
}

Write-Host "`n2. Starting application in background..." -ForegroundColor Cyan
$process = Start-Process -FilePath "dotnet" -ArgumentList "run" -PassThru -WindowStyle Hidden -RedirectStandardOutput "app-output.log" -RedirectStandardError "app-errors.log"

Write-Host "Waiting 15 seconds for application to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

Write-Host "`n3. Testing the exact scenario..." -ForegroundColor Cyan

try {
    # Test if application is running
    $testResponse = Invoke-WebRequest -Uri "http://localhost:5031" -TimeoutSec 5 -ErrorAction Stop
    Write-Host "✅ Application is running on port 5031" -ForegroundColor Green
    
    # Login first
    Write-Host "Logging in..." -ForegroundColor Yellow
    $loginData = @{
        cpf = "12345678901"
        senha = "123456"
    }
    
    $loginResponse = Invoke-WebRequest -Uri "http://localhost:5031/Auth/Login" -Method POST -Body $loginData -SessionVariable session
    Write-Host "✅ Login successful" -ForegroundColor Green
    
    # Access the etapas page that should trigger our debug logging
    Write-Host "Accessing Etapas page for obra 1..." -ForegroundColor Yellow
    $etapasResponse = Invoke-WebRequest -Uri "http://localhost:5031/Obra/Etapas/1" -WebSession $session
    
    Write-Host "✅ Etapas page accessed" -ForegroundColor Green
    Write-Host "Response length: $($etapasResponse.Content.Length) characters" -ForegroundColor Cyan
    
    # Check for etapa content in the response
    if ($etapasResponse.Content -match "etapa-accordion|Etapa \d+|etapa-card") {
        Write-Host "✅ Page contains etapa elements" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Page does NOT contain etapa elements" -ForegroundColor Yellow
    }
    
    # Check for empty state indicators
    if ($etapasResponse.Content -match "Nenhuma etapa|empty|0 etapas") {
        Write-Host "⚠️  Page shows empty state" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n4. Checking application logs..." -ForegroundColor Cyan

# Wait a moment for logs to be written
Start-Sleep -Seconds 2

# Check if log files exist and show relevant content
if (Test-Path "app-output.log") {
    Write-Host "`n=== APPLICATION OUTPUT LOG ===" -ForegroundColor Green
    $logContent = Get-Content "app-output.log" -ErrorAction SilentlyContinue
    
    # Filter for our debug messages
    $debugLines = $logContent | Where-Object { 
        $_ -match "DEBUG.*Etapa|ObterEtapasViewModelAsync|Etapas encontradas|RESULTADO FINAL|ObraId recebido|MAPPING" 
    }
    
    if ($debugLines) {
        $debugLines | ForEach-Object { Write-Host $_ -ForegroundColor White }
    } else {
        Write-Host "No debug messages found in output log" -ForegroundColor Yellow
        # Show last 20 lines of log
        Write-Host "`nLast 20 lines of output log:" -ForegroundColor Cyan
        $logContent | Select-Object -Last 20 | ForEach-Object { Write-Host $_ -ForegroundColor Gray }
    }
} else {
    Write-Host "No output log file found" -ForegroundColor Yellow
}

if (Test-Path "app-errors.log") {
    $errorContent = Get-Content "app-errors.log" -ErrorAction SilentlyContinue
    if ($errorContent) {
        Write-Host "`n=== APPLICATION ERROR LOG ===" -ForegroundColor Red
        $errorContent | ForEach-Object { Write-Host $_ -ForegroundColor Red }
    }
}

# Stop the application
Write-Host "`n5. Stopping application..." -ForegroundColor Cyan
if ($process -and !$process.HasExited) {
    $process.Kill()
    $process.WaitForExit(5000)
}

# Clean up log files
Remove-Item "app-output.log" -ErrorAction SilentlyContinue
Remove-Item "app-errors.log" -ErrorAction SilentlyContinue

Write-Host "`n=== DEBUGGING COMPLETED ===" -ForegroundColor Green
Write-Host "Key things to check:" -ForegroundColor Yellow
Write-Host "1. Did we see 'ObraId recebido: 1' in the logs?" -ForegroundColor White
Write-Host "2. Did we see 'Etapas encontradas no banco: 4'?" -ForegroundColor White
Write-Host "3. Did we see any mapping errors?" -ForegroundColor White
Write-Host "4. Did we see 'RESULTADO FINAL: 0 etapas no ViewModel'?" -ForegroundColor White