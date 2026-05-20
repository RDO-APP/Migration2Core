# Implementation Tasks: Accordion Legacy Manual Implementation

## Overview
Replace Bootstrap 5 accordion with Gilberto's legacy manual JavaScript accordion implementation to restore proper expand/collapse functionality for Etapa cards.

**Status**: 📋 READY FOR IMPLEMENTATION  
**Priority**: HIGH - Blocking user functionality  
**Estimated Time**: 2-3 hours

---

## Task 1: Remove Bootstrap 5 Accordion Dependencies

**File**: `RDO-NET8-Migration/RdoApp.Core/Views/Etapa/_EtapaAccordionPartial.cshtml`

**Current State** (BROKEN):
```razor
<button class="accordion-button collapsed" 
        type="button" 
        data-bs-toggle="collapse" 
        data-bs-target="#collapse-etapa-@Model.Id">
```

**Target State** (WORKING):
```razor
<div class="panel-heading" onclick="toggleEtapa(@Model.Id)">
    <h4 class="panel-title expand">
```

**Changes Required**:
1. Remove `<button>` wrapper with `accordion-button` class
2. Remove `data-bs-toggle="collapse"` attribute
3. Remove `data-bs-target` attribute
4. Remove `aria-expanded` and `aria-controls` attributes
5. Add `onclick="toggleEtapa(@Model.Id)"` to panel-heading div
6. Change `accordion-collapse` class to `panel-collapse collapse`
7. Add `style="display: none;"` to collapse div (default hidden state)
8. Remove `data-bs-parent="#accordion"` attribute

**Acceptance Criteria**:
- ✅ No Bootstrap 5 data attributes remain
- ✅ onclick handler added to panel-heading
- ✅ Collapse div has proper ID format: `collapse-etapa-@Model.Id`
- ✅ Default state is collapsed (display: none)

---

## Task 2: Implement Manual JavaScript Toggle Function

**File**: `RDO-NET8-Migration/RdoApp.Core/Views/Etapa/Cards.cshtml`

**Location**: Add to existing `@section Scripts` block (after nuclear modal functions)

**Implementation**:
```javascript
// LEGACY MANUAL ACCORDION - Pure JavaScript (NO Bootstrap)
function toggleEtapa(etapaId) {
    console.log('🎯 TOGGLE ETAPA:', etapaId);
    
    try {
        // Find collapse element
        var collapseElement = document.getElementById('collapse-etapa-' + etapaId);
        if (!collapseElement) {
            console.error('❌ Collapse element not found:', 'collapse-etapa-' + etapaId);
            return;
        }
        
        // Get current display state
        var isVisible = collapseElement.style.display === 'block';
        
        // Toggle display
        if (isVisible) {
            collapseElement.style.display = 'none';
            collapseElement.classList.remove('in'); // Legacy class
            console.log('✅ Etapa collapsed:', etapaId);
        } else {
            collapseElement.style.display = 'block';
            collapseElement.classList.add('in'); // Legacy class
            console.log('✅ Etapa expanded:', etapaId);
        }
        
        // Update aria-expanded for accessibility
        var headingElement = document.querySelector('[onclick*="toggleEtapa(' + etapaId + ')"]');
        if (headingElement) {
            headingElement.setAttribute('aria-expanded', !isVisible);
        }
        
    } catch (error) {
        console.error('❌ Toggle error:', error);
    }
}
```

**Acceptance Criteria**:
- ✅ Function toggles display between 'none' and 'block'
- ✅ Console logging for debugging
- ✅ Error handling for missing elements
- ✅ Updates aria-expanded attribute
- ✅ Adds/removes 'in' class for legacy compatibility

---

## Task 3: Add Legacy CSS Classes

**File**: `RDO-NET8-Migration/RdoApp.Core/Views/Etapa/Cards.cshtml`

**Location**: Add to existing `@section Styles` block

