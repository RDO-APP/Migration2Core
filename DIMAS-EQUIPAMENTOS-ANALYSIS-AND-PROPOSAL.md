# RDO App Equipamentos — Analysis & Navigation Proposal for Dimas

**Prepared by**: Kiro (AI)  
**Date**: May 2026  
**Purpose**: Help Dimas understand the existing codebases and propose the correct navigation pattern for the Equipamentos version

---

## 1. The Three Codebases You Need to Know

| Codebase | Developer | Tech | Status |
|---|---|---|---|
| `EquipoToPiscina-1/RDO-Production-Gilberto/` | Gilberto | ASP.NET Framework + AngularJS | Production (source of truth) |
| `RDO-APP/RDOAppPiscinasMobile` (GitHub) | Carlos | React Native | In development |
| `RDO-CleanMigration-2026/` | Migration team | .NET 8 MVC + EF Core | ~35% complete |

Your job is to build the **Equipamentos version** of the mobile app. The reference for how it should work is **Gilberto's code**, not Carlos's.

---

## 2. Gilberto's Navigation Pattern (The Correct Reference)

This is the navigation flow in the original production .NET app:

```
LOGIN
  ↓
ESCOLHER OBRA (escolher.html)
  → User sees a list of Obra cards
  → Each card shows: name, city/state, progress bar
  → User clicks a card → obra is stored in session
  ↓
ETAPA INDEX (etapa/index.html)
  → User sees a TABLE of Etapas (stages) for the selected Obra
  → Each row: order number, stage name, edit/delete actions
  → User selects an Etapa
  ↓
TAREFA CARDS (tarefa/cards.html)
  → User sees individual Task Cards for the selected Etapa
  → Each card: status, description, dates, workers, equipment, progress
  → Actions: view details, edit, add measurement
```

**Key point from the code**: These are THREE SEPARATE SCREENS with THREE SEPARATE ROUTES:
- `/obra/escolher` → Obra selection
- `/etapa/index` → Etapa list for selected Obra
- `/tarefa/cards` → Task cards for selected Etapa

The data model confirms this hierarchy:
```
Obra (1) → has many → Etapa (N) → has many → Tarefa (N)
```

From `etapa.cs`:
```csharp
public int eta_id_obra { get; set; }        // Etapa belongs to Obra
public virtual ICollection<tarefa> tarefa   // Etapa has many Tarefas
```

---

## 3. ⚠️ Critical Problem: Carlos's Piscinas App Does NOT Follow This Pattern

The mobile app built by Carlos (`RDOAppPiscinasMobile`) **collapses all three levels into a single card**.

From the technical briefing written for Carlos (`MOBILE-ESCOLHER-OBRA-TECHNICAL-BRIEFING-CARLOS.md`), the Obra card already includes:

```
┌────────────────────────────┐
│ ESCOLA MUNICIPAL EXEMPLO   │  ← Obra name
├────────────────────────────┤
│ 📍 Rua Exemplo, 123        │  ← Address
│    Bairro - São Paulo/SP   │
├────────────────────────────┤
│ ━━━━━━━━━━━━━━━━━━━━━━━━ │  ← Progress bar
│ 75% concluído              │  ← Calculated from ALL tarefas
│ 15/20 tarefas              │  ← Total tarefas across ALL etapas
└────────────────────────────┘
```

And the Task Card (`MOBILE-TASKCARD-TECHNICAL-BRIEFING-CARLOS.md`) is accessed directly from the Obra card — **skipping the Etapa screen entirely**.

The API endpoint confirms this:
```
GET /api/tarefa/etapa/{etapaId}
```
Carlos's app calls this endpoint but the user never explicitly selects an Etapa — the app either picks the first one or aggregates all of them into the Obra card's progress.

**Why this works for Piscinas but NOT for Equipamentos:**

The Piscinas app is for swimming pool maintenance. Each pool (Obra) typically has a small, predictable set of tasks (clean pool, check chemicals, etc.). The Etapa level is essentially irrelevant to the field worker — they just need to see "what do I do at this pool today."

The Equipamentos version is for construction/equipment management. An Obra can have many Etapas (foundation, structure, finishing, etc.), each with many tasks involving different equipment. **Collapsing Etapa into the Obra card would make the task list unmanageable** — a user could be looking at 50+ tasks from all stages mixed together.

---

## 4. Comparison Table

| Aspect | Gilberto (.NET) | Carlos (Piscinas Mobile) | Equipamentos (what you should build) |
|---|---|---|---|
| Obra screen | Cards with progress | Cards with progress + task count | Cards with progress ✅ |
| Etapa screen | Separate table view | **SKIPPED** ❌ | Separate screen ✅ |
| Task screen | Cards per Etapa | Cards aggregated from Obra | Cards per Etapa ✅ |
| Navigation depth | 3 screens | 2 screens | 3 screens ✅ |
| Task count shown | Per Etapa | Per Obra (all stages) | Per Etapa ✅ |

