# Apontador App — Complete Analysis & Navigation Proposal for Dimas

**Prepared by**: Kiro (AI)  
**Date**: May 2026  
**Based on**: Live analysis of RDO-APP/Equipamentos, RDO-APP/RDOAppPiscinasMobile, RDO-APP/Migration2Core  
**For**: Dimas Torres — developer of the Equipamentos/Apontador mobile app

---

## 1. The Four Repositories — What Each One Is

| Repository | Developer | Tech | Purpose |
|---|---|---|---|
| `RDO-APP/Equipamentos` | Dimas + Brenda | ASP.NET Framework + AngularJS | Legacy Equipamentos web app — your reference for business logic |
| `RDO-APP/RDOAppPiscinasMobile` | Carlos | React Native + Expo | Mobile app — already has Apontador variant built in |
| `RDO-APP/Migration2Core` | Migration team | .NET 8 MVC + EF Core | Backend migration — 48 entities done, API in progress |
| `RDO-APP/EquipoToPiscina` | Lucio + Kiro | ASP.NET Framework + AngularJS | First migration attempt — RDO adapted for Piscinas. Abandoned Jan 2026. Contains the legacy production code by Gilberto (`RDO-Production-Gilberto/`) which is the source of truth for business logic and navigation patterns. |

---

## 2. The Most Important Discovery: Carlos Already Built the Apontador Variant

The `RDOAppPiscinasMobile` repo is **not just a Piscinas app**. Carlos built a variant system from the start. In `src/config/appVariant.ts`:

```typescript
export const APP_VARIANTS = {
  appPiscinas: {
    type: 'pools',
    headerTitle: 'PISCINAS',
    apiUrls: {
      prod: 'https://piscinas.rdoapp.com.br',
      homolog: 'http://192.168.0.8:5000',
    }
  },
  appApontador: {
    type: 'equipments',
    headerTitle: 'APONTADOR',
    apiUrls: {
      prod: 'https://sistema.rdoapp.com.br',   // ← your backend
      homolog: 'http://192.168.0.8:58951',
    }
  },
}
```

To run the Apontador variant today:
```bash
npm run start:appApontador
npm run android:appApontador:homolog
npm run ios:appApontador:homolog
```

The variant config, API routing, and build scripts are already wired. **You are not starting from zero.**

---

## 3. The Navigation Pattern Problem — Carlos vs. Gilberto

This is the core issue you need to understand before writing a single line of code.

### Gilberto's Pattern (The Correct Reference — `RDO-APP/Equipamentos`)

The legacy Equipamentos web app follows a strict 4-level navigation:

```
LOGIN
  ↓
ESCOLHER OBRA  (escolher.html)
  → Grid of Obra cards
  → Each card: name, city/state, progress bar
  → Tap → obra stored in session
  ↓
ETAPA / TAREFAS  (tarefa/cards.html)
  → Accordion: one collapsible section per Etapa
  → Inside each Etapa: Task Cards
  → Each Task Card: status, dates, workers, equipment count, progress
  → Actions: Nova Medição, Histórico, Editar, Excluir, Relatório Horas
  ↓
TASK DETAIL / NOVA MEDIÇÃO
  → Date, Hora Inicial/Final
  → Horímetro Inicial, Horímetro Final, Total Horas  ← EQUIPMENT-SPECIFIC
  → Quantidade Construída, Comentário, Foto
```

The data model enforces this:
```
Obra (1) → has many → Etapa (N) → has many → Tarefa (N)
```

### Carlos's Piscinas Pattern (What Was Actually Built)

Carlos built **two different dashboards** in the same codebase:

**`PiscineiroDashboard` — the collapsed pattern (Piscinas only):**
```typescript
// piscineiro-screen.tsx
card.etapas.tarefas.map((etapa: any) => {
  return <TaskCard etapa={etapa} obra={card?.obra} ... />
})
```
This renders Task Cards directly from the Obra card — **Etapa is skipped as a navigation step**. The user goes Login → Obra+Tasks on one screen. This works for Piscinas because each pool has a small, predictable set of tasks and the stage doesn't matter to the field worker.

**`NormalDashboard` + `NormalWorkDetails` — the correct pattern:**
```typescript
// normal-dasboard.tsx
onPress={() => setSelectedObra(card?.obra)  // tap obra card → go to details

// normal-work-details.tsx
filteredEtapas.map((etapa: any) => {
  // Collapsible accordion header per Etapa
  <Pressable onPress={() => toggleGroup(groupKey)}>
    {etapa.titulo}
  </Pressable>
  // Task cards inside each Etapa
  etapa.tarefas.map((tarefa) => <TaskCard ... />)
})
```

