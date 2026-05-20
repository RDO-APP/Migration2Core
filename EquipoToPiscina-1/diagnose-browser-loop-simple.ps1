# Simple Browser Loop Diagnosis
Write-Host "🔍 DIAGNOSING BROWSER LOOP ISSUE" -ForegroundColor Yellow
Write-Host ""

# Check Visual Studio processes
Write-Host "1. Checking Visual Studio processes..." -ForegroundColor Green
$vsProcesses = Get-Process | Where-Object { $_.ProcessName -like "*devenv*" }
if ($vsProcesses) {
    Write-Host "   ✅ Visual Studio running" -ForegroundColor Green
} else {
    Write-Host "   ❌ Visual Studio not found" -ForegroundColor Red
}

# Check IIS Express processes
Write-Host "2. Checking IIS Express..." -ForegroundColor Green
$iisProcesses = Get-Process | Where-Object { $_.ProcessName -like "*iisexpress*" }
if ($iisProcesses) {
    Write-Host "   ✅ IIS Express running" -ForegroundColor Green
} else {
    Write-Host "   ❌ IIS Express not running" -ForegroundColor Red
}

# Check common ports
Write-Host "3. Testing common ports..." -ForegroundColor Green
$ports = @(5000, 5001, 44300, 44301)
foreach ($port in $ports) {
    try {
        $connection = Test-NetConnection -ComputerName "localhost" -Port $port -WarningAction SilentlyContinue
        if ($connection.TcpTestSucceeded) {
            Write-Host "   ✅ Port $port is open" -ForegroundColor Green
        }
    } catch {
        # Continue silently
    }
}

Write-Host ""
Write-Host "🔧 IMMEDIATE ACTIONS TO TRY:" -ForegroundColor Yellow
Write-Host "1. Press Shift+F5 in Visual Studio to stop debugging" -ForegroundColor Cyan
Write-Host "2. Close all browser tabs" -ForegroundColor Cyan
Write-Host "3. Open browser in incognito mode" -ForegroundColor Cyan
Write-Host "4. Try navigating to https://localhost:44300 directly" -ForegroundColor Cyan
Write-Host "5. Check Visual Studio Output window for errors" -ForegroundColor Cyan

Write-Host ""
Write-Host "If still looping, the issue might be:" -ForegroundColor White
Write-Host "- Authentication redirect loop" -ForegroundColor Yellow
Write-Host "- HTTPS redirection issue" -ForegroundColor Yellow
Write-Host "- Session/cookie problems" -ForegroundColor Yellow

Write-Host ""
Write-Host "✅ DIAGNOSIS COMPLETE" -ForegroundColor Green