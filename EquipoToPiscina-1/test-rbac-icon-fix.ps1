# Test RBAC Icon Fix - User Group Based Icons
Write-Host "=== TESTING RBAC ICON FIX ===" -ForegroundColor Green

# Navigate to project directory
Set-Location "RDO-NET8-Migration\RdoApp.Core"

Write-Host "Building project..." -ForegroundColor Yellow
dotnet build --no-restore

if ($LASTEXITCODE -eq 0) {
    Write-Host "Build successful! Starting application..." -ForegroundColor Green
    
    # Start the application
    Start-Process "dotnet" -ArgumentList "run" -NoNewWindow
    
    # Wait for application to start
    Start-Sleep -Seconds 5
    
    Write-Host "Opening browser to test icon display..." -ForegroundColor Yellow
    Start-Process "https://localhost:7297/Auth/Login"
    
    Write-Host ""
    Write-Host "=== TEST INSTRUCTIONS ===" -ForegroundColor Cyan
    Write-Host "1. Login with CPF: 12345678901 and Password: 1234"
    Write-Host "2. Check if icons display correctly on obra cards"
    Write-Host "3. Icons should now show based on user's group permissions:"
    Write-Host "   - Contratante users: see 'contratante' icons"
    Write-Host "   - Contratada users: see 'contratada' icons"
    Write-Host ""
    Write-Host "=== EXPECTED BEHAVIOR ===" -ForegroundColor Yellow
    Write-Host "- Icons should appear (no more missing icons)"
    Write-Host "- Icon type matches user's role in the project"
    Write-Host "- Same obra may show different icons to different users"
    Write-Host ""
    Write-Host "Press any key to stop the application..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    
    # Stop the application
    Get-Process -Name "dotnet" -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowTitle -like "*RdoApp*" } | Stop-Process -Force
    Write-Host "Application stopped." -ForegroundColor Green
} else {
    Write-Host "Build failed! Check errors above." -ForegroundColor Red
}

Write-Host "=== TEST COMPLETE ===" -ForegroundColor Green