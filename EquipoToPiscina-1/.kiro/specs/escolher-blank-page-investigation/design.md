# Escolher Blank Page Investigation - Design

**Created:** January 20, 2026  
**Status:** Investigation Phase  
**Type:** Root Cause Analysis & Fix Strategy

---

## Investigation Architecture

### Diagnostic Flow

```
User Reports Blank Page
         ↓
Browser Diagnostics (F12)
    ├── Console Tab → JavaScript Errors?
    ├── Network Tab → Failed Requests?
    ├── Elements Tab → HTML Present?
    └── Sources Tab → View Source
         ↓
Server Diagnostics
    ├── Controller Logs → Action Executing?
    ├── Service Logs → Data Retrieved?
    ├── View Engine → Compilation Errors?
    └── HTTP Response → Status Code?
         ↓
Root Cause Analysis
    ├── Model Type Mismatch?
    ├── Missing Dependencies?
    ├── Razor Syntax Error?
    ├── Runtime Exception?
    └── Authentication Issue?
         ↓
Fix Strategy Selection
    ├── Option A: Model Type Fix
    ├── Option B: Full Rollback
    ├── Option C: Hybrid Approach
    └── Option D: Incremental Restoration
         ↓
Implementation & Testing
```

---

## Hypothesis Tree

### Primary Hypotheses (Most Likely)

#### H1: Model Type Mismatch ⭐⭐⭐⭐⭐

**Theory:**
```csharp
// View expects:
@model IEnumerable<dynamic>

// Controller returns:
return View(obras); // IEnumerable<ObraViewModel>

// When accessing:
@obra.Descricao // Fails silently with dynamic
```

**Evidence:**
- Backup uses `IEnumerable<dynamic>`
- Controller returns `IEnumerable<ObraViewModel>`
- Dynamic type doesn't enforce compile-time checking
- Property access may fail at runtime without error

**Test:**
```csharp
// Change model type to:
@model IEnumerable<RdoApp.Core.Models.ViewModels.ObraViewModel>
```

**Likelihood:** 90%  
**Impact:** HIGH - Complete rendering failure  
**Fix Difficulty:** EASY - One line change

---

#### H2: Missing External CSS Files ⭐⭐⭐⭐

**Theory:**
```html
<!-- View references:
<link rel="stylesheet" href="~/css/fontello.css" />
<link rel="stylesheet" href="~/css/escolher-legacy.css" />

<!-- But files may not exist or have wrong content -->
```

**Evidence:**
- Current version uses external CSS
- Backup uses inline CSS
- External files may not have been created
- 404 errors would prevent styling

**Test:**
```powershell
# Check if files exist:
Test-Path "RDO-NET8-Migration/RdoApp.Core/wwwroot/css/fontello.css"
Test-Path "RDO-NET8-Migration/RdoApp.Core/wwwroot/css/escolher-legacy.css"
```

**Likelihood:** 70%  
**Impact:** MEDIUM - Page renders but unstyled  
**Fix Difficulty:** MEDIUM - Need to create/restore CSS files

---

#### H3: Razor Compilation Error ⭐⭐⭐

**Theory:**
```razor
<!-- Syntax error in restored view prevents compilation -->
@foreach (var obra in Model)
{
    @obra.SomeProperty // Property doesn't exist
}
```

**Evidence:**
- Backup file is 600 lines with complex Razor syntax
- May have syntax errors or typos
- Compilation errors cause blank page

**Test:**
```powershell
# Check build output for errors:
dotnet build RDO-NET8-Migration/RdoApp.Core/RdoApp.Core.csproj
```

**Likelihood:** 50%  
**Impact:** HIGH - Complete rendering failure  
**Fix Difficulty:** MEDIUM - Need to find and fix syntax errors

---

### Secondary Hypotheses (Less Likely)

#### H4: ViewBag Null Reference ⭐⭐

**Theory:**
```razor
<!-- View accesses ViewBag property that's null -->
<span>@ViewBag.UsuarioNome</span> <!-- Throws if null -->
```

