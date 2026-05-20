# ESCOLHER PRUNING - PHASE 1: BACKUP
# Date: 2026-01-18
# Purpose: Create timestamped backup of files to be quarantined

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "ESCOLHER PRUNING - PHASE 1: BACKUP" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Create timestamped backup folder
$timestamp = Get-Date -Format "yyyy-MM-dd-HHmmss"
$backupPath = "backups/escolher-pruning-$timestamp"
New-Item -ItemType Directory -Path $backupPath -Force | Out-Null
Write-Host "✅ Backup folder created: $backupPath" -ForegroundColor Green

# Step 2: Backup redundant files
Write-Host "`n📦 Backing up 11 redundant files..." -ForegroundColor Yellow

# Layouts (2 unused)
Copy-Item "RDO-NET8-Migration/RdoApp.Core/Views/Shared/_LayoutSelection.cshtml" "$backupPath/" -ErrorAction SilentlyContinue
Copy-Item "RDO-NET8-Migration/RdoApp.Core/Views/Shared/_LayoutNavigation.cshtml" "$backupPath/" -ErrorAction SilentlyContinue
Write-Host "  ✓ 2 layouts backed up" -ForegroundColor Gray

# Header Components (3 unused)
Copy-Item "RDO-NET8-Migration/RdoApp.Core/Components/HeaderEscolher.razor" "$backupPath/" -ErrorAction SilentlyContinue
Copy-Item "RDO-NET8-Migration/RdoApp.Core/Components/UnifiedRdoHeader.razor" "$backupPath/" -ErrorAction SilentlyContinue
Copy-Item "RDO-NET8-Migration/RdoApp.Core/Components/NavigationHeader.razor" "$backupPath/" -ErrorAction SilentlyContinue
Write-Host "  ✓ 3 header components backed up" -ForegroundColor Gray

# CSS Files (3 unused)
Copy-Item "RDO-NET8-Migration/RdoApp.Core/wwwroot/css/rdo-unified-theme.css" "$backupPath/" -ErrorAction SilentlyContinue
Copy-Item "RDO-NET8-Migration/RdoApp.Core/wwwroot/css/rdo-navigation.css" "$backupPath/" -ErrorAction SilentlyContinue
Copy-Item "RDO-NET8-Migration/RdoApp.Core/wwwroot/css/rdo-selection.css" "$backupPath/" -ErrorAction SilentlyContinue
Write-Host "  ✓ 3 CSS files backed up" -ForegroundColor Gray

# Orphan Component (2 files)
Copy-Item "RDO-NET8-Migration/RdoApp.Core/Components/RdoObraCards.razor" "$backupPath/" -ErrorAction SilentlyContinue
Copy-Item "RDO-NET8-Migration/RdoApp.Core/Components/RdoObraCards.razor.css" "$backupPath/" -ErrorAction SilentlyContinue
Write-Host "  ✓ 1 orphan component (2 files) backed up" -ForegroundColor Gray

Write-Host "`n✅ 11 files backed up successfully" -ForegroundColor Green

# Step 3: Create backup manifest
$manifest = @"
ESCOLHER PRUNING BACKUP MANIFEST
Date: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
Purpose: Selective Consolidation - Remove unused files

FILES BACKED UP:
- 2 Layouts (unused by Escolher.cshtml)
  - _LayoutSelection.cshtml
  - _LayoutNavigation.cshtml

- 3 Header Components (unused by Escolher.cshtml)
  - HeaderEscolher.razor
  - UnifiedRdoHeader.razor
  - NavigationHeader.razor

- 3 CSS Files (unused by Escolher.cshtml)
  - rdo-unified-theme.css
  - rdo-navigation.css
  - rdo-selection.css

- 1 Orphan Component (never integrated)
  - RdoObraCards.razor
  - RdoObraCards.razor.css

ROLLBACK COMMAND:
Copy-Item "$backupPath/*" "RDO-NET8-Migration/RdoApp.Core/" -Recurse -Force

EMERGENCY ROLLBACK SCRIPT:
.\rollback-escolher-pruning.ps1 $backupPath
"@

$manifest | Out-File "$backupPath/MANIFEST.txt" -Encoding UTF8
Write-Host "✅ Backup manifest created" -ForegroundColor Green

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "PHASE 1 COMPLETE" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "`nBackup location: $backupPath" -ForegroundColor Yellow
Write-Host "`nNext step: Review backup, then run Phase 2 (Quarantine)" -ForegroundColor Yellow
Write-Host "Command: .\execute-escolher-pruning-phase2-quarantine.ps1 $backupPath" -ForegroundColor Cyan
