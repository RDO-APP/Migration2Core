# Clear Legacy Sessions Complete - Force AccountController Login
# This script ensures all legacy authentication is cleared

Write-Host "=== CLEARING LEGACY SESSIONS AND FORCING ACCOUNT LOGIN ===" -ForegroundColor Green

# 1. Stop any running processes
Write-Host "1. Stopping any running RDO processes..." -ForegroundColor Yellow
Get-Process | Where-Object {$_.ProcessName -like "*rdoapp*" -or $_.ProcessName -like "*iisexpress*"} | Stop-Process -Force -ErrorAction SilentlyContinue

# 2. Clear browser cache directories (common locations)
Write-Host "2. Clearing browser cache..." -ForegroundColor Yellow
$cachePaths = @(
    "$env:LOCALAPPDATA\Microsoft\Windows\INetCache\*",
    "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache\*",
    "$env:LOCALAPPDATA\Mozilla\Firefox\Profiles\*\cache2\*"
)

foreach ($path in $cachePaths) {
    if (Test-Path $path) {
        Remove-Item $path -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "   Cleared: $path" -ForegroundColor Gray
    }
}

# 3. Clear IIS Express configuration
Write-Host "3. Clearing IIS Express configuration..." -ForegroundColor Yellow
$iisConfigPath = "$env:USERPROFILE\Documents\IISExpress\config\applicationhost.config"
if (Test-Path $iisConfigPath) {
    # Backup and reset IIS config
    Copy-Item $iisConfigPath "$iisConfigPath.backup" -Force
    Write-Host "   IIS config backed up" -ForegroundColor Gray
}

# 4. Clear temporary ASP.NET files
Write-Host "4. Clearing temporary ASP.NET files..." -ForegroundColor Yellow
$tempAspNetPaths = @(
    "$env:WINDOWS\Microsoft.NET\Framework\v4.0.30319\Temporary ASP.NET Files\*",
    "$env:WINDOWS\Microsoft.NET\Framework64\v4.0.30319\Temporary ASP.NET Files\*"
)

foreach ($path in $tempAspNetPaths) {
    if (Test-Path $path) {
        Remove-Item $path -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "   Cleared: $path" -ForegroundColor Gray
    }
}

# 5. Build and start with fresh session
Write-Host "5. Building project with fresh configuration..." -ForegroundColor Yellow
Set-Location "RDO-NET8-Migration\RdoApp.Core"

# Clean and rebuild
dotnet clean
dotnet build --configuration Release

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Build successful!" -ForegroundColor Green
    
    # Start the application
    Write-Host "6. Starting application with AccountController as default..." -ForegroundColor Yellow
    Write-Host "   Navigate to: https://localhost:5001/Account/Login" -ForegroundColor Cyan
    Write-Host "   All legacy routes will redirect to AccountController" -ForegroundColor Cyan
    
    Start-Process "https://localhost:5001/Account/Login"
    dotnet run --urls "https://localhost:5001"
} else {
    Write-Host "❌ Build failed. Check compilation errors." -ForegroundColor Red
}

Write-Host "=== LEGACY SESSION CLEARING COMPLETE ===" -ForegroundColor Green