`NormalWorkDetails` already implements the Gilberto pattern: Obra → Etapa accordion → Task Cards. It even has the same filters as the legacy web app (description, status, dates, etapa name).

### The Verdict

| | Piscinas (`PiscineiroDashboard`) | Apontador (what you need) |
|---|---|---|
| Login | ✅ Same | ✅ Same |
| Obra selection | ✅ Same | ✅ Same |
| Etapa screen | ❌ Skipped | ✅ Required |
| Task cards | ✅ Flat list | ✅ Per Etapa |
| Hour meter fields | ❌ Not used | ✅ Required |
| Equipment report | ❌ Not present | ✅ Required |

**Do not copy `PiscineiroDashboard` for Apontador. Use `NormalDashboard` + `NormalWorkDetails` as your base.**

---

## 4. Proposed Navigation Model for Apontador

This is a 4-screen stack, matching Gilberto's pattern, built on top of Carlos's existing components.

### Screen 1: Login
**Reuse as-is.** `src/components/screens/login-screen.tsx`

The login screen is shared between both variants. No changes needed.

```
┌─────────────────────────────┐
│         APONTADOR           │
│                             │
│  CPF: [___.___.___-__]      │
│  Senha: [__________]        │
│                             │
│       [ENTRAR]              │
│  Esqueci minha senha        │
└─────────────────────────────┘
```

---

### Screen 2: Escolher Obra
**Reuse `NormalDashboard` with minor label changes.**

The `NormalDashboard` already shows Obra cards in a grid with filters for name and city. For Apontador, the label "Unidade escolar" becomes "Obra".

```
┌─────────────────────────────────────┐
│  APONTADOR          [user ▼]        │
├─────────────────────────────────────┤
│  Obra: [buscar...]  Município: [...] │
├─────────────────────────────────────┤
│  ┌──────────┐  ┌──────────┐        │
│  │ OBRA A   │  │ OBRA B   │        │
│  │ São Paulo│  │ Campinas │        │
│  │ ████░░ 65%│  │ ██░░░ 40%│        │
│  └──────────┘  └──────────┘        │
│  ┌──────────┐  ┌──────────┐        │
│  │ OBRA C   │  │ OBRA D   │        │
│  └──────────┘  └──────────┘        │
└─────────────────────────────────────┘
```

**Changes from Piscinas:**
- Header title: "APONTADOR" (already in `appVariant.ts`)
- Card label: "Obra" not "Unidade Escolar"
- On tap: navigate to Etapa List (not directly to tasks)

---

### Screen 3: Etapa List (NEW — this is what Carlos skipped)
**Build this as a new screen, or adapt `NormalWorkDetails` into a dedicated Etapa selection screen.**

This is the key screen that separates Apontador from Piscinas. The user sees the Etapas for the selected Obra and taps one to enter its tasks.

```
┌─────────────────────────────────────┐
│  ← OBRA A — São Paulo               │
│  ETAPAS                             │
├─────────────────────────────────────┤
│  ┌───────────────────────────────┐  │
│  │ 1. FUNDAÇÃO                   │  │
│  │    12 tarefas · 45% concluído │  │
│  │    3 equipamentos ativos      │  │
│  └───────────────────────────────┘  │
│  ┌───────────────────────────────┐  │
│  │ 2. ESTRUTURA                  │  │
│  │    8 tarefas · 20% concluído  │  │
│  │    5 equipamentos ativos      │  │
│  └───────────────────────────────┘  │
│  ┌───────────────────────────────┐  │
│  │ 3. ACABAMENTO                 │  │
│  │    0 tarefas · 0% concluído   │  │
│  └───────────────────────────────┘  │
└─────────────────────────────────────┘
```

**Why a dedicated screen instead of the accordion in `NormalWorkDetails`:**

The accordion in `NormalWorkDetails` collapses/expands Etapas on the same screen. This works on desktop but on mobile with many Etapas and many tasks per Etapa, it becomes a very long scroll. A dedicated Etapa selection screen is cleaner and matches the Gilberto pattern more precisely.

**Etapa Card data to show:**
- Stage name (`eta_ds_etapa`)
- Order number (`eta_nr_orderm`)
- Task count for this stage
- Completion percentage
- Equipment count assigned to this stage

**API endpoint needed:**
```
GET /api/etapa/carregarLista  (already exists in legacy backend)
```

---