**Implementation**:
```css
/* LEGACY ACCORDION STYLES - Manual JavaScript Pattern */

/* Panel Group - Legacy Structure */
.panel-group.accordion {
    margin-bottom: 20px;
}

.panel-default {
    border: 1px solid #ddd;
    border-radius: 4px;
    margin-bottom: 10px;
}

/* Panel Heading - Clickable Header */
.panel-heading {
    background-color: transparent !important;
    border: none !important;
    padding: 5px !important;
    cursor: pointer;
}

.panel-heading:hover {
    opacity: 0.9;
}

.panel-title {
    margin: 0 !important;
}

.panel-title .card {
    cursor: pointer !important;
}

.panel-title .card:hover {
    transform: translateY(-2px) !important;
    box-shadow: 0 4px 8px rgba(0,0,0,0.15) !important;
    transition: all 0.2s ease !important;
}

/* Panel Collapse - Expandable Content */
.panel-collapse {
    overflow: hidden;
    transition: height 0.3s ease;
}

.panel-collapse.collapse {
    display: none;
}

.panel-collapse.collapse.in {
    display: block !important;
}

.panel-body {
    padding: 15px;
    background-color: #f9f9f9;
}

/* Accordion Body */
.accordion-body {
    padding: 15px;
    background-color: #f9f9f9;
}
```

**Acceptance Criteria**:
- ✅ Panel heading has pointer cursor
- ✅ Collapse div hidden by default
- ✅ 'in' class shows content
- ✅ Smooth hover effects
- ✅ Compatible with existing card styles

---

## Task 4: Remove Bootstrap 5 Initialization Code

**File**: `RDO-NET8-Migration/RdoApp.Core/Views/Shared/_Layout.cshtml`

**Search For**:
- Bootstrap Collapse API initialization
- `bootstrap-compatibility.js` references
- Any code that initializes `data-bs-toggle="collapse"`

**Action**: Remove or comment out Bootstrap accordion initialization

**Note**: Be careful not to remove Bootstrap code used by other components (modals, dropdowns, etc.)

**Acceptance Criteria**:
- ✅ No Bootstrap Collapse initialization for accordion
- ✅ Other Bootstrap features still work (modals, etc.)
- ✅ No console errors about missing Bootstrap

---

## Task 5: Update Accordion Container Structure

**File**: `RDO-NET8-Migration/RdoApp.Core/Views/Etapa/Cards.cshtml`

**Current State**:
```razor
<div class="accordion" id="accordion">
```

**Target State**:
```razor
<div class="panel-group accordion" id="accordion">
```

**Changes Required**:
1. Add `panel-group` class to accordion container
2. Ensure ID remains "accordion" for compatibility

**Acceptance Criteria**:
- ✅ Container has both `panel-group` and `accordion` classes
- ✅ ID is "accordion"

---

## Task 6: Update Accordion Item Structure

**File**: `RDO-NET8-Migration/RdoApp.Core/Views/Etapa/_EtapaAccordionPartial.cshtml`

**Complete Rewrite**:

