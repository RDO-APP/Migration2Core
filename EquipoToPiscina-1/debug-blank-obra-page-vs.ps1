# Debug Blank Obra Page - Visual Studio F5 Ready
Write-Host "🔍 DEBUGGING BLANK OBRA PAGE ISSUE" -ForegroundColor Yellow
Write-Host ""

# Stop any running processes first
Write-Host "1. Stopping any running RDO processes..." -ForegroundColor Green
Get-Process | Where-Object {$_.ProcessName -like "*RdoApp*"} | Stop-Process -Force -ErrorAction SilentlyContinue
Get-Process dotnet -ErrorAction SilentlyContinue | Where-Object {$_.CommandLine -like "*RdoApp*"} | Stop-Process -Force -ErrorAction SilentlyContinue

# Navigate to project directory
Set-Location "RDO-NET8-Migration/RdoApp.Core"

# Clean and build
Write-Host "2. Cleaning and building project..." -ForegroundColor Green
dotnet clean --verbosity quiet
dotnet build --verbosity quiet

if ($LASTEXITCODE -eq 0) {
    Write-Host "   ✅ Build successful!" -ForegroundColor Green
} else {
    Write-Host "   ❌ Build failed!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "🎯 DEBUGGING STEPS FOR VISUAL STUDIO:" -ForegroundColor Cyan
Write-Host ""
Write-Host "STEP 1: Open Visual Studio" -ForegroundColor White
Write-Host "   • Double-click RdoApp.Core.sln to open in Visual Studio" -ForegroundColor Gray
Write-Host "   • Or use File → Open → Project/Solution" -ForegroundColor Gray
Write-Host ""
Write-Host "STEP 2: Set Breakpoints" -ForegroundColor White
Write-Host "   • ObraController.cs → Escolher method (line where it returns View)" -ForegroundColor Gray
Write-Host "   • ObraApiController.cs → ObterObras method (first line)" -ForegroundColor Gray
Write-Host ""
Write-Host "STEP 3: Start Debugging" -ForegroundColor White
Write-Host "   • Press F5 to start debugging" -ForegroundColor Gray
Write-Host "   • Navigate to: https://localhost:7139/Obra/Escolher" -ForegroundColor Gray
Write-Host ""
Write-Host "STEP 4: Check What Happens" -ForegroundColor White
Write-Host "   • Does the Escolher method get called?" -ForegroundColor Gray
Write-Host "   • What data is passed to the View?" -ForegroundColor Gray
Write-Host "   • Open F12 Developer Tools in browser" -ForegroundColor Gray
Write-Host "   • Check Console tab for JavaScript errors" -ForegroundColor Gray
Write-Host "   • Check Network tab - is /api/ObraApi/ObterObras being called?" -ForegroundColor Gray
Write-Host ""
Write-Host "STEP 5: Key Things to Verify" -ForegroundColor White
Write-Host "   • Authentication: Is user logged in?" -ForegroundColor Gray
Write-Host "   • API Call: Is the JavaScript making the API call?" -ForegroundColor Gray
Write-Host "   • API Response: What does /api/ObraApi/ObterObras return?" -ForegroundColor Gray
Write-Host "   • Frontend: Is the JavaScript processing the response?" -ForegroundColor Gray
Write-Host ""
Write-Host "🔧 KNOWN ISSUE ANALYSIS:" -ForegroundColor Yellow
Write-Host "   • Backend API works (returns 103 obras)" -ForegroundColor White
Write-Host "   • Authentication works (login successful)" -ForegroundColor White
Write-Host "   • Issue is likely in frontend JavaScript" -ForegroundColor White
Write-Host "   • Page loads but doesn't populate obra cards" -ForegroundColor White
Write-Host ""
Write-Host "💡 DEBUGGING FOCUS:" -ForegroundColor Cyan
Write-Host "   1. Check if JavaScript is calling the API" -ForegroundColor White
Write-Host "   2. Check if API returns data in browser" -ForegroundColor White
Write-Host "   3. Check if JavaScript processes the response" -ForegroundColor White
Write-Host "   4. Look for JavaScript errors in F12 Console" -ForegroundColor White
Write-Host ""
Write-Host "🚀 READY FOR VISUAL STUDIO F5 DEBUGGING!" -ForegroundColor Green