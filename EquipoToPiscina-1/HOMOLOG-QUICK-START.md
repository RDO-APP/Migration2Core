# RDO App Homologation - Quick Start Guide

## 🎯 Objective
Set up a homologation environment to fix the **"laudo entity not part of model"** error and missing **Teste.rdlc** template without affecting production.

## 📋 Prerequisites
- MySQL access to create homolog database
- Visual Studio or MSBuild installed
- Access to production database for structure copy
- IIS or development server for hosting

## 🚀 Quick Setup (30 minutes)

### Step 1: Database Setup (5 minutes)
```bash
# Execute the SQL script
mysql -u rdoadmin -p < Database/create-homolog-db.sql

# Or run manually:
# 1. CREATE DATABASE piscinas_rdoapp_homolog;
# 2. Copy structure from production
# 3. Insert sample data
```

### Step 2: Build Homolog Environment (10 minutes)
```powershell
# Run the build script
.\Deploy\build-homolog.ps1

# This will:
# - Clean bin/obj folders
# - Update connection string to homolog DB
# - Build the solution (if MSBuild available)
```

### Step 3: Fix Entity Framework Issue (5 minutes)
```powershell
# Apply the quick fix
.\Deploy\fix-laudo-entity.ps1 -ApplyQuickFix

# This changes: context.laudo.FirstOrDefault()
# To: context.Set<laudo>().FirstOrDefault()
```

### Step 4: Create Missing RDLC Template (5 minutes)
```powershell
# Create the missing Teste.rdlc file
.\Deploy\create-missing-rdlc.ps1

# This copies an existing report template and customizes it for Laudo
```

### Step 5: Test the Environment (5 minutes)
```powershell
# Run comprehensive tests
.\Deploy\test-homolog.ps1

# Check for:
# - Application loads without "AGUARDE" screen
# - Laudo pages accessible
# - No entity framework errors
```

## 🔧 Manual Steps (if scripts fail)

### If Build Script Fails:
1. Open solution in Visual Studio
2. Update connection string in Web.config:
   ```xml
   database=piscinas_rdoapp_homolog
   ```
3. Right-click `rdoappModel.Context.tt` → Run Custom Tool
4. Right-click `rdoappModel.tt` → Run Custom Tool
5. Build Solution (Ctrl+Shift+B)

### If Entity Fix Fails:
Edit `rdoappProject\Api\Models\LaudoModel.cs`:
```csharp
// Find lines like:
laudo _laudo = context.laudo.FirstOrDefault(x => x.lau_id_laudo == idRdo);

// Replace with:
laudo _laudo = context.Set<laudo>().FirstOrDefault(x => x.lau_id_laudo == idRdo);
```

### If RDLC Creation Fails:
1. Copy `rdoappProject\Api\Contents\Reports\Rdo_def.rdlc`
2. Rename to `Teste.rdlc`
3. Place in same directory

## 🧪 Testing Checklist

### Database Tests
- [ ] Homolog database created
- [ ] Laudo table exists with correct structure
- [ ] Sample data inserted
- [ ] Foreign keys working

### Application Tests
- [ ] Application loads (no AGUARDE screen)
- [ ] Navigate to `/laudos/index` successfully
- [ ] Navigate to `/laudos/cadastro` successfully
- [ ] No "entity not part of model" errors

### PDF Generation Tests
- [ ] Create a new Laudo
- [ ] Generate PDF without errors
- [ ] PDF contains expected data
- [ ] Images display (if applicable)

## 🚨 Troubleshooting

### "Entity not part of model" Error Persists
1. Check connection string points to homolog DB
2. Verify laudo table exists in homolog DB
3. Rebuild solution completely
4. Clear browser cache
5. Restart application/IIS

### "Teste.rdlc not found" Error
1. Verify file exists at `rdoappProject\Api\Contents\Reports\Teste.rdlc`
2. Check file permissions
3. Rebuild project to embed resources
4. Verify file is included in project

### Application Still Shows "AGUARDE"
1. Check browser console for JavaScript errors
2. Verify API endpoints respond (should return 405, not 404)
3. Check database connection
4. Review application logs

## 📁 File Structure After Setup
```
RDO-Project/
├── rdoappClass/
│   ├── bin/Debug/rdoappClass.dll ✓ (rebuilt)
│   └── laudo.cs ✓ (verified)
├── rdoappProject/
│   ├── Api/Contents/Reports/Teste.rdlc ✓ (created)
│   ├── Api/Models/LaudoModel.cs ✓ (fixed)
│   └── Web.config ✓ (updated for homolog)
├── Database/
│   └── create-homolog-db.sql ✓ (executed)
└── Deploy/
    ├── backup/ ✓ (contains backups)
    └── *.ps1 ✓ (scripts executed)
```

## 🎯 Success Criteria

### ✅ Environment Ready When:
1. **Database**: Homolog DB created with laudo table
2. **Build**: Solution builds without errors
3. **Entity**: No "entity not part of model" errors
4. **Reports**: Teste.rdlc exists and loads
5. **Testing**: All test scripts pass

### ✅ Functionality Working When:
1. Navigate to `/laudos/index` - shows laudo list
2. Navigate to `/laudos/cadastro` - shows create form
3. Create new laudo - saves successfully
4. Generate PDF - downloads without errors
5. PDF content - displays laudo data correctly

## 🚀 Production Deployment (After Testing)

Once homolog testing is successful:

1. **Backup Production**
   ```bash
   mysqldump -u rdoadmin -p piscinas_rdoapp > prod_backup_$(date +%Y%m%d).sql
   ```

2. **Deploy Changes**
   - Copy updated `rdoappClass.dll` to production
   - Copy `Teste.rdlc` to production reports folder
   - Update `LaudoModel.cs` with entity fix

3. **Verify Production**
   - Test laudo functionality
   - Generate sample PDF
   - Monitor for errors

## 📞 Support

If issues persist after following this guide:

1. **Check logs** in `C:\Logs\` (if configured)
2. **Review test results** from `test-homolog.ps1`
3. **Verify database** connection and table structure
4. **Compare** homolog vs production configurations

## 🎉 Next Steps

After successful homolog setup:
1. Customize `Teste.rdlc` report layout for better Laudo presentation
2. Add additional test cases for edge scenarios
3. Implement automated deployment pipeline
4. Set up monitoring and alerting for production

---

**Estimated Total Time: 30 minutes**  
**Difficulty: Intermediate**  
**Risk Level: Low (homolog environment)**