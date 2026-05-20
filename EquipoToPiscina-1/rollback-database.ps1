# DATABASE ROLLBACK SCRIPT
# Restore database from backup if deployment fails

param(
    [Parameter(Mandatory=$true)]
    [string]$BackupFile
)

if (!(Test-Path $BackupFile)) {
    Write-Host "Backup file not found: $BackupFile" -ForegroundColor Red
    exit 1
}

Write-Host "DANGER: This will restore database from backup!" -ForegroundColor Red
Write-Host "Backup file: $BackupFile" -ForegroundColor Yellow
Write-Host "This will OVERWRITE current database data!" -ForegroundColor Red

$confirmation = Read-Host "Type 'RESTORE' to confirm database rollback"
if ($confirmation -ne "RESTORE") {
    Write-Host "Rollback cancelled" -ForegroundColor Yellow
    exit 0
}

Write-Host "Restoring database..." -ForegroundColor Yellow

# MySQL Restore Command
$mysqlRestoreCmd = "mysql -u rdoadmin -p piscinas_rdoapp < $BackupFile"

Write-Host "Restore command: $mysqlRestoreCmd" -ForegroundColor Cyan
Write-Host "Execute this command manually with your MySQL password" -ForegroundColor Yellow
Write-Host "Database will be restored from: $BackupFile" -ForegroundColor Green