---

## 5. Proposal for Dimas — Equipamentos Navigation

Follow Gilberto's 3-screen pattern, adapted for React Native:

### Screen 1: Escolher Obra
Same as Carlos's implementation — this part is correct.

```
Login → Obra Cards Grid
  Card shows: name, address, overall progress, total etapas count
  Tap card → navigate to Etapa List
```

### Screen 2: Etapa List (NEW — Carlos skipped this)
This is the screen Carlos didn't build. You need it.

```
Header: [← Back] | OBRA NAME | [user menu]
Body: List of Etapa cards for the selected Obra
  Each Etapa card shows:
    - Stage name (eta_ds_etapa)
    - Order number (eta_nr_orderm)
    - Task count for this stage
    - Stage progress (% of tasks completed)
    - Equipment count assigned to this stage
  Tap card → navigate to Task Cards for this Etapa
```

**Why a card instead of a table?** Gilberto used a table (desktop). On mobile, cards are more touch-friendly. But the key is: **one screen per Etapa, not all tasks mixed together**.

### Screen 3: Task Cards (per Etapa)
Similar to Carlos's Task Card component, but scoped to the selected Etapa.

```
Header: [← Back] | ETAPA NAME | [user menu]
Body: Task Cards for the selected Etapa
  Each card shows: (same as Carlos's spec)
    - Status badge
    - Task description
    - Planning vs Execution dates (2x2 grid)
    - Workers assigned
    - Equipment assigned ← this is more prominent in Equipamentos
    - Hour meter readings (tar_dt_medicao_horimetro_inicial/final)
    - Progress percentage
```

**Equipment-specific additions to the Task Card:**
The `tarefa` entity already has hour meter fields that Carlos's Piscinas app doesn't use:
```
tar_dt_medicao_horimetro_inicial  ← Initial hour meter reading
tar_dt_medicao_horimetro_final    ← Final hour meter reading
tar_dt_medicao_horimetro_total    ← Total hours (calculated)
```
These are critical for the Equipamentos version and should be prominently displayed on the card.

---

## 6. Proposed Screen Flow (React Native)

```
Stack Navigator:
  LoginScreen
    ↓ (on success)
  EscolherObraScreen          ← Reuse Carlos's component (mostly)
    ↓ (on obra tap)
  EtapaListScreen             ← NEW — build this
    ↓ (on etapa tap)
  TarefaCardsScreen           ← Adapt Carlos's TaskCard component
    ↓ (on task tap)
  TarefaDetailScreen          ← Adapt Carlos's detail screen
```

---

## 7. API Endpoints You'll Need

These already exist in the .NET backend (Gilberto's API):

```
GET  /api/obra/escolher                    → List obras for logged user
POST /api/obra/selecionar                  → Select an obra (store in session)
GET  /api/etapa/carregarLista              → List etapas for selected obra
GET  /api/tarefa/etapa/{etapaId}           → List tarefas for an etapa
GET  /api/tarefa/{tarefaId}                → Task details
PUT  /api/tarefa/{tarefaId}                → Update task
POST /api/tarefa/{tarefaId}/equipamento    → Assign equipment to task
```

The .NET 8 migration (`RDO-CleanMigration-2026`) will eventually expose these same endpoints. For now, check with the backend team which base URL to use.

---

## 8. What to Reuse from Carlos's Code

You can reuse these parts from `RDOAppPiscinasMobile`:

- `EscolherObraScreen` — the Obra card component and grid layout
- `PermissionHelper` — the permission checking utility (exact same logic)
- `TaskCard` component — adapt it, don't rewrite from scratch
- Authentication flow (login, token storage, AsyncStorage)
- API service structure

**Do NOT reuse** the navigation structure that skips Etapa. That's the core difference.

---

## 9. Note on the GitHub Repository

The repository `https://github.com/RDO-APP/RDOAppPiscinasMobile` is **private** and could not be accessed directly for this analysis. This document is based on:

1. The technical briefing documents written for Carlos (stored in `RDO-CleanMigration-2026/`)
2. Gilberto's original production code (`EquipoToPiscina-1/RDO-Production-Gilberto/`)
3. The EF6 entity classes in `EquipoToPiscina-1/rdoappClass/`

To access Carlos's actual React Native code, you'll need to be added as a collaborator to the `RDO-APP` GitHub organization.

---

## 10. Summary for Dimas

**The single most important thing to understand:**

Carlos built the Piscinas app by merging Obra + Etapa + Tarefas into 2 screens. This was a deliberate simplification for the pool maintenance use case where stages don't matter much.

**You cannot do this for Equipamentos.** Construction equipment management requires the full 3-level hierarchy: Obra → Etapa → Tarefas. Without the Etapa screen, a user on a large construction site would see 50+ tasks from all stages mixed together with no way to filter by phase of work.

Follow Gilberto's pattern. Build 3 screens. The Etapa screen is not optional.
