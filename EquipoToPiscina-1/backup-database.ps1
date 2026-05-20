# DATABASE BACKUP SCRIPT
# Run this before any production deployment

$backupDate = Get-Date -Format "yyyyMMdd_HHmmss"
$backupDir = "backups/database"

if (!(Test-Path $backupDir)) {
    New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
}

Write-Host "Creating database backup..." -ForegroundColor Yellow

# MySQL Backup Command
$backupFile = "$backupDir/piscinas_rdoapp_backup_$backupDate.sql"
$mysqlDumpCmd = "mysqldump -u rdoadmin -p piscinas_rdoapp > $backupFile"

Write-Host "Backup command: $mysqlDumpCmd" -ForegroundColor Cyan
Write-Host "Execute this command manually with your MySQL password" -ForegroundColor Yellow
Write-Host "Backup will be saved to: $backupFile" -ForegroundColor Green

# Verify backup size
if (Test-Path $backupFile) {
    $backupSize = (Get-Item $backupFile).Length / 1MB
    Write-Host "Backup completed: $([math]::Round($backupSize, 2)) MB" -ForegroundColor Green
} else {
    Write-Host "Backup file not found - run mysqldump command manually" -ForegroundColor Yellow
}
