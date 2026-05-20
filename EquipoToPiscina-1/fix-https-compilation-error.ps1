# Fix HTTPS Compilation Error - .NET 8 RDO Project
# Date: December 28, 2025

Write-Host "🔧 FIXING HTTPS COMPILATION ERROR" -ForegroundColor Yellow
Write-Host "=================================" -ForegroundColor Yellow

# Navigate to project directory
$projectPath = "RDO-NET8-Migration\RdoApp.Core"
Write-Host "📁 Navigating to: $projectPath" -ForegroundColor Cyan

if (Test-Path $projectPath) {
    Set-Location $projectPath
    
    Write-Host "🧹 Cleaning previous build..." -ForegroundColor Cyan
    dotnet clean --verbosity quiet
    
    Write-Host "📦 Restoring NuGet packages..." -ForegroundColor Cyan
    dotnet restore --verbosity quiet
    
    Write-Host "🔨 Attempting compilation..." -ForegroundColor Cyan
    $buildResult = dotnet build --verbosity normal 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ COMPILATION SUCCESSFUL!" -ForegroundColor Green
        Write-Host "🚀 Project is ready for F5 in Visual Studio" -ForegroundColor Green
        
        Write-Host "`n📋 NEXT STEPS:" -ForegroundColor Yellow
        Write-Host "1. Open Visual Studio" -ForegroundColor White
        Write-Host "2. Load RdoApp.Core.csproj" -ForegroundColor White
        Write-Host "3. Press F5 to run" -ForegroundColor White
        Write-Host "4. Test login at: http://localhost:5031/Auth/Login" -ForegroundColor White
        Write-Host "5. Use CPF: 567.065.455-20, Password: RXL8DjdYj6Y=" -ForegroundColor White
    } else {
        Write-Host "❌ COMPILATION FAILED" -ForegroundColor Red
        Write-Host "📋 Build Output:" -ForegroundColor Yellow
        Write-Host $buildResult -ForegroundColor White
        
        Write-Host "`n🔍 TROUBLESHOOTING:" -ForegroundColor Yellow
        Write-Host "- Check if all using statements are correct" -ForegroundColor White
        Write-Host "- Verify .NET 8 SDK is installed" -ForegroundColor White
        Write-Host "- Try 'dotnet --version' to check .NET version" -ForegroundColor White
    }
} else {
    Write-Host "❌ Project directory not found: $projectPath" -ForegroundColor Red
    Write-Host "📁 Current directory: $(Get-Location)" -ForegroundColor Yellow
    Write-Host "📋 Available directories:" -ForegroundColor Yellow
    Get-ChildItem -Directory | Select-Object Name
}

Write-Host "`n🏁 Script completed" -ForegroundColor Cyan