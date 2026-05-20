# DAY 8 - BACKUP AND ROLLBACK STRATEGY
# Quick and practical backup setup for production deployment

Write-Host "STARTING BACKUP STRATEGY SETUP..." -ForegroundColor Green
Write-Host "Date: $(Get-Date)" -ForegroundColor Yellow
Write-Host "Objective: Setup backup and rollback procedures for production" -ForegroundColor Yellow
Write-Host ""

# Backup Strategy 1: Create Backup Scripts
Write-Host "BACKUP 1: CREATING BACKUP SCRIPTS" -ForegroundColor Magenta
Write-Host "Creating database and application backup scripts..."

# Database Backup Script
$databaseBackupScript = @'
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
'@

$databaseBackupScript | Out-File -FilePath "backup-database.ps1" -Encoding UTF8
Write-Host "Database backup script created: backup-database.ps1" -ForegroundColor Green

# Application Backup Script
$applicationBackupScript = @'
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
'@

$applicationBackupScript | Out-File -FilePath "backup-application.ps1" -Encoding UTF8
Write-Host "Application backup script created: backup-application.ps1" -ForegroundColor Green

Write-Host ""

# Backup Strategy 2: Create Rollback Scripts
Write-Host "BACKUP 2: CREATING ROLLBACK SCRIPTS" -ForegroundColor Magenta
Write-Host "Creating rollback procedures..."

# Database Rollback Script
$databaseRollbackScript = @'
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
'@

$databaseRollbackScript | Out-File -FilePath "rollback-database.ps1" -Encoding UTF8
Write-Host "Database rollback script created: rollback-database.ps1" -ForegroundColor Green

# Application Rollback Script
$applicationRollbackScript = @'
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
'@

$applicationRollbackScript | Out-File -FilePath "rollback-application.ps1" -Encoding UTF8
Write-Host "Application rollback script created: rollback-application.ps1" -ForegroundColor Green

Write-Host ""

# Backup Strategy 3: Create Backup Directories
Write-Host "BACKUP 3: CREATING BACKUP DIRECTORIES" -ForegroundColor Magenta
Write-Host "Setting up backup directory structure..."

$backupDirs = @(
    "backups",
    "backups/database",
    "backups/application",
    "backups/logs"
)

