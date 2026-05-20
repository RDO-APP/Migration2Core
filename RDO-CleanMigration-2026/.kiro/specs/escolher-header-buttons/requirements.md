# Escolher Header Buttons - Requirements

**Feature**: Fix missing action buttons in Escolher Obra page header  
**Date**: February 5, 2026  
**Status**: Requirements Complete  
**Approach**: Debug-first, evidence-based implementation

---

## 1. PROBLEM STATEMENT

### Current State
- Escolher Obra page header shows:
  - ✅ Logo "Piscinas" (left) - WORKING
  - ✅ User dropdown with name "Ricardo Freire" (right) - WORKING
  - ✅ Logo and user name are horizontally aligned - WORKING
  - ❌ Action buttons (center-right) - NOT APPEARING (zero buttons visible)

### Expected State
- Header should show 2 action buttons between logo and user dropdown:
  1. **DASHBOARD GERAL** (bar chart icon) - Links to Charts page
  2. **NOVA UNIDADE ESCOLAR** (plus icon) - Links to New Obra page

### Root Cause Hypothesis
- Routes `/chart` and `/obra/cadastro` already exist in `ObterRotasDefault()`
- Both routes have `visualizar` permission
- Buttons use `PermissionHelper.HasPermission()` to check visibility
- **Hypothesis**: Session data not persisting or routes array empty

---

## 2. USER REQUIREMENTS

### 2.1 Button Requirements

#### Button 1: DASHBOARD GERAL (Charts)
**User Story**: As a logged-in user, I want to access the general dashboard (charts) from any page

**Acceptance Criteria**:
- Button displays bar chart icon (`fa fa-bar-chart`)
- Button has tooltip "DASHBOARD GERAL"
- Button links to Charts page (`/Chart/Index`)
- Button visible if user has `visualizar` permission on `/chart` route
- Button respects legacy permission logic (route-specific permissions)

**Legacy Reference**:
```html
<li class="btn-tooltip" title="DASHBOARD GERAL" 
    permission="visualizar" 
    permission-route="/chart">
    <a class="pointer btn-icon-topo" ng-click="controller.redirectCharts()">
        <i class="fa fa-bar-chart"></i>
    </a>
</li>
```

---

#### Button 2: NOVA UNIDADE ESCOLAR (New Obra)
**User Story**: As a logged-in user, I want to create a new obra (school unit) from any page

**Acceptance Criteria**:
- Button displays plus icon (`fa fa-plus`)
- Button has tooltip "NOVA UNIDADE ESCOLAR"
- Button links to New Obra page (`/Obra/Cadastro`)
- Button visible if user has `visualizar` permission on `/obra/cadastro` route
- Button respects legacy permission logic (route-specific permissions)

**Legacy Reference**:
```html
<li class="btn-tooltip" title="NOVA UNIDADE ESCOLAR" 
    permission="visualizar" 
    permission-route="/obra/cadastro">
    <a class="pointer btn-icon-topo" ng-click="controller.novaObra()">
        <i class="fa fa-plus"></i>
    </a>
</li>
```

---

### 2.2 Permission System Requirements

**User Story**: As a system, I need to check permissions using session data like the legacy system

**Acceptance Criteria**:
- Permission checking uses `PermissionHelper.HasPermission(Context, permission, route)`
- Permission helper reads session data (`LoginData` key)
- Session data contains `Routes` array with route paths and permissions
- Permission check logic matches legacy `Permission.check()` exactly:
  1. Find route by path in Routes array
  2. Check if route has the requested permission
  3. Return true only if both route exists AND has permission

**Legacy Reference** (app.js):
```javascript
Permission.check = function (permission, route) {
    var data = Auth.getUser();
    for (var i in data.routes) {
        if (data.routes[i].path == route) {
            for (var j in data.routes[i].permissions) {
                if (data.routes[i].permissions[j] == permission) {
                    return true;
                }
            }
        }
    }
    return false;
}
```

---

### 2.3 Session Data Requirements

**User Story**: As a system, I need to persist login data in session across requests

