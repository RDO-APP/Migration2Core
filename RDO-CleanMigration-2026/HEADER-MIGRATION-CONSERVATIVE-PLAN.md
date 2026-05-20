# Header Migration - Conservative Plan
**Based on Lessons Learned from Failed Attempts**  
**Date**: February 3, 2026  
**Philosophy**: Incremental, Testable, Reversible  

---

## 🎯 CORE PRINCIPLE

**"Copy the structure, not the technology"**

We will recreate the EXACT visual and functional behavior of the legacy header using modern ASP.NET Core patterns, but we will NOT try to replicate AngularJS's dynamic behavior all at once.

---

## 📚 LESSONS LEARNED

### ❌ What Failed Before:
1. **Assumption-based development** - Added features that didn't exist in legacy
2. **Big bang approach** - Tried to implement everything at once
3. **Lack of verification** - Didn't verify each element against legacy code
4. **Technology mixing** - Tried to use AngularJS patterns in Razor

### ✅ What Will Work:
1. **Evidence-based development** - Only implement what we can see in legacy code
2. **Incremental approach** - One element at a time, test, verify, move on
3. **Visual verification** - Compare side-by-side with legacy at each step
4. **Technology separation** - Use Razor/C# patterns, not AngularJS patterns

---

## 🏗️ ARCHITECTURE DECISION

### Two Header Variants:

1. **`_HeaderSimple.cshtml`** - For pages WITHOUT obra context (Login, Escolher)
   - Logo only
   - User dropdown only
   - NO action buttons
   - NO obra name

2. **`_HeaderFull.cshtml`** - For pages WITH obra context (Task Cards, RDOs, etc.)
   - Logo
   - Obra name (center)
   - User dropdown
   - 6 action buttons (with visibility logic)
   - Mobile menu

**Why Two Headers?**
- Avoids complex conditional logic in a single file
- Easier to test and maintain
- Matches legacy behavior (different states)
- Prevents bugs from obra-dependent features on obra-less pages

---

## 📋 IMPLEMENTATION PHASES

### PHASE 1: Foundation (2-3 hours)
**Goal**: Get the basic structure working with NO dynamic features

#### Task 1.1: Create Base Header Partial
- File: `Views/Shared/_HeaderBase.cshtml`
- Content: Static HTML structure from legacy `nav.html`
- Elements:
  - `<div class="topo">`
  - `<nav class="navbar bg-blue-default">`
  - Logo (static, no click handler yet)
  - User dropdown (static username, no dynamic data)
  - Empty placeholder for buttons

**Acceptance Criteria**:
- Header renders without errors
- Logo displays correctly
- User dropdown shows placeholder text
- CSS classes match legacy exactly

**Test**: Load Escolher page, verify header appears

---

#### Task 1.2: Copy Legacy CSS
- File: `wwwroot/css/header.css`
- Source: Extract from legacy CSS files
- Copy EXACTLY:
  - `.topo` styles
  - `.navbar` styles
  - `.navbar-brand` styles
  - `.user` dropdown styles
  - `.ball-hover` button styles

**Acceptance Criteria**:
- Header looks visually identical to legacy
- Colors match exactly
- Spacing matches exactly
- Font sizes match exactly

**Test**: Side-by-side screenshot comparison

---

### PHASE 2: Simple Header (2-3 hours)
**Goal**: Complete the header for pages WITHOUT obra (Escolher, Login)

#### Task 2.1: Implement Logo Click
- Add `href` to logo: `@Url.Action("Escolher", "Obra")`
- Test: Click logo, should navigate to Escolher page

**Acceptance Criteria**:
- Logo is clickable
- Navigates to correct page
- No JavaScript errors

---

#### Task 2.2: Implement User Dropdown with Real Data
- Replace placeholder with `@User.Identity.Name`
- Add "TROCAR SENHA" link: `@Url.Action("ChangePassword", "Account")`
- Add "SAIR" form: POST to `@Url.Action("Logout", "Account")`

**Acceptance Criteria**:
- Shows logged-in user's name
- Dropdown opens/closes correctly
- Change Password link works
- Logout button works

**Test**: Login, verify username displays, test both dropdown options

---

#### Task 2.3: Create _HeaderSimple.cshtml
- Copy `_HeaderBase.cshtml` to `_HeaderSimple.cshtml`
- Remove button placeholders
- Remove obra name placeholder
- Keep only: Logo + User Dropdown

**Acceptance Criteria**:
- File compiles without errors
- Renders correctly on Escolher page
- No console errors

---

#### Task 2.4: Update Layouts to Use _HeaderSimple
- Update `_LayoutEscolher.cshtml`: `@await Html.PartialAsync("_HeaderSimple")`
- Update `_LayoutLogin.cshtml` (if exists): Same

**Acceptance Criteria**:
- Escolher page shows simple header
- Login page shows simple header (if applicable)
- No obra-dependent features visible