**Evidence:**
- View uses `@ViewBag.UsuarioNome`
- Controller may not set this value
- Null reference causes exception

**Test:**
```csharp
// Add to controller:
ViewBag.UsuarioNome = User.Identity?.Name ?? "Usuário";
```

**Likelihood:** 30%  
**Impact:** MEDIUM - Partial rendering failure  
**Fix Difficulty:** EASY - Set ViewBag value

---

#### H5: Authentication/Authorization Issue ⭐

**Theory:**
```csharp
// User not authenticated, redirected before page loads
[Authorize]
public async Task<IActionResult> Escolher()
```

**Evidence:**
- Controller has `[Authorize]` attribute
- User may not be logged in
- Redirect causes blank page

**Test:**
```
# Check if redirected to login:
# Look at Network tab for 302 redirect
```

**Likelihood:** 20%  
**Impact:** HIGH - No page access  
**Fix Difficulty:** EASY - Login first

---

## Diagnostic Protocol

### Step 1: Browser Console Check

**Objective:** Identify JavaScript errors

**Procedure:**
1. Open browser to `https://localhost:7201/Obra/Escolher`
2. Press F12 to open Developer Tools
3. Go to Console tab
4. Look for red error messages

**Expected Findings:**
- ✅ No errors = JavaScript is fine
- ❌ Errors present = JavaScript issue

**Example Errors:**
```
Uncaught ReferenceError: $ is not defined
Uncaught TypeError: Cannot read property 'Descricao' of undefined
Uncaught SyntaxError: Unexpected token
```

---

### Step 2: Network Tab Check

**Objective:** Identify failed resource requests

**Procedure:**
1. Stay in F12 Developer Tools
2. Go to Network tab
3. Refresh page (Ctrl+F5)
4. Look for red/failed requests

**Expected Findings:**
- ✅ All 200 OK = Resources loading fine
- ❌ 404 errors = Missing files
- ❌ 500 errors = Server errors

**Example Failures:**
```
GET /css/fontello.css → 404 Not Found
GET /css/escolher-legacy.css → 404 Not Found
GET /fonts/fontello.woff2 → 404 Not Found
```

---

### Step 3: Page Source Check

**Objective:** Determine if HTML is being generated

**Procedure:**
1. Right-click on blank page
2. Select "View Page Source" (Ctrl+U)
3. Examine HTML content

**Expected Findings:**

**Scenario A: Full HTML Present**
```html
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <title>Selecionar Obra - RDO App Piscinas</title>
    <!-- CSS links -->
</head>
<body>
    <!-- Full content -->
</body>
</html>
```
**Diagnosis:** Rendering issue, not generation issue

**Scenario B: Partial HTML**
```html
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <title>Selecionar Obra - RDO App Piscinas</title>
</head>
<body>
    <!-- Empty or incomplete -->
</body>
</html>
```
**Diagnosis:** View rendering stopped partway

**Scenario C: Error Message**
```html
<html>
<body>
    <h1>An error occurred while processing your request.</h1>
    <p>Request ID: ...</p>
</body>
</html>
```
**Diagnosis:** Runtime exception

**Scenario D: Completely Empty**
```html

```
**Diagnosis:** View not found or not executing

---

### Step 4: Elements Tab Check

**Objective:** Inspect rendered DOM

**Procedure:**
1. Stay in F12 Developer Tools
2. Go to Elements tab
3. Expand `<html>` → `<body>`
4. Look for content

**Expected Findings:**
- ✅ Full DOM tree = HTML generated
- ❌ Empty body = No content rendered
- ⚠️ Hidden elements = CSS display:none issue

---

### Step 5: Server Log Check

**Objective:** Identify server-side errors

**Procedure:**
1. Check Visual Studio Output window
2. Look for exception messages
3. Check IIS Express logs

