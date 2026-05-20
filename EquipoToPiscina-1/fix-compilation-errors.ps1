# Fix Compilation Errors in RDO Homolog Test Environment
# This script resolves NuGet package restoration and reference issues

Write-Host "🔧 FIXING COMPILATION ERRORS..." -ForegroundColor Yellow
Write-Host ""

# Navigate to the project directory
$projectPath = "RDO-Homolog-Test\rdoappProject"
if (!(Test-Path $projectPath)) {
    Write-Host "❌ Project path not found: $projectPath" -ForegroundColor Red
    exit 1
}

Write-Host "📁 Project path found: $projectPath" -ForegroundColor Green

# Clean bin and obj folders
Write-Host "🧹 Cleaning build folders..." -ForegroundColor Yellow
$binPath = "$projectPath\bin"
$objPath = "$projectPath\obj"

if (Test-Path $binPath) {
    Remove-Item $binPath -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "✅ Bin folder cleaned" -ForegroundColor Green
}

if (Test-Path $objPath) {
    Remove-Item $objPath -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "✅ Obj folder cleaned" -ForegroundColor Green
}

# Check packages folder
$packagesPath = "RDO-Homolog-Test\packages"
if (!(Test-Path $packagesPath)) {
    Write-Host "📦 Creating packages folder..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $packagesPath -Force | Out-Null
}

Write-Host ""
Write-Host "🎯 COMPILATION ERROR SOLUTIONS:" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "SOLUTION 1: NuGet Package Restore (RECOMMENDED)" -ForegroundColor Yellow
Write-Host "1. In Visual Studio: Right-click Solution → Restore NuGet Packages" -ForegroundColor White
Write-Host "2. Wait for completion" -ForegroundColor White
Write-Host "3. Build → Rebuild Solution" -ForegroundColor White
Write-Host ""
Write-Host "SOLUTION 2: Package Manager Console" -ForegroundColor Yellow
Write-Host "1. Tools → NuGet Package Manager → Package Manager Console" -ForegroundColor White
Write-Host "2. Run: Update-Package -Reinstall" -ForegroundColor Cyan
Write-Host "3. Build → Rebuild Solution" -ForegroundColor White
Write-Host ""
Write-Host "SOLUTION 3: Manual Package Installation" -ForegroundColor Yellow
Write-Host "1. Tools → NuGet Package Manager → Manage NuGet Packages for Solution" -ForegroundColor White
Write-Host "2. Go to 'Installed' tab" -ForegroundColor White
Write-Host "3. Update all packages" -ForegroundColor White
Write-Host "4. Build → Rebuild Solution" -ForegroundColor White
Write-Host ""
Write-Host "SOLUTION 4: Clear NuGet Cache" -ForegroundColor Yellow
Write-Host "1. Tools → Options → NuGet Package Manager → General" -ForegroundColor White
Write-Host "2. Click 'Clear All NuGet Cache(s)'" -ForegroundColor White
Write-Host "3. Restart Visual Studio" -ForegroundColor White
Write-Host "4. Restore packages and rebuild" -ForegroundColor White
Write-Host ""
Write-Host "🚀 Try SOLUTION 1 first - it usually resolves NuGet issues!" -ForegroundColor Green
Write-Host ""