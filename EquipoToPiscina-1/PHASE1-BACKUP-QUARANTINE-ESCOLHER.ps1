# PHASE 1: BACKUP AND QUARANTINE - ESCOLHER CONSOLIDATION
# Date: January 19, 2026
# Purpose: Move rejected versions to backup folder (NO CODE CHANGES)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "PHASE 1: BACKUP AND QUARANTINE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Create timestamp
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$backupFolder = "RDO-NET8-Migration/RdoApp.Core/_BACKUP_ESCOLHER_CONSOLIDATION_$timestamp"

Write-Host "Creating backup folder: $backupFolder" -ForegroundColor Yellow
New-Item -ItemType Directory -Path $backupFolder -Force | Out-Null

if (Test-Path $backupFolder) {
    Write-Host "✅ Backup folder created successfully" -ForegroundColor Green
} else {
    Write-Host "❌ Failed to create backup folder" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "QUARANTINING REJECTED VIEW VERSIONS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Array to track moved files
$movedFiles = @()
$failedFiles = @()

# Function to move file safely
function Move-FileSafely {
    param($source, $destination, $description)
    
    if (Test-Path $source) {
        try {
            Move-Item $source $destination -Force
            Write-Host "✅ Moved: $description" -ForegroundColor Green
            $script:movedFiles += $description
        } catch {
            Write-Host "❌ Failed: $description - $($_.Exception.Message)" -ForegroundColor Red
            $script:failedFiles += $description
        }
    } else {
        Write-Host "⚠️  Not found: $description (already moved or doesn't exist)" -ForegroundColor Yellow
    }
}

# Move rejected VIEW versions
Write-Host ""
Write-Host "Moving rejected Escolher views..." -ForegroundColor Yellow
Move-FileSafely "RDO-NET8-Migration/RdoApp.Core/Views/Obra/EscolherDebug.cshtml" "$backupFolder/" "EscolherDebug.cshtml"
Move-FileSafely "RDO-NET8-Migration/RdoApp.Core/Views/Obra/EscolherNuclear.cshtml" "$backupFolder/" "EscolherNuclear.cshtml"
Move-FileSafely "RDO-NET8-Migration/RdoApp.Core/Views/Obra/EscolherMinimal.cshtml" "$backupFolder/" "EscolherMinimal.cshtml"
Move-FileSafely "RDO-NET8-Migration/RdoApp.Core/Views/Obra/Escolher-Diagnostic.cshtml" "$backupFolder/" "Escolher-Diagnostic.cshtml"
Move-FileSafely "RDO-NET8-Migration/RdoApp.Core/Views/Obra/Escolher.cshtml.backup" "$backupFolder/" "Escolher.cshtml.backup"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "QUARANTINING REJECTED LAYOUT VERSIONS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "NOTE: _Layout.cshtml and _LayoutNavigation.cshtml are used by other pages" -ForegroundColor Yellow
Write-Host "      Only moving _LayoutBlazor.cshtml (experimental, unused)" -ForegroundColor Yellow
Write-Host ""

Move-FileSafely "RDO-NET8-Migration/RdoApp.Core/Views/Shared/_LayoutBlazor.cshtml" "$backupFolder/" "_LayoutBlazor.cshtml"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "QUARANTINING REJECTED CSS FILES" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Move-FileSafely "RDO-NET8-Migration/RdoApp.Core/wwwroot/css/rdo-selection.css" "$backupFolder/" "rdo-selection.css"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "QUARANTINING UNUSED BLAZOR COMPONENT" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Move-FileSafely "RDO-NET8-Migration/RdoApp.Core/Components/RdoObraCards.razor" "$backupFolder/" "RdoObraCards.razor"
Move-FileSafely "RDO-NET8-Migration/RdoApp.Core/Components/RdoObraCards.razor.css" "$backupFolder/" "RdoObraCards.razor.css"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "BACKUP SUMMARY" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Backup Location: $backupFolder" -ForegroundColor Cyan
Write-Host ""
Write-Host "Files Successfully Moved: $($movedFiles.Count)" -ForegroundColor Green
foreach ($file in $movedFiles) {
    Write-Host "  ✅ $file" -ForegroundColor Green
}

if ($failedFiles.Count -gt 0) {
    Write-Host ""
    Write-Host "Files Failed to Move: $($failedFiles.Count)" -ForegroundColor Red
    foreach ($file in $failedFiles) {
        Write-Host "  ❌ $file" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "MASTER FILES REMAINING (WINNERS)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "✅ Master View: Escolher.cshtml (Layout = null)" -ForegroundColor Green
Write-Host "✅ Master CSS: escolher-legacy.css" -ForegroundColor Green
Write-Host "✅ Master Icons: fontello.css" -ForegroundColor Green
Write-Host "✅ Master Layout: _LayoutSelection.cshtml (for future use)" -ForegroundColor Green
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "VERIFICATION: CHECKING MASTER FILES" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Verify master files still exist
$masterFiles = @(
    "RDO-NET8-Migration/RdoApp.Core/Views/Obra/Escolher.cshtml",
    "RDO-NET8-Migration/RdoApp.Core/wwwroot/css/escolher-legacy.css",
    "RDO-NET8-Migration/RdoApp.Core/wwwroot/css/fontello.css",
    "RDO-NET8-Migration/RdoApp.Core/Views/Shared/_LayoutSelection.cshtml"
)

$allMasterFilesExist = $true
foreach ($file in $masterFiles) {
    if (Test-Path $file) {
        Write-Host "✅ $file" -ForegroundColor Green
    } else {
        Write-Host "❌ MISSING: $file" -ForegroundColor Red
        $allMasterFilesExist = $false
    }
}

Write-Host ""
if ($allMasterFilesExist) {
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "✅ PHASE 1 COMPLETE - ALL MASTER FILES INTACT" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next Steps:" -ForegroundColor Cyan
    Write-Host "1. Review backup folder: $backupFolder" -ForegroundColor White
    Write-Host "2. Run compilation test: dotnet build" -ForegroundColor White
    Write-Host "3. Test Escolher page: Navigate to /Obra/Escolher" -ForegroundColor White
    Write-Host ""
    Write-Host "Emergency Rollback:" -ForegroundColor Yellow
    Write-Host "  Copy-Item '$backupFolder/*' 'RDO-NET8-Migration/RdoApp.Core/Views/Obra/' -Force" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "❌ CRITICAL: MASTER FILES MISSING" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "EXECUTE EMERGENCY ROLLBACK IMMEDIATELY!" -ForegroundColor Red
    exit 1
}

# Create backup manifest
$manifestPath = "$backupFolder/BACKUP-MANIFEST.txt"
$manifest = @"
ESCOLHER CONSOLIDATION - BACKUP MANIFEST
Date: $timestamp
Phase: 1 (Backup and Quarantine)

FILES QUARANTINED:
==================

VIEWS (5 files):
- EscolherDebug.cshtml
- EscolherNuclear.cshtml
- EscolherMinimal.cshtml
- Escolher-Diagnostic.cshtml
- Escolher.cshtml.backup

LAYOUTS (1 file):
- _LayoutBlazor.cshtml

CSS (1 file):
- rdo-selection.css

COMPONENTS (2 files):
- RdoObraCards.razor
- RdoObraCards.razor.css

TOTAL: 9 files quarantined

MASTER FILES REMAINING:
=======================
- Escolher.cshtml (Layout = null)
- escolher-legacy.css
- fontello.css
- _LayoutSelection.cshtml (for future use)

REASON FOR QUARANTINE:
======================
These files represent 7 iterations of "almost working" code.
Current working version: Escolher.cshtml with Layout = null
Consolidation goal: One master version per category

EMERGENCY ROLLBACK:
===================
Copy-Item '$backupFolder/*' 'RDO-NET8-Migration/RdoApp.Core/Views/Obra/' -Force
Copy-Item '$backupFolder/_LayoutBlazor.cshtml' 'RDO-NET8-Migration/RdoApp.Core/Views/Shared/' -Force
Copy-Item '$backupFolder/rdo-selection.css' 'RDO-NET8-Migration/RdoApp.Core/wwwroot/css/' -Force
Copy-Item '$backupFolder/RdoObraCards.razor*' 'RDO-NET8-Migration/RdoApp.Core/Components/' -Force

"@

$manifest | Out-File -FilePath $manifestPath -Encoding UTF8
Write-Host "📄 Backup manifest created: $manifestPath" -ForegroundColor Cyan
Write-Host ""
