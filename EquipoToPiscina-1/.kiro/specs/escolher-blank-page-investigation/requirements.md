# Escolher Blank Page Investigation - Requirements

**Created:** January 20, 2026  
**Status:** Investigation Phase  
**Priority:** CRITICAL  
**Type:** Bug Investigation & Root Cause Analysis

---

## Problem Statement

After restoring the December 2025 backup of `Escolher.cshtml`, the page at `https://localhost:7201/Obra/Escolher` renders as completely blank with no content visible.

### Timeline

1. **This Morning** - Escolher.cshtml was working (simplified version, ~100 lines)
2. **User Requested** - "Return to December 2025 working state" (with blue header, filters)
3. **Restoration Performed** - Backup from January 18, 2026 (~600 lines) was restored
4. **Result** - Blank page appeared at the URL
5. **Current State** - Investigating why the restored version doesn't render

### Key Context

- This is NOT a pre-existing issue
- The blank page is a NEW issue caused by the restoration
- The backup file was previously working in December 2025
- The simplified version (current) was working this morning
- User wants the December 2025 features (blue header, filters, JavaScript)

---

## User Requirements

### Functional Requirements

**FR1: Page Must Render**
- The Escolher page must display visible content
- No blank/white screen
- All HTML elements must be rendered

**FR2: Blue Header**
- Top navigation bar with blue gradient background
- Logo section with "rdo Piscinas" branding
- Navigation icons (Reports, Add)
- User info section with avatar and name

**FR3: Filter Functionality**
- Two input fields: "Unidade Escolar" and "Município"
- Real-time filtering as user types
- Filter results displayed immediately
- "No results" message when filters match nothing

**FR4: Obra Cards Display**
- Grid layout of obra cards
- Each card shows:
  - Dynamic icon (contratante/contratada)
  - Obra description
  - City/State
  - Status (Básica/Gratuita)
  - Progress bar with percentage
- Responsive layout (2-10 cards per row based on screen size)

**FR5: Navigation**
- Clicking a card navigates to Etapa/Cards page
- ObraId passed as parameter
- Session storage of selected obra

**FR6: Legend**
- Progress bar legend at bottom
- Three status indicators:
  - Green: Prazo atingido
  - Red: Prazo ultrapassado
  - Gray: Em andamento

### Non-Functional Requirements

**NFR1: No Layout Inheritance**
- `Layout = null` must be preserved
- Standalone page (no shared layout)
- Self-contained HTML structure

**NFR2: Performance**
- Page must load within 2 seconds
- No blocking JavaScript
- Efficient CSS rendering

**NFR3: Browser Compatibility**
- Must work in Chrome, Edge, Firefox
- No console errors
- All assets must load (CSS, JS, fonts)

**NFR4: Maintainability**
- Code must be readable
- Comments for complex logic
- Clear separation of concerns

---

## Investigation Scope

### In Scope

1. **Root Cause Analysis**
   - Why does the restored version show blank page?
   - What changed between working and non-working versions?
   - Are there compilation errors?
   - Are there runtime errors?

2. **Model Type Investigation**
   - Backup uses `IEnumerable<dynamic>`
   - Controller returns `IEnumerable<ObraViewModel>`
   - Does type mismatch cause silent failure?

3. **Dependency Analysis**
   - Are all CSS files loading?
   - Are all JavaScript files loading?
   - Are all font files loading?
   - Are there 404 errors?

4. **View Engine Analysis**
   - Is Razor compiling the view?
   - Are there syntax errors?
   - Are there runtime exceptions?
   - Is the view being found?

5. **Browser Diagnostic**
   - Console errors
   - Network failures
   - Page source content
   - Rendering issues

### Out of Scope

1. **New Features** - No new functionality to be added
2. **Architectural Changes** - No refactoring or modernization
3. **Performance Optimization** - Focus is on making it work, not making it fast
4. **Code Quality** - Focus is on functionality, not code elegance

---

## Success Criteria

### Must Have

1. **Page Renders** - Escolher page displays visible content (not blank)
2. **Blue Header Visible** - Top navigation bar appears correctly
3. **Filters Work** - Can type in filter inputs and see results update
4. **Cards Display** - All obra cards render in grid layout
5. **Navigation Works** - Clicking card navigates to Etapa/Cards
6. **No Console Errors** - Browser console shows no JavaScript errors
7. **No 404 Errors** - All assets load successfully (CSS, JS, fonts)

### Should Have

1. **Icon Transformation** - Dynamic icons (t→contratante, d→contratada) work
2. **Hover Effects** - Cards respond to mouse hover
3. **Progress Bars** - Show correct colors and percentages
4. **Legend** - Displays at bottom of page

### Could Have

1. **Responsive Layout** - Adapts to different screen sizes
2. **Filter Tabs** - Tab switching functionality
3. **User Avatar** - Displays user initial or icon

---

## Investigation Questions

### Critical Questions (Must Answer)

1. **Does the page render ANY HTML?**
   - View page source - is there content?
   - Or is it completely empty?

2. **Are there console errors?**
   - JavaScript errors?
   - Razor compilation errors?
   - Runtime exceptions?

3. **Are there network failures?**
   - 404 for CSS files?
   - 404 for JavaScript files?
   - 404 for font files?

4. **Is the controller action executing?**
   - Is `Escolher()` action being called?
   - Is Model being populated?
   - Is View being returned?

