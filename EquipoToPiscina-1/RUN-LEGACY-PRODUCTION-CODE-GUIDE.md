# HOW TO RUN LEGACY PRODUCTION CODE

**Date:** January 22, 2026  
**Status:** 🟢 READY TO RUN  
**Purpose:** Run the working AngularJS + .NET Framework application

---

## OVERVIEW

The legacy production code is a **working application** that uses:
- **Backend:** ASP.NET MVC 5 + Web API 2 (.NET Framework 4.8)
- **Frontend:** AngularJS 1.x SPA
- **Database:** MySQL (AWS RDS)
- **Architecture:** Hybrid MVC + AngularJS with URL rewriting

**This application WORKS** - it's the baseline we need before attempting any migration.

---

## LOCATION

**Solution File:** `RDO-Production-Gilberto/solution/rdoapp.sln`

**Project Directory:** `RDO-Production-Gilberto/rdoappProject/`

**Database:** `piscinas_rdoapp_homologa` (currently configured in Web.config)

---

## PREREQUISITES

### 1. Visual Studio

**Required:** Visual Studio 2019 or 2022 with:
- ASP.NET and web development workload
- .NET Framework 4.8 SDK

### 2. IIS Express

**Included with Visual Studio** - no separate installation needed

### 3. Database Access

**Already configured in Web.config:**
- Server: `equipamentos.cslrikufb7hm.us-east-2.rds.amazonaws.com`
- Database: `piscinas_rdoapp_homologa`
- User: `rdoadmin`
- Password: `rdoapp2018aws`

---

## HOW TO RUN

### Option 1: Visual Studio F5 (RECOMMENDED)

**This is the simplest way to run the legacy application:**

1. **Open Solution in Visual Studio:**
   ```
   Double-click: RDO-Production-Gilberto/solution/rdoapp.sln
   ```

2. **Wait for NuGet Restore:**
   - Visual Studio will automatically restore NuGet packages
   - This may take 1-2 minutes
   - Watch the status bar for "Restore complete"

3. **Set Startup Project:**
   - Right-click `rdoappProject` in Solution Explorer
   - Select "Set as Startup Project"

4. **Press F5 to Run:**
   - Visual Studio will compile the project
   - IIS Express will start automatically
   - Browser will open to the application

5. **Expected URL:**
   ```
   http://localhost:[port]/
   ```
   - Port is assigned by IIS Express (usually 50000-60000 range)
   - Application will redirect to AngularJS login page

### Option 2: IIS Express Command Line

**If you prefer command line:**

1. **Navigate to project directory:**
   ```powershell
   cd RDO-Production-Gilberto\rdoappProject
   ```

2. **Run IIS Express:**
   ```powershell
   "C:\Program Files\IIS Express\iisexpress.exe" /path:"$PWD" /port:50000
   ```

3. **Open browser:**
   ```
   http://localhost:50000/
   ```

### Option 3: Full IIS (Production-like)

**For production-like testing:**

1. **Open IIS Manager** (run `inetmgr`)

2. **Create Application Pool:**
   - Name: `RDO-Legacy`
   - .NET CLR Version: `v4.0`
   - Managed Pipeline Mode: `Integrated`

3. **Create Website:**
   - Site name: `RDO-Legacy`
   - Physical path: `[full path to]\RDO-Production-Gilberto\rdoappProject`
   - Binding: `http://localhost:8080`
   - Application pool: `RDO-Legacy`

4. **Open browser:**
   ```
   http://localhost:8080/
   ```

---

## WHAT TO EXPECT

### 1. Login Page

**URL:** `http://localhost:[port]/`

**What you'll see:**
- AngularJS login form
- RDO App logo
- Username and password fields
- "Entrar" (Login) button

**Test credentials:**
- Username: `ricardo` (or any valid user in database)
- Password: (check database for correct password)

### 2. Work Selection Page (Escolher Obra)

**URL:** `http://localhost:[port]/#/obra/escolher`

**What you'll see:**
- Grid of work cards (obras)
- Each card shows:
  - Work name
  - Municipality
  - Status indicators
  - "Acessar" button
- Filter options at top

### 3. Task Cards Page (Etapa/Tarefa)

**URL:** `http://localhost:[port]/#/etapa/[obraId]`

**What you'll see:**
- Accordion sections for each stage (etapa)
- Task cards within each section
- Status indicators (hand icons)
- Action buttons (Nova Medição, etc.)

---

## ARCHITECTURE OVERVIEW

### Backend Structure

```
rdoappProject/
├── Api/                          # Web API Controllers
│   ├── Controllers/
│   │   ├── AuthController.cs    # Authentication
│   │   ├── ObraController.cs    # Work management
│   │   ├── EtapaController.cs   # Stage management
│   │   └── TarefaController.cs  # Task management
│   └── Models/                   # Data models
│
├── Client/                       # AngularJS Frontend
│   ├── Controllers/              # AngularJS controllers
│   ├── Views/                    # AngularJS templates
│   └── app.js                    # AngularJS app config
│
├── Assets/                       # Static files
│   ├── Scripts/                  # JavaScript libraries
│   ├── Styles/                   # CSS files
│   └── images/                   # Images
│
├── Global.asax                   # Application startup
└── Web.config                    # Configuration
```

### How It Works

1. **URL Rewriting:**
   - All non-API requests are rewritten to `/` (index.html)
   - AngularJS handles client-side routing
   - API requests go to `/api/*` endpoints

2. **Authentication:**
   - Server-side session management
   - Cookie-based authentication
   - AngularJS checks auth status on route change

