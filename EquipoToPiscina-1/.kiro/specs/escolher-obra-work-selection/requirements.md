# ESCOLHER OBRA - Work Selection Page Requirements

**Work Date**: January 17-18, 2026  
**Status**: ✅ IMPLEMENTED & TESTED  
**Context**: .NET 8 migration from AngularJS to Razor/Blazor Server

---

## OVERVIEW

The ESCOLHER OBRA page is the **gateway** between authentication and workspace. After login, users see a grid of available obras (construction projects) and select one to work on. This selection establishes the work context for all subsequent operations.

### Purpose
- Display all obras accessible to the authenticated user
- Allow user to select which obra to work on
- Establish obra context in session for downstream pages
- Provide visual feedback on obra progress and status

### User Flow
```
1. User logs in → /Account/Login
2. System redirects → /Obra/Escolher (this page)
3. User sees grid of obra cards
4. User clicks an obra card
5. System stores obraId in session
6. System redirects → /Etapa/Cards (task workspace)
```

---

## BUSINESS REQUIREMENTS

### BR-1: User Authorization
- **Rule:** Only authenticated users can access this page
- **Implementation:** `[Authorize]` attribute on controller
- **Failure:** Redirect to `/Account/Login`

### BR-2: User-Specific Obras
- **Rule:** Display only obras assigned to the authenticated user
- **Implementation:** Filter by `colaboradorId` from claims
- **Data Source:** `IObraService.ObterObrasAsync(colaboradorId)`

### BR-3: Obra Selection
- **Rule:** User must select exactly one obra to proceed
- **Implementation:** POST form with `obraId` hidden field
- **Storage:** Store `obraId` and `obraNome` in session
- **Redirect:** Navigate to `/Etapa/Cards?obraId={id}`

### BR-4: Visual Progress Indicators
- **Rule:** Each obra card shows progress percentage and status color
- **Colors:**
  - Green (`#57B257`): On schedule (progress >= expected)
  - Red (`#D04541`): Overdue (progress < expected)
  - Gray (`#999999`): In progress (no deadline set)

### BR-5: Obra Type Indicators
- **Rule:** Display icon indicating obra type
- **Types:**
  - `icon-contratante`: Cyan (`#00bcd4`) - Client-managed
  - `icon-contratada`: Orange (`#ff9800`) - Contractor-managed

---

## FUNCTIONAL REQUIREMENTS

### FR-1: Page Rendering
- **Must:** Display grid of obra cards
- **Must:** Show header with RDO branding
- **Must:** Show user profile in header
- **Must Not:** Show 6-button action toolbar (no obra context yet)
- **Must:** Handle empty state (no obras available)

### FR-2: Obra Card Content
Each card must display:
- **Icon:** Type indicator (contratante/contratada)
- **Title:** Obra description (h5, 24px)
- **Location:** City and state (p, 12px)
- **Status:** Basic/Gratuita classification (p, 12px)
- **Progress Bar:** Visual progress with percentage
- **Color:** Status-based background color

### FR-3: Filtering (Optional - Not Yet Implemented)
- **Future:** Filter by unidade (unit name)
- **Future:** Filter by município (city)
- **Current:** Display all obras without filtering

### FR-4: Responsive Layout
- **Desktop (1920x1080):** 5 cards per row
- **Laptop (1366x768):** 5 cards per row
- **Tablet (1024x768):** 3 cards per row
- **Mobile (768x1024):** 2 cards per row
- **Small Mobile (480x800):** 1 card per row

### FR-5: Interaction
- **Hover:** Card lifts up, shadow increases, border turns cyan
- **Hover:** Icon color changes to dark blue (`#28496F`)
- **Hover:** Text color changes to white
- **Click:** Submit form, store obraId, redirect to workspace

---

## NON-FUNCTIONAL REQUIREMENTS

### NFR-1: Performance
- **Load Time:** < 2 seconds for 100+ obras
- **Rendering:** No visible layout shift
- **Images:** Use icon fonts (no image loading delay)

### NFR-2: Visual Parity
- **Standard:** Match legacy production system exactly
- **Colors:** Use exact hex codes from production
- **Layout:** Use exact CSS patterns from production
- **Typography:** Match font sizes, weights, spacing

