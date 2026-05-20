# SPEC CREATED: Escolher Header Buttons

**Date**: February 5, 2026  
**Status**: Requirements Complete - Ready for Implementation  
**Location**: `RDO-CleanMigration-2026/.kiro/specs/escolher-header-buttons/requirements.md`

---

## CLARIFICATION

**User Correction**: "no new **code** files" means no new .cs, .cshtml, .js files  
**Specification/documentation files ARE allowed** and helpful for planning

---

## WHAT WAS CREATED

Comprehensive **requirements specification** for fixing the missing action buttons in the Escolher Obra page header.

### Spec File Location
```
RDO-CleanMigration-2026/
└── .kiro/
    └── specs/
        └── escolher-header-buttons/
            └── requirements.md  ← SPEC FILE
```

---

## SPEC SUMMARY

### Problem Statement
- **Current**: Zero buttons visible in header (only logo and user dropdown)
- **Expected**: 2 buttons visible (DASHBOARD GERAL + NOVA UNIDADE ESCOLAR)
- **Hypothesis**: Session data not persisting or routes array empty

### User Requirements Captured

#### 1. Button Requirements
- **Button 1**: DASHBOARD GERAL (bar chart icon) → Charts page
- **Button 2**: NOVA UNIDADE ESCOLAR (plus icon) → New Obra page
- Both buttons use permission checking (`visualizar` on specific routes)

#### 2. Permission System
- Uses `PermissionHelper.HasPermission(Context, permission, route)`
- Reads session data (`LoginData` key)
- Matches legacy `Permission.check()` logic exactly

#### 3. Session Data
- Login stores `LoginViewModel` in session
- Contains Routes array with paths and permissions
- Must persist between login and Escolher page

#### 4. Debug Requirements
- Add temporary logging to `PermissionHelper.HasPermission()`
- Show session data, routes count, all routes, permission checks
- Identify root cause before making code changes

#### 5. Header Overlap Fix
- Add `.conteudo` wrapper to fix content positioning
- Content should start 103px below header

---

## IMPLEMENTATION PHASES

### Phase 1: Debug Session Data (15 min)
**Goal**: Identify root cause

**Steps**:
1. Add debug logging to `PermissionHelper.HasPermission()`
2. Run application
3. Capture console output
4. Analyze results

**Expected Scenarios**:
- A: Session data missing → Fix session middleware
- B: Routes array empty → Fix `ObterRotasDefault()` call
- C: Route not in array → Add missing route
- D: Permission not in route → Fix permission
- E: Everything works → Investigate view rendering

---

### Phase 2: Apply Fix (10-30 min)
**Goal**: Fix identified issue based on debug results

**Approach**: Evidence-based fix (no guessing)

---

### Phase 3: Remove Debug Logging (5 min)
**Goal**: Clean up temporary debug code

---

### Phase 4: Fix Header Overlap (5 min)
**Goal**: Add `.conteudo` wrapper to Escolher.cshtml

---

## SUCCESS CRITERIA

### Buttons Visible
- ✅ DASHBOARD GERAL button (bar chart icon) visible
- ✅ NOVA UNIDADE ESCOLAR button (plus icon) visible
- ✅ Buttons have hover effect
- ✅ Tooltips appear on hover

### Functionality Working
- ✅ Charts button links to `/Chart/Index`
- ✅ Nova Obra button links to `/Obra/Cadastro`
- ✅ Permission checking works correctly

### Layout Fixed
- ✅ Content starts 103px below header
- ✅ First row of cards fully visible
- ✅ No overlap

---

## USER CORRECTIONS APPLIED

All user corrections from conversation have been incorporated:

1. ✅ **"do not create new routes, respect the legacy rules!"**
   - Spec uses existing routes only (`/chart`, `/obra/cadastro`)
   - No new routes without user approval

2. ✅ **"Always go study the legacy code!"**
   - Studied `nav.html` and `NavController.js`
   - Documented legacy button structure and permission logic

3. ✅ **"Debug first with logging, NO code changes until debug results analyzed"**
   - Phase 1 is debug only (no code changes)
   - Fix applied only after debug results analyzed

4. ✅ **User wants ONLY 2 buttons on Escolher page**
   - Spec focuses on Charts and Nova Obra buttons only
   - Other 4 legacy buttons out of scope (obra-dependent)

5. ✅ **Respect ALL legacy logic while avoiding old technology**
   - Permission checking matches legacy exactly
   - Uses modern ASP.NET Core (not AngularJS)

6. ✅ **"no new files" = no new CODE files**
   - Specification/documentation files are allowed
   - No new .cs, .cshtml, .js files will be created

---

## TECHNICAL DETAILS

### Files Involved (NO NEW CODE FILES)
- `Utils/PermissionHelper.cs` - Permission checking (needs debug logging)
- `Views/Shared/_HeaderEscolher.cshtml` - Header view (buttons already defined)
- `Controllers/AccountController.cs` - Login and routes (verify `ObterRotasDefault()`)
- `Views/Obra/Escolher.cshtml` - Page content (needs `.conteudo` wrapper)
- `Program.cs` - Session configuration (verify middleware)

### Routes Already Exist
```csharp
// In ObterRotasDefault() - ALREADY DEFINED ✅
rota.Path = "/chart";
rota.Permissions.Add("visualizar");

rota.Path = "/obra/cadastro";
rota.Permissions.Add("visualizar");
```

### Current Header Implementation
```razor
@* In _HeaderEscolher.cshtml - ALREADY IMPLEMENTED ✅ *@
@if (PermissionHelper.HasPermission(Context, "visualizar", "/chart"))
{
    <li class="btn-tooltip pointer" title="DASHBOARD GERAL">
        <a href="@Url.Action("Index", "Chart")">
            <i class="fa fa-bar-chart"></i>
        </a>
    </li>
}

@if (PermissionHelper.HasPermission(Context, "visualizar", "/obra/cadastro"))
{
    <li class="btn-tooltip pointer" title="NOVA UNIDADE ESCOLAR">
        <a href="@Url.Action("Cadastro", "Obra")">
            <i class="fa fa-plus"></i>
        </a>
    </li>
}
```

**Everything is already implemented!** The issue is that `PermissionHelper.HasPermission()` is returning `false`.

---

## NEXT STEPS

Should I proceed with **Phase 1** now - adding debug logging to the existing `PermissionHelper.cs` file to identify why the buttons don't appear?

---

## ESTIMATED TIME

| Phase | Task | Time |
|-------|------|------|
| Phase 1 | Add debug logging | 5 min |
| Phase 1 | Test and analyze | 10 min |
| Phase 2 | Apply fix | 10-30 min |
| Phase 2 | Test fix | 5 min |
| Phase 3 | Remove debug logging | 5 min |
| Phase 4 | Fix overlap | 5 min |
| **TOTAL** | | **40-60 min** |

---

**Status**: SPEC COMPLETE - READY FOR PHASE 1 (DEBUG LOGGING)
