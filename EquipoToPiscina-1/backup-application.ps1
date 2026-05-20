# APPLICATION BACKUP SCRIPT
# Backup current application files before deployment

$backupDate = Get-Date -Format "yyyyMMdd_HHmmss"
$backupDir = "backups/application"

if (!(Test-Path $backupDir)) {
    New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
}

Write-Host "Creating application backup..." -ForegroundColor Yellow

# Backup key directories
$backupPaths = @(
    "RDO-NET8-Migration/RdoApp.Core",
    "appsettings.json",
    "appsettings.Production.json"
)

$backupZip = "$backupDir/rdoapp_backup_$backupDate.zip"

try {
    Compress-Archive -Path $backupPaths -DestinationPath $backupZip -Force
    $backupSize = (Get-Item $backupZip).Length / 1MB
    Write-Host "Application backup completed: $([math]::Round($backupSize, 2)) MB" -ForegroundColor Green
    Write-Host "Backup saved to: $backupZip" -ForegroundColor Green
} catch {
    Write-Host "Application backup failed: $($_.Exception.Message)" -ForegroundColor Red
}
