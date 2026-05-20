# Prepare for Visual Studio F5 debugging
Write-Host "Preparing for Visual Studio F5 debugging..." -ForegroundColor Green

# Kill any running processes
Write-Host "Stopping RDO processes..." -ForegroundColor Yellow
Get-Process | Where-Object {$_.ProcessName -like "*RdoApp*"} | Stop-Process -Force -ErrorAction SilentlyContinue
Get-Process dotnet -ErrorAction SilentlyContinue | Where-Object {$_.CommandLine -like "*RdoApp*"} | Stop-Process -Force -ErrorAction SilentlyContinue

# Clean and build
Write-Host "Cleaning and building project..." -ForegroundColor Yellow
Set-Location "RDO-NET8-Migration/RdoApp.Core"

Remove-Item -Path "bin\Debug\net8.0\RdoApp.Core.exe" -Force -ErrorAction SilentlyContinue
Remove-Item -Path "obj\Debug\net8.0\apphost.exe" -Force -ErrorAction SilentlyContinue

dotnet clean --verbosity quiet
dotnet build --verbosity quiet

if ($LASTEXITCODE -eq 0) {
    Write-Host "Build successful!" -ForegroundColor Green
} else {
    Write-Host "Build failed!" -ForegroundColor Red
    exit 1
}

# Try to open Visual Studio
$vsPath = "${env:ProgramFiles}\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe"
if (Test-Path $vsPath) {
    Write-Host "Opening Visual Studio..." -ForegroundColor Green
    Start-Process -FilePath $vsPath -ArgumentList "RdoApp.Core.sln"
} else {
    Write-Host "Visual Studio not found at expected location" -ForegroundColor Yellow
    Write-Host "Please open Visual Studio manually and load RdoApp.Core.sln" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "READY FOR F5 DEBUGGING!" -ForegroundColor Green
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Wait for Visual Studio to load" -ForegroundColor White
Write-Host "2. Press F5 to start debugging" -ForegroundColor White
Write-Host "3. Test the obra page at /Obra/Escolher" -ForegroundColor White
Write-Host "4. Check F12 Console for JavaScript errors" -ForegroundColor White