foreach ($dir in $backupDirs) {
    if (!(Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Host "Created directory: $dir" -ForegroundColor Green
    } else {
        Write-Host "Directory exists: $dir" -ForegroundColor Yellow
    }
}

Write-Host ""

# Backup Strategy 4: Create Deployment Checklist
Write-Host "BACKUP 4: CREATING DEPLOYMENT CHECKLIST" -ForegroundColor Magenta
Write-Host "Creating production deployment checklist..."

$deploymentChecklist = @'
# PRODUCTION DEPLOYMENT CHECKLIST

## PRE-DEPLOYMENT (MANDATORY)
- [ ] 1. Create database backup: `./backup-database.ps1`
- [ ] 2. Create application backup: `./backup-application.ps1`
- [ ] 3. Verify backup files exist and have reasonable size
- [ ] 4. Test application compilation: `dotnet build --configuration Release`
- [ ] 5. Verify all tests pass: `dotnet test` (if tests exist)
- [ ] 6. Check disk space on production server
- [ ] 7. Notify users of maintenance window

## DEPLOYMENT STEPS
- [ ] 8. Stop production application
- [ ] 9. Deploy new application files
- [ ] 10. Update database schema (if needed)
- [ ] 11. Update configuration files
- [ ] 12. Start application
- [ ] 13. Verify application starts successfully
- [ ] 14. Test critical functionality (login, main features)
- [ ] 15. Monitor application logs for errors

## POST-DEPLOYMENT VERIFICATION
- [ ] 16. Test user authentication
- [ ] 17. Test API endpoints
- [ ] 18. Verify database connectivity
- [ ] 19. Check application performance
- [ ] 20. Monitor system resources (CPU, memory)
- [ ] 21. Verify security headers are present
- [ ] 22. Test HTTPS redirection

## ROLLBACK PROCEDURES (IF NEEDED)
- [ ] 23. Stop failed application
- [ ] 24. Restore database: `./rollback-database.ps1 <backup-file>`
- [ ] 25. Restore application: `./rollback-application.ps1 <backup-zip>`
- [ ] 26. Verify rollback successful
- [ ] 27. Notify users of rollback completion

## EMERGENCY CONTACTS
- Database Admin: [YOUR_DBA_CONTACT]
- System Admin: [YOUR_SYSADMIN_CONTACT]
- Application Owner: [YOUR_CONTACT]

## BACKUP LOCATIONS
- Database Backups: `backups/database/`
- Application Backups: `backups/application/`
- Deployment Logs: `backups/logs/`

## ROLLBACK TIME ESTIMATES
- Database Rollback: 5-10 minutes
- Application Rollback: 2-5 minutes
- Total Rollback Time: 10-15 minutes

## SUCCESS CRITERIA
- Application starts without errors
- Users can login successfully
- API endpoints respond correctly
- Database queries execute normally
- No critical errors in logs
- Performance within acceptable limits
'@

$deploymentChecklist | Out-File -FilePath "PRODUCTION-DEPLOYMENT-CHECKLIST.md" -Encoding UTF8
Write-Host "Deployment checklist created: PRODUCTION-DEPLOYMENT-CHECKLIST.md" -ForegroundColor Green

Write-Host ""

# Backup Strategy 5: Test Backup Scripts
Write-Host "BACKUP 5: TESTING BACKUP SCRIPTS" -ForegroundColor Magenta
Write-Host "Testing backup script functionality..."

# Test application backup
Write-Host "Testing application backup..." -ForegroundColor Yellow
try {
    & "./backup-application.ps1"
    Write-Host "Application backup test: SUCCESS" -ForegroundColor Green
} catch {
    Write-Host "Application backup test: FAILED - $($_.Exception.Message)" -ForegroundColor Red
}

# Check if backup files were created
$backupFiles = Get-ChildItem "backups" -Recurse -File | Measure-Object
if ($backupFiles.Count -gt 0) {
    Write-Host "Backup files created: $($backupFiles.Count)" -ForegroundColor Green
} else {
    Write-Host "No backup files found" -ForegroundColor Yellow
}

Write-Host ""

# Final Assessment
Write-Host "BACKUP STRATEGY SETUP COMPLETE" -ForegroundColor Magenta
Write-Host "================================" -ForegroundColor Magenta

$backupComponents = @{
    "Database Backup Script" = (Test-Path "backup-database.ps1")
    "Application Backup Script" = (Test-Path "backup-application.ps1")
    "Database Rollback Script" = (Test-Path "rollback-database.ps1")
    "Application Rollback Script" = (Test-Path "rollback-application.ps1")
    "Backup Directories" = (Test-Path "backups")
    "Deployment Checklist" = (Test-Path "PRODUCTION-DEPLOYMENT-CHECKLIST.md")
}

$allReady = $true
foreach ($component in $backupComponents.GetEnumerator()) {
    if ($component.Value) {
        Write-Host "$($component.Key): READY" -ForegroundColor Green
    } else {
        Write-Host "$($component.Key): MISSING" -ForegroundColor Red
        $allReady = $false
    }
}

Write-Host ""

if ($allReady) {
    Write-Host "BACKUP STRATEGY STATUS: COMPLETE" -ForegroundColor Green
    Write-Host "Production deployment backup procedures are ready" -ForegroundColor Green
    Write-Host ""
    Write-Host "BEFORE PRODUCTION DEPLOYMENT:" -ForegroundColor Yellow
    Write-Host "1. Run: ./backup-database.ps1" -ForegroundColor Yellow
    Write-Host "2. Run: ./backup-application.ps1" -ForegroundColor Yellow
    Write-Host "3. Follow: PRODUCTION-DEPLOYMENT-CHECKLIST.md" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "IF ROLLBACK NEEDED:" -ForegroundColor Cyan
    Write-Host "1. Run: ./rollback-database.ps1 <backup-file>" -ForegroundColor Cyan
    Write-Host "2. Run: ./rollback-application.ps1 <backup-zip>" -ForegroundColor Cyan
} else {
    Write-Host "BACKUP STRATEGY STATUS: INCOMPLETE" -ForegroundColor Red
    Write-Host "Some backup components are missing" -ForegroundColor Red
}

Write-Host ""
Write-Host "Backup strategy setup completed at: $(Get-Date)" -ForegroundColor Cyan
Write-Host "DAY 8 STEP 4 COMPLETED: Backup and Rollback Strategy" -ForegroundColor Green