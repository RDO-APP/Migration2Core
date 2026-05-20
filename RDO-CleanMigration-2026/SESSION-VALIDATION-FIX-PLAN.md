# SESSION VALIDATION FIX - REDIRECT TO LOGIN ON F5
**Date:** February 5, 2026  
**Issue:** After F5 restart, session is lost but user stays on Escolher page  
**Goal:** Redirect to login when session data is missing

---

## THE PROBLEM

**Current Behavior:**
1. User logs in → Session created with LoginData
2. User presses F5 (restart) → Session cleared
3. Authentication cookie still valid → User stays authenticated
4. But LoginData is gone → Buttons don't appear
5. User sees red banner but stays on page

**Expected Behavior:**
1. User logs in → Session created with LoginData
2. User presses F5 (restart) → Session cleared
3. Check for LoginData in session
4. If missing → Redirect to login
5. User logs in again → Session recreated

---

## THE SOLUTION

### Add Session Validation to ObraController

**File:** `ObraController.cs` → `Escolher()` method

**Add check at the beginning:**
```csharp
[HttpGet]
public async Task<IActionResult> Escolher()
{
    // CHECK 1: Validate session has LoginData
    var loginDataJson = HttpContext.Session.GetString("LoginData");
    if (string.IsNullOrEmpty(loginDataJson))
    {
        _logger.LogWarning("LoginData missing from session, redirecting to login");
        return RedirectToAction("Login", "Account");
    }

    // CHECK 2: Validate colaboradorId in claims (existing code)
    var colaboradorIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
    
    if (string.IsNullOrEmpty(colaboradorIdClaim) || !int.TryParse(colaboradorIdClaim, out int colaboradorId))
    {
        _logger.LogWarning("Invalid colaboradorId in claims, redirecting to login");
        return RedirectToAction("Login", "Account");
    }

    // Rest of existing code...
}
```

---

## IMPLEMENTATION STEPS

### Step 1: Add Session Check (2 minutes)

**Action:** Add LoginData validation at the beginning of `Escolher()` method

**Code to add:**
```csharp
// Validate session has LoginData
var loginDataJson = HttpContext.Session.GetString("LoginData");
if (string.IsNullOrEmpty(loginDataJson))
{
    _logger.LogWarning("LoginData missing from session, redirecting to login");
    return RedirectToAction("Login", "Account");
}
```

**Location:** Right at the start of the `Escolher()` method, before any other checks

---

### Step 2: Remove Debug Code from Header (1 minute)

**Action:** Remove the debug logging we added to `_HeaderEscolher.cshtml`

**Why:** No longer needed once session validation works

---

### Step 3: Test (2 minutes)

**Action:**
1. Restart application (F5)
2. Should redirect to login automatically
3. Login as Ricardo Freire
4. Should see Escolher page with buttons

---

## WHY THIS WORKS

### Current Flow (BROKEN):
```
F5 Restart
  ↓
Session cleared
  ↓
Cookie still valid → User.Identity.IsAuthenticated = true
  ↓
[Authorize] passes
  ↓
Escolher() executes
  ↓
No LoginData check
  ↓
Page renders with red banner
```

### Fixed Flow:
```
F5 Restart
  ↓
Session cleared
  ↓
Cookie still valid → User.Identity.IsAuthenticated = true
  ↓
[Authorize] passes
  ↓
Escolher() executes
  ↓
Check for LoginData → MISSING!
  ↓
Redirect to Login
  ↓
User logs in again
  ↓
Session recreated with LoginData
  ↓
Buttons appear
```

---

## ALTERNATIVE: Clear Cookie on Restart

**If you want to clear authentication cookie on restart:**

**File:** `Program.cs`

**Add cookie configuration:**
```csharp
builder.Services.AddAuthentication(CookieAuthenticationDefaults.AuthenticationScheme)
    .AddCookie(options =>
    {
        options.LoginPath = "/Account/Login";
        options.LogoutPath = "/Account/Logout";
        options.ExpireTimeSpan = TimeSpan.FromHours(8);
        options.SlidingExpiration = true;
        
        // OPTION: Make cookie session-only (cleared on browser close)
        options.Cookie.IsEssential = true;
        options.Cookie.HttpOnly = true;
        options.Cookie.SecurePolicy = CookieSecurePolicy.Always;
        
        // This makes cookie expire when browser closes
        // options.ExpireTimeSpan = TimeSpan.Zero;
    });
```

**But this is NOT recommended because:**
- Users lose session on browser close (annoying)
- Session validation is cleaner
- Gives better control

---

## RECOMMENDED APPROACH

**Use Session Validation (Step 1 above)**

**Why:**
- ✅ Simple 3-line check
- ✅ Clear error logging
- ✅ Redirects to login automatically
- ✅ No cookie configuration changes
- ✅ Works for all scenarios (restart, session timeout, etc.)

---

## IMPLEMENTATION NOW

**Ready to implement?**

**I will:**
1. Add session validation to `ObraController.cs`
2. Remove debug code from `_HeaderEscolher.cshtml`
3. You test by pressing F5

**Total time:** 3 minutes

**Say "proceed" and I'll make the changes.**

---

**Created:** February 5, 2026  
**Status:** Ready to implement  
**Time:** 3 minutes to fix

