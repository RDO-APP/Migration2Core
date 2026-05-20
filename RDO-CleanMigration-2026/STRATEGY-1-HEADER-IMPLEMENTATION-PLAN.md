# STRATEGY 1: HEADER IMPLEMENTATION PLAN

**Date**: February 4, 2026  
**Scope**: Fix header issues (buttons + overlap)  
**Status**: PLAN READY - NO CODE CHANGES YET

---

## OVERVIEW

This strategy fixes **2 critical header issues**:
1. ❌ **Buttons not appearing** - Missing dashboard route in Routes array
2. ❌ **Header overlap** - Missing `.conteudo` wrapper div

**Estimated Time**: 30-45 minutes  
**Risk Level**: LOW (isolated changes, easy to rollback)

---

## ISSUE #1: BUTTONS NOT APPEARING

### Root Cause:
`AccountController.ObterRotasDefault()` does NOT include `/dashboard/index` route, so `PermissionHelper.HasPermission()` returns `false` for all button checks.

### Current Routes in ObterRotasDefault():
```csharp
✅ /obra/escolher (visualizar)
✅ /obra/cadastro (visualizar)
✅ /colaborador/alterarsenha (visualizar)
✅ /convidada (visualizar)
✅ /etapa/index (visualizar)
✅ /etapa/cadastro (visualizar)
✅ /chart (visualizar)  ← Charts button uses this
✅ /chart/rdos (visualizar)
✅ /chart/atrasado (visualizar)
✅ /chart/diaimprodutivo (visualizar)
✅ /chart/tarefa (visualizar)
✅ /chart/comentario (visualizar)
✅ /tarefa/paralizacoes/index (visualizar)

❌ /dashboard/index (acessarDashboard) ← MISSING!
```

### Header Button Checks:
```csharp
// Button 1: Dashboard - FAILS (route not in array)
@if (PermissionHelper.HasPermission(Context, "acessarDashboard", "/dashboard/index"))

// Button 2: Charts - SHOULD WORK (route exists)
@if (PermissionHelper.HasPermission(Context, "visualizar", "/chart"))

// Button 3: New Obra - SHOULD WORK (route exists)
@if (PermissionHelper.HasPermission(Context, "visualizar", "/obra/cadastro"))
```

### Solution:

**Add missing dashboard route to `ObterRotasDefault()`**:

```csharp
// File: Controllers/AccountController.cs
// Method: ObterRotasDefault()
// Location: After /chart route, before ObterRotasAdmin()

rota = new RouteViewModel();
rota.Name = "Dashboard";
rota.Path = "/dashboard/index";
rota.Permissions = new List<string>();
rota.Permissions.Add("acessarDashboard");
rota.Permissions.Add("visualizar");
ListaRotas.Add(rota);
```

**Why this works**:
1. Adds `/dashboard/index` route to Routes array
2. Includes `acessarDashboard` permission
3. `PermissionHelper.HasPermission(Context, "acessarDashboard", "/dashboard/index")` will return `true`
4. Button will render

---

## ISSUE #2: HEADER OVERLAP

### Root Cause:
Current implementation missing `.conteudo` wrapper div, so CSS rule `.topo + .conteudo { padding-top: 103px; }` never applies.

### Legacy Pattern:
```html
<div class="topo">
    <nav>...</nav>
</div>

<div class="conteudo">  <!-- ← THIS WRAPPER IS MISSING -->
    <div class="container">
        <!-- Content here -->
    </div>
</div>
```

**CSS Rule**:
```css
.topo + .conteudo {
    padding-top: 103px;  /* Pushes content below fixed header */
}
```

### Current Implementation:
```razor
@* _HeaderEscolher.cshtml renders .topo *@

@* Escolher.cshtml - NO .conteudo WRAPPER! *@
<div class="container">
    <div class="row justify-content-center">
        <div class="col-12">
            @* Content starts at top: 0 *@
```

### Solution:

**Add `.conteudo` wrapper div in Escolher.cshtml**:

```razor
@* File: Views/Obra/Escolher.cshtml *@
@model IEnumerable<dynamic>
@{
    Layout = "_LayoutEscolher";
    ViewData["Title"] = "Escolher Unidade Escolar";
}

<div class="conteudo">  <!-- ← ADD THIS WRAPPER -->
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-12">
                @if (Model != null && Model.Any())
                {
                    <div class="lista-obras">
                        @* Cards here *@
                    </div>
                }
                else
                {
                    <div class="alert alert-warning text-center">
                        <strong>Nenhuma unidade escolar encontrada.</strong><br />
                        Você não está associado a nenhuma unidade escolar.
                    </div>
                }
            </div>
        </div>
    </div>
</div>  <!-- ← ADD THIS CLOSING TAG -->
```

**Why this works**:
1. Creates `.conteudo` div immediately after `.topo` (from header)
2. CSS selector `.topo + .conteudo` matches
3. `padding-top: 103px` applies automatically
4. Content starts below header

---

## IMPLEMENTATION STEPS

### Phase 1: Fix Buttons (15 minutes)

**Step 1.1: Add Dashboard Route**
```csharp
// File: RdoApp.Core/Controllers/AccountController.cs
// Method: ObterRotasDefault()
// Line: ~180 (after /chart route)

rota = new RouteViewModel();
rota.Name = "Dashboard";
rota.Path = "/dashboard/index";
rota.Permissions = new List<string>();
rota.Permissions.Add("acessarDashboard");
rota.Permissions.Add("visualizar");
ListaRotas.Add(rota);
```