**Expected Findings:**
```
// Success:
info: Microsoft.AspNetCore.Hosting.Diagnostics[1]
      Request starting HTTP/2 GET https://localhost:7201/Obra/Escolher
info: Microsoft.AspNetCore.Routing.EndpointMiddleware[0]
      Executing endpoint 'ObraController.Escolher'
info: Microsoft.AspNetCore.Mvc.ViewResult[1]
      Executing ViewResult, running view Escolher.

// Failure:
fail: Microsoft.AspNetCore.Diagnostics.DeveloperExceptionPageMiddleware[1]
      An unhandled exception has occurred while executing the request.
System.NullReferenceException: Object reference not set to an instance of an object.
```

---

## Fix Strategy Options

### Option A: Model Type Fix (RECOMMENDED)

**Approach:** Change model type from `dynamic` to `ObraViewModel`

**Changes:**
```csharp
// Change FROM:
@model IEnumerable<dynamic>

// Change TO:
@model IEnumerable<RdoApp.Core.Models.ViewModels.ObraViewModel>
```

**Pros:**
- ✅ Minimal change (1 line)
- ✅ Preserves all December 2025 features
- ✅ Fixes most likely root cause
- ✅ Strongly typed (better IntelliSense)

**Cons:**
- ⚠️ May not fix if root cause is different

**Risk:** LOW  
**Effort:** MINIMAL  
**Success Probability:** 90%

---

### Option B: Full Rollback

**Approach:** Restore the January 20 simplified version

**Changes:**
```powershell
# Restore working version:
Copy-Item 'Escolher.cshtml.jan20-backup' 'Escolher.cshtml' -Force
```

**Pros:**
- ✅ Guaranteed to work (was working this morning)
- ✅ No investigation needed
- ✅ Zero risk

**Cons:**
- ❌ Loses December 2025 features (blue header, filters)
- ❌ User explicitly requested these features
- ❌ Doesn't solve the problem, just avoids it

**Risk:** NONE  
**Effort:** MINIMAL  
**Success Probability:** 100% (but wrong outcome)

---

### Option C: Hybrid Approach

**Approach:** Start with working version, add features incrementally

**Changes:**
1. Start with January 20 backup (working)
2. Add blue header
3. Test
4. Add filters
5. Test
6. Add JavaScript
7. Test

**Pros:**
- ✅ Identifies exactly what breaks
- ✅ Can stop at last working state
- ✅ Educational

**Cons:**
- ❌ Time-consuming
- ❌ Multiple test cycles
- ❌ May end up at same place

**Risk:** LOW  
**Effort:** HIGH  
**Success Probability:** 80%

---

### Option D: Inline CSS Restoration

**Approach:** Replace external CSS with inline CSS from backup

**Changes:**
```html
<!-- Remove external CSS: -->
<link rel="stylesheet" href="~/css/fontello.css" />
<link rel="stylesheet" href="~/css/escolher-legacy.css" />

<!-- Add inline CSS from backup: -->
<style>
    /* ~400 lines of CSS */
</style>
```

**Pros:**
- ✅ Eliminates CSS dependency issues
- ✅ Self-contained page
- ✅ No 404 errors possible

**Cons:**
- ⚠️ Large inline CSS (400 lines)
- ⚠️ Harder to maintain
- ⚠️ May not fix if root cause is model type

**Risk:** LOW  
**Effort:** MEDIUM  
**Success Probability:** 60%

---

## Recommended Fix Sequence

### Phase 1: Quick Win (Model Type Fix)

**Rationale:** 90% chance this is the issue, 1-line fix

**Steps:**
1. Change `@model IEnumerable<dynamic>` to `@model IEnumerable<RdoApp.Core.Models.ViewModels.ObraViewModel>`
2. Test page
3. If works → DONE
4. If doesn't work → Phase 2

**Time:** 2 minutes  
**Risk:** Minimal

---

### Phase 2: CSS Dependency Fix

**Rationale:** If model type wasn't the issue, CSS might be

