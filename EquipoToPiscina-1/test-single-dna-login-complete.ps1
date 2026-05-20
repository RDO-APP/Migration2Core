# Test Single DNA Login - Complete Verification
Write-Host "Testing Single DNA Login Implementation" -ForegroundColor Cyan

# Build and test the application
Set-Location "RDO-NET8-Migration/RdoApp.Core"

Write-Host "Building application..." -ForegroundColor Yellow
dotnet build --configuration Release

if ($LASTEXITCODE -eq 0) {
    Write-Host "Build successful" -ForegroundColor Green
    
    # Start server
    Write-Host "Starting server on https://localhost:7201..." -ForegroundColor Yellow
    Start-Process -FilePath "dotnet" -ArgumentList "run --urls=https://localhost:7201" -WindowStyle Normal
    
    Write-Host "Server started. Please test in browser:" -ForegroundColor Green
    Write-Host "1. Navigate to https://localhost:7201" -ForegroundColor White
    Write-Host "2. Check F12 console for 404 errors" -ForegroundColor White
    Write-Host "3. Verify logo displays correctly" -ForegroundColor White
    Write-Host "4. Test login functionality" -ForegroundColor White
    
} else {
    Write-Host "Build failed" -ForegroundColor Red
}

Set-Location "../.."