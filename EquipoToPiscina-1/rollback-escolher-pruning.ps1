# EMERGENCY ROLLBACK SCRIPT
# Restores all files from backup in case of failure

param(
    [Parameter(Mandatory=$true)]
    [string]$BackupPath
)

Write-Host "========================================" -ForegroundColor Red
Write-Host "🚨 EMERGENCY ROLLBACK INITIATED" -ForegroundColor Red
Write-Host "========================================" -ForegroundColor Red
Write-Host ""

# Verify backup path exists
if (-not (Test-Path $BackupPath)) {
    Write-Host "❌ ERROR: Backup path not found: $BackupPath" -ForegroundColor Red
    exit 1
}

Write-Host "📂 Backup location: $BackupPath" -ForegroundColor Yellow
Write-Host ""

# Stop application if running
Write-Host "🛑 Stopping application..." -ForegroundColor Yellow
Stop-Process -Name "dotnet" -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
Write-Host "✅ Application stopped" -ForegroundColor Green

# Restore all files from backup
Write-Host "`n📦 Restoring files from backup..." -ForegroundColor Yellow
Copy-Item "$BackupPath/*" "RDO-NET8-Migration/RdoApp.Core/" -Recurse -Force

# Verify restoration
$restoredFiles = @(
    "Views/Shared/_LayoutSelection.cshtml",
    "Views/Shared/_LayoutNavigation.cshtml",
    "Components/HeaderEscolher.razor",
    "Components/UnifiedRdoHeader.razor",
    "Components/NavigationHeader.razor",
    "wwwroot/css/rdo-unified-theme.css",
    "wwwroot/css/rdo-navigation.css",
    "wwwroot/css/rdo-selection.css",
    "Components/RdoObraCards.razor",
    "Components/RdoObraCards.razor.css"
)

Write-Host "`n🔍 Verifying restoration..." -ForegroundColor Yellow
$allRestored = $true
foreach ($file in $restoredFiles) {
    $fullPath = "RDO-NET8-Migration/RdoApp.Core/$file"
    if (Test-Path $fullPath) {
        Write-Host "  ✓ $file" -ForegroundColor Green
    } else {
        Write-Host "  ✗ $file" -ForegroundColor Red
        $allRestored = $false
    }
}

if ($allRestored) {
    Write-Host "`n✅ ROLLBACK COMPLETE" -ForegroundColor Green
    Write-Host "All 11 files restored successfully" -ForegroundColor Green
} else {
    Write-Host "`n❌ ROLLBACK INCOMPLETE" -ForegroundColor Red
    Write-Host "Some files failed to restore - manual intervention required" -ForegroundColor Red
    Write-Host "Check backup folder: $BackupPath" -ForegroundColor Yellow
    exit 1
}

# Recompile
Write-Host "`n🔨 Recompiling application..." -ForegroundColor Yellow
Push-Location "RDO-NET8-Migration/RdoApp.Core"
dotnet build --no-restore --verbosity quiet
$buildResult = $LASTEXITCODE
Pop-Location

if ($buildResult -eq 0) {
    Write-Host "✅ Application recompiled successfully" -ForegroundColor Green
} else {
    Write-Host "⚠️ Compilation warnings/errors - check output" -ForegroundColor Yellow
}

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "SYSTEM RESTORED TO PRE-PRUNING STATE" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "`nYou can now investigate the failure and try again" -ForegroundColor Yellow
Write-Host "Safe to restart testing" -ForegroundColor Yellow