**Steps:**
1. Check if `fontello.css` and `escolher-legacy.css` exist
2. If missing → Create them from backup inline CSS
3. If exist → Verify content is correct
4. Test page
5. If works → DONE
6. If doesn't work → Phase 3

**Time:** 10 minutes  
**Risk:** Low

---

### Phase 3: Full Diagnostic

**Rationale:** If quick fixes don't work, need deeper investigation

**Steps:**
1. Run all diagnostic protocols
2. Gather all evidence
3. Analyze findings
4. Identify root cause
5. Apply targeted fix
6. Test page

**Time:** 30 minutes  
**Risk:** Low

---

### Phase 4: Fallback (Full Restore)

**Rationale:** If all else fails, restore entire backup

**Steps:**
1. Backup current version
2. Restore December 2025 backup completely
3. Verify all files present
4. Test page
5. Should work (was working before)

**Time:** 5 minutes  
**Risk:** None

---

## Testing Strategy

### Test 1: Basic Rendering

**Objective:** Verify page displays content

**Procedure:**
1. Navigate to `https://localhost:7201/Obra/Escolher`
2. Observe page

**Pass Criteria:**
- ✅ Page is not blank
- ✅ Some content visible
- ✅ No error messages

---

### Test 2: Blue Header

**Objective:** Verify header displays correctly

**Pass Criteria:**
- ✅ Blue gradient background visible
- ✅ "rdo Piscinas" logo visible
- ✅ User name visible
- ✅ Navigation icons visible

---

### Test 3: Filters

**Objective:** Verify filter functionality

**Procedure:**
1. Type in "Unidade Escolar" input
2. Observe card filtering

**Pass Criteria:**
- ✅ Input fields visible
- ✅ Typing updates results
- ✅ Cards filter correctly

---

### Test 4: Obra Cards

**Objective:** Verify cards display and work

**Pass Criteria:**
- ✅ Cards display in grid
- ✅ Icons visible
- ✅ Progress bars visible
- ✅ Hover effects work
- ✅ Clicking navigates

---

### Test 5: Console Clean

**Objective:** Verify no errors

**Procedure:**
1. Open F12 Console
2. Refresh page

**Pass Criteria:**
- ✅ No red error messages
- ✅ No 404 errors in Network tab
- ✅ All resources load (200 OK)

---

## Implementation Plan

### Pre-Implementation Checklist

- [ ] Diagnostic information gathered
- [ ] Root cause identified
- [ ] Fix strategy selected
- [ ] User approval obtained
- [ ] Backup created

### Implementation Steps

1. **Create Backup**
   ```powershell
   Copy-Item 'Escolher.cshtml' 'Escolher.cshtml.pre-fix-backup'
   ```

2. **Apply Fix**
   - Implement chosen fix strategy
   - Make minimal changes
   - Document changes

3. **Test Locally**
   - Run all test cases
   - Verify all features work
   - Check console for errors

4. **Verify Success**
   - Page renders
   - All features work
   - No errors

5. **Document Changes**
   - What was changed
   - Why it was changed
   - How to verify it works

---

## Rollback Plan

### If Fix Fails

**Immediate Rollback:**
```powershell
# Restore pre-fix backup:
Copy-Item 'Escolher.cshtml.pre-fix-backup' 'Escolher.cshtml' -Force
```

**Alternative Rollback:**
```powershell
# Restore January 20 working version:
Copy-Item 'Escolher.cshtml.jan20-backup' 'Escolher.cshtml' -Force
```

---

## Success Metrics

### Investigation Success

- ✅ Root cause identified with evidence
- ✅ Fix strategy documented
- ✅ User approval obtained

### Implementation Success

- ✅ Page renders (not blank)
- ✅ Blue header visible
- ✅ Filters work
- ✅ Cards display
- ✅ Navigation works
- ✅ No console errors
- ✅ No 404 errors

---

**Status:** Design Complete - Ready for Investigation  
**Recommended First Step:** Apply Model Type Fix (Option A)  
**Estimated Time to Resolution:** 2-30 minutes depending on root cause
