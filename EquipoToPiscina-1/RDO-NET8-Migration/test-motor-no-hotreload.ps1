# Motor Test - Disable Blazor Hot-Reload Middleware
# This script runs the application WITHOUT hot-reload to bypass middleware interference

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "MOTOR TEST - NO HOT-RELOAD" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Stop any running processes
Write-Host "[1/4] Stopping any running dotnet processes..." -ForegroundColor Yellow
Get-Process -Name "dotnet" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

# Set environment variable to suppress browser refresh
Write-Host "[2/4] Disabling Blazor hot-reload middleware..." -ForegroundColor Yellow
$env:DOTNET_WATCH_SUPPRESS_BROWSER_REFRESH = "1"
Write-Host "   Environment variable set: DOTNET_WATCH_SUPPRESS_BROWSER_REFRESH=1" -ForegroundColor Green

# Navigate to project directory
Write-Host "[3/4] Navigating to project directory..." -ForegroundColor Yellow
Set-Location "RDO-NET8-Migration\RdoApp.Core"

# Run without hot-reload
Write-Host "[4/4] Starting application WITHOUT hot-reload..." -ForegroundColor Yellow
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "APPLICATION STARTING" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Once the application starts:" -ForegroundColor Cyan
Write-Host "1. Open browser to: https://localhost:7201/Obra/Escolher" -ForegroundColor White
Write-Host "2. You should see a BLUE SCREEN with 'MOTOR IS RUNNING'" -ForegroundColor White
Write-Host "3. If you see the blue screen, the motor works!" -ForegroundColor White
Write-Host "4. Press Ctrl+C to stop the server" -ForegroundColor White
Write-Host ""

# Run without hot-reload
dotnet run --no-hot-reload
