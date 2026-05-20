# RDO Clean Migration 2026 (Project 2)

**Period:** January 22 – February 17, 2026  
**Status:** In Progress (~35% complete)  
**Stack:** ASP.NET Core (.NET 8) + Razor Views + Entity Framework Core + MySQL (AWS RDS)

---

## Why This Project Exists

This is the second-generation migration of the RDO App. Project 1 (EquipoToPiscina) was abandoned after months of fighting a legacy ASP.NET Framework + AngularJS codebase. Rather than continue patching a fragile foundation, a clean-room migration was started from scratch using all the lessons learned.

The source of truth for the legacy code is: `EquipoToPiscina-1/RDO-Production-Gilberto/`

---

## What Is Different From Project 1

| Problem in Project 1 | Solution in Project 2 |
|---|---|
| Inline JS in Razor views → blank page crisis | Zero inline scripts — all JS in separate files |
| Blazor mixed into Framework 4.x | Pure .NET 8 MVC — no Blazor |
| AngularJS conflicts | No AngularJS — clean Razor + Bootstrap 5 |
| Incremental patching of legacy code | Clean-room rewrite, legacy code as reference only |
| No separation of concerns | Controllers → Services → EF Core → MySQL |
| Entity mismatches discovered late | All 48 entities mapped and verified upfront |

---

## Project Structure

```
RDO-CleanMigration-2026/
└── RDO-CleanMigration-2026/
    └── RdoApp.Core/               ← Main ASP.NET Core project
        ├── Controllers/           ← AccountController, ObraController, HomeController
        ├── Data/
        │   ├── Entities/          ← 48 EF Core entity classes
        │   └── Configurations/    ← Fluent API mappings
        ├── Views/
        │   ├── Account/           ← Login.cshtml
        │   ├── Obra/              ← Escolher.cshtml (project selection)
        │   └── Shared/            ← _HeaderEscolher.cshtml, layouts
        └── wwwroot/
            ├── css/               ← header.css, escolher.css
            ├── fonts/             ← Fontello, Font Awesome, SF UI Display
            └── images/
```

---

## What Was Completed

### Database Layer — 100%
All 48 entities migrated from Entity Framework 6 to EF Core with Fluent API configurations. Connected to the existing AWS RDS MySQL database. No schema changes — legacy table and column names preserved to avoid data migration.

**Entity phases:**
- Phase 1: Foundation (15 entities) — Colaborador, Obra, Empresa, Municipio, etc.
- Phase 2: Work Management (4 entities)
- Phase 3: Assignment (4 entities)
- Phase 4: Daily Reporting (5 entities)
- Phase 5: Quality & Incidents (4 entities)
- Phase 6: History/Audit (4 entities)
- Phase 7: Security/RBAC (9 entities)
- Phase 8: Media & System (2 entities)

### Authentication — 100%
CPF-based login working. ASP.NET Core cookie authentication configured. Session management implemented.

**Test credentials:** CPF `567.065.455-20` / Password `1234`

### Escolher Obra Page — ~80%
The project selection page (first page after login) is implemented with:
- Header with logo, user dropdown, logout
- Obra cards showing real data from the database
- Permission-based button toolbar (RBAC)
- CSS layout matching the legacy design

**Pending:** Project selection click handler (store selected obra in session and redirect to dashboard)

---

## What Remains (Next Developer — Dimas)

### Immediate
- [ ] Copy font files from `EquipoToPiscina-1/RDO-Production-Gilberto/rdoappProject/Assets/Fonts/` to `wwwroot/fonts/`
- [ ] Copy `user.png` from `Assets/images/` to `wwwroot/images/`
- [ ] Test the app end-to-end (login → escolher → select obra)
- [ ] Implement obra selection logic in `ObraController.cs`

### Short Term
- [ ] Project Dashboard (Etapas/Tarefas accordion view)
- [ ] Change Password page
- [ ] Task management pages (list, create, edit)

### Medium Term
- [ ] RDO (Daily Report) creation and listing
- [ ] Laudo (Water Quality Inspection) pages
- [ ] Full RBAC enforcement (5-level permission system)
- [ ] Service layer (repository pattern)

### Long Term
- [ ] Unit and integration tests
- [ ] Production deployment configuration
- [ ] Performance optimization

---

## How to Run

1. Open `RDO-CleanMigration-2026/RDO-CleanMigration-2026.sln` in Visual Studio 2022
2. Ensure the connection string in `appsettings.json` points to the AWS RDS MySQL instance
3. Press F5 — the app starts on `https://localhost:7xxx`
4. Login with CPF `567.065.455-20` / Password `1234`

See `HOW-TO-RUN-IN-VISUAL-STUDIO.md` for detailed setup instructions.

---

## Main Obstacles Encountered

### 1. Permission System — Buttons Not Appearing
The header action toolbar buttons (Dashboard, Charts, New Obra, etc.) are controlled by a 5-level RBAC system stored in the database. The buttons were rendering as an empty `<ul>` because the permission query was returning zero results for the test user. Multiple diagnostic sessions were needed to trace the query through `PermissionHelper` → database → view rendering.

**Status:** Resolved — buttons now render correctly when the user has permissions assigned.

### 2. Header Alignment / Flexbox Layout
The header had overlapping elements and misaligned sections. The legacy header used a mix of absolute positioning and float-based layout. Translating this to modern flexbox required several iterations.

**Status:** Resolved.

### 3. Session Validation
After login, some requests were losing the session and redirecting back to login unexpectedly. Root cause was missing `[Authorize]` attribute configuration and session cookie settings.

**Status:** Resolved.

### 4. Font Files (Manual Step Required)
Font files (Fontello, Font Awesome, SF UI Display) are binary assets that cannot be committed to git easily and must be copied manually from the legacy project.

**Status:** Pending — Dimas needs to copy these files (see Immediate tasks above).

---

## Key Rules for This Codebase

1. **No inline JavaScript in `.cshtml` files** — all JS goes in `wwwroot/js/`
2. **No Blazor** — pure Razor MVC only
3. **Preserve legacy column names** — do not rename database fields
4. **Test in incognito mode** — catches session/cookie issues early
5. **Stop IIS Express before compiling** — avoids MSB3026 file lock errors
6. **One change at a time** — test before moving to the next change

---

## Analysis Documents

The `analysis/` folder contains detailed technical documents written during the initial legacy code study:

- `00-ANALYSIS-SUMMARY.md` — Overview of the legacy system
- `01-LEGACY-CODE-STRUCTURE-ANALYSIS.md` — File-by-file breakdown
- `02-DATABASE-SCHEMA-RELATIONSHIPS.md` — All 48 tables and their relationships
- `03-ENTITY-RELATIONSHIP-DIAGRAM.md` — ERD in text format
