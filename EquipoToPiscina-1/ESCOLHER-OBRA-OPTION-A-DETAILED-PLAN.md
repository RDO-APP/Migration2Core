# ESCOLHER OBRA - OPTION A DETAILED IMPLEMENTATION PLAN

**Date**: January 16, 2026  
**Status**: READY FOR USER REVIEW  
**Approach**: Legacy-First - Pure CSS, No Bootstrap, Separated Components

---

## EXECUTIVE SUMMARY

This plan implements Option A (Legacy-First Approach) with TWO SEPARATE SECTIONS:
1. **HEADER SECTION**: Remove custom header, use default layout (match legacy)
2. **OBRA CARDS SECTION**: Extract pure CSS from Gilberto, remove Bootstrap, simplify component

**Philosophy**: "Legacy rules as foundation while using modern .NET 8 implementation"

**Key Principles**:
- ❌ NO Bootstrap 3
- ❌ NO Bootstrap 5
- ✅ Pure CSS extracted from Gilberto's production
- ✅ Simple HTML structure (no complex layouts)
- ✅ Blazor for data binding, legacy for appearance

---

## SECTION 1: HEADER IMPLEMENTATION

### 1.1 CURRENT STATE ANALYSIS

**Current Implementation**:
```
┌─────────────────────────────────────┐
│  UNIFIED RDO HEADER (Blazor)       │  ← ADDED during migration
│  - Logo                             │
│  - User Name                        │
│  - Obra Name (shows null/empty)     │
│  - Logout Button                    │
├─────────────────────────────────────┤
│  Obra Cards Content                 │
└─────────────────────────────────────┘
```

**Files Involved**:
- `Views/Shared/_LayoutSelection.cshtml` - Contains UnifiedRdoHeader component
- `Components/UnifiedRdoHeader.razor` - Custom Blazor header
- `wwwroot/css/rdo-unified-theme.css` - Header styling

**Problems**:
1. Legacy has NO custom header on escolher page
2. Shows "Obra Name: null" (confusing - no obra selected yet)
3. Uses blue gradient instead of legacy cyan
4. Over-engineered for a simple selection page

---

### 1.2 LEGACY PATTERN (GILBERTO'S PRODUCTION)

**Legacy Structure**:
```html
<!-- escolher.html - NO CUSTOM HEADER -->
<section ng-controller="ObraController as controller">
    <!-- Filters -->
    <!-- Title -->
    <!-- Obra Cards -->
</section>
```

**Legacy Layout**:
```
┌─────────────────────────────────────┐
│  DEFAULT LAYOUT HEADER (from master)│  ← Comes from master layout
├─────────────────────────────────────┤
│  <section>                          │
│    Filters                          │
│    Title                            │
│    Obra Cards                       │
│  </section>                         │
└─────────────────────────────────────┘
```

**Key Finding**: ❌ **NO CUSTOM HEADER IN ESCOLHER PAGE**

---

### 1.3 HEADER IMPLEMENTATION PLAN

**Strategy**: Remove custom header component, use simple HTML structure

**Step 1: Modify Escolher.cshtml**

**File**: `Views/Obra/Escolher.cshtml`

**Change**: Remove layout dependency, create standalone page

**Step 2: Create Legacy CSS File**

**File**: `wwwroot/css/escolher-legacy.css` (NEW)

**Content**: Pure CSS extracted from Gilberto's production (no Bootstrap)

---

### 1.4 HEADER SECTION SUMMARY

**Changes Made**:
1. ✅ Removed `_LayoutSelection.cshtml` dependency
2. ✅ Removed UnifiedRdoHeader component
3. ✅ Created simple HTML structure (Layout = null)
4. ✅ Created `escolher-legacy.css` with pure CSS

**Result**: Exact match to legacy structure - no custom header

---

## SECTION 2: OBRA CARDS IMPLEMENTATION

### 2.1 CURRENT STATE ANALYSIS

**Current Component**: `Components/RdoObraCards.razor`

**Problems**:
1. Uses component CSS file (`RdoObraCards.razor.css`)
2. Complex CSS classes (`.rdo-obra-cards-container`, `.rdo-filters-section`)
3. Bootstrap 5 influences in styling
4. Over-engineered structure

**Files Involved**:
- `Components/RdoObraCards.razor` - Blazor component
- `Components/RdoObraCards.razor.css` - Component CSS (to be removed)
- `wwwroot/css/rdo-selection.css` - Additional styling (to be removed)

---

### 2.2 LEGACY PATTERN (GILBERTO'S PRODUCTION)

