# ESCOLHER PAGE: COMPLETE PLAN SUMMARY

**Date**: February 4, 2026  
**Status**: PLANS READY - NO CODE CHANGES YET  
**Documents Created**: 3

---

## DOCUMENTS CREATED

### 1. ESCOLHER-PAGE-COMPLETE-DIAGNOSTIC-5-ISSUES.md
**Purpose**: Complete diagnostic of all issues  
**Content**: 5 critical issues identified with root cause analysis

### 2. STRATEGY-1-HEADER-IMPLEMENTATION-PLAN.md
**Purpose**: Fix header issues  
**Content**: Detailed plan to fix buttons + overlap

### 3. STRATEGY-2-OBRA-CARDS-IMPLEMENTATION-PLAN.md
**Purpose**: Fix obra cards issues  
**Content**: Detailed plan to add filters + enhance cards

---

## 5 CRITICAL ISSUES IDENTIFIED

### HEADER ISSUES (3):
1. ❌ **BUTTONS NOT APPEARING**
   - **Root Cause**: Missing `/dashboard/index` route in `ObterRotasDefault()`
   - **Fix**: Add dashboard route to Routes array
   - **Time**: 15 minutes

2. ❌ **HEADER OVERLAP**
   - **Root Cause**: Missing `.conteudo` wrapper div
   - **Fix**: Add wrapper div in Escolher.cshtml
   - **Time**: 10 minutes

3. ✅ **ALIGNMENT WORKING**
   - **Status**: Fixed previously with flexbox
   - **Action**: None needed

### OBRA CARDS ISSUES (2):
4. ❌ **FILTERS COMPLETELY MISSING**
   - **Root Cause**: Never migrated from legacy
   - **Fix**: Add filter HTML + JavaScript
   - **Time**: 30 minutes

5. ❌ **CARDS OVERSIMPLIFIED**
   - **Root Cause**: Simplified during initial migration
   - **Fix**: Enhance controller + update card HTML + add legend
   - **Time**: 2 hours

---

## STRATEGY 1: HEADER (30-45 minutes)

### Phase 1: Fix Buttons (15 min)
**File**: `Controllers/AccountController.cs`  
**Change**: Add dashboard route to `ObterRotasDefault()`

```csharp
rota = new RouteViewModel();
rota.Name = "Dashboard";
rota.Path = "/dashboard/index";
rota.Permissions = new List<string>();
rota.Permissions.Add("acessarDashboard");
rota.Permissions.Add("visualizar");
ListaRotas.Add(rota);
```

**Result**: Dashboard, Charts, and New Obra buttons appear

### Phase 2: Fix Overlap (10 min)
**File**: `Views/Obra/Escolher.cshtml`  
**Change**: Add `.conteudo` wrapper div

```razor
<div class="conteudo">
    <div class="container">
        @* Existing content *@
    </div>
</div>
```

**Result**: Content starts 103px below header (no overlap)

### Phase 3: Verification (5 min)
**Checklist**:
- [ ] 3 buttons visible
- [ ] Content below header
- [ ] Logo and user aligned
- [ ] Dropdown works

---

## STRATEGY 2: OBRA CARDS (2-3 hours)

### Phase 1: Add Filters (30 min)
**File**: `Views/Obra/Escolher.cshtml`  
**Changes**:
1. Add filter HTML (2 inputs)
2. Add filter JavaScript (client-side filtering)

**Result**: Users can filter obras by name and municipality

### Phase 2: Enhance Controller (45 min)
**File**: `Controllers/ObraController.cs`  
**Changes**:
1. Add enhanced data fields (municipality, status, progress)
2. Calculate progress percentage
3. Calculate status color class

**Result**: Controller returns rich data for cards

### Phase 3: Update Card HTML (30 min)
**File**: `Views/Obra/Escolher.cshtml`  
**Change**: Replace simple cards with enhanced cards

**Result**: Cards show progress bars, status colors, municipality

### Phase 4: Add Legend (15 min)
**File**: `Views/Obra/Escolher.cshtml`  
**Change**: Add legend HTML at bottom

**Result**: Legend explains 3 progress bar colors

### Phase 5: Final Integration (15 min)
**Changes**: Update filter JavaScript for enhanced cards

**Result**: Filters work with enhanced card structure

---

## IMPLEMENTATION ORDER

### RECOMMENDED:
1. **Strategy 1 first** (header) - Quick wins, more visible
2. **Strategy 2 second** (cards) - More complex, takes longer

### ALTERNATIVE:
1. **Strategy 1 Phase 2 first** (overlap) - Fastest fix
2. **Strategy 1 Phase 1 second** (buttons) - More visible
3. **Strategy 2** (cards) - Most complex

---

## TOTAL TIME ESTIMATE

| Strategy | Time | Buffer | Total |
|----------|------|--------|-------|
| Strategy 1 | 30 min | +15 min | 45 min |
| Strategy 2 | 140 min | +40 min | 180 min |
| **TOTAL** | **170 min** | **+55 min** | **225 min (3h 45min)** |

---

## FILES TO MODIFY

### Strategy 1 (Header):
1. `Controllers/AccountController.cs` - Add dashboard route
2. `Views/Obra/Escolher.cshtml` - Add .conteudo wrapper

