# Simple server start
Write-Host "Starting RDO server..." -ForegroundColor Green

# Kill any existing processes
Get-Process | Where-Object {$_.ProcessName -like "*RdoApp*"} | Stop-Process -Force -ErrorAction SilentlyContinue

# Navigate to project and start
Set-Location "RDO-NET8-Migration/RdoApp.Core"

Write-Host "Building project..." -ForegroundColor Yellow
dotnet build

if ($LASTEXITCODE -eq 0) {
    Write-Host "Starting server on port 8000..." -ForegroundColor Green
    dotnet run --urls "http://localhost:8000"
} else {
    Write-Host "Build failed!" -ForegroundColor Red
}