**Test**: Navigate through Login → Escolher, verify header consistency

---

### PHASE 3: Full Header Structure (3-4 hours)
**Goal**: Add all 6 buttons and obra name, but with STATIC visibility (no RBAC yet)

#### Task 3.1: Add Obra Name Display (Center)
- File: `_HeaderFull.cshtml`
- Add: `<h2 id="tituloObra">@ViewData["ObraName"]</h2>`
- Position: Center of navbar
- Style: Match legacy exactly

**Acceptance Criteria**:
- Obra name displays in center
- Text is uppercase
- Font and size match legacy

**Test**: Set ViewData["ObraName"] = "TEST OBRA", verify display

---

#### Task 3.2: Add All 6 Button Placeholders
- Copy button HTML structure from legacy `nav.html`
- Add all 6 buttons with correct icons:
  1. Laudos (`fa fa-folder`)
  2. Dashboard Obra (`icon-dashboard`)
  3. RDOs (`icon-rdo-novo_2`)
  4. Tarefas (`fa fa-th`)
  5. Dashboard Geral (`fa fa-bar-chart`)
  6. Nova Obra (`fa fa-plus`)
- Use `#` for href (no functionality yet)
- Add tooltips with correct titles

**Acceptance Criteria**:
- All 6 buttons visible
- Icons display correctly
- Tooltips show on hover
- Buttons don't do anything yet (expected)

**Test**: Visual inspection, hover over each button

---

#### Task 3.3: Copy Button CSS
- Extract button styles from legacy
- Copy hover effects
- Copy tooltip styles
- Ensure spacing matches legacy

**Acceptance Criteria**:
- Buttons look identical to legacy
- Hover effects work
- Spacing between buttons correct

**Test**: Side-by-side comparison with legacy

---

### PHASE 4: Button Functionality (2-3 hours)
**Goal**: Make buttons navigate to correct pages

#### Task 4.1: Implement Button Click Handlers
- Button 1 (Laudos): `@Url.Action("Index", "Laudo")`
- Button 2 (Dashboard Obra): `@Url.Action("Index", "Dashboard")`
- Button 3 (RDOs): `@Url.Action("Index", "Rdo")`
- Button 4 (Tarefas): `@Url.Action("Cards", "Tarefa")`
- Button 5 (Dashboard Geral): `@Url.Action("Index", "Chart")`
- Button 6 (Nova Obra): `@Url.Action("Cadastro", "Obra")`

**Acceptance Criteria**:
- Each button navigates to correct page
- No JavaScript errors
- Navigation works consistently

**Test**: Click each button, verify navigation

---

### PHASE 5: Visibility Logic (3-4 hours)
**Goal**: Hide/show buttons based on obra selection and permissions

#### Task 5.1: Implement Obra-Dependent Visibility
- Create helper method in controller:
  ```csharp
  public bool HasObraSelected()
  {
      return HttpContext.Session.GetInt32("ObraId").HasValue;
  }
  ```
- Pass to ViewData: `ViewData["HasObra"] = HasObraSelected()`
- In header, wrap buttons 1, 3, 4 with:
  ```razor
  @if (ViewData["HasObra"] as bool? ?? false)
  {
      <!-- Button HTML -->
  }
  ```

**Acceptance Criteria**:
- Buttons 1, 3, 4 hidden on Escolher page
- Buttons 1, 3, 4 visible on Task Cards page
- Buttons 2, 5, 6 always visible (for now)

**Test**: 
- Navigate to Escolher → verify 3 buttons hidden
- Select obra → navigate to Tasks → verify 3 buttons visible

---

#### Task 5.2: Implement RBAC Visibility (Optional - Can be Phase 6)
- Add permission checks for buttons 2, 5, 6:
  ```razor
  @if (User.HasClaim("Permission", "acessarDashboard"))
  {
      <!-- Dashboard Obra button -->
  }
  
  @if (User.HasClaim("Permission", "visualizar"))
  {
      <!-- Dashboard Geral button -->
      <!-- Nova Obra button -->
  }
  ```

**Acceptance Criteria**:
- Buttons only show if user has permission
- No errors if permission doesn't exist

**Test**: Test with different user roles

---

### PHASE 6: Mobile Menu (4-5 hours)
**Goal**: Add hamburger menu for mobile devices

#### Task 6.1: Add Mobile Menu HTML Structure
- Copy mobile menu structure from legacy `nav.html`
- Add hamburger icon (checkbox + label pattern)
- Add sidebar container
- Add user section in sidebar
- Add menu items in sidebar

**Acceptance Criteria**:
- Mobile menu HTML renders
- No visual impact on desktop view

---

#### Task 6.2: Add Mobile Menu CSS
- Copy mobile menu styles from legacy
- Add responsive breakpoints
- Add slide-in animation
- Add overlay

