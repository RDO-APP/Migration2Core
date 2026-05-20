# 🚨 CLEAR LEGACY SESSION SCRIPT
# This script clears browser cache and forces a fresh start with the new AccountController

Write-Host "🚨 CLEARING LEGACY SESSION AND CACHE" -ForegroundColor Red
Write-Host "=====================================" -ForegroundColor Yellow

# Stop any running application processes
Write-Host "1. Stopping application processes..." -ForegroundColor Cyan
try {
    Get-Process -Name "RdoApp*" -ErrorAction SilentlyContinue | Stop-Process -Force
    Get-Process -Name "dotnet" -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -like "*RdoApp*" } | Stop-Process -Force
    Write-Host "   ✅ Application processes stopped" -ForegroundColor Green
} catch {
    Write-Host "   ⚠️ No application processes found" -ForegroundColor Yellow
}

# Clear browser cache (Chrome)
Write-Host "`n2. Clearing Chrome browser cache..." -ForegroundColor Cyan
try {
    $chromePath = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default"
    if (Test-Path $chromePath) {
        Remove-Item "$chromePath\Cookies*" -Force -ErrorAction SilentlyContinue
        Remove-Item "$chromePath\Cache*" -Force -Recurse -ErrorAction SilentlyContinue
        Remove-Item "$chromePath\Local Storage*" -Force -Recurse -ErrorAction SilentlyContinue
        Remove-Item "$chromePath\Session Storage*" -Force -Recurse -ErrorAction SilentlyContinue
        Write-Host "   ✅ Chrome cache cleared" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️ Chrome not found" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ❌ Error clearing Chrome cache: $($_.Exception.Message)" -ForegroundColor Red
}

# Clear browser cache (Edge)
Write-Host "`n3. Clearing Edge browser cache..." -ForegroundColor Cyan
try {
    $edgePath = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default"
    if (Test-Path $edgePath) {
        Remove-Item "$edgePath\Cookies*" -Force -ErrorAction SilentlyContinue
        Remove-Item "$edgePath\Cache*" -Force -Recurse -ErrorAction SilentlyContinue
        Remove-Item "$edgePath\Local Storage*" -Force -Recurse -ErrorAction SilentlyContinue
        Remove-Item "$edgePath\Session Storage*" -Force -Recurse -ErrorAction SilentlyContinue
        Write-Host "   ✅ Edge cache cleared" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️ Edge not found" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ❌ Error clearing Edge cache: $($_.Exception.Message)" -ForegroundColor Red
}

# Clear application cache folders
Write-Host "`n4. Clearing application cache..." -ForegroundColor Cyan
try {
    $binPaths = @(
        "RDO-NET8-Migration\RdoApp.Core\bin",
        "RDO-NET8-Migration\RdoApp.Core\obj",
        "rdoappProject\bin",
        "rdoappProject\obj"
    )
    
    foreach ($path in $binPaths) {
        if (Test-Path $path) {
            Remove-Item $path -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "   ✅ Cleared $path" -ForegroundColor Green
        }
    }
} catch {
    Write-Host "   ❌ Error clearing application cache: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n🎯 NEXT STEPS:" -ForegroundColor Yellow
Write-Host "===============" -ForegroundColor Yellow
Write-Host "1. Press F5 in Visual Studio to rebuild and start" -ForegroundColor White
Write-Host "2. Open browser in INCOGNITO/PRIVATE mode" -ForegroundColor White
Write-Host "3. Navigate to: https://localhost:7201/" -ForegroundColor White
Write-Host "4. Should redirect to: /Account/Login (NEW RAZOR)" -ForegroundColor White
Write-Host "5. Login with: CPF 567.065.455-20, Password RXL8DjdYj6Y=" -ForegroundColor White

Write-Host "`n🚨 IMPORTANT:" -ForegroundColor Red
Write-Host "- Use INCOGNITO mode to avoid cached sessions" -ForegroundColor Yellow
Write-Host "- If still redirected to legacy, check Program.cs middleware" -ForegroundColor Yellow
Write-Host "- The new login should show 'AccountController Login' debug info" -ForegroundColor Yellow

Write-Host "`n✅ LEGACY SESSION CLEARING COMPLETE!" -ForegroundColor Green