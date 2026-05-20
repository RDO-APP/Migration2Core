Write-Host "=== RESTORING WORKING STATE ===" -ForegroundColor Green

# Stop processes
Get-Process -Name "RdoApp.Core" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

# Navigate to project
Set-Location "RDO-NET8-Migration/RdoApp.Core"

# Restore backup files
if (Test-Path "Views/Obra/Escolher.cshtml.backup") {
    Copy-Item "Views/Obra/Escolher.cshtml.backup" "Views/Obra/Escolher.cshtml" -Force
    Write-Host "Restored Escolher.cshtml" -ForegroundColor Green
}

if (Test-Path "Controllers/Api/ObraApiController.cs.backup") {
    Copy-Item "Controllers/Api/ObraApiController.cs.backup" "Controllers/Api/ObraApiController.cs" -Force
    Write-Host "Restored ObraApiController.cs" -ForegroundColor Green
}

# Build
Write-Host "Building..." -ForegroundColor Yellow
dotnet build --no-restore

if ($LASTEXITCODE -eq 0) {
    Write-Host "BUILD SUCCESS!" -ForegroundColor Green
    
    # Start app
    Start-Process -FilePath "dotnet" -ArgumentList "run" -WorkingDirectory (Get-Location) -WindowStyle Hidden
    Start-Sleep -Seconds 8
    
    # Open browser
    Start-Process "https://localhost:7139/Auth/Login"
    
    Write-Host "Application started!" -ForegroundColor Green
    Write-Host "Login: ricardo / 123456" -ForegroundColor Yellow
} else {
    Write-Host "BUILD FAILED!" -ForegroundColor Red
}

Set-Location "../.."