### NFR-3: Browser Compatibility
- **Chrome:** Latest version
- **Edge:** Latest version
- **Firefox:** Latest version
- **Safari:** Latest version (if applicable)

### NFR-4: Accessibility
- **Keyboard:** All cards accessible via Tab key
- **Screen Reader:** Proper ARIA labels (future enhancement)
- **Contrast:** Meet WCAG AA standards

---

## TECHNICAL REQUIREMENTS

### TR-1: Architecture Pattern
- **Pattern:** Server-side Razor view with POST forms
- **No:** Client-side JavaScript frameworks
- **No:** Blazor components on this page
- **Yes:** Pure HTML + CSS + Razor syntax

### TR-2: Layout Integration
- **Layout:** Use `~/Views/Shared/_Layout.cshtml`
- **Flag:** Set `ViewBag.IsObraSelection = true`
- **Effect:** Triggers simplified header (no action toolbar)
- **Cleanup:** Set `ViewBag.CurrentObra = null`

### TR-3: Data Flow
```
Controller → Service → Repository → Database
    ↓
ViewModel (ObraViewModel)
    ↓
View (Escolher.cshtml)
    ↓
Browser (HTML + CSS)
```

### TR-4: Session Management
```csharp
// On obra selection:
HttpContext.Session.SetInt32("ObraId", obraId);
HttpContext.Session.SetString("ObraNome", obra.Descricao);
```

### TR-5: Error Handling
- **Database Error:** Display empty state with message
- **No Obras:** Display "Você deve cadastrar uma unidade escolar..."
- **Invalid User:** Redirect to login
- **Selection Error:** Show TempData error, stay on page

---

## USER STORIES

### US-1: View Available Obras
**As a** logged-in user  
**I want to** see all obras I have access to  
**So that** I can choose which one to work on

**Acceptance Criteria:**
- [ ] Page displays after successful login
- [ ] Only my assigned obras are visible
- [ ] Each obra shows complete information
- [ ] Grid layout is responsive
- [ ] No blank page or errors

### US-2: Select an Obra
**As a** user viewing the obra list  
**I want to** click on an obra card  
**So that** I can start working on tasks for that obra

**Acceptance Criteria:**
- [ ] Clicking a card submits the selection
- [ ] System stores my selection in session
- [ ] System redirects me to task workspace
- [ ] Selected obra context persists across pages

### US-3: Understand Obra Status
**As a** user viewing obra cards  
**I want to** see visual progress indicators  
**So that** I can prioritize which obra needs attention

**Acceptance Criteria:**
- [ ] Progress bar shows percentage complete
- [ ] Green color indicates on schedule
- [ ] Red color indicates overdue
- [ ] Gray color indicates in progress
- [ ] Icons indicate obra type

### US-4: Navigate Efficiently
**As a** user in the system  
**I want to** quickly identify and select obras  
**So that** I can minimize time spent navigating

**Acceptance Criteria:**
- [ ] Cards are visually distinct
- [ ] Hover effects provide feedback
- [ ] Layout fits 5 cards per row (desktop)
- [ ] No scrolling needed for small lists

---

## CONSTRAINTS

### C-1: Legacy Compatibility
- **Must:** Match visual design of legacy system exactly
- **Must:** Use same color codes, fonts, spacing
- **Must:** Maintain same user experience
- **Reason:** User familiarity, training materials

### C-2: No Bootstrap
- **Must Not:** Use Bootstrap CSS classes
- **Must Not:** Use Bootstrap JavaScript
- **Reason:** Conflicts with legacy CSS, causes layout issues
- **Alternative:** Pure CSS with legacy patterns

### C-3: No Client-Side Frameworks
- **Must Not:** Use AngularJS (being migrated away from)
- **Must Not:** Use React, Vue, or other frameworks
- **Must:** Use server-side Razor rendering
- **Reason:** Simplicity, maintainability, performance

### C-4: Session-Based State
- **Must:** Use server-side session storage
- **Must Not:** Use client-side localStorage
- **Reason:** Security, server-side validation

---

## DEPENDENCIES

### D-1: Authentication System
- **Requires:** User must be logged in
- **Provides:** `ClaimTypes.NameIdentifier` with colaboradorId
- **Fallback:** Redirect to `/Account/Login`

