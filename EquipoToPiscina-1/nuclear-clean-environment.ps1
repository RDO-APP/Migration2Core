Write-Host "NUCLEAR ENVIRONMENT CLEAN - DEEP PURGE" -ForegroundColor Red
Write-Host "=======================================" -ForegroundColor Red

Write-Host ""
Write-Host "STEP 1: KILL ALL DOTNET PROCESSES" -ForegroundColor Yellow
Write-Host "Kill all RdoApp.Core processes:" -ForegroundColor White
Write-Host "   taskkill /F /IM RdoApp.Core.exe" -ForegroundColor Cyan
Write-Host "   taskkill /F /IM dotnet.exe" -ForegroundColor Cyan
Write-Host "   Get-Process -Name '*rdoapp*' | Stop-Process -Force" -ForegroundColor Cyan

Write-Host ""
Write-Host "STEP 2: NUKE BUILD FOLDERS" -ForegroundColor Yellow
Write-Host "Delete these folders manually:" -ForegroundColor White
Write-Host "   RDO-NET8-Migration/RdoApp.Core/bin" -ForegroundColor Cyan
Write-Host "   RDO-NET8-Migration/RdoApp.Core/obj" -ForegroundColor Cyan
Write-Host "   RDO-NET8-Migration/RdoApp.Core/wwwroot/css/*.min.css" -ForegroundColor Cyan

Write-Host ""
Write-Host "STEP 3: CLEAR BROWSER CACHE" -ForegroundColor Yellow
Write-Host "Clear ALL browser data for localhost:" -ForegroundColor White
Write-Host "   - Clear cache and cookies" -ForegroundColor Cyan
Write-Host "   - Clear local storage" -ForegroundColor Cyan
Write-Host "   - Use Incognito/Private mode" -ForegroundColor Cyan

Write-Host ""
Write-Host "STEP 4: PORT PRIORITY" -ForegroundColor Yellow
Write-Host "HTTPS is ABSOLUTE PRIORITY:" -ForegroundColor White
Write-Host "   PRIMARY: https://localhost:7001" -ForegroundColor Green
Write-Host "   IGNORE:  http://localhost:5031" -ForegroundColor Red
Write-Host "   Blazor Hub MUST connect via HTTPS" -ForegroundColor Cyan

Write-Host ""
Write-Host "STEP 5: FRESH BUILD SEQUENCE" -ForegroundColor Yellow
Write-Host "Execute in exact order:" -ForegroundColor White
Write-Host "   1. dotnet clean" -ForegroundColor Cyan
Write-Host "   2. dotnet restore" -ForegroundColor Cyan
Write-Host "   3. dotnet build" -ForegroundColor Cyan
Write-Host "   4. dotnet run --urls https://localhost:7001" -ForegroundColor Cyan

Write-Host ""
Write-Host "EXECUTE THESE COMMANDS NOW:" -ForegroundColor Red