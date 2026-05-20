# Restore Original Escolher View
Write-Host "🔄 RESTORING ORIGINAL VIEW" -ForegroundColor Yellow
Write-Host ""

$originalView = "RDO-NET8-Migration/RdoApp.Core/Views/Obra/Escolher.cshtml"
$backupView = "RDO-NET8-Migration/RdoApp.Core/Views/Obra/Escolher.cshtml.backup"

if (Test-Path $backupView) {
    Write-Host "1. Restoring original view..." -ForegroundColor Green
    Copy-Item $backupView $originalView -Force
    Write-Host "   ✅ Original view restored!" -ForegroundColor Green
} else {
    Write-Host "❌ Backup file not found!" -ForegroundColor Red
    Write-Host "   Cannot restore original view." -ForegroundColor Red
}

Write-Host ""
Write-Host "✅ ORIGINAL VIEW RESTORED!" -ForegroundColor Green