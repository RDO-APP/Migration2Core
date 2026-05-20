# Migration2Core — RDO App Migration History

This repository contains the two projects that represent the full migration journey of the **RDO App** (Relatório Diário de Obras) from a legacy ASP.NET Framework + AngularJS system to a modern .NET 8 MVC application.

---

## Projects

### 1. `EquipoToPiscina-1/` — First Migration Attempt
**Period:** May 2025 – January 2026  
**Status:** Abandoned

The original RDO App adapted for swimming pool maintenance companies (Piscinas). This project worked directly on top of the legacy codebase (ASP.NET Framework 4.x + AngularJS + Entity Framework 6). After months of fighting cascading issues — blank page crises, Blazor incompatibility, AngularJS conflicts, and session instability — the decision was made to abandon incremental patching and start clean.

→ See [`EquipoToPiscina-1/README.md`](./EquipoToPiscina-1/README.md) for full details and obstacle history.

---

### 2. `RDO-CleanMigration-2026/` — Clean Migration (Active)
**Period:** January 22 – February 2026  
**Status:** In Progress (~35% complete)

A clean-room rewrite targeting .NET 8 / ASP.NET Core MVC + EF Core. All 48 database entities are migrated, authentication works, and the Escolher Obra (project selection) page is implemented. The legacy database schema is preserved — no data migration required.

→ See [`RDO-CleanMigration-2026/README.md`](./RDO-CleanMigration-2026/README.md) for current status, what remains, and how to run.

---

## For Dimas (New Developer)

**Start here:** Read `RDO-CleanMigration-2026/README.md` — it has the current status, what's done, what's pending, and the rules for this codebase.

**Reference code:** The original production code by Gilberto is at `EquipoToPiscina-1/RDO-Production-Gilberto/`. When in doubt about how something should look or behave, check there first.

**Database:** AWS RDS MySQL. Connection string is in `appsettings.json` (not committed — ask for credentials).

**Quick start:**
1. Open `RDO-CleanMigration-2026/RDO-CleanMigration-2026/RDO-CleanMigration-2026.sln` in Visual Studio 2022
2. Press F5
3. Login: CPF `567.065.455-20` / Password `1234`

---

## Timeline

| Date | Event |
|---|---|
| May 14, 2025 | EquipoToPiscina project started |
| Jun 2025 | Laudo (water quality inspection) feature added |
| Dec 2025 | Week-long blank page crisis — root cause found |
| Jan 22, 2026 | Clean migration started (this project) |
| Jan 23–25, 2026 | All 48 entities migrated to EF Core |
| Jan 26, 2026 | Login page working |
| Jan 27, 2026 | Escolher Obra header implemented |
| Feb 2026 | Permission system and button toolbar fixed |
| Feb 17, 2026 | Last recorded work session |
