# Diagnose Browser Loop Issue After F5 Recompilation
Write-Host "🔍 DIAGNOSING BROWSER LOOP ISSUE" -ForegroundColor Yellow
Write-Host ""

# Check if Visual Studio is still running
Write-Host "1. Checking Visual Studio processes..." -ForegroundColor Green
$vsProcesses = Get-Process | Where-Object { $_.ProcessName -like "*devenv*" -or $_.ProcessName -like "*VisualStudio*" }
if ($vsProcesses) {
    Write-Host "   ✅ Visual Studio processes found:" -ForegroundColor Green
    $vsProcesses | ForEach-Object { Write-Host "      - $($_.ProcessName) (PID: $($_.Id))" -ForegroundColor Cyan }
} else {
    Write-Host "   ❌ No Visual Studio processes found" -ForegroundColor Red
}

Write-Host ""

# Check if IIS Express is running
Write-Host "2. Checking IIS Express processes..." -ForegroundColor Green
$iisProcesses = Get-Process | Where-Object { $_.ProcessName -like "*iisexpress*" }
if ($iisProcesses) {
    Write-Host "   ✅ IIS Express processes found:" -ForegroundColor Green
    $iisProcesses | ForEach-Object { Write-Host "      - $($_.ProcessName) (PID: $($_.Id))" -ForegroundColor Cyan }
} else {
    Write-Host "   ❌ No IIS Express processes found" -ForegroundColor Red
}

Write-Host ""

# Check if RdoApp processes are running
Write-Host "3. Checking RdoApp processes..." -ForegroundColor Green
$rdoProcesses = Get-Process | Where-Object { $_.ProcessName -like "*RdoApp*" }
if ($rdoProcesses) {
    Write-Host "   ⚠️  RdoApp processes still running:" -ForegroundColor Yellow
    $rdoProcesses | ForEach-Object { Write-Host "      - $($_.ProcessName) (PID: $($_.Id))" -ForegroundColor Cyan }
} else {
    Write-Host "   ✅ No RdoApp processes found" -ForegroundColor Green
}

Write-Host ""

# Check browser processes
Write-Host "4. Checking browser processes..." -ForegroundColor Green
$browserProcesses = Get-Process | Where-Object { 
    $_.ProcessName -like "*chrome*" -or 
    $_.ProcessName -like "*firefox*" -or 
    $_.ProcessName -like "*edge*" -or 
    $_.ProcessName -like "*msedge*" 
}
if ($browserProcesses) {
    Write-Host "   ✅ Browser processes found:" -ForegroundColor Green
    $browserProcesses | Select-Object ProcessName -Unique | ForEach-Object { 
        Write-Host "      - $($_.ProcessName)" -ForegroundColor Cyan 
    }
} else {
    Write-Host "   ❌ No browser processes found" -ForegroundColor Red
}

Write-Host ""

# Test localhost connection
Write-Host "5. Testing localhost connections..." -ForegroundColor Green
$commonPorts = @(5000, 5001, 44300, 44301, 7000, 7001, 8080, 8081)

foreach ($port in $commonPorts) {
    try {
        $connection = Test-NetConnection -ComputerName "localhost" -Port $port -WarningAction SilentlyContinue
        if ($connection.TcpTestSucceeded) {
            Write-Host "   ✅ Port $port is open" -ForegroundColor Green
        }
    } catch {
        # Port not open, continue silently
    }
}

Write-Host ""

# Check project file for startup URL
Write-Host "6. Checking project startup configuration..." -ForegroundColor Green
$projectPath = "RDO-NET8-Migration/RdoApp.Core"
if (Test-Path "$projectPath/Properties/launchSettings.json") {
    Write-Host "   ✅ Found launchSettings.json" -ForegroundColor Green
    try {
        $launchSettings = Get-Content "$projectPath/Properties/launchSettings.json" | ConvertFrom-Json
        if ($launchSettings.profiles) {
            Write-Host "   📋 Available profiles:" -ForegroundColor Cyan
            $launchSettings.profiles.PSObject.Properties | ForEach-Object {
                $profile = $_.Value
                if ($profile.applicationUrl) {
                    Write-Host "      - $($_.Name): $($profile.applicationUrl)" -ForegroundColor White
                }
            }
        }
    } catch {
        Write-Host "   ⚠️  Could not parse launchSettings.json" -ForegroundColor Yellow
    }
} else {
    Write-Host "   ❌ launchSettings.json not found" -ForegroundColor Red
}

Write-Host ""

# Check for common redirect loop causes
Write-Host "7. Checking for redirect loop causes..." -ForegroundColor Green

# Check Startup.cs or Program.cs for authentication redirects
$startupFiles = @(
    "$projectPath/Startup.cs",
    "$projectPath/Program.cs"
)

foreach ($file in $startupFiles) {
    if (Test-Path $file) {
        Write-Host "   📄 Checking $file..." -ForegroundColor Cyan
        $content = Get-Content $file -Raw
        
        if ($content -match "UseAuthentication|RequireAuthorization|LoginPath") {
            Write-Host "      ⚠️  Authentication configuration found" -ForegroundColor Yellow
        }
        
        if ($content -match "UseHttpsRedirection") {
            Write-Host "      ⚠️  HTTPS redirection enabled" -ForegroundColor Yellow
        }
        
        if ($content -match "app\.UseRouting|app\.MapControllers") {
            Write-Host "      ✅ Routing configuration found" -ForegroundColor Green
        }
    }
}

Write-Host ""

# Provide recommendations
Write-Host "🔧 RECOMMENDATIONS:" -ForegroundColor Yellow
Write-Host ""
Write-Host "If you're experiencing a browser loop:" -ForegroundColor White
Write-Host "1. Stop Visual Studio debugging (Shift+F5)" -ForegroundColor Cyan
Write-Host "2. Close all browser tabs" -ForegroundColor Cyan
Write-Host "3. Clear browser cache (Ctrl+Shift+Delete)" -ForegroundColor Cyan
Write-Host "4. Try incognito/private browsing mode" -ForegroundColor Cyan
Write-Host "5. Check Visual Studio Output window for errors" -ForegroundColor Cyan
Write-Host "6. Look for authentication redirect loops" -ForegroundColor Cyan

Write-Host ""
Write-Host "Next steps:" -ForegroundColor White
Write-Host "- Check Visual Studio Output window" -ForegroundColor Cyan
Write-Host "- Try accessing localhost directly" -ForegroundColor Cyan
Write-Host "- Check browser developer tools (F12)" -ForegroundColor Cyan

Write-Host ""
Write-Host "✅ DIAGNOSIS COMPLETE" -ForegroundColor Green