```razor
@model EtapaViewModel

<!-- LEGACY MANUAL ACCORDION PATTERN -->
<div class="panel panel-default">
    <!-- Clickable Header -->
    <div class="panel-heading" onclick="toggleEtapa(@Model.Id)">
        <h4 class="panel-title expand">
            <div class="card kiro-compact-card" style="margin: 0; display: block; width: 100%;">
                <div class="head kiro-card-header" style="display: flex; align-items: center; padding: 8px 12px; border-radius: 4px;">
                    <i class="fa fa-hand-paper-o" style="margin-right: 8px;"></i>
                    <span class="task-title">@Model.SafeDescricao</span>
                    <span class="badge bg-primary" style="margin-left: auto;">@Model.BadgeText</span>
                </div>
            </div>
        </h4>
    </div>
    
    <!-- Collapsible Content -->
    <div id="collapse-etapa-@Model.Id" class="panel-collapse collapse" style="display: none;">
        <div class="accordion-body">
            @if (Model.HasValidTarefas)
            {
                <div class="task-cards-grid-container" style="justify-content: start !important; padding-left: 20px !important;">
                    @foreach (var tarefa in Model.ValidTarefas)
                    {
                        @if (tarefa != null && tarefa.Id > 0)
                        {
                            <component type="typeof(RdoApp.Core.Components.TaskCard)" 
                                       render-mode="ServerPrerendered" 
                                       param-Task="tarefa" 
                                       param-CanEdit="@(ViewBag.CanEdit == true)" 
                                       param-IsWorkFinalized="@(ViewBag.IsWorkFinalized == true)" />
                        }
                    }
                </div>
                
                @if (ViewBag.CanCreateNew == true && ViewBag.IsWorkFinalized != true)
                {
                    <div class="add-task-button-container">
                        <button id="btn-adicionar-nova-tarefa-@Model.Id" class="btn btn-outline-primary" onclick="novaTarefa(@Model.Id)">
                            <i class="fa fa-clipboard" aria-hidden="true"></i>
                            <span>Adicionar nova tarefa</span>
                        </button>
                    </div>
                }
            }
            else
            {
                <div class="empty-state-container">
                    <i class="fa fa-info-circle fa-2x text-muted mb-2"></i>
                    <p class="text-muted">Nenhuma tarefa válida encontrada nesta etapa.</p>
                </div>
                
                @if (ViewBag.CanCreateNew == true && ViewBag.IsWorkFinalized != true)
                {
                    <div class="text-center mt-3">
                        <button id="btn-adicionar-nova-tarefa-@Model.Id" class="btn btn-outline-primary" onclick="novaTarefa(@Model.Id)">
                            <i class="fa fa-clipboard" aria-hidden="true"></i>
                            <span>Adicionar nova tarefa</span>
                        </button>
                    </div>
                }
            }
        </div>
    </div>
</div>
```

**Key Changes**:
1. Removed `<h2>` and `<button>` wrappers
2. Changed to `<div class="panel panel-default">` structure
3. Added `onclick="toggleEtapa(@Model.Id)"` to panel-heading
4. Changed collapse div classes to `panel-collapse collapse`
5. Added `style="display: none;"` to collapse div
6. Changed `accordion-body` class (kept for compatibility)
7. Preserved all TaskCard rendering logic

**Acceptance Criteria**:
- ✅ Structure matches Gilberto's legacy pattern
- ✅ onclick handler on panel-heading
- ✅ Collapse div has correct ID and classes
- ✅ TaskCard components still render correctly
- ✅ Add task button still works

---

## Task 7: Testing & Verification

**Test Script**: Create `test-accordion-legacy-manual.ps1`

```powershell
Write-Host "🧪 TESTING ACCORDION LEGACY MANUAL IMPLEMENTATION" -ForegroundColor Cyan
Write-Host ""

Write-Host "📋 TEST CHECKLIST:" -ForegroundColor Yellow
Write-Host ""

Write-Host "1. Visual Inspection:" -ForegroundColor White
Write-Host "   - Navigate to Etapa/Cards page"
Write-Host "   - Verify Etapa headers are visible"
Write-Host "   - Verify cyan header color (#5bc0de)"
Write-Host "   - Verify badge displays task count"
Write-Host ""

Write-Host "2. Click Functionality:" -ForegroundColor White
Write-Host "   - Click first Etapa header"
Write-Host "   - Verify content expands (display: block)"
Write-Host "   - Verify TaskCards are visible"
Write-Host "   - Click again to collapse"
Write-Host "   - Verify content hides (display: none)"
Write-Host ""

Write-Host "3. Console Logging:" -ForegroundColor White
Write-Host "   - Open F12 Console"
Write-Host "   - Click Etapa header"
Write-Host "   - Verify log: '🎯 TOGGLE ETAPA: [id]'"
Write-Host "   - Verify log: '✅ Etapa expanded: [id]' or '✅ Etapa collapsed: [id]'"
Write-Host "   - Verify NO Bootstrap errors"
Write-Host ""

Write-Host "4. Multiple Accordions:" -ForegroundColor White
Write-Host "   - Expand Etapa 1"
Write-Host "   - Expand Etapa 2"
Write-Host "   - Verify both are expanded simultaneously"
Write-Host "   - Collapse Etapa 1"
Write-Host "   - Verify Etapa 2 remains expanded"
Write-Host ""

Write-Host "5. TaskCard Interactions:" -ForegroundColor White
Write-Host "   - Expand Etapa"
Write-Host "   - Click 'Nova Medição' button on TaskCard"
Write-Host "   - Verify modal opens correctly"
Write-Host "   - Close modal"
Write-Host "   - Verify accordion remains expanded"
Write-Host ""

Write-Host "6. Error Handling:" -ForegroundColor White
Write-Host "   - Check F12 Console for errors"
Write-Host "   - Verify no 'element not found' errors"
Write-Host "   - Verify no Bootstrap Collapse errors"
Write-Host ""

Write-Host "✅ EXPECTED RESULTS:" -ForegroundColor Green
Write-Host "   - Accordions expand/collapse on click"
Write-Host "   - Multiple accordions can be open simultaneously"
Write-Host "   - TaskCards render correctly inside expanded accordions"
Write-Host "   - No console errors"
Write-Host "   - Clean console logs for debugging"
Write-Host ""

Write-Host "❌ IF TESTS FAIL:" -ForegroundColor Red
Write-Host "   1. Check element IDs match: 'collapse-etapa-[id]'"
Write-Host "   2. Verify onclick handler is present"
Write-Host "   3. Check JavaScript function is loaded"
Write-Host "   4. Verify CSS classes are applied"
Write-Host "   5. Check for JavaScript errors in console"
Write-Host ""

Write-Host "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
```