**Step 1.2: Rebuild & Test**
```powershell
# Stop server
# Rebuild project
dotnet build

# Start server
dotnet run

# Test: Login → Escolher page → Check if buttons appear
```

**Expected Result**:
- Dashboard button appears ✅
- Charts button appears ✅
- New Obra button appears ✅

---

### Phase 2: Fix Header Overlap (10 minutes)

**Step 2.1: Add .conteudo Wrapper**
```razor
@* File: RdoApp.Core/Views/Obra/Escolher.cshtml *@
@* Line: ~12 (before <div class="container">) *@

<div class="conteudo">  <!-- ADD THIS -->
    <div class="container">
        @* Existing content *@
    </div>
</div>  <!-- ADD THIS -->
```

**Step 2.2: Test**
```powershell
# Refresh browser (Ctrl+F5)
# Check if content is below header (not overlapping)
```

**Expected Result**:
- Content starts 103px below header ✅
- First row of cards visible ✅
- No overlap ✅

---

### Phase 3: Verification (5 minutes)

**Checklist**:
- [ ] Dashboard button visible
- [ ] Charts button visible
- [ ] New Obra button visible
- [ ] Content below header (no overlap)
- [ ] Logo and user still aligned
- [ ] Dropdown still works

---

## FILES TO MODIFY

### File 1: AccountController.cs
**Path**: `RDO-CleanMigration-2026/RdoApp.Core/Controllers/AccountController.cs`  
**Method**: `ObterRotasDefault()`  
**Change**: Add dashboard route  
**Lines**: ~180 (after /chart route)

### File 2: Escolher.cshtml
**Path**: `RDO-CleanMigration-2026/RdoApp.Core/Views/Obra/Escolher.cshtml`  
**Change**: Add `.conteudo` wrapper div  
**Lines**: ~12 (wrap entire content)

---

## ROLLBACK PLAN

### If Buttons Still Don't Appear:
1. Check browser console for errors
2. Check session data exists: `HttpContext.Session.GetString("LoginData")`
3. Add debug logging to `PermissionHelper.HasPermission()`
4. Verify Routes array contains dashboard route

### If Header Overlap Persists:
1. Check CSS file loaded: `escolher.css`
2. Verify `.topo + .conteudo` rule exists
3. Check browser DevTools: Computed styles for `.conteudo`
4. Try adding `!important`: `padding-top: 103px !important;`

### If Everything Breaks:
```bash
# Revert changes
git checkout HEAD -- Controllers/AccountController.cs
git checkout HEAD -- Views/Obra/Escolher.cshtml

# Rebuild
dotnet build
```

---

## TESTING CHECKLIST

### Before Changes:
- [ ] Login works
- [ ] Escolher page loads
- [ ] Zero buttons visible
- [ ] Header overlaps cards
- [ ] Logo and user aligned

### After Phase 1 (Buttons):
- [ ] Dashboard button visible
- [ ] Charts button visible
- [ ] New Obra button visible
- [ ] Buttons clickable (even if routes don't exist yet)

### After Phase 2 (Overlap):
- [ ] Content starts below header
- [ ] First row of cards visible
- [ ] No overlap
- [ ] Filters visible (if added)

### Final Verification:
- [ ] All 3 buttons visible
- [ ] Content below header
- [ ] Logo and user aligned
- [ ] Dropdown works
- [ ] Cards clickable

---

## QUESTIONS FOR USER

Before implementing, confirm:

1. **Dashboard Route**: Should we add `/dashboard/index` route even if Dashboard controller doesn't exist yet?
   - YES: Add route now, implement controller later
   - NO: Change header to use existing routes

2. **Permission Name**: Should dashboard use `acessarDashboard` or `visualizar`?
   - Legacy uses: `acessarDashboard`
   - Other routes use: `visualizar`
   - Recommendation: Use `acessarDashboard` (matches legacy)

3. **Implementation Order**: Fix buttons first or overlap first?
   - Recommendation: Buttons first (more visible impact)

---

## SUCCESS CRITERIA

### Buttons Fixed:
- ✅ Dashboard button visible
- ✅ Charts button visible
- ✅ New Obra button visible
- ✅ Buttons have hover effect
- ✅ Tooltips appear on hover

### Overlap Fixed:
- ✅ Content starts 103px below header
- ✅ First row of cards fully visible
- ✅ No overlap between header and content
- ✅ Scrolling works correctly

---

## ESTIMATED TIME

| Phase | Task | Time |
|-------|------|------|
| Phase 1 | Add dashboard route | 5 min |
| Phase 1 | Rebuild & test | 10 min |
| Phase 2 | Add .conteudo wrapper | 5 min |
| Phase 2 | Test overlap fix | 5 min |
| Phase 3 | Final verification | 5 min |
| **TOTAL** | | **30 min** |

**Buffer**: +15 minutes for unexpected issues  
**Total with buffer**: **45 minutes**

---

## RISK ASSESSMENT

### Low Risk:
- Adding route to Routes array (isolated change)
- Adding wrapper div (doesn't break existing HTML)
- CSS rule already exists (just needs to apply)

### Medium Risk:
- Session data might not persist (need to debug)
- Other pages might need `.conteudo` wrapper too

### High Risk:
- None identified

---

## NEXT STEPS

After Strategy 1 complete:
1. Test header thoroughly
2. Get user confirmation
3. Move to **Strategy 2: Obra Cards** (filters + enhanced cards)

---

**STATUS**: PLAN READY - AWAITING USER APPROVAL TO IMPLEMENT