### D-2: Obra Service
- **Interface:** `IObraService`
- **Method:** `ObterObrasAsync(int colaboradorId)`
- **Returns:** `List<ObraViewModel>`

### D-3: Layout System
- **File:** `~/Views/Shared/_Layout.cshtml`
- **Requires:** `ViewBag.IsObraSelection` flag
- **Provides:** Header with conditional toolbar

### D-4: Session Management
- **Requires:** Session middleware configured
- **Stores:** `ObraId` (int), `ObraNome` (string)
- **Lifetime:** Until logout or session timeout

### D-5: Static Assets
- **CSS:** `~/css/escolher-legacy.css`
- **Icons:** `~/css/fontello.css`
- **Fonts:** Fontello icon font files

---

## OUT OF SCOPE

### Not Included in This Spec
- [ ] Filtering functionality (future enhancement)
- [ ] Sorting functionality (future enhancement)
- [ ] Search functionality (future enhancement)
- [ ] Pagination (not needed for current data volume)
- [ ] Obra creation/editing (separate feature)
- [ ] Obra deletion (separate feature)
- [ ] Multi-obra selection (not a requirement)
- [ ] Obra favorites/bookmarks (future enhancement)

---

## SUCCESS CRITERIA

### Definition of Done
- [x] Page renders without blank screen
- [x] All 5 visual issues fixed (header, cards, icons, colors, styles)
- [x] Layout uses `_Layout.cshtml` with `IsObraSelection` flag
- [x] 5 cards per row on desktop screens
- [x] Icons display with correct colors
- [x] Progress bar colors show correctly
- [x] Visual parity with legacy system
- [x] Obra selection works (POST form)
- [x] Session storage works
- [x] Redirect to workspace works
- [x] Error handling works
- [x] Empty state works
- [x] Documentation complete
- [x] Test script created
- [x] Inline JavaScript syntax error fixed (January 18, 2026)

### Quality Gates
- [x] No console errors in browser
- [x] No 404 errors for assets
- [x] No compilation errors
- [x] No runtime exceptions
- [x] Passes visual inspection
- [x] Matches legacy screenshots
- [x] Works in all supported browsers
- [x] Responsive on all screen sizes

---

## RISKS & MITIGATIONS

### Risk 1: Empty View File
- **Risk:** View file becomes empty (0 bytes)
- **Impact:** Blank page, no errors, hard to diagnose
- **Mitigation:** File size checks in build process
- **Detection:** Verify file size > 5000 bytes
- **Status:** ✅ RESOLVED (January 17, 2026)

### Risk 5: Razor Syntax Ambiguity in JavaScript
- **Risk:** Inline JavaScript with ambiguous Razor syntax causes view crash
- **Impact:** Page renders blank, F12 Console empty, response size 0.1 kB
- **Example:** `<script>console.log("ID @obra.Id");</script>` crashes parser
- **Mitigation:** Use JavaScript concatenation or explicit `@()` syntax
- **Detection:** Check for Razor variables inside JavaScript strings
- **Status:** ✅ RESOLVED (January 18, 2026) - Changed to `"ID " + @obra.Id`

### Risk 2: Layout Conflicts
- **Risk:** Bootstrap CSS conflicts with legacy CSS
- **Impact:** Visual layout breaks, cards misaligned
- **Mitigation:** Use `Layout = null` OR pure legacy CSS
- **Current:** Using layout with legacy CSS (working)

### Risk 3: Session Loss
- **Risk:** Session expires or gets cleared
- **Impact:** User loses obra context, must reselect
- **Mitigation:** Session timeout warnings (future)
- **Current:** Standard ASP.NET session management

### Risk 4: Performance with Large Lists
- **Risk:** 1000+ obras cause slow rendering
- **Impact:** Page load time > 5 seconds
- **Mitigation:** Pagination or virtual scrolling (future)
- **Current:** Not an issue (max ~200 obras per user)

---

## TESTING REQUIREMENTS

### Test 1: Visual Verification
- [ ] Page renders (not blank)
- [ ] Header present with RDO logo
- [ ] 5 cards per row on desktop
- [ ] Icons display correctly
- [ ] Progress bar colors show
- [ ] Hover effects work
- [ ] Legend displays at bottom

