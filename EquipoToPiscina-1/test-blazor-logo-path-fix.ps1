# Test Blazor Logo Path Resolution Fix
Write-Host "Testing Blazor Logo Path Resolution Fix" -ForegroundColor Cyan

# Build the application
Set-Location "RDO-NET8-Migration/RdoApp.Core"

Write-Host "Building application..." -ForegroundColor Yellow
dotnet build --configuration Release

if ($LASTEXITCODE -eq 0) {
    Write-Host "Build successful" -ForegroundColor Green
    
    # Verify logo file exists
    $logoPath = "wwwroot/images/logo.jpg"
    if (Test-Path $logoPath) {
        $logoSize = (Get-Item $logoPath).Length
        Write-Host "Logo file verified: $logoPath ($logoSize bytes)" -ForegroundColor Green
    } else {
        Write-Host "ERROR: Logo file missing at $logoPath" -ForegroundColor Red
    }
    
    Write-Host "`nStarting server for testing..." -ForegroundColor Yellow
    Write-Host "Navigate to: https://localhost:7201" -ForegroundColor Green
    Write-Host "`nExpected results:" -ForegroundColor Yellow
    Write-Host "1. Logo should display correctly (no broken image)" -ForegroundColor White
    Write-Host "2. F12 Console should show NO 404 errors for logo" -ForegroundColor White
    Write-Host "3. Console should show 'LOGIN PAGE: Anonymous state expected'" -ForegroundColor White
    Write-Host "4. No 'Bridge Failure' messages should appear" -ForegroundColor White
    
    # Start the server
    dotnet run --urls=https://localhost:7201
    
} else {
    Write-Host "Build failed" -ForegroundColor Red
}

Set-Location "../.."