**Acceptance Criteria**:
- Login stores `LoginViewModel` in session with key "LoginData"
- `LoginViewModel` contains:
  - `Routes`: Array of routes with paths and permissions
  - `Menu`: Menu structure
  - `Usuario`: User information
- Session data persists between login and Escolher page
- Session data is valid JSON and deserializable
- Routes array contains at least:
  - `/chart` with `visualizar` permission
  - `/obra/cadastro` with `visualizar` permission

**Current Implementation** (AccountController.cs):
```csharp
var loginViewModel = new LoginViewModel
{
    Routes = ObterRotasDefault(colaborador),
    Menu = ObterMenuDefault(colaborador),
    Usuario = new UsuarioViewModel { ... }
};

HttpContext.Session.SetString("LoginData", 
    System.Text.Json.JsonSerializer.Serialize(loginViewModel));
```

---

### 2.4 Debug Requirements

**User Story**: As a developer, I need to debug why buttons don't appear before making code changes

**Acceptance Criteria**:
- Add temporary debug logging to `PermissionHelper.HasPermission()`
- Debug logging shows:
  - Whether session data exists (null/empty check)
  - Routes array count
  - All routes in session with their permissions
  - Whether requested route exists in array
  - Whether requested permission exists in route
  - Final result (true/false)
- Debug logging uses `Console.WriteLine()` for visibility
- Debug logging is comprehensive enough to identify root cause
- Debug logging is temporary and will be removed after fix

---

### 2.5 Header Overlap Fix Requirements

**User Story**: As a user, I want the page content to start below the header (not overlapped)

**Acceptance Criteria**:
- Content starts 103px below header (matches legacy)
- First row of obra cards is fully visible
- No overlap between header and content
- Uses CSS rule `.topo + .conteudo { padding-top: 103px; }`
- Requires wrapping content in `<div class="conteudo">` element

**Current Issue**:
- `Escolher.cshtml` missing `.conteudo` wrapper
- Content starts at top of page, overlapped by fixed header

---

## 3. TECHNICAL CONSTRAINTS

### 3.1 Technology Stack
- **Backend**: ASP.NET Core 8.0
- **Frontend**: Razor Views + Bootstrap 5
- **Session**: ASP.NET Core Session middleware
- **Authentication**: Cookie-based authentication

### 3.2 Legacy Compatibility
- Must respect ALL legacy permission logic
- Must use existing routes (no new routes without user approval)
- Must match legacy button behavior exactly
- Must avoid AngularJS-specific code (use modern equivalents)

### 3.3 Code Quality
- No code changes until debug results analyzed
- Evidence-based fixes only (based on debug output)
- Minimal changes (surgical fixes, not rewrites)
- Remove debug logging after fix confirmed

---

## 4. OUT OF SCOPE

### Not Included in This Feature
- Other 4 legacy buttons (Laudos, Dashboard, RDOs, Tarefas)
  - These buttons depend on obra selection
  - Escolher page = no obra selected yet
  - Will be implemented later for post-selection pages
- Mobile menu implementation
- Button hover effects (already working via CSS)
- Button click functionality (already working via links)

---

## 5. SUCCESS CRITERIA

### Definition of Done
- [ ] Debug logging added to `PermissionHelper.HasPermission()`
- [ ] Application runs and debug output captured
- [ ] Root cause identified from debug output
- [ ] Fix applied based on debug results
- [ ] Both buttons visible on Escolher page
- [ ] Buttons have correct icons and tooltips
- [ ] Buttons link to correct pages
- [ ] Permission checking works correctly
- [ ] Debug logging removed
- [ ] Header overlap fixed (content below header)
- [ ] User confirms buttons working

### Acceptance Testing
1. **Login Test**:
   - Login with Ricardo's credentials
   - Navigate to Escolher page
   - Verify 2 buttons visible

2. **Button Visibility Test**:
   - Verify DASHBOARD GERAL button visible (bar chart icon)
   - Verify NOVA UNIDADE ESCOLAR button visible (plus icon)
   - Verify tooltips appear on hover

3. **Button Functionality Test**:
   - Click DASHBOARD GERAL → redirects to Charts page
   - Click NOVA UNIDADE ESCOLAR → redirects to New Obra page