### Strategy 2 (Obra Cards):
1. `Controllers/ObraController.cs` - Enhance data + calculations
2. `Views/Obra/Escolher.cshtml` - Add filters + enhance cards + add legend
3. `wwwroot/css/escolher.css` - Add legend CSS (if missing)

---

## QUESTIONS FOR USER

### Before Strategy 1:
1. Should we add `/dashboard/index` route even if Dashboard controller doesn't exist yet?
   - **Recommendation**: YES (add route now, implement controller later)

2. Should dashboard use `acessarDashboard` or `visualizar` permission?
   - **Recommendation**: `acessarDashboard` (matches legacy)

### Before Strategy 2:
1. How is progress calculated?
   - **Assumption**: (Completed Tasks / Total Tasks) * 100

2. How is status color determined?
   - **Assumption**: Green = 100%, Red = deadline exceeded, Gray = in progress

3. What is "statusBasicaGratuita"?
   - **Assumption**: Always "Básica" for now

4. What is "contratanteContratada"?
   - **Assumption**: Always "contratante" for now

5. Does database have separate city/state fields?
   - **Assumption**: `ObrDsCidade` + `ObrDsEstado`

---

## SUCCESS CRITERIA

### Strategy 1 Complete:
- ✅ Dashboard button visible
- ✅ Charts button visible
- ✅ New Obra button visible
- ✅ Content starts below header (no overlap)
- ✅ Logo and user aligned
- ✅ Dropdown works

### Strategy 2 Complete:
- ✅ Filter inputs visible
- ✅ Real-time filtering works
- ✅ Cards show municipality
- ✅ Cards show status text
- ✅ Cards show progress bar
- ✅ Progress bars color-coded
- ✅ Legend visible at bottom
- ✅ Legend explains colors

---

## RISK ASSESSMENT

### Low Risk:
- Adding route to Routes array
- Adding wrapper div
- Adding filter HTML
- Adding legend HTML

### Medium Risk:
- Filter JavaScript (might conflict)
- Enhanced card HTML (might break layout)
- Progress calculation (depends on DB structure)

### High Risk:
- None identified

---

## ROLLBACK PLAN

### If Strategy 1 Fails:
```bash
git checkout HEAD -- Controllers/AccountController.cs
git checkout HEAD -- Views/Obra/Escolher.cshtml
dotnet build
```

### If Strategy 2 Fails:
```bash
git checkout HEAD -- Controllers/ObraController.cs
git checkout HEAD -- Views/Obra/Escolher.cshtml
git checkout HEAD -- wwwroot/css/escolher.css
dotnet build
```

---

## NEXT STEPS

1. **User reviews plans** and answers questions
2. **User approves** Strategy 1 and/or Strategy 2
3. **Implement Strategy 1** (header fixes)
4. **Test and verify** Strategy 1
5. **Implement Strategy 2** (obra cards)
6. **Test and verify** Strategy 2
7. **Move to next feature** (Dashboard? Etapas/Tarefas?)

---

## VISUAL COMPARISON

### BEFORE (Current):
```
┌─────────────────────────────────────────────────────────┐
│ HEADER (fixed, 54px height)                             │
│ [Logo] Piscinas                              [User▼]    │
│                                              (NO BUTTONS)│
└─────────────────────────────────────────────────────────┘
                                                            ← 0px padding (OVERLAP!)
┌──────────┐ ┌──────────┐ ┌──────────┐  ← HIDDEN UNDER HEADER
│ [icon]   │ │ [icon]   │ │ [icon]   │  (NO FILTERS)
│ Obra 1   │ │ Obra 2   │ │ Obra 3   │
│ ID: 1    │ │ ID: 2    │ │ ID: 3    │
└──────────┘ └──────────┘ └──────────┘

(No progress bars, no legend)
```

### AFTER (Target):
```
┌─────────────────────────────────────────────────────────┐
│ HEADER (fixed, 54px height)                             │
│ [Logo] Piscinas          [Dashboard][Charts][+] [User▼] │
└─────────────────────────────────────────────────────────┘
                                                            ← 103px padding-top
┌─────────────────────────────────────────────────────────┐
│                        Filtros                          │
│         [Unidade escolar input] [Município input]       │
└─────────────────────────────────────────────────────────┘

        Selecione uma das unidades escolares abaixo:

┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐
│ [icon]   │ │ [icon]   │ │ [icon]   │ │ [icon]   │
│ Obra 1   │ │ Obra 2   │ │ Obra 3   │ │ Obra 4   │
│ São Paulo│ │ Rio      │ │ Curitiba │ │ Salvador │
│ (Básica) │ │ (Básica) │ │ (Básica) │ │ (Básica) │
│ STATUS   │ │ STATUS   │ │ STATUS   │ │ STATUS   │
│ [▓▓▓░░]  │ │ [▓▓▓▓░]  │ │ [▓▓░░░]  │ │ [▓▓▓▓▓]  │
│ 60%      │ │ 80%      │ │ 40%      │ │ 100%     │
└──────────┘ └──────────┘ └──────────┘ └──────────┘

BARRA DE PROGRESSO DA UNIDADE ESCOLAR:
[■] UNIDADE ESCOLAR COM PRAZO ESTIMADO ATINGIDO
[■] UNIDADE ESCOLAR COM PRAZO ESTIMADO ULTRAPASSADO
[■] UNIDADE ESCOLAR EM ANDAMENTO
```

---

**STATUS**: PLANS READY - AWAITING USER APPROVAL TO IMPLEMENT
