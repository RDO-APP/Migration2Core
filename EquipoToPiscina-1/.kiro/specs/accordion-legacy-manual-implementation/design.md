# Design Document: Accordion Legacy Manual Implementation

## Introduction

This document describes the design for replacing Bootstrap 5 accordion with Gilberto's legacy manual JavaScript accordion implementation to restore proper expand/collapse functionality.

## Architecture Overview

### Current State (BROKEN)
```
┌─────────────────────────────────────────┐
│ Bootstrap 5 Accordion                   │
│ - data-bs-toggle="collapse"             │
│ - Bootstrap Collapse API                │
│ - accordion-button classes              │
│ - CONFLICT with legacy patterns         │
└─────────────────────────────────────────┘
```

### Target State (WORKING)
```
┌─────────────────────────────────────────┐
│ Legacy Manual Accordion                 │
│ - onclick="toggleEtapa(id)"             │
│ - Pure JavaScript toggle                │
│ - panel-heading/panel-collapse classes  │
│ - NO Bootstrap dependencies             │
└─────────────────────────────────────────┘
```

## Component Design

### 1. Accordion Structure

**File**: `Views/Etapa/_EtapaAccordionPartial.cshtml`

**Legacy Pattern** (from Gilberto's cards.html):
```html
<div class="panel-group accordion" id="accordion">
    <div class="panel panel-default">
        <div class="panel-heading" ng-click="controller.loadCards(etapa.titulo)">
            <h4 data-toggle="collapse" data-target="#collapse{{etapa.id}}" class="panel-title expand">
                <a href="#">{{ etapa.titulo }}</a>
            </h4>
        </div>
        <div id="collapse{{etapa.id}}" class="panel-collapse collapse">
            <div class="panel-body">
                <!-- Task cards here -->
            </div>
        </div>
    </div>
</div>
```

**New Implementation** (Pure .NET 8 with legacy pattern):
```html
<div class="panel panel-default">
    <div class="panel-heading" onclick="toggleEtapa(@Model.Id)">
        <h4 class="panel-title expand">
            <div class="card kiro-compact-card">
                <div class="head kiro-card-header">
                    <i class="fa fa-hand-paper-o"></i>
                    <span>@Model.SafeDescricao</span>
                    <span class="badge bg-primary">@Model.BadgeText</span>
                </div>
            </div>
        </h4>
    </div>
    <div id="collapse-etapa-@Model.Id" class="panel-collapse collapse" style="display: none;">
        <div class="panel-body">
            <!-- Task cards rendered by Blazor -->
        </div>
    </div>
</div>
```

### 2. JavaScript Toggle Function

**File**: `Views/Etapa/Cards.cshtml` (in @section Scripts)

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
        var headingElement = document.querySelector('[onclick="toggleEtapa(' + etapaId + ')"]');
        if (headingElement) {
            headingElement.setAttribute('aria-expanded', !isVisible);
        }
        
    } catch (error) {
        console.error('❌ Toggle error:', error);
    }
}
```

### 3. CSS Styling

**File**: `wwwroot/css/task-cards-compact.css` (or inline in Cards.cshtml)

**Legacy-Compatible Styles**:
```css
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
    background-color: transparent;
    border: none;
    padding: 0;
    cursor: pointer;
}

.panel-heading:hover {
    opacity: 0.9;
}

.panel-title {
    margin: 0;
    font-size: 16px;
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
    display: block;
}

.panel-body {
    padding: 15px;
    background-color: #f9f9f9;
}

/* Card inside heading - preserve existing styles */
.panel-heading .card.kiro-compact-card {
    margin: 0;
    cursor: pointer;
}
```

## Data Flow

### Accordion Expansion Flow

```
User Click
    ↓
onclick="toggleEtapa(id)"
    ↓
JavaScript Function
    ↓
Find Element by ID
    ↓
Check Current State
    ↓
Toggle display: none ↔ block
    ↓
Update aria-expanded
    ↓
Console Log Result
```

### Task Card Rendering Flow

```
Etapa Expanded
    ↓
panel-body visible
    ↓
Blazor TaskCard Components
    ↓
Render in Grid Layout
    ↓