4. **Permission Test**:
   - Verify buttons only visible if user has permissions
   - Verify permission checking uses session data
   - Verify permission logic matches legacy

5. **Layout Test**:
   - Verify content starts below header (no overlap)
   - Verify first row of cards fully visible

---

## 6. IMPLEMENTATION PHASES

### Phase 1: Debug Session Data (15 minutes)
**Goal**: Identify root cause of missing buttons

**Tasks**:
1. Add debug logging to `PermissionHelper.HasPermission()`
2. Rebuild project
3. Run application
4. Login and navigate to Escolher
5. Capture console output
6. Analyze debug results

**Expected Outcomes**:
- Scenario A: Session data missing → Fix session middleware
- Scenario B: Routes array empty → Fix `ObterRotasDefault()` call
- Scenario C: Route not in array → Add missing route
- Scenario D: Permission not in route → Fix permission
- Scenario E: Everything works → Investigate view rendering

---

### Phase 2: Apply Fix (10-30 minutes)
**Goal**: Fix identified issue

**Tasks**:
1. Apply fix based on debug results
2. Rebuild project
3. Test login → Escolher
4. Verify buttons appear

**Possible Fixes**:
- **Fix A**: Configure session middleware properly
- **Fix B**: Verify `ObterRotasDefault()` called in login
- **Fix C**: Add missing route to `ObterRotasDefault()`
- **Fix D**: Fix permission in route definition
- **Fix E**: Investigate view rendering issue

---

### Phase 3: Remove Debug Logging (5 minutes)
**Goal**: Clean up temporary debug code

**Tasks**:
1. Remove all `Console.WriteLine()` statements
2. Keep only core permission checking logic
3. Rebuild project
4. Final test

---

### Phase 4: Fix Header Overlap (5 minutes)
**Goal**: Ensure content starts below header

**Tasks**:
1. Add `.conteudo` wrapper to `Escolher.cshtml`
2. Test content positioning
3. Verify no overlap

---

## 7. RISKS AND MITIGATION

### Risk 1: Session Not Persisting
**Impact**: High - Buttons won't appear if session data missing  
**Probability**: Medium  
**Mitigation**: 
- Verify session middleware configuration
- Check middleware order in `Program.cs`
- Verify session cookie settings

### Risk 2: Routes Array Empty
**Impact**: High - Buttons won't appear if no routes  
**Probability**: Low (routes already defined)  
**Mitigation**:
- Verify `ObterRotasDefault()` called in login
- Check if routes are serialized correctly

### Risk 3: JSON Deserialization Failure
**Impact**: High - Permission checking fails  
**Probability**: Low  
**Mitigation**:
- Add try-catch in `PermissionHelper`
- Log deserialization errors
- Verify JSON format

---

## 8. DEPENDENCIES

### Required Files
- `RdoApp.Core/Utils/PermissionHelper.cs` - Permission checking logic
- `RdoApp.Core/Views/Shared/_HeaderEscolher.cshtml` - Header view
- `RdoApp.Core/Controllers/AccountController.cs` - Login and routes
- `RdoApp.Core/Views/Obra/Escolher.cshtml` - Page content
- `RdoApp.Core/Program.cs` - Session configuration

### Required Data
- Session data with `LoginData` key
- Routes array with `/chart` and `/obra/cadastro`
- Permissions: `visualizar` on both routes

---

## 9. NOTES

### User Corrections Applied
- ✅ "do not create new routes, respect the legacy rules!" - Will use existing routes
- ✅ "Always go study the legacy code!" - Studied nav.html and NavController.js
- ✅ "Debug first with logging, NO code changes until debug results analyzed" - Phase 1 is debug only
- ✅ User wants ONLY 2 buttons on Escolher page (not all 6 legacy buttons)

### Key Insights
- Routes `/chart` and `/obra/cadastro` already exist in `ObterRotasDefault()`
- Both routes have `visualizar` permission
- Problem is NOT missing routes
- Problem is likely session data not persisting or being read correctly
- Debug logging will reveal exact issue

---

**Status**: Requirements Complete - Ready for Design Phase
