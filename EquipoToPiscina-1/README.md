# EquipoToPiscina — RDO App Piscinas (Project 1)

**Period:** May 2025 – January 2026  
**Status:** Abandoned (see Project 2)  
**Stack:** ASP.NET Framework 4.x + AngularJS + Entity Framework 6 + MySQL (AWS RDS)

---

## What This Project Was

This was the first attempt to adapt the original RDO App (Relatório Diário de Obras — a daily construction report system) into a new version for swimming pool maintenance companies (Piscinas).

The original app was built by Gilberto and ran on legacy ASP.NET Framework with AngularJS on the frontend. The goal was to rename entities, adapt the UI, and add a new Laudo (water quality inspection report) feature — all while keeping the same database structure and production code running.

---

## Folder Structure

| Folder | Description |
|---|---|
| `RDO-Production-Gilberto/` | Original production code (source of truth, do not modify) |
| `rdoappProject/` | ASP.NET Web API + AngularJS frontend (the active migration target) |
| `rdoappClass/` | Entity Framework 6 class library (48 entities) |
| `RDO-Homolog-Test/` | Homologation environment for testing |
| `RDO-NET8-Migration/` | Abandoned attempt to migrate to .NET 8 inside this project |
| `solution/` | Visual Studio solution file |

---

## What Was Accomplished

- Renamed entities and UI labels from "Obra" (construction) to "Unidade Escolar" / Piscinas context
- Added the `Laudo` entity (water quality inspection with 8 measurement fields)
- Implemented `Nova Medição` modal for recording water quality data
- Connected to AWS RDS MySQL production database
- Authentication system working (CPF-based login)
- Escolher Obra (project selection) page partially working
- Etapas/Tarefas (stages/tasks) accordion view implemented

---

## Main Obstacles Encountered

### 1. Week-Long Blank Page Crisis
The most damaging issue. Inline JavaScript mixed with Razor syntax caused the view engine to silently fail and render a blank page. This took over a week to diagnose because the error produced no visible exception — just an empty white screen.

**Root cause:** `@{ }` Razor blocks mixed with JavaScript inside `.cshtml` files caused the Roslyn compiler to fail silently.

### 2. Blazor Architecture Mismatch
An attempt was made to use Blazor Server components inside the legacy ASP.NET Framework app. This created a hybrid architecture that was fundamentally incompatible — Blazor requires .NET Core/5+, not Framework 4.x. This caused cascading failures including circuit errors, middleware conflicts, and authentication breaks.

### 3. AngularJS Legacy Pollution
The original app used AngularJS for client-side routing and data binding. Attempts to modernize individual pages while leaving AngularJS in place created conflicts between the two systems competing for DOM control.

### 4. Asset Path Crisis
Static assets (CSS, fonts, JavaScript) had path resolution issues when the app ran under IIS vs. the development server. Fontello icon fonts returned 404 errors intermittently.

### 5. Session and Authentication Instability
The login worked in normal browser mode but failed in incognito mode due to cookie/session configuration differences. This was fixed multiple times but kept regressing as other changes were made.

### 6. Process Lock Compilation Errors (MSB3026/MSB3027)
The running IIS Express process locked DLL files, preventing recompilation. Required killing processes before every build.

### 7. Database Field Name Mismatches
Entity Framework 6 model names did not always match the actual MySQL column names, causing silent query failures and null data in views.

---

## Why This Project Was Abandoned

By January 2026, the codebase had accumulated too much technical debt from the repeated attempts to fix cascading issues. The core problem was architectural: trying to modernize a legacy ASP.NET Framework + AngularJS app incrementally, while keeping it running, created more problems than it solved.

The decision was made to start a clean migration to .NET 8 (Project 2) using all the lessons learned here, rather than continue patching a fragile foundation.

---

## Key Lessons Learned (Passed to Project 2)

- Never mix inline JavaScript with Razor syntax in `.cshtml` files
- Do not attempt Blazor inside ASP.NET Framework — incompatible runtimes
- Copy working production code exactly before attempting any improvements
- Test in incognito mode from the start
- Stop all processes before compiling
- One problem at a time — do not introduce new architecture while fixing bugs