**Legacy HTML Structure**:
```html
<section ng-controller="ObraController">
    <!-- Filters -->
    <div class="container text-center">
        <input placeholder="Unidade escolar" ng-model="controller.filtroUnidade"/>
        <input placeholder="Município" ng-model="controller.filtroMunicipio"/>
    </div>
    
    <!-- Title -->
    <h2>Selecione uma das unidades escolares abaixo:</h2>
    
    <!-- Obra Cards -->
    <div class="lista-obras">
        <div class="item" ng-repeat="obra in controller.obras">
            <button class="btn change-background">
                <i class="icon-{{obra.contratanteContratada}}"></i>
                <h5>{{obra.descricao}}</h5>
                <p>{{obra.cidadeEstado}}</p>
                <p>({{obra.statusBasicaGratuita}})</p>
                <small>STATUS</small>
                <div class="progress {{obra.classeStatusCss}}">
                    <div class="progress-bar" style="width: {{100 - obra.progressoPorcentagem}}%;">
                        <span class="branco">{{obra.progressoPorcentagem}}%</span>
                    </div>
                    <span class="azul">{{obra.progressoPorcentagem}}%</span>
                </div>
            </button>
        </div>
    </div>
    
    <!-- Legend -->
    <div class="area-legenda">
        <!-- Legend items -->
    </div>
</section>
```

**Key Patterns**:
- Simple class names (`.lista-obras`, `.item`, `.progress`)
- Direct HTML structure (no complex wrappers)
- AngularJS data binding (`ng-repeat`, `ng-model`)
- Inline styles for dynamic values

---

### 2.3 OBRA CARDS IMPLEMENTATION PLAN

**Strategy**: Simplify component, use legacy HTML structure, remove component CSS

**Step 1: Simplify RdoObraCards.razor**

**File**: `Components/RdoObraCards.razor`

**Changes**:
- Remove complex wrapper divs
- Use legacy class names
- Keep Blazor data binding
- Remove component CSS file reference

**Step 2: Remove Component CSS Files**

**Files to Delete**:
- `Components/RdoObraCards.razor.css`
- `wwwroot/css/rdo-selection.css`

**Rationale**: All styling will be in `escolher-legacy.css`

---

### 2.4 OBRA CARDS SECTION SUMMARY

**Changes Made**:
1. ✅ Simplified component structure
2. ✅ Used legacy class names
3. ✅ Removed component CSS files
4. ✅ All styling in single `escolher-legacy.css` file

**Result**: Blazor for functionality, legacy for appearance

---

## SECTION 3: DETAILED IMPLEMENTATION TASKS

### TASK 1: Create Legacy CSS File

**File**: `wwwroot/css/escolher-legacy.css` (NEW)

**Action**: Create new CSS file with pure CSS extracted from Gilberto

**Estimated Time**: 30 minutes

---

### TASK 2: Modify Escolher.cshtml

**File**: `Views/Obra/Escolher.cshtml`

**Action**: Remove layout dependency, create standalone page

**Estimated Time**: 15 minutes

---

### TASK 3: Simplify RdoObraCards Component

**File**: `Components/RdoObraCards.razor`

**Action**: Use legacy HTML structure, remove complex wrappers

**Estimated Time**: 30 minutes

---

### TASK 4: Remove Component CSS Files

**Files**: 
- `Components/RdoObraCards.razor.css`
- `wwwroot/css/rdo-selection.css`

**Action**: Delete files (styling moved to escolher-legacy.css)

**Estimated Time**: 5 minutes

---

### TASK 5: Remove Debug Code

**Files**: All files with diagnostic overlays

**Action**: Remove green/blue debug indicators, console.error statements

**Estimated Time**: 15 minutes

---

### TASK 6: Testing & Validation

**Actions**:
1. Visual comparison with Gilberto's production
2. Functionality testing (filtering, selection)
3. Routing verification
4. Cross-browser testing

**Estimated Time**: 45 minutes

---

## SECTION 4: IMPLEMENTATION SUMMARY

### Total Estimated Time: 2.5 hours

### Files to Create:
1. `wwwroot/css/escolher-legacy.css` (NEW)

### Files to Modify:
1. `Views/Obra/Escolher.cshtml`
2. `Components/RdoObraCards.razor`

### Files to Delete:
1. `Components/RdoObraCards.razor.css`
2. `wwwroot/css/rdo-selection.css`

---

## SECTION 5: ACCEPTANCE CRITERIA

### Visual Matching:
- ✅ No custom header (like legacy)
- ✅ Simple HTML structure
- ✅ Legacy class names (`.lista-obras`, `.item`, `.progress`)
- ✅ Legacy color scheme (cyan, green, red, gray)
- ✅ 4 cards per row on desktop
- ✅ Responsive layout (3/2/1 cards on smaller screens)

### Functionality:
- ✅ Filtering by Unidade and Município works
- ✅ Obra selection navigates to Etapa/Cards page
- ✅ Progress bars display correctly
- ✅ Icon system works (contratante/contratada)
- ✅ Legend displays correctly

### Code Quality:
- ✅ No Bootstrap dependencies
- ✅ Pure CSS only
- ✅ Simple HTML structure
- ✅ No debug code
- ✅ No console errors

---

## SECTION 6: NEXT STEPS

**User Decision Required**:

1. **Approve this plan** - Proceed with implementation
2. **Request modifications** - Specify changes needed
3. **Choose different option** - Go back to Option B or C

**Questions for User**:
1. Do you approve this separated approach (HEADER + OBRA CARDS)?
2. Any specific visual elements that need adjustment?
3. Should we proceed with implementation?

---

**STATUS**: ✅ DETAILED PLAN COMPLETE - Awaiting User Approval