**Acceptance Criteria**:
- ✅ All 6 test categories pass
- ✅ No console errors
- ✅ Visual match to legacy system
- ✅ Smooth user experience

---

## Task 8: Remove Debug Indicators

**File**: `RDO-NET8-Migration/RdoApp.Core/Views/Etapa/Cards.cshtml`

**Remove**:
```html
<!-- ACCORDION DEBUG INDICATOR -->
<div style="position: fixed; top: 80px; right: 10px; background: blue; color: white; padding: 5px 10px; border-radius: 4px; z-index: 9999; font-size: 12px;">
    ACCORDION DEBUG: <span id="accordion-status">Loading...</span>
</div>
```

**Acceptance Criteria**:
- ✅ No debug indicators visible
- ✅ Clean production-ready code

---

## Implementation Order

1. **Task 6** - Update _EtapaAccordionPartial.cshtml (complete rewrite)
2. **Task 5** - Update accordion container in Cards.cshtml
3. **Task 2** - Add toggleEtapa() JavaScript function
4. **Task 3** - Add legacy CSS classes
5. **Task 4** - Remove Bootstrap 5 initialization (if present)
6. **Task 7** - Test all functionality
7. **Task 8** - Remove debug indicators

---

## Rollback Plan

If implementation fails:

1. **Revert Files**:
   ```bash
   git checkout HEAD -- Views/Etapa/_EtapaAccordionPartial.cshtml
   git checkout HEAD -- Views/Etapa/Cards.cshtml
   ```

2. **Verify Rollback**:
   - Page loads without errors
   - Accordions in previous state (even if not working)

3. **Investigate**:
   - Review console errors
   - Check element IDs match
   - Verify JavaScript syntax
   - Test in isolation

---

## Success Criteria

✅ **Functional Requirements**:
1. Clicking Etapa header expands/collapses accordion
2. Multiple accordions can be expanded simultaneously
3. TaskCard components render correctly inside expanded accordions
4. No console errors during accordion operations
5. Smooth expand/collapse animation

✅ **Visual Requirements**:
1. Accordion headers look identical to before
2. Card structure preserved (cyan header, badge, icon)
3. No visual glitches or layout shifts
4. Hover effects work correctly

✅ **Technical Requirements**:
1. No Bootstrap 5 dependencies for accordion
2. Pure JavaScript implementation
3. Clean console logs for debugging
4. Proper error handling
5. Legacy CSS classes applied

---

## Notes

- **DO NOT** change TaskCard component - it's working correctly
- **DO NOT** remove Bootstrap 5 entirely - other components use it
- **DO** preserve all existing functionality (filters, modals, buttons)
- **DO** test thoroughly before marking complete

---

**STATUS**: 📋 READY FOR IMPLEMENTATION  
**NEXT STEP**: Begin with Task 6 (complete rewrite of _EtapaAccordionPartial.cshtml)
