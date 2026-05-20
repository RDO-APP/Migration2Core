# 🧪 Local Homologation Testing Guide

## Current Situation
- ✅ Code changes applied successfully to local files
- ✅ Entity Framework fixes implemented  
- ✅ Teste.rdlc template created
- ✅ Connection strings updated for homolog
- ❌ Changes not yet deployed to server

## 🚀 Local Testing Steps

### Step 1: Database Setup (5 minutes)

**Create Homolog Database:**
```sql
-- Connect to your MySQL server and run:
CREATE DATABASE IF NOT EXISTS `piscinas_rdoapp_homolog` 
CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Copy structure from production:
-- Option A: If you have access to production DB
CREATE TABLE piscinas_rdoapp_homolog.laudo LIKE piscinas_rdoapp.laudo;
INSERT INTO piscinas_rdoapp_homolog.laudo SELECT * FROM piscinas_rdoapp.laudo LIMIT 10;

-- Option B: Create table manually
CREATE TABLE `laudo` (
  `lau_id_laudo` int(11) NOT NULL AUTO_INCREMENT,
  `lau_id_status` int(11) NOT NULL DEFAULT 1,
  `lau_id_obra` int(11) NOT NULL DEFAULT 1,
  `lau_dt_laudo` date NOT NULL,
  `lau_ds_comentario_assinatura` varchar(2000) DEFAULT NULL,
  `lau_id_colaborador` int(11) DEFAULT 1,
  `lau_dt_geracao` datetime DEFAULT CURRENT_TIMESTAMP,
  `lau_tp_comentario_assinatura` varchar(1) DEFAULT NULL,
  `lau_ds_comentario_geracao` text,
  `lau_tp_comentario_geracao` varchar(1) DEFAULT NULL,
  `lau_tp_nivel_cloro` tinyint(1) DEFAULT 1,
  `lau_tp_ph` tinyint(1) DEFAULT 1,
  `lau_tp_limpidez` tinyint(1) DEFAULT 1,
  `lau_tp_superficie` tinyint(1) DEFAULT 1,
  `lau_tp_fundo` tinyint(1) DEFAULT 1,
  `lau_tp_nivel_cloro_2` tinyint(1) DEFAULT 0,
  `lau_tp_nivel_bacterias` tinyint(1) DEFAULT 0,
  `lau_tp_nivel_proliferacao` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`lau_id_laudo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Insert test data
INSERT INTO laudo (lau_id_laudo, lau_id_status, lau_id_obra, lau_dt_laudo, lau_ds_comentario_geracao) 
VALUES (1, 1, 1, CURDATE(), 'Teste de homologação');
```

### Step 2: Build Solution (10 minutes)

**In Visual Studio:**
1. Open the solution
2. **Right-click** `rdoappClass/rdoappModel.Context.tt` → **Run Custom Tool**
3. **Right-click** `rdoappClass/rdoappModel.tt` → **Run Custom Tool**
4. **Build Solution** (Ctrl+Shift+B)
5. Check for build errors

**Expected Output:**
- ✅ No build errors
- ✅ `rdoappClass/bin/Debug/rdoappClass.dll` updated
- ✅ Entity classes regenerated

### Step 3: Local IIS/Development Server (5 minutes)

**Option A: IIS Express (Recommended)**
1. Set `rdoappProject` as startup project
2. Press **F5** or **Ctrl+F5** to run
3. Note the local URL (e.g., `http://localhost:12345`)

**Option B: Local IIS**
1. Create new IIS application
2. Point to `rdoappProject` folder
3. Set application pool to .NET Framework 4.8

### Step 4: Test Laudo Functionality (10 minutes)

**Navigate to Local Application:**
```
http://localhost:[port]/laudos/index
```

**Test Checklist:**
- [ ] Page loads without "AGUARDE" screen
- [ ] No "entity not part of model" errors in browser console
- [ ] Navigate to `/laudos/cadastro`
- [ ] Try to create a new Laudo
- [ ] Attempt PDF generation

### Step 5: Verify Fixes

**Test Entity Framework Fix:**
```csharp
// This should work now (in LaudoModel.cs):
laudo _laudo = context.Set<laudo>().FirstOrDefault(x => x.lau_id_laudo == idRdo);
```

**Test RDLC Template:**
```
// This file should exist:
rdoappProject/Api/Contents/Reports/Teste.rdlc
```

## 🔧 Troubleshooting Local Testing

### If "Entity not part of model" error persists:
1. **Check connection string** points to homolog DB
2. **Verify laudo table exists** in homolog database
3. **Rebuild solution** completely (Clean → Rebuild)
4. **Check Entity Framework logs** for initialization errors

### If "Teste.rdlc not found" error:
1. **Verify file exists** at correct path
2. **Check file properties** → Build Action = "Embedded Resource"
3. **Rebuild project** to embed resources
4. **Check file permissions**

### If application won't start:
1. **Check Web.config** for syntax errors
2. **Verify connection string** format
3. **Check IIS Express** configuration
4. **Review Visual Studio** output window for errors

## 📊 Expected Test Results

### ✅ Success Indicators:
- Application loads without infinite loading screen
- Laudo index page displays (even if empty)
- No Entity Framework errors in logs
- PDF generation attempts don't crash
- Browser console shows no critical JavaScript errors

### ⚠️ Acceptable Issues:
- Empty laudo list (if no test data)
- PDF content formatting issues (template needs customization)
- Minor UI glitches (not related to our fixes)

### ❌ Failure Indicators:
- "Entity not part of model" errors
- "Teste.rdlc not found" errors
- Application crashes on startup
- Infinite "AGUARDE" loading screen

## 🚀 Next Steps After Local Success

### If Local Testing Succeeds:
1. **Document successful tests**
2. **Prepare deployment package**
3. **Deploy to production server**
4. **Monitor production for issues**

### If Local Testing Fails:
1. **Review error messages**
2. **Check database connectivity**
3. **Verify file paths and permissions**
4. **Consult troubleshooting guide above**

## 📞 Quick Verification Commands

**Check Database Connection:**
```csharp
// Add this temporarily to a controller to test:
using (var context = new rdoappEntities())
{
    var count = context.Set<laudo>().Count();
    return Json(new { LaudoCount = count });
}
```

**Check RDLC File:**
```csharp
// Add this to verify file exists:
var path = Server.MapPath("~/Api/Contents/Reports/Teste.rdlc");
var exists = System.IO.File.Exists(path);
return Json(new { RdlcExists = exists, Path = path });
```

---

## 🎯 Success Criteria

**Local testing is successful when:**
1. ✅ Application starts without errors
2. ✅ Navigate to `/laudos/index` successfully  
3. ✅ No "entity not part of model" errors
4. ✅ No "Teste.rdlc not found" errors
5. ✅ Can attempt to create new Laudo
6. ✅ PDF generation doesn't crash (content may need refinement)

**Time Estimate: 30 minutes**
**Difficulty: Intermediate**
**Prerequisites: Visual Studio, MySQL access**