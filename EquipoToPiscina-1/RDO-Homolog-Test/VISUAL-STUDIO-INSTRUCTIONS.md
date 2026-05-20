# 🎯 Visual Studio Testing Instructions

## Quick Start Guide for Testing Homolog Environment

### ✅ **Prerequisites Completed:**
- Test environment created in `RDO-Homolog-Test/`
- All fixes applied (Entity Framework, RDLC template, connection string)
- Database setup script ready

---

## 🗄️ **Step 1: Setup Database (5 minutes)**

### **Run Database Script:**
1. Open **MySQL Workbench** or your MySQL client
2. Connect to your MySQL server
3. Open and execute: `RDO-Homolog-Test/setup-homolog-database.sql`
4. Verify success message appears

### **Expected Result:**
```
✅ Database: piscinas_rdoapp_homolog created
✅ Tables: laudo, obra, colaborador, status_rdo, etc.
✅ Test data: 4 sample laudo records inserted
```

---

## 🔧 **Step 2: Open Solution in Visual Studio (2 minutes)**

### **Open Test Solution:**
1. Navigate to `RDO-Homolog-Test/` folder
2. Double-click `rdoapp.sln` (or the .sln file present)
3. Visual Studio will open with the test solution

### **Set Startup Project:**
1. Right-click `rdoappProject` in Solution Explorer
2. Select **"Set as Startup Project"**

---

## ⚙️ **Step 3: Regenerate Entity Framework (3 minutes)**

### **Run T4 Templates:**
1. In Solution Explorer, expand `rdoappClass` project
2. **Right-click** `rdoappModel.Context.tt` → **"Run Custom Tool"**
3. **Right-click** `rdoappModel.tt` → **"Run Custom Tool"**
4. Wait for code generation to complete

### **Expected Result:**
- No errors in Error List
- `rdoappModel.Context.cs` updated
- Entity classes regenerated

---

## 🔨 **Step 4: Build Solution (2 minutes)**

### **Build Process:**
1. **Build** → **Rebuild Solution** (or Ctrl+Shift+B)
2. Wait for build to complete
3. Check **Output** window for any errors

### **Expected Result:**
```
========== Rebuild All: 2 succeeded, 0 failed, 0 skipped ==========
```

---

## 🚀 **Step 5: Run Application (2 minutes)**

### **Start Debugging:**
1. Press **F5** or click **"Start Debugging"**
2. Wait for application to start
3. Note the local URL (e.g., `http://localhost:12345`)

### **Expected Result:**
- IIS Express starts successfully
- Browser opens with application
- No startup errors in Output window

---

## 🧪 **Step 6: Test Laudo Functionality (10 minutes)**

### **Test Navigation:**
1. **Navigate to:** `http://localhost:[port]/laudos/index`
2. **Expected:** Page loads without "AGUARDE" screen
3. **Expected:** Shows list of test laudo records

### **Test Laudo Index Page:**
- ✅ Page loads successfully
- ✅ Shows 4 test laudo records
- ✅ No "entity not part of model" errors
- ✅ No JavaScript errors in browser console

### **Test Laudo Creation:**
1. **Navigate to:** `http://localhost:[port]/laudos/cadastro`
2. **Expected:** Form loads without errors
3. **Try:** Fill out form and save
4. **Expected:** No Entity Framework errors

### **Test PDF Generation:**
1. From laudo list, click **PDF/Generate** button
2. **Expected:** No "Teste.rdlc not found" errors
3. **Expected:** PDF generation process starts
4. **Expected:** File downloads or preview appears

---

## ✅ **Success Criteria**

### **✅ Application Startup:**
- [ ] Solution builds without errors
- [ ] Application starts in IIS Express
- [ ] No Entity Framework initialization errors
- [ ] Browser opens application successfully

### **✅ Laudo Index Page:**
- [ ] Navigate to `/laudos/index` successfully
- [ ] Page loads without "AGUARDE" loading screen
- [ ] Shows test laudo records from database
- [ ] No "entity not part of model" errors
- [ ] No JavaScript errors in browser console

### **✅ Laudo Creation Page:**
- [ ] Navigate to `/laudos/cadastro` successfully
- [ ] Form loads and displays correctly
- [ ] Can interact with form fields
- [ ] No Entity Framework errors when loading

### **✅ PDF Generation:**
- [ ] PDF generation button/link works
- [ ] No "Teste.rdlc not found" errors
- [ ] PDF generation process completes
- [ ] File downloads or preview displays

### **✅ Database Integration:**
- [ ] Application connects to homolog database
- [ ] Can retrieve laudo records
- [ ] Can create new laudo records
- [ ] CRUD operations work correctly

---

## 🚨 **Troubleshooting**

### **If Build Fails:**
1. Check **Error List** for specific errors
2. Ensure all NuGet packages are restored
3. Try **Clean Solution** → **Rebuild Solution**
4. Check .NET Framework version (should be 4.8)

### **If "Entity not part of model" Error:**
1. Verify homolog database exists and is accessible
2. Check connection string in Web.config
3. Regenerate T4 templates again
4. Clean and rebuild solution

### **If "Teste.rdlc not found" Error:**
1. Verify file exists: `rdoappProject/Api/Contents/Reports/Teste.rdlc`
2. Check file properties: Build Action = "Embedded Resource"
3. Rebuild solution to embed resources

### **If Application Won't Start:**
1. Check **Output** window for specific errors
2. Verify IIS Express is configured correctly
3. Check Web.config syntax
4. Try running as Administrator

### **If Database Connection Fails:**
1. Verify MySQL server is running
2. Test connection string manually
3. Check firewall settings
4. Verify database user permissions

---

## 📊 **Expected Test Results**

### **🎉 Complete Success:**
- All pages load without errors
- Laudo CRUD operations work
- PDF generation succeeds
- No Entity Framework errors
- No RDLC template errors

### **⚠️ Partial Success:**
- Pages load but some features don't work
- PDF generates but formatting needs improvement
- Minor UI issues (acceptable for testing)

### **❌ Failure:**
- "Entity not part of model" errors persist
- "Teste.rdlc not found" errors
- Application crashes on startup
- Cannot access laudo pages

---

## 🎯 **After Testing**

### **If Tests Succeed:**
1. **Document successful results**
2. **Take screenshots of working functionality**
3. **Prepare to apply same fixes to production**
4. **Plan production deployment**

### **If Tests Fail:**
1. **Note specific error messages**
2. **Check troubleshooting guide above**
3. **Refine fixes in test environment**
4. **Do not proceed to production**

---

## 📞 **Need Help?**

### **Common Issues:**
- **Build errors:** Check NuGet packages and .NET version
- **Database errors:** Verify connection string and database setup
- **Runtime errors:** Check Output window and browser console

### **Debug Information:**
- **Solution:** Located in `RDO-Homolog-Test/`
- **Database:** `piscinas_rdoapp_homolog`
- **Key fixes:** Entity Framework + RDLC template
- **Original code:** Completely unchanged

---

**🎉 Ready to test! Follow the steps above and report your results.**

**Time Estimate: 20-30 minutes**
**Risk Level: Zero (test environment only)**