5. **Is the model type causing issues?**
   - Does `IEnumerable<dynamic>` work with `ObraViewModel`?
   - Are properties accessible?
   - Are there null reference exceptions?

### Important Questions (Should Answer)

6. **What's in the page source?**
   - Full HTML structure?
   - Partial HTML?
   - Error message?

7. **What's the HTTP response status?**
   - 200 OK?
   - 500 Internal Server Error?
   - 404 Not Found?

8. **Are ViewBag values set?**
   - Is `ViewBag.UsuarioNome` populated?
   - Are other ViewBag properties set?

### Nice to Know Questions (Could Answer)

9. **What's the exact difference between working and non-working?**
   - Line-by-line comparison
   - What was added/removed?

10. **Can we isolate the problem?**
    - Does a minimal version work?
    - Can we add features incrementally?

---

## Investigation Approach

### Phase 1: Diagnostic (No Changes)

**Objective:** Gather information about the blank page issue

**Tasks:**
1. Check browser console for errors
2. Check network tab for failed requests
3. View page source to see if HTML is present
4. Check server logs for exceptions
5. Verify controller action is executing
6. Verify Model is populated

**Deliverable:** Diagnostic report with findings

### Phase 2: Root Cause Analysis

**Objective:** Identify the exact cause of the blank page

**Tasks:**
1. Analyze diagnostic findings
2. Identify most likely cause
3. Verify hypothesis with targeted tests
4. Document root cause

**Deliverable:** Root cause analysis document

### Phase 3: Fix Strategy

**Objective:** Determine the best approach to fix the issue

**Tasks:**
1. Evaluate fix options
2. Assess risks and benefits
3. Choose optimal fix strategy
4. Document implementation plan

**Deliverable:** Fix strategy document

### Phase 4: Implementation (With Permission)

**Objective:** Apply the fix and verify it works

**Tasks:**
1. Implement chosen fix
2. Test page rendering
3. Verify all features work
4. Document changes made

**Deliverable:** Working Escolher page

---

## Known Issues & Constraints

### Known Issues

1. **Model Type Mismatch**
   - Backup uses `IEnumerable<dynamic>`
   - Controller returns `IEnumerable<ObraViewModel>`
   - May cause silent failure when accessing properties

2. **External CSS Dependencies**
   - Current version uses external CSS files
   - Backup uses inline CSS
   - External files may not exist or may be cached

3. **JavaScript Dependencies**
   - Backup has 150 lines of inline JavaScript
   - Current version has none
   - May cause functionality issues

### Constraints

1. **No Changes Without Permission**
   - Investigation only at this stage
   - No fixes applied until user approves

2. **Preserve User Intent**
   - User wants December 2025 features
   - Must not lose blue header, filters, JavaScript

3. **No Architectural Changes**
   - Keep `Layout = null`
   - Keep standalone page structure
   - No Blazor components

---

## Risk Assessment

### High Risk

1. **Model Type Mismatch** - May cause complete rendering failure
2. **Missing Dependencies** - CSS/JS files may not exist
3. **Razor Compilation Errors** - Syntax errors may prevent compilation

### Medium Risk

1. **Browser Cache** - Old CSS/JS may be cached
2. **ViewBag Issues** - Missing ViewBag values may cause errors
3. **Session Issues** - Authentication/authorization problems

### Low Risk

1. **Icon Font Issues** - Icons may not display but page should render
2. **Progress Bar Issues** - May show incorrectly but page should render
3. **Hover Effects** - May not work but page should render

---

## Dependencies

### Technical Dependencies

1. **ASP.NET Core 8.0** - Framework version
2. **Razor View Engine** - View compilation
3. **Bootstrap 5** - CSS framework (if used)
4. **jQuery** - JavaScript library (if used)
5. **Font Awesome** - Icon library (if used)

### File Dependencies

1. **Escolher.cshtml** - Main view file
2. **ObraController.cs** - Controller with Escolher action
3. **ObraViewModel.cs** - Model class
4. **fontello.css** - Icon font CSS (if external)
5. **escolher-legacy.css** - Page-specific CSS (if external)

### Service Dependencies

1. **IObraService** - Service for fetching obras
2. **Authentication** - User must be logged in
3. **Session** - May be used for state management

---

## Acceptance Criteria

### Investigation Complete When:

1. ✅ Root cause identified with evidence
2. ✅ All diagnostic questions answered
3. ✅ Fix strategy documented
4. ✅ User approval obtained for fix approach

### Fix Complete When:

1. ✅ Page renders visible content (not blank)
2. ✅ Blue header displays correctly
3. ✅ Filters work and update results
4. ✅ Obra cards display in grid
5. ✅ Clicking card navigates correctly
6. ✅ No console errors
7. ✅ No 404 errors
8. ✅ All features from December 2025 work

---

## Next Steps

1. **Gather Diagnostic Information**
   - Browser console errors
   - Network tab failures
   - Page source content
   - Server logs

2. **Analyze Findings**
   - Identify root cause
   - Verify hypothesis

3. **Propose Fix Strategy**
   - Document approach
   - Get user approval

4. **Implement Fix**
   - Apply changes
   - Test thoroughly
   - Verify all features work

---

**Status:** Requirements Defined - Ready for Investigation  
**Next Action:** Gather diagnostic information from browser