### Screen 4: Task Cards (per Etapa)
**Adapt `NormalWorkDetails` task card section, scoped to the selected Etapa.**

This is similar to Carlos's `TaskCard` component but with equipment-specific fields added.

```
┌─────────────────────────────────────┐
│  ← FUNDAÇÃO                         │
│  [FILTRO] [+ TAREFA] [+ ETAPA]      │
├─────────────────────────────────────┤
│  ┌───────────────────────────────┐  │
│  │ [Em Execução]        [65%  ●] │  │
│  │ Escavação mecânica            │  │
│  │ ┌──────────┬──────────┐      │  │
│  │ │PLANEJADO │EXECUTADO │      │  │
│  │ │01/03 →   │03/03 →   │      │  │
│  │ │15/03     │--/--     │      │  │
│  │ └──────────┴──────────┘      │  │
│  │ 👷 2 colaboradores            │  │
│  │ 🚜 Escavadeira CAT 320        │  │
│  │ ⏱ Horímetro: 1250 → 1268     │  │
│  │ Total: 18h                    │  │
│  │ [+ Medição] [Histórico] [PDF] │  │
│  └───────────────────────────────┘  │
│  ┌───────────────────────────────┐  │
│  │ [Planejada]          [0%   ●] │  │
│  │ Concretagem da laje           │  │
│  └───────────────────────────────┘  │
└─────────────────────────────────────┘
```

**Equipment-specific additions to the Task Card (not in Piscinas):**
- Horímetro Inicial / Horímetro Final / Total Horas
- Equipment name and model (from `ObraTarefaEquipamento`)
- "Relatório Controle de Horas" button → PDF/Excel export

**Fields from the legacy `tarefa` entity to display:**
```typescript
// Already in the database, just not shown in Piscinas variant
tar_dt_medicao_horimetro_inicial  // Initial hour meter reading
tar_dt_medicao_horimetro_final    // Final hour meter reading
tar_dt_medicao_horimetro_total    // Total hours (calculated)
tar_nr_horas_trabalhadas          // Hours worked
tar_dt_medicao_hora_inicial       // Start time
tar_dt_medicao_hora_final         // End time
```

---

### Screen 5: Nova Medição (Add Register)
**Adapt `AddRegisterModal` / `add-register-screen.tsx` with equipment fields.**

The Piscinas version captures water quality fields (pH, chlorine, etc.). The Apontador version captures equipment operation fields.

```
┌─────────────────────────────────────┐
│  Nova Medição                       │
│  Escavação mecânica                 │
├─────────────────────────────────────┤
│  Status: [Em Execução ▼]            │
│  Data:   [03/03/2026]               │
│  Hora Inicial: [07:00]              │
│  Hora Final:   [17:00]              │
│                                     │
│  Horímetro Inicial: [1250]          │
│  Horímetro Final:   [1268]          │
│  Total Horas:       [18.0] (auto)   │
│                                     │
│  Qtd Construída: [___]              │
│  Comentário: [________________]     │
│  Foto: [Adicionar foto]             │
│                                     │
│  [SALVAR]  [Cancelar]               │
└─────────────────────────────────────┘
```

---

## 5. What to Reuse from Carlos's Code

| Component | File | Action |
|---|---|---|
| Login screen | `screens/login-screen.tsx` | Reuse as-is |
| Obra cards grid | `screens/normal-dasboard.tsx` | Reuse, change label "Unidade escolar" → "Obra" |
| Task card component | `cards/taskCard.tsx` | Adapt — add hour meter fields |
| Add register modal | `screens/add_modify_register/add-register-screen.tsx` | Adapt — replace water quality fields with hour meter fields |
| History screen | `screens/history/history-screen.tsx` | Reuse — already shows Horímetro columns |
| Permission helper | `utils/` | Reuse as-is |
| Auth context | `contexts/AuthContext.tsx` | Reuse as-is |
| App variant config | `src/config/appVariant.ts` | Already configured for `appApontador` |

**What to build new:**
- `EtapaListScreen` — the Etapa selection screen (Screen 3 above)
- Equipment hours report button + PDF generation in Task Card
- Hour meter fields in `AddRegisterModal` for `appApontador` variant

---

## 6. How to Implement the Variant Difference

Carlos's variant system uses `APP_VARIANT` to switch behavior. The pattern to follow:

```typescript
import { APP_VARIANT } from '@/src/config/appVariant';

// In the dashboard router
function Dashboard({ obras }) {
  if (APP_VARIANT === 'appApontador') {
    return <ApontadorDashboard obras={obras} />;  // 3-screen flow
  }
  return <PiscineiroDashboard obras={obras} />;   // 2-screen flow
}
```

