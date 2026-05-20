# Open Visual Studio Manually - Simple Approach
Write-Host "🎯 OPENING VISUAL STUDIO FOR DEBUGGING" -ForegroundColor Yellow
Write-Host ""

# Try common Visual Studio paths
$vsPaths = @(
    "${env:ProgramFiles}\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe",
    "${env:ProgramFiles}\Microsoft Visual Studio\2022\Professional\Common7\IDE\devenv.exe",
    "${env:ProgramFiles}\Microsoft Visual Studio\2022\Enterprise\Common7\IDE\devenv.exe",
    "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\Community\Common7\IDE\devenv.exe",
    "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\Professional\Common7\IDE\devenv.exe"
)

$vsFound = $false
foreach ($path in $vsPaths) {
    if (Test-Path $path) {
        Write-Host "✅ Found Visual Studio at: $path" -ForegroundColor Green
        Write-Host "🚀 Opening Visual Studio with RdoApp.Core.sln..." -ForegroundColor Cyan
        
        try {
            Start-Process -FilePath $path -ArgumentList "RDO-NET8-Migration\RdoApp.Core\RdoApp.Core.sln"
            $vsFound = $true
            break
        } catch {
            Write-Host "❌ Error opening Visual Studio: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

if (-not $vsFound) {
    Write-Host "❌ Visual Studio not found in common locations" -ForegroundColor Red
    Write-Host ""
    Write-Host "🔧 MANUAL STEPS:" -ForegroundColor Yellow
    Write-Host "1. Open Visual Studio manually from Start Menu" -ForegroundColor White
    Write-Host "2. File → Open → Project/Solution" -ForegroundColor White
    Write-Host "3. Navigate to: RDO-NET8-Migration\RdoApp.Core\RdoApp.Core.sln" -ForegroundColor White
    Write-Host "4. Press F5 to start debugging" -ForegroundColor White
    Write-Host ""
    Write-Host "🎯 OR DOUBLE-CLICK:" -ForegroundColor Cyan
    Write-Host "   Double-click RdoApp.Core.sln file in Windows Explorer" -ForegroundColor White
} else {
    Write-Host ""
    Write-Host "🎯 NEXT STEPS:" -ForegroundColor Cyan
    Write-Host "1. Wait for Visual Studio to load the solution" -ForegroundColor White
    Write-Host "2. Press F5 to start debugging" -ForegroundColor White
    Write-Host "3. Navigate to /Obra/Escolher in browser" -ForegroundColor White
    Write-Host "4. Use F12 Developer Tools to check for errors" -ForegroundColor White
}

Write-Host ""
Write-Host "📋 DEBUGGING CHECKLIST:" -ForegroundColor Yellow
Write-Host "□ Visual Studio opened with solution" -ForegroundColor White
Write-Host "□ F5 pressed (debugging started)" -ForegroundColor White
Write-Host "□ Browser opened to https://localhost:7139" -ForegroundColor White
Write-Host "□ Navigated to /Obra/Escolher" -ForegroundColor White
Write-Host "□ F12 Developer Tools opened" -ForegroundColor White
Write-Host "□ Console tab checked for JavaScript errors" -ForegroundColor White
Write-Host "□ Network tab checked for API calls" -ForegroundColor White