# Switch to Diagnostic View for Debugging
Write-Host "🔧 SWITCHING TO DIAGNOSTIC VIEW" -ForegroundColor Yellow
Write-Host ""

$originalView = "RDO-NET8-Migration/RdoApp.Core/Views/Obra/Escolher.cshtml"
$diagnosticView = "RDO-NET8-Migration/RdoApp.Core/Views/Obra/Escolher-Diagnostic.cshtml"
$backupView = "RDO-NET8-Migration/RdoApp.Core/Views/Obra/Escolher.cshtml.backup"

# Ensure backup exists
if (-not (Test-Path $backupView)) {
    Write-Host "1. Creating backup of original view..." -ForegroundColor Green
    Copy-Item $originalView $backupView -Force
    Write-Host "   ✅ Backup created!" -ForegroundColor Green
}

# Switch to diagnostic view
Write-Host "2. Switching to diagnostic view..." -ForegroundColor Green
Copy-Item $diagnosticView $originalView -Force
Write-Host "   ✅ Diagnostic view activated!" -ForegroundColor Green

Write-Host ""
Write-Host "🎯 DIAGNOSTIC VIEW ACTIVE!" -ForegroundColor Cyan
Write-Host ""
Write-Host "NEXT STEPS:" -ForegroundColor White
Write-Host "1. Open Visual Studio with RdoApp.Core.sln" -ForegroundColor Gray
Write-Host "2. Press F5 to start debugging" -ForegroundColor Gray
Write-Host "3. Navigate to /Obra/Escolher" -ForegroundColor Gray
Write-Host "4. Check the diagnostic information displayed" -ForegroundColor Gray
Write-Host ""
Write-Host "WHAT TO LOOK FOR:" -ForegroundColor Yellow
Write-Host "• Model Count: Should show 103 if API works" -ForegroundColor White
Write-Host "• User ID Claim: Should show a number, not NULL" -ForegroundColor White
Write-Host "• Obra cards: Should display if data is passed correctly" -ForegroundColor White
Write-Host ""
Write-Host "TO RESTORE ORIGINAL VIEW LATER:" -ForegroundColor Cyan
Write-Host "   .\restore-original-view.ps1" -ForegroundColor Gray