For the Task Card, use the same pattern to show/hide fields:
```typescript
// In TaskCard component
{APP_VARIANT === 'appApontador' && (
  <View style={styles.horimetroRow}>
    <Text>⏱ {horimetroInicial} → {horimetroFinal} ({horimetroTotal}h)</Text>
  </View>
)}

{APP_VARIANT === 'appPiscinas' && (
  <View style={styles.waterQualityRow}>
    <Text>pH: {ph} | Cloro: {cloro}</Text>
  </View>
)}
```

---

## 7. Navigation Stack (React Navigation / Expo Router)

Carlos uses Expo Router. The Apontador navigation stack should be:

```
app/
  _layout.tsx          ← Root layout (auth guard)
  index.tsx            ← Login screen
  (tabs)/
    _layout.tsx        ← Tab bar (if needed)
    dashboard.tsx      ← Escolher Obra (Screen 2)
    etapas.tsx         ← Etapa List (Screen 3) — NEW
    tarefas.tsx        ← Task Cards (Screen 4)
```

Or using stack navigation (simpler for this flow):
```typescript
// Apontador stack
<Stack>
  <Stack.Screen name="login" />
  <Stack.Screen name="obras" />        // Escolher Obra
  <Stack.Screen name="etapas" />       // Etapa List ← NEW
  <Stack.Screen name="tarefas" />      // Task Cards
  <Stack.Screen name="medicao" />      // Nova Medição
</Stack>
```

---

## 8. API Endpoints Needed

All of these already exist in the legacy backend (`https://sistema.rdoapp.com.br`):

```
POST /api/usuario/login                    → Login
POST /api/usuario/loginObra                → Select obra (store in session)
POST /api/obra/ObterObras                  → List obras for user
POST /api/etapa/CarregarLista              → List etapas for selected obra
POST /api/tarefa/carregarCards             → Task cards for selected etapa
POST /api/tarefa/salvar                    → Save task / nova medição
POST /api/tarefa/historico                 → Task measurement history
GET  /api/tarefa/relatorioHorasEquipamento → Equipment hours report (PDF/Excel)
```

The `appApontador` variant in `appVariant.ts` already points to `https://sistema.rdoapp.com.br` for production.

---

## 9. Summary — What Dimas Needs to Do

### Phase 1: Wire the Apontador variant (1-2 days)
- [ ] Confirm `appApontador` variant runs and connects to the correct backend
- [ ] Replace `PiscineiroDashboard` with `NormalDashboard` for `appApontador`
- [ ] Change "Unidade escolar" label to "Obra" for `appApontador`
- [ ] Test login → obra list flow end-to-end

### Phase 2: Build the Etapa List screen (2-3 days)
- [ ] Create `EtapaListScreen` component
- [ ] Call `POST /api/etapa/CarregarLista` with selected `idObra`
- [ ] Display Etapa cards with name, order, task count, progress
- [ ] Navigate to Task Cards on tap

### Phase 3: Adapt Task Cards for equipment (2-3 days)
- [ ] Add hour meter fields to `TaskCard` for `appApontador`
- [ ] Show equipment name/model on card
- [ ] Add "Relatório Horas" button
- [ ] Scope task list to selected Etapa (not all tasks for the Obra)

### Phase 4: Adapt Nova Medição for equipment (2 days)
- [ ] Replace water quality fields with hour meter fields in `AddRegisterModal`
- [ ] Auto-calculate `horimetroTotal = horimetroFinal - horimetroInicial`
- [ ] Test save flow end-to-end

### Phase 5: Equipment Hours Report (1-2 days)
- [ ] Add date range filter modal
- [ ] Call report endpoint
- [ ] Open PDF/Excel using `expo-intent-launcher` (already in the project)

**Total estimate: ~10-12 days of focused development**

---

## 10. The One Rule to Remember

The Piscinas app skips Etapa because pools are simple — one location, predictable tasks, stage doesn't matter.

The Equipamentos app **cannot skip Etapa** because construction sites have multiple phases (foundation, structure, finishing), each with different equipment, different workers, and different measurement requirements. Mixing all tasks from all stages on one screen would be unusable.

**Login → Obra → Etapa → Tarefa. Always. No shortcuts.**

---

*Document based on live code analysis of RDO-APP/Equipamentos and RDO-APP/RDOAppPiscinasMobile repositories, May 2026.*
