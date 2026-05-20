# Prepare project for Visual Studio F5 debugging
Write-Host "🔧 PREPARING FOR VISUAL STUDIO F5 DEBUGGING" -ForegroundColor Green
Write-Host ""

# Step 1: Kill any running processes
Write-Host "1️⃣  Stopping all RDO processes..." -ForegroundColor Yellow
Get-Process | Where-Object {$_.ProcessName -like "*RdoApp*"} | ForEach-Object {
    Write-Host "   Stopping: $($_.ProcessName) (PID: $($_.Id))" -ForegroundColor Gray
    Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
}

Get-Process dotnet -ErrorAction SilentlyContinue | ForEach-Object {
    if ($_.MainWindowTitle -like "*RdoApp*" -or $_.CommandLine -like "*RdoApp*") {
        Write-Host "   Stopping dotnet: PID $($_.Id)" -ForegroundColor Gray
        Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
    }
}

# Step 2: Clean project
Write-Host ""
Write-Host "2️⃣  Cleaning project..." -ForegroundColor Yellow
Set-Location "RDO-NET8-Migration/RdoApp.Core"

# Remove locked files
Remove-Item -Path "bin\Debug\net8.0\RdoApp.Core.exe" -Force -ErrorAction SilentlyContinue
Remove-Item -Path "obj\Debug\net8.0\apphost.exe" -Force -ErrorAction SilentlyContinue

dotnet clean --verbosity quiet

# Step 3: Build project
Write-Host ""
Write-Host "3️⃣  Building project..." -ForegroundColor Yellow
dotnet build --verbosity quiet

if ($LASTEXITCODE -eq 0) {
    Write-Host "   ✅ Build successful!" -ForegroundColor Green
} else {
    Write-Host "   ❌ Build failed!" -ForegroundColor Red
    Write-Host "   Check build errors above" -ForegroundColor Yellow
    exit 1
}

# Step 4: Open Visual Studio
Write-Host ""
Write-Host "4️⃣  Opening Visual Studio..." -ForegroundColor Yellow

# Try to find Visual Studio
$vsPath = ""
$vsPaths = @(
    "${env:ProgramFiles}\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe",
    "${env:ProgramFiles}\Microsoft Visual Studio\2022\Professional\Common7\IDE\devenv.exe",
    "${env:ProgramFiles}\Microsoft Visual Studio\2022\Enterprise\Common7\IDE\devenv.exe",
    "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\Community\Common7\IDE\devenv.exe",
    "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\Professional\Common7\IDE\devenv.exe"
)

foreach ($path in $vsPaths) {
    if (Test-Path $path) {
        $vsPath = $path
        break
    }
}

if ($vsPath) {
    Write-Host "   Found Visual Studio at: $vsPath" -ForegroundColor Green
    Write-Host "   Opening RdoApp.Core.sln..." -ForegroundColor Green
    
    # Open Visual Studio with the solution
    Start-Process -FilePath $vsPath -ArgumentList "RdoApp.Core.sln"
    
    Write-Host ""
    Write-Host "🎉 READY FOR F5 DEBUGGING!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📋 NEXT STEPS:" -ForegroundColor Cyan
    Write-Host "   1. Wait for Visual Studio to fully load" -ForegroundColor White
    Write-Host "   2. Set breakpoints if needed" -ForegroundColor White
    Write-Host "   3. Press F5 to start debugging" -ForegroundColor White
    Write-Host "   4. The app will start on https://localhost:7031 or http://localhost:5031" -ForegroundColor White
    Write-Host ""
    Write-Host "🔍 TO TEST THE OBRA PAGE ISSUE:" -ForegroundColor Cyan
    Write-Host "   1. Navigate to /Auth/Login" -ForegroundColor White
    Write-Host "   2. Login with CPF: 567.065.455-20" -ForegroundColor White
    Write-Host "   3. Go to /Obra/Escolher" -ForegroundColor White
    Write-Host "   4. Check if 103 obras are displayed" -ForegroundColor White
    Write-Host "   5. Press F12 to check Console for JavaScript errors" -ForegroundColor White
    
} else {
    Write-Host "   ❌ Visual Studio not found!" -ForegroundColor Red
    Write-Host "   Please open Visual Studio manually and load RdoApp.Core.sln" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "📁 Project location:" -ForegroundColor Cyan
    Write-Host "   $(Get-Location)\RdoApp.Core.sln" -ForegroundColor White
}

Write-Host ""
Write-Host "✨ All automated processes stopped - ready for manual F5 debugging!" -ForegroundColor Green