User Interactions Available
```

## Key Design Decisions

### Decision 1: Remove Bootstrap 5 Completely

**Rationale**: 
- Bootstrap 5 conflicts with Gilberto's legacy manual pattern
- Legacy uses `data-toggle="collapse"` (Bootstrap 3 syntax)
- Current uses `data-bs-toggle="collapse"` (Bootstrap 5 syntax)
- Manual JavaScript is simpler and more reliable

**Implementation**:
- Remove all `data-bs-*` attributes
- Remove Bootstrap Collapse API initialization
- Use pure JavaScript `onclick` handlers

### Decision 2: Preserve Card Visual DNA

**Rationale**:
- Users expect familiar interface
- Card structure already working
- Only accordion mechanism needs fixing

**Implementation**:
- Keep `kiro-compact-card` structure
- Keep cyan header color (#5bc0de)
- Keep badge display
- Only change: onclick handler instead of data-bs-toggle

### Decision 3: Use Inline Display Toggle

**Rationale**:
- Simplest possible implementation
- No CSS class conflicts
- Direct DOM manipulation
- Immediate visual feedback

**Implementation**:
```javascript
element.style.display = isVisible ? 'none' : 'block';
```

### Decision 4: Maintain Blazor TaskCard Components

**Rationale**:
- TaskCard components are working correctly
- No need to change what works
- Accordion only controls visibility, not rendering

**Implementation**:
- TaskCards remain as Blazor components
- Accordion only toggles parent container visibility
- No changes to TaskCard.razor

## Error Handling

### Scenario 1: Element Not Found

```javascript
if (!collapseElement) {
    console.error('❌ Collapse element not found:', 'collapse-etapa-' + etapaId);
    return; // Fail gracefully
}
```

### Scenario 2: JavaScript Error

```javascript
try {
    // Toggle logic
} catch (error) {
    console.error('❌ Toggle error:', error);
    // Don't break page, just log error
}
```

### Scenario 3: Multiple Clicks

**Behavior**: Each click toggles state
**No special handling needed**: Simple toggle logic handles this naturally

## Testing Strategy

### Test 1: Single Accordion Expansion
1. Click Etapa header
2. Verify collapse element display changes to 'block'
3. Verify console log shows "Etapa expanded"
4. Verify task cards are visible

### Test 2: Single Accordion Collapse
1. Click expanded Etapa header
2. Verify collapse element display changes to 'none'
3. Verify console log shows "Etapa collapsed"
4. Verify task cards are hidden

### Test 3: Multiple Accordions
1. Expand Etapa 1
2. Expand Etapa 2
3. Verify both are expanded simultaneously
4. Collapse Etapa 1
5. Verify Etapa 2 remains expanded

### Test 4: TaskCard Interactions
1. Expand Etapa
2. Click TaskCard button (e.g., "Nova Medição")
3. Verify modal opens correctly
4. Verify accordion remains expanded

### Test 5: Page Reload
1. Expand Etapa
2. Reload page
3. Verify all accordions start collapsed (default state)

## Migration Path

### Phase 1: Remove Bootstrap 5 (File: _EtapaAccordionPartial.cshtml)
- Remove `data-bs-toggle="collapse"`
- Remove `data-bs-target` attributes
- Remove `accordion-button` class
- Remove `accordion-collapse` class
- Add `onclick="toggleEtapa(@Model.Id)"`
- Change classes to `panel-heading`, `panel-collapse`

### Phase 2: Add JavaScript Function (File: Cards.cshtml)
- Add `toggleEtapa(etapaId)` function in @section Scripts
- Add console logging for debugging
- Add error handling

### Phase 3: Remove Bootstrap Initialization (File: _Layout.cshtml)
- Remove Bootstrap Collapse API initialization code
- Remove `bootstrap-compatibility.js` reference
- Keep only essential Bootstrap CSS (if needed for other components)

### Phase 4: Add Legacy CSS (File: task-cards-compact.css or inline)
- Add `.panel-group`, `.panel-heading`, `.panel-collapse` styles
- Ensure compatibility with existing card styles
- Test visual appearance

### Phase 5: Testing
- Test all accordion interactions
- Verify TaskCard components still work
- Check console for errors
- Validate accessibility (aria-expanded)

## Rollback Plan

If implementation fails:

1. **Revert Files**:
   - `_EtapaAccordionPartial.cshtml` → restore Bootstrap 5 attributes
   - `Cards.cshtml` → remove toggleEtapa function
   - `_Layout.cshtml` → restore Bootstrap initialization

2. **Verify Rollback**:
   - Check page loads without errors
   - Verify accordions are in previous state (even if not working)

3. **Investigate**:
   - Review console errors
   - Check element IDs match
   - Verify JavaScript syntax

## Success Criteria

✅ **Functional Requirements**:
1. Clicking Etapa header expands/collapses accordion
2. Multiple accordions can be expanded simultaneously
3. TaskCard components render correctly inside expanded accordions
4. No console errors during accordion operations

✅ **Visual Requirements**:
1. Accordion headers look identical to before
2. Card structure preserved (cyan header, badge, icon)
3. Smooth expand/collapse animation (optional)
4. No visual glitches or layout shifts

✅ **Technical Requirements**:
1. No Bootstrap 5 dependencies for accordion
2. Pure JavaScript implementation
3. Clean console logs for debugging
4. Proper error handling

## Conclusion

This design provides a simple, reliable accordion implementation using Gilberto's proven legacy pattern. By removing Bootstrap 5 conflicts and using pure JavaScript, we ensure the accordion works correctly while maintaining the familiar visual appearance.

**Next Step**: Implement changes in tasks.md

---

**STATUS**: ✅ DESIGN COMPLETE - Ready for implementation
