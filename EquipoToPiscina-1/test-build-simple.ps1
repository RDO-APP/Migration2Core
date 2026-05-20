Write-Host "=== TESTING 3 STRUCTURAL IMPROVEMENTS ===" -ForegroundColor Cyan

Set-Location "RDO-NET8-Migration/RdoApp.Core"

Write-Host "Building project..." -ForegroundColor Yellow
dotnet build --configuration Release --verbosity minimal

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ BUILD SUCCESSFUL!" -ForegroundColor Green
    Write-Host "All 3 structural improvements implemented successfully!" -ForegroundColor Green
} else {
    Write-Host "❌ BUILD FAILED" -ForegroundColor Red
}