**Acceptance Criteria**:
- Menu hidden by default
- Hamburger icon visible on mobile
- Sidebar slides in when opened

**Test**: Resize browser to mobile width, test menu

---

#### Task 6.3: Implement Mobile Menu Functionality
- Checkbox toggle for open/close
- Close menu when item clicked
- Close menu when overlay clicked

**Acceptance Criteria**:
- Menu opens when hamburger clicked
- Menu closes when item clicked
- Menu closes when clicking outside

**Test**: Full mobile navigation flow

---

## 🧪 TESTING STRATEGY

### After Each Phase:
1. **Visual Test**: Side-by-side screenshot with legacy
2. **Functional Test**: Click every interactive element
3. **Console Test**: Check for JavaScript errors
4. **Responsive Test**: Test on mobile width
5. **Cross-browser Test**: Test on Chrome, Firefox, Edge

### Regression Testing:
- After each phase, re-test ALL previous phases
- Ensure new changes didn't break existing functionality

---

## 🔄 ROLLBACK STRATEGY

### If Something Breaks:
1. **Immediate**: Comment out the new code
2. **Verify**: Confirm app works without new code
3. **Debug**: Fix issue in isolation
4. **Re-test**: Verify fix works
5. **Re-deploy**: Uncomment and test again

### Git Strategy:
- Commit after EACH task completion
- Use descriptive commit messages: "Phase 2 Task 1: Implement logo click"
- Tag after each phase: "header-phase-1-complete"
- Can rollback to any phase if needed

---

## 📊 PROGRESS TRACKING

### Phase Checklist:
- [x] Phase 1: Foundation (2-3 hours) ✅ **COMPLETE** - 1.5 hours actual
  - [x] Task 1.1: Create Base Header Partial ✅
  - [x] Task 1.2: Copy Legacy CSS ✅
  - [x] Task 1.3: Update Layout ✅
- [ ] Phase 2: Simple Header (2-3 hours)
  - [ ] Task 2.1: Implement Logo Click
  - [ ] Task 2.2: Implement User Dropdown
  - [ ] Task 2.3: Create _HeaderSimple.cshtml
  - [ ] Task 2.4: Update Layouts
- [ ] Phase 3: Full Header Structure (3-4 hours)
  - [ ] Task 3.1: Add Obra Name Display
  - [ ] Task 3.2: Add Button Placeholders
  - [ ] Task 3.3: Copy Button CSS
- [ ] Phase 4: Button Functionality (2-3 hours)
  - [ ] Task 4.1: Implement Click Handlers
- [ ] Phase 5: Visibility Logic (3-4 hours)
  - [ ] Task 5.1: Obra-Dependent Visibility
  - [ ] Task 5.2: RBAC Visibility (Optional)
- [ ] Phase 6: Mobile Menu (4-5 hours)
  - [ ] Task 6.1: Add HTML Structure
  - [ ] Task 6.2: Add CSS
  - [ ] Task 6.3: Implement Functionality

**Total Estimated Time**: 16-22 hours (2-3 days)

---

## 🎯 SUCCESS CRITERIA

### Phase 1-2 Success:
- Simple header works on Escolher page
- Logo and user dropdown functional
- No errors in console

### Phase 3-4 Success:
- Full header displays all elements
- All buttons navigate correctly
- Visual match with legacy

### Phase 5 Success:
- Buttons show/hide based on obra selection
- RBAC permissions work (if implemented)

### Phase 6 Success:
- Mobile menu works on small screens
- Desktop view unaffected
- Smooth animations

### Overall Success:
- Header looks identical to legacy
- All functionality works
- No regressions in existing features
- Code is maintainable and documented

---

## 🚨 RED FLAGS - STOP IF:

1. **More than 2 hours stuck on one task** → Ask for help or skip to next phase
2. **Breaking existing functionality** → Rollback immediately
3. **Adding features not in legacy** → Stop, verify against legacy code first
4. **Complex JavaScript required** → Reconsider approach, keep it simple
5. **More than 3 failed attempts** → Document issue, move to next task

---

## 📝 DOCUMENTATION REQUIREMENTS

### After Each Phase:
- Update this document with actual time taken
- Document any deviations from plan
- Add screenshots of completed work
- Note any issues encountered and solutions

### Final Documentation:
- Complete header specification document
- CSS documentation
- Known limitations
- Future improvement suggestions

---

## 🎓 KEY PRINCIPLES

1. **Evidence Over Assumption**: Only implement what you can verify in legacy code
2. **Incremental Over Big Bang**: Small steps, test frequently
3. **Visual Over Functional**: Get it looking right first, then make it work
4. **Simple Over Complex**: Use the simplest solution that works
5. **Reversible Over Permanent**: Always have a way to undo changes

---

**Document Status**: ✅ Ready for Implementation  
**Next Step**: Begin Phase 1, Task 1.1  
**Estimated Completion**: 2-3 days of focused work