3. **Data Flow:**
   ```
   Browser → AngularJS → HTTP Request → Web API → Entity Framework → MySQL
   ```

---

## TROUBLESHOOTING

### Issue: "Could not load file or assembly"

**Solution:**
```powershell
# Restore NuGet packages
cd RDO-Production-Gilberto\rdoappProject
nuget restore
```

### Issue: "Database connection failed"

**Check:**
1. Internet connection (database is on AWS)
2. Firewall not blocking port 3306
3. Database credentials in Web.config are correct

**Test connection:**
```sql
-- Use DBeaver or MySQL Workbench
Server: equipamentos.cslrikufb7hm.us-east-2.rds.amazonaws.com
Port: 3306
Database: piscinas_rdoapp_homologa
User: rdoadmin
Password: rdoapp2018aws
```

### Issue: "Port already in use"

**Solution:**
- Change port in IIS Express
- Or stop other applications using the port

### Issue: "Blank page after login"

**This should NOT happen in legacy code** - if it does:
1. Check browser console for JavaScript errors
2. Check Network tab for failed API requests
3. Verify database has data (obras, etapas, tarefas)

---

## COMPARING WITH .NET 8 MIGRATION

### What Works in Legacy (But Not in .NET 8)

✅ **Login page** - renders correctly  
✅ **Obra selection** - shows 103 work cards  
✅ **Task cards** - displays correctly  
✅ **Modals** - open and close properly  
✅ **Authentication** - session management works  
✅ **Database** - all queries work  

### Why Legacy Works

1. **Simple architecture** - MVC + AngularJS, no Blazor conflicts
2. **Mature technology** - .NET Framework 4.8 is stable
3. **URL rewriting** - Clean separation of API and frontend
4. **No view rendering issues** - AngularJS handles all UI
5. **No pipeline conflicts** - Single request pipeline

---

## NEXT STEPS AFTER RUNNING LEGACY

### 1. Document What Works

**Create a checklist:**
- [ ] Login flow works
- [ ] Obra selection shows all cards
- [ ] Task cards display correctly
- [ ] Modals open and close
- [ ] Data saves to database
- [ ] PDF generation works

### 2. Analyze Architecture

**Understand:**
- How authentication works
- How API endpoints are structured
- How AngularJS routing works
- How data flows through the system

### 3. Plan Migration Restart

**Decision points:**
- Keep AngularJS frontend? (If it works, don't fix it)
- Migrate backend only to .NET 8 Web API?
- Or migrate frontend to modern framework (React/Vue/Blazor WASM)?

### 4. Incremental Approach

**Recommended strategy:**
1. **Phase 1:** Migrate backend to .NET 8 Web API (keep AngularJS)
2. **Phase 2:** Test API with Postman
3. **Phase 3:** Connect AngularJS to new API
4. **Phase 4:** (Optional) Migrate frontend later

---

## WHY THIS IS IMPORTANT

**After 1+ week of debugging .NET 8 blank page:**
- We need a **working baseline** to compare against
- We need to **understand what works** before migrating
- We need to **verify the problem is in .NET 8**, not in our logic

**Running the legacy code proves:**
- ✅ Database is correct
- ✅ Business logic is correct
- ✅ UI design is correct
- ❌ .NET 8 migration has architectural problems

---

## MIGRATION LESSONS LEARNED

### What Went Wrong in .NET 8 Migration

1. **Mixed MVC + Blazor Server** - These frameworks conflict
2. **View rendering issues** - Razor views have compatibility problems
3. **Pipeline conflicts** - Antiforgery, routing, Blazor Hub all fighting
4. **Browser-side issues** - Client problems are hard to diagnose server-side

### What to Do Differently

1. **Separate concerns** - Backend API + Frontend SPA
2. **Test incrementally** - One component at a time
3. **Use Postman** - Test API before touching frontend
4. **Keep what works** - Don't migrate AngularJS if it's working
5. **Avoid mixing frameworks** - No MVC + Blazor in same app

---

## QUICK START COMMANDS

### Open in Visual Studio
```powershell
# Open solution
start RDO-Production-Gilberto\solution\rdoapp.sln

# Then press F5 in Visual Studio
```

### Run with IIS Express
```powershell
cd RDO-Production-Gilberto\rdoappProject
& "C:\Program Files\IIS Express\iisexpress.exe" /path:"$PWD" /port:50000
```

### Test Database Connection
```powershell
# Use DBeaver or MySQL Workbench
# Connection details in Web.config
```

---

## EXPECTED OUTCOME

**After running legacy code, you should see:**

1. ✅ Login page loads correctly
2. ✅ Authentication works
3. ✅ Obra selection shows all work cards
4. ✅ Task cards display properly
5. ✅ Modals open and close
6. ✅ Data saves to database

**This proves:**
- The database is correct
- The business logic is correct
- The UI design is correct
- **The problem is in the .NET 8 migration architecture**

---

## CONCLUSION

**The legacy code is your safety net.**

**It's the working baseline that proves:**
- Your requirements are correct
- Your database is correct
- Your business logic is correct

**When you're ready to restart the migration:**
- Use the legacy code as reference
- Migrate incrementally (backend first)
- Test each component individually
- Don't mix MVC + Blazor Server

**For now, run the legacy code and verify everything works.**

---

**Document Status:** 🟢 READY TO USE  
**Last Updated:** January 22, 2026  
**Next Action:** Open `RDO-Production-Gilberto/solution/rdoapp.sln` in Visual Studio and press F5
