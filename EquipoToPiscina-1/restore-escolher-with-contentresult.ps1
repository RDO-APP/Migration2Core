# Restore Escolher Backup with ContentResult Approach
# This restores the December 2025 working backup but modifies controller to use ContentResult

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "RESTORE ESCOLHER WITH CONTENTRESULT" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Backup current file
Write-Host "Step 1: Backing up current Escolher.cshtml..." -ForegroundColor Yellow
$currentFile = "RDO-NET8-Migration\RdoApp.Core\Views\Obra\Escolher.cshtml"
$backupFile = "RDO-NET8-Migration\RdoApp.Core\Views\Obra\Escolher.cshtml.motor-test-backup"

if (Test-Path $currentFile) {
    Copy-Item $currentFile $backupFile -Force
    Write-Host "✓ Current file backed up to: $backupFile" -ForegroundColor Green
} else {
    Write-Host "✗ Current file not found" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Step 2: Restore December 2025 backup
Write-Host "Step 2: Restoring December 2025 backup..." -ForegroundColor Yellow
$sourceBackup = "RDO-NET8-Migration\RdoApp.Core\Views\Obra\Escolher.cshtml.jan20-backup"

if (Test-Path $sourceBackup) {
    Copy-Item $sourceBackup $currentFile -Force
    Write-Host "✓ December 2025 backup restored" -ForegroundColor Green
} else {
    Write-Host "✗ Backup file not found: $sourceBackup" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Step 3: Apply model type fix
Write-Host "Step 3: Applying model type fix..." -ForegroundColor Yellow

$content = Get-Content $currentFile -Raw

# Fix 1: Change model type from dynamic to ObraViewModel
$content = $content -replace '@model IEnumerable<dynamic>', '@model IEnumerable<RdoApp.Core.Models.ViewModels.ObraViewModel>'

# Fix 2: Add using directive if not present
if ($content -notmatch '@using RdoApp.Core.Models.ViewModels') {
    $content = "@using RdoApp.Core.Models.ViewModels`r`n" + $content
}

Set-Content $currentFile -Value $content -NoNewline

Write-Host "✓ Model type fix applied" -ForegroundColor Green
Write-Host ""

# Step 4: Show what was changed
Write-Host "Step 4: Changes applied:" -ForegroundColor Yellow
Write-Host "  • Model type: IEnumerable<dynamic> → IEnumerable<ObraViewModel>" -ForegroundColor White
Write-Host "  • Added: @using RdoApp.Core.Models.ViewModels" -ForegroundColor White
Write-Host ""

Write-Host "========================================" -ForegroundColor Green
Write-Host "✅ RESTORE COMPLETE" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

Write-Host "IMPORTANT:" -ForegroundColor Yellow
Write-Host "  The controller is currently using ContentResult approach." -ForegroundColor White
Write-Host "  This bypasses the Blazor middleware that was blocking rendering." -ForegroundColor White
Write-Host ""
Write-Host "  If you want to use the restored View instead of ContentResult:" -ForegroundColor White
Write-Host "  1. Modify ObraController.cs → Escolher action" -ForegroundColor White
Write-Host "  2. Change: return Content(html, 'text/html')" -ForegroundColor White
Write-Host "  3. To: return View(obrasList)" -ForegroundColor White
Write-Host ""
Write-Host "  OR run with hot-reload disabled:" -ForegroundColor White
Write-Host "  dotnet run --no-hot-reload" -ForegroundColor White
Write-Host ""

Write-Host "Next step: Run test-contentresult-motor.ps1 to verify" -ForegroundColor Cyan
