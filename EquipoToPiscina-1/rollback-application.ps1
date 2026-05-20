# APPLICATION ROLLBACK SCRIPT
# Restore application from backup if deployment fails

param(
    [Parameter(Mandatory=$true)]
    [string]$BackupZip
)

if (!(Test-Path $BackupZip)) {
    Write-Host "Backup file not found: $BackupZip" -ForegroundColor Red
    exit 1
}

Write-Host "DANGER: This will restore application from backup!" -ForegroundColor Red
Write-Host "Backup file: $BackupZip" -ForegroundColor Yellow
Write-Host "This will OVERWRITE current application files!" -ForegroundColor Red

$confirmation = Read-Host "Type 'RESTORE' to confirm application rollback"
if ($confirmation -ne "RESTORE") {
    Write-Host "Rollback cancelled" -ForegroundColor Yellow
    exit 0
}

Write-Host "Restoring application..." -ForegroundColor Yellow

try {
    # Stop application if running
    Get-Process -Name "dotnet" -ErrorAction SilentlyContinue | Stop-Process -Force
    
    # Extract backup
    Expand-Archive -Path $BackupZip -DestinationPath "." -Force
    
    Write-Host "Application restored successfully" -ForegroundColor Green
    Write-Host "Restart the application to complete rollback" -ForegroundColor Yellow
} catch {
    Write-Host "Application rollback failed: $($_.Exception.Message)" -ForegroundColor Red
}
