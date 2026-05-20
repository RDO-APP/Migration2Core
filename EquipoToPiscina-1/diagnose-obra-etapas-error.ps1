# Diagnose Obra Etapas Error
Write-Host "=== DIAGNOSING OBRA ETAPAS ERROR ===" -ForegroundColor Yellow

# Stop any running processes
Write-Host "Stopping any running processes..." -ForegroundColor Cyan
Get-Process -Name "RdoApp.Core" -ErrorAction SilentlyContinue | Stop-Process -Force
Get-Process -Name "dotnet" -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -eq "dotnet" -and $_.MainWindowTitle -like "*RdoApp*" } | Stop-Process -Force

# Build the project
Write-Host "Building project..." -ForegroundColor Cyan
Set-Location "RDO-NET8-Migration/RdoApp.Core"
dotnet build --no-restore

if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed! Fix compilation errors first." -ForegroundColor Red
    exit 1
}

# Start the application with detailed logging
Write-Host "Starting application with detailed error logging..." -ForegroundColor Cyan
$env:ASPNETCORE_ENVIRONMENT = "Development"
$env:ASPNETCORE_DETAILEDERRORS = "true"

# Start in background and capture output
Start-Process -FilePath "dotnet" -ArgumentList "run --no-build" -NoNewWindow -RedirectStandardOutput "app-output.log" -RedirectStandardError "app-errors.log"

# Wait for startup
Write-Host "Waiting for application to start..." -ForegroundColor Cyan
Start-Sleep -Seconds 5

# Check if app is running
$process = Get-Process -Name "RdoApp.Core" -ErrorAction SilentlyContinue
if ($process) {
    Write-Host "Application started successfully. Process ID: $($process.Id)" -ForegroundColor Green
    
    # Open browser to test
    Write-Host "Opening browser to test..." -ForegroundColor Cyan
    Start-Process "https://localhost:7201"
    
    Write-Host "=== INSTRUCTIONS ===" -ForegroundColor Yellow
    Write-Host "1. Login to the application" -ForegroundColor White
    Write-Host "2. Select an obra from the list" -ForegroundColor White
    Write-Host "3. If you get an error, check the logs below:" -ForegroundColor White
    Write-Host ""
    Write-Host "=== MONITORING LOGS ===" -ForegroundColor Yellow
    Write-Host "Press Ctrl+C to stop monitoring and view full logs" -ForegroundColor White
    
    # Monitor logs in real-time
    try {
        Get-Content "app-output.log", "app-errors.log" -Wait -Tail 10
    }
    catch {
        Write-Host "Monitoring stopped." -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host "=== FULL ERROR LOG ===" -ForegroundColor Red
    if (Test-Path "app-errors.log") {
        Get-Content "app-errors.log"
    }
    
    Write-Host ""
    Write-Host "=== FULL OUTPUT LOG ===" -ForegroundColor Cyan
    if (Test-Path "app-output.log") {
        Get-Content "app-output.log" | Select-Object -Last 50
    }
    
} else {
    Write-Host "Failed to start application!" -ForegroundColor Red
    if (Test-Path "app-errors.log") {
        Write-Host "=== STARTUP ERRORS ===" -ForegroundColor Red
        Get-Content "app-errors.log"
    }
}