# RDO App - Homologation Environment Setup

## Overview
Create a staging environment to safely test Entity Framework fixes and Laudo PDF generation without affecting production.

## Environment Structure

### 1. Database Setup (MySQL)
```sql
-- Create homologation database
CREATE DATABASE `piscinas_rdoapp_homolog` 
CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Create homolog user (optional - can reuse existing)
CREATE USER 'rdoadmin_homolog'@'%' IDENTIFIED BY 'rdoapp2024homolog';
GRANT ALL PRIVILEGES ON piscinas_rdoapp_homolog.* TO 'rdoadmin_homolog'@'%';
FLUSH PRIVILEGES;
```

### 2. Directory Structure
```
RDO-Homologation/
├── rdoappClass/                 # Class library (copied from main)
├── rdoappProject/              # Web application (copied from main)
├── solution/                   # Solution files
├── Database/
│   ├── backup/                 # Database backups
│   ├── scripts/               # SQL scripts
│   └── migrations/            # Schema changes
├── Config/
│   ├── homolog.config         # Homolog-specific settings
│   └── connection-strings.config
├── Deploy/
│   ├── build.ps1             # Build script
│   ├── deploy.ps1            # Deployment script
│   └── rollback.ps1          # Rollback script
└── Tests/
    ├── integration/          # Integration tests
    └── reports/             # Test reports
```

### 3. Configuration Changes

#### Connection String (Homolog)
```xml
<!-- rdoappProject/Web.config -->
<connectionStrings>
  <add name="rdoappEntities" 
       connectionString="metadata=res://*/rdoappModel.csdl|res://*/rdoappModel.ssdl|res://*/rdoappModel.msl;provider=MySql.Data.MySqlClient;provider connection string=&quot;server=equipamentos.cslrikufb7hm.us-east-2.rds.amazonaws.com;User Id=rdoadmin;password=rdoapp2018aws;database=piscinas_rdoapp_homolog&quot;" 
       providerName="System.Data.EntityClient" />
</connectionStrings>
```

#### App Settings (Homolog)
```xml
<appSettings>
  <add key="Environment" value="Homologation" />
  <add key="basePath" value="/homolog/" />
  <add key="EnableDebugMode" value="true" />
  <add key="LogLevel" value="Debug" />
</appSettings>
```

## Implementation Plan

### Phase 1: Environment Setup (Day 1)
1. **Database Setup**
   - Create homolog database
   - Copy production data (sanitized)
   - Verify laudo table exists

2. **Code Setup**
   - Copy current codebase
   - Update connection strings
   - Configure homolog-specific settings

3. **IIS Setup** (if using IIS)
   - Create new application pool
   - Configure homolog site
   - Set up subdomain: `homolog.piscinas.rdoapp.com.br`

### Phase 2: Fix Implementation (Day 2)
1. **Entity Framework Fix**
   - Clean bin/obj folders
   - Regenerate T4 templates
   - Update model metadata
   - Test laudo entity access

2. **Missing RDLC Template**
   - Create Teste.rdlc based on existing templates
   - Configure report parameters
   - Test PDF generation

### Phase 3: Testing (Day 3)
1. **Unit Tests**
   - Test laudo entity CRUD operations
   - Test PDF generation
   - Test report parameters

2. **Integration Tests**
   - End-to-end laudo creation
   - PDF download functionality
   - Signature workflow

### Phase 4: Production Deployment (Day 4)
1. **Backup Production**
2. **Deploy Tested Changes**
3. **Verify Production**
4. **Monitor for Issues**

## Automation Scripts

### Build Script
```powershell
# Deploy/build.ps1
param(
    [string]$Environment = "Homolog",
    [string]$Configuration = "Debug"
)

Write-Host "Building RDO App for $Environment..." -ForegroundColor Green

# Clean previous builds
Remove-Item "rdoappClass\bin" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "rdoappClass\obj" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "rdoappProject\bin" -Recurse -Force -ErrorAction SilentlyContinue

# Build class library
dotnet build rdoappClass\rdoappClass.csproj -c $Configuration

# Build web project  
dotnet build rdoappProject\rdoappProject.csproj -c $Configuration

Write-Host "Build completed successfully!" -ForegroundColor Green
```

### Database Migration Script
```sql
-- Database/scripts/verify-laudo-table.sql
-- Verify laudo table structure in homolog

USE piscinas_rdoapp_homolog;

-- Check if laudo table exists
SELECT COUNT(*) as table_exists 
FROM information_schema.tables 
WHERE table_schema = 'piscinas_rdoapp_homolog' 
AND table_name = 'laudo';

-- Show table structure
DESCRIBE laudo;

-- Check sample data
SELECT COUNT(*) as record_count FROM laudo;

-- Verify foreign key constraints
SELECT 
    CONSTRAINT_NAME,
    COLUMN_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'piscinas_rdoapp_homolog'
AND TABLE_NAME = 'laudo'
AND REFERENCED_TABLE_NAME IS NOT NULL;
```

## Testing Checklist

### Database Tests
- [ ] laudo table exists
- [ ] All columns present with correct types
- [ ] Foreign key constraints working
- [ ] Sample data available for testing

### Entity Framework Tests
- [ ] rdoappEntities context initializes
- [ ] context.laudo DbSet accessible
- [ ] CRUD operations work
- [ ] Relationships load correctly

### Laudo Functionality Tests
- [ ] Laudo list loads (/laudos/index)
- [ ] Laudo creation form works (/laudos/cadastro)
- [ ] PDF generation succeeds
- [ ] Report contains correct data
- [ ] Images display in PDF (if applicable)

### Report Tests
- [ ] Teste.rdlc file exists
- [ ] Report parameters populate
- [ ] PDF renders without errors
- [ ] Signature fields work
- [ ] Logo displays correctly

## Rollback Plan

### If Issues Occur:
1. **Stop homolog application**
2. **Restore previous database backup**
3. **Revert code changes**
4. **Restart with known good version**

### Rollback Script
```powershell
# Deploy/rollback.ps1
param([string]$BackupDate)

Write-Host "Rolling back to backup from $BackupDate..." -ForegroundColor Yellow

# Restore database
mysql -u rdoadmin -p piscinas_rdoapp_homolog < "Database/backup/homolog_$BackupDate.sql"

# Restore code
git checkout HEAD~1  # or specific commit

# Rebuild
.\Deploy\build.ps1 -Environment "Homolog"

Write-Host "Rollback completed!" -ForegroundColor Green
```

## Security Considerations

### Homolog Environment
- Use separate database credentials
- Sanitize production data (remove PII)
- Restrict access to development team
- Use HTTPS even in homolog
- Enable detailed logging for debugging

### Data Privacy
```sql
-- Sanitize sensitive data for homolog
UPDATE colaborador SET 
    col_nr_cpf = CONCAT('000', LPAD(col_id_colaborador, 8, '0')),
    col_ds_email = CONCAT('test', col_id_colaborador, '@example.com'),
    col_ds_telefone_principal = '11999999999'
WHERE col_id_colaborador > 0;
```

## Monitoring & Logging

### Application Logs
- Enable detailed EF logging
- Log all laudo operations
- Monitor PDF generation performance
- Track error rates

### Database Monitoring
- Monitor connection pool usage
- Track query performance
- Log entity framework queries
- Monitor laudo table operations

## Next Steps

1. **Create homolog database** using the SQL scripts above
2. **Copy production data** (sanitized) to homolog
3. **Set up homolog web application** with updated connection strings
4. **Implement the Entity Framework fixes** in homolog
5. **Test thoroughly** before production deployment

Would you like me to help you implement any specific part of this homologation setup?