### Test 2: Functional Testing
- [ ] Can click obra card
- [ ] Form submits correctly
- [ ] Session stores obraId
- [ ] Redirects to /Etapa/Cards
- [ ] No console errors
- [ ] No 404 errors

### Test 3: Browser Testing
- [ ] Works in Chrome
- [ ] Works in Edge
- [ ] Works in Firefox
- [ ] Works in incognito mode

### Test 4: Responsive Testing
- [ ] Desktop: 5 cards per row
- [ ] Laptop: 5 cards per row
- [ ] Tablet: 3 cards per row
- [ ] Mobile: 2 cards per row

### Test 5: Error Handling
- [ ] Empty state displays correctly
- [ ] Invalid user redirects to login
- [ ] Database error shows message
- [ ] Selection error shows TempData

---

## MAINTENANCE NOTES

### Code Locations
- **Controller:** `RDO-NET8-Migration/RdoApp.Core/Controllers/ObraController.cs`
- **View:** `RDO-NET8-Migration/RdoApp.Core/Views/Obra/Escolher.cshtml`
- **CSS:** `RDO-NET8-Migration/RdoApp.Core/wwwroot/css/escolher-legacy.css`
- **ViewModel:** `RDO-NET8-Migration/RdoApp.Core/Models/ViewModels/ObraViewModel.cs`
- **Service:** `RDO-NET8-Migration/RdoApp.Core/Services/Interfaces/IObraService.cs`

### Key Patterns
- **Layout Flag:** `ViewBag.IsObraSelection = true`
- **Cards Per Row:** `flex-basis: 100%; flex-shrink: 1;`
- **Icon Colors:** `.icon-contratante` (cyan), `.icon-contratada` (orange)
- **Progress Colors:** `.bg-verde`, `.bg-vermelho`, `.bg-cinza` with `!important`
- **Progress Flip:** `transform: scaleX(-1)` on container and text

### Common Issues
1. **Blank Page:** Check view file size (should be > 5KB)
2. **No Header:** Verify `Layout = "~/Views/Shared/_Layout.cshtml"`
3. **4 Cards Instead of 5:** Check `flex-basis: 100%` in CSS
4. **Icons Missing:** Verify fontello.css is loaded
5. **Colors Not Showing:** Check `!important` on progress bar classes
6. **View Crash (Blank Page):** Check for ambiguous Razor syntax in inline JavaScript
   - ❌ BAD: `<script>console.log("ID @obra.Id");</script>`
   - ✅ GOOD: `<script>console.log("ID " + @obra.Id);</script>`
   - ✅ GOOD: `<script>console.log("ID @(obra.Id)");</script>`

---

## REFERENCES

### Documentation Files
- `ESCOLHER-OBRA-CRISIS-RESOLVED.md` - Blank page fix (January 17, 2026)
- `ESCOLHER-OBRA-ALL-5-ISSUES-FIXED-COMPLETE.md` - Visual fixes (January 17, 2026)
- `ESCOLHER-OBRA-VISUAL-FIXES-COMPLETE.md` - Detailed visual fixes (January 17, 2026)
- `DEEP-VISUAL-FUNCTIONAL-AUDIT-ESCOLHER-OBRA-HEADER-DNA.md` - Header analysis
- `ESCOLHER-OBRA-INLINE-JAVASCRIPT-SYNTAX-FIX-COMPLETE.md` - JavaScript syntax fix (January 18, 2026)
- `ESCOLHER-OBRA-FILE-NAMING-COMPLETE.md` - File naming convention (January 18, 2026)
- `ESCOLHER-OBRA-FILE-NAMING-AUDIT-COMPLETE.md` - Naming audit (January 18, 2026)

### Legacy Reference Files
- `RDO-Production-Gilberto/rdoappProject/Client/Views/Obra/escolher.html`
- `EquipoToPiscina-Updated/rdoappProject/Assets/Styles/custom.css` (lines 820-950)

### Test Scripts
- `test-escolher-visual-fixes.ps1` - Visual verification
- `test-escolher-obra-fixes.ps1` - Functional testing

---

**Status:** ✅ REQUIREMENTS COMPLETE  
**Next:** Review design.md for implementation details
