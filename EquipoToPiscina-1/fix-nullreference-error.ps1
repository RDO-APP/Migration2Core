# Fix NullReference Error - .NET 8 RDO Project
# Date: December 28, 2025

Write-Host "🔧 FIXING NULLREFERENCE ERROR" -ForegroundColor Yellow
Write-Host "==============================" -ForegroundColor Yellow

# Navigate to project directory
$projectPath = "RDO-NET8-Migration\RdoApp.Core"
Write-Host "📁 Navigating to: $projectPath" -ForegroundColor Cyan

if (Test-Path $projectPath) {
    Set-Location $projectPath
    
    Write-Host "⚠️  IMPORTANT: Make sure to STOP the application in Visual Studio first!" -ForegroundColor Red
    Write-Host "   - Click the STOP button (red square) in Visual Studio" -ForegroundColor Yellow
    Write-Host "   - Or press Shift+F5 to stop debugging" -ForegroundColor Yellow
    Write-Host "   - Or close the browser window" -ForegroundColor Yellow
    
    Write-Host "`n🔍 Checking for running processes..." -ForegroundColor Cyan
    $processes = Get-Process -Name "RdoApp.Core" -ErrorAction SilentlyContinue
    if ($processes) {
        Write-Host "❌ Found running RdoApp.Core processes:" -ForegroundColor Red
        $processes | ForEach-Object { Write-Host "   Process ID: $($_.Id)" -ForegroundColor Yellow }
        Write-Host "   Please stop the application in Visual Studio and try again." -ForegroundColor Red
        return
    }
    
    Write-Host "✅ No running processes found. Proceeding with build..." -ForegroundColor Green
    
    Write-Host "🧹 Cleaning previous build..." -ForegroundColor Cyan
    dotnet clean --verbosity quiet
    
    Write-Host "📦 Restoring NuGet packages..." -ForegroundColor Cyan
    dotnet restore --verbosity quiet
    
    Write-Host "🔨 Building project..." -ForegroundColor Cyan
    $buildResult = dotnet build --verbosity normal 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ BUILD SUCCESSFUL!" -ForegroundColor Green
        Write-Host "🔧 NullReference error has been fixed in Error.cshtml" -ForegroundColor Green
        
        Write-Host "`n📋 NEXT STEPS:" -ForegroundColor Yellow
        Write-Host "1. Press F5 in Visual Studio to run the application" -ForegroundColor White
        Write-Host "2. Try accessing the login page in incognito mode" -ForegroundColor White
        Write-Host "3. The error page should now work properly if any errors occur" -ForegroundColor White
        Write-Host "4. Login URL: http://localhost:5031/Auth/Login" -ForegroundColor White
        Write-Host "5. Test credentials: CPF 567.065.455-20, Password RXL8DjdYj6Y=" -ForegroundColor White
    } else {
        Write-Host "❌ BUILD FAILED" -ForegroundColor Red
        Write-Host "📋 Build Output:" -ForegroundColor Yellow
        Write-Host $buildResult -ForegroundColor White
    }
} else {
    Write-Host "❌ Project directory not found: $projectPath" -ForegroundColor Red
}

Write-Host "`n🏁 Script completed" -ForegroundColor Cyan