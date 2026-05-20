#!/usr/bin/env pwsh

Write-Host "=== TESTING ENHANCED ETAPA DEBUG LOGGING ===" -ForegroundColor Green

# Stop any running processes first
Get-Process | Where-Object {$_.ProcessName -like "*dotnet*" -or $_.ProcessName -like "*RdoApp*"} | Stop-Process -Force -ErrorAction SilentlyContinue

# Navigate to project directory
Set-Location "RDO-NET8-Migration/RdoApp.Core"

Write-Host "`nStarting application and monitoring console output..." -ForegroundColor Cyan
Write-Host "The debug logs from EtapaService should appear in the console." -ForegroundColor Yellow
Write-Host "Press Ctrl+C to stop the application when you see the debug output." -ForegroundColor Yellow

# Start the application and show console output
dotnet run