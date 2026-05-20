# RESTART SERVER WITHOUT HOT-RELOAD
# This script restarts the server with hot-reload disabled

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  RESTARTING SERVER WITHOUT HOT-RELOAD                     ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Step 1: Stop any running processes
Write-Host "Step 1: Stopping any running RdoApp processes..." -ForegroundColor Yellow
Get-Process -Name "RdoApp.Core" -ErrorAction SilentlyContinue | Stop-Process -Force
Get-Process -Name "dotnet" -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowTitle -like "*RdoApp*" } | Stop-Process -Force
Write-Host "  ✅ Processes stopped" -ForegroundColor Green
Write-Host ""

# Step 2: Navigate to project directory
Write-Host "Step 2: Navigating to project directory..." -ForegroundColor Yellow
Set-Location "RDO-NET8-Migration\RdoApp.Core"
Write-Host "  ✅ Current directory: $(Get-Location)" -ForegroundColor Green
Write-Host ""

# Step 3: Start server
Write-Host "Step 3: Starting server WITHOUT hot-reload..." -ForegroundColor Yellow
Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║  SERVER STARTING - WATCH FOR THESE LOGS:                  ║" -ForegroundColor Green
Write-Host "║                                                            ║" -ForegroundColor Green
Write-Host "║  ✅ SHOULD SEE:                                            ║" -ForegroundColor Green
Write-Host "║     'Now listening on: https://localhost:7201'             ║" -ForegroundColor Green
Write-Host "║     'Application started'                                  ║" -ForegroundColor Green
Write-Host "║                                                            ║" -ForegroundColor Green
Write-Host "║  ❌ SHOULD NOT SEE:                                        ║" -ForegroundColor Green
Write-Host "║     'BrowserRefreshMiddleware loaded'                      ║" -ForegroundColor Green
Write-Host "║     'BlazorWasmHotReloadMiddleware loaded'                 ║" -ForegroundColor Green
Write-Host "║                                                            ║" -ForegroundColor Green
Write-Host "║  If you DON'T see hot-reload logs, the fix worked! ✅     ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "Starting in 3 seconds..." -ForegroundColor Yellow
Start-Sleep -Seconds 3
Write-Host ""

# Start the server
dotnet run

# Note: This script will keep running until you press Ctrl+C
