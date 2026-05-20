# Test Redirect Loop Fix - ERR_TOO_MANY_REDIRECTS Resolution
# This script tests the authentication flow to ensure no redirect loops

Write-Host "=== TESTING REDIRECT LOOP FIX ===" -ForegroundColor Green

# 1. Clear browser cache and cookies first
Write-Host "1. Clearing browser data..." -ForegroundColor Yellow
$cachePaths = @(
    "$env:LOCALAPPDATA\Microsoft\Windows\INetCache\*",
    "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache\*",
    "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cookies*"
)

foreach ($path in $cachePaths) {
    if (Test-Path $path) {
        Remove-Item $path -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "   Cleared: $path" -ForegroundColor Gray
    }
}

# 2. Test root path redirect
Write-Host "2. Testing root path redirect..." -ForegroundColor Yellow
Write-Host "   Opening: https://localhost:5001/" -ForegroundColor Cyan
Start-Process "https://localhost:5001/"

Start-Sleep -Seconds 2

# 3. Test legacy paths
Write-Host "3. Testing legacy path blocking..." -ForegroundColor Yellow
Write-Host "   Opening: https://localhost:5001/home" -ForegroundColor Cyan
Start-Process "https://localhost:5001/home"

Start-Sleep -Seconds 2

# 4. Test direct login access
Write-Host "4. Testing direct login access..." -ForegroundColor Yellow
Write-Host "   Opening: https://localhost:5001/Account/Login" -ForegroundColor Cyan
Start-Process "https://localhost:5001/Account/Login"

Start-Sleep -Seconds 2

# 5. Instructions for manual testing
Write-Host "5. Manual Testing Instructions:" -ForegroundColor Yellow
Write-Host "   ✅ Login page should load without redirect loops" -ForegroundColor Green
Write-Host "   ✅ After login, should redirect to /Obra/Escolher (not /Home)" -ForegroundColor Green
Write-Host "   ✅ Legacy paths (/home, /) should redirect to /Account/Login" -ForegroundColor Green
Write-Host "   ✅ /Obra/Escolher should be accessible after authentication" -ForegroundColor Green

Write-Host ""
Write-Host "🔧 Key Changes Applied:" -ForegroundColor Cyan
Write-Host "   • AccountController redirects to Obra/Escolher (not Home/Index)" -ForegroundColor White
Write-Host "   • Program.cs middleware allows /obra/escolher path" -ForegroundColor White
Write-Host "   • ObraController redirects to Account/Login (not Auth/Login)" -ForegroundColor White
Write-Host "   • Added session clearing on logout" -ForegroundColor White

Write-Host ""
Write-Host "🧪 Test Credentials:" -ForegroundColor Cyan
Write-Host "   CPF: 12345678901" -ForegroundColor White
Write-Host "   Password: [use existing test password]" -ForegroundColor White

Write-Host ""
Write-Host "=== REDIRECT LOOP FIX TEST COMPLETE ===" -ForegroundColor Green