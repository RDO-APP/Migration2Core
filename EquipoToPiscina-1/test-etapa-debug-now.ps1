# Quick test to run the application and see debug output
Write-Host "=== TESTING ETAPA DEBUG OUTPUT ===" -ForegroundColor Yellow

Write-Host "Starting application..." -ForegroundColor Green
Set-Location "RDO-NET8-Migration/RdoApp.Core"

# Start the application in background
Start-Process -FilePath "dotnet" -ArgumentList "run" -NoNewWindow -PassThru

Write-Host "Application started. Please:" -ForegroundColor Cyan
Write-Host "1. Open your browser to https://localhost:5001" -ForegroundColor White
Write-Host "2. Login with your credentials" -ForegroundColor White
Write-Host "3. Navigate to an obra and click on 'Etapas'" -ForegroundColor White
Write-Host "4. Check this console window for debug output" -ForegroundColor White
Write-Host ""
Write-Host "Press any key to stop the application..." -ForegroundColor Yellow

# Wait for user input
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# Stop the application
Get-Process -Name "dotnet" -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -eq "dotnet" } | Stop-Process -Force

Set-Location "../.."
Write-Host "Application stopped." -ForegroundColor Green