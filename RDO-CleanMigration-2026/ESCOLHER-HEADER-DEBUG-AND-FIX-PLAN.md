# ESCOLHER HEADER: DEBUG AND FIX PLAN

**Date**: February 4, 2026  
**Status**: PLAN READY - NO CODE CHANGES YET  
**Approach**: Debug first, then fix based on findings

---

## USER REQUIREMENTS

### 1. Debug Session Data First
**Answer**: YES - Add debug logging, NO code changes yet

### 2. Which Buttons Should Appear?
**Answer**: Only TWO buttons on Escolher page:
- **Button 1**: DASHBOARD GERAL (Charts - bar chart icon)
- **Button 2**: NOVA UNIDADE ESCOLAR (Plus icon)

### 3. Respect Legacy Logic?
**Answer**: YES - MUST respect ALL legacy logic, avoid old technology

---

## BUTTON REQUIREMENTS

### Button 1: DASHBOARD GERAL (Charts)
**Legacy**:
```html
<li class="btn-tooltip" title="DASHBOARD GERAL" 
    permission="visualizar" 
    permission-route="/chart">
    <a class="pointer" ng-click="controller.redirectCharts()">
        <i class="fa fa-bar-chart"></i>
    </a>
</li>
```

**Requirements**:
- **Route**: `/chart`
- **Permission**: `visualizar` on route `/chart`
- **Visibility**: Always visible (if has permission)
- **Icon**: `fa fa-bar-chart`
- **Title**: "DASHBOARD GERAL"

**Current Route Status**: ✅ EXISTS in `ObterRotasDefault()`
```csharp
rota = new RouteViewModel();
rota.Name = "Gráfico";
rota.Path = "/chart";
rota.Permissions = new List<string>();
rota.Permissions.Add("visualizar");
ListaRotas.Add(rota);
```

---

### Button 2: NOVA UNIDADE ESCOLAR (Plus)
**Legacy**:
```html
<li class="btn-tooltip" title="NOVA UNIDADE ESCOLAR" 
    permission="visualizar" 
    permission-route="/obra/cadastro">
    <a class="pointer" ng-click="controller.novaObra()">
        <i class="fa fa-plus"></i>
    </a>
</li>
```

**Requirements**:
- **Route**: `/obra/cadastro`
- **Permission**: `visualizar` on route `/obra/cadastro`
- **Visibility**: Always visible (if has permission)
- **Icon**: `fa fa-plus`
- **Title**: "NOVA UNIDADE ESCOLAR"

**Current Route Status**: ✅ EXISTS in `ObterRotasDefault()`
```csharp
rota = new RouteViewModel();
rota.Name = "Adicionar Obra";
rota.Path = "/obra/cadastro";
rota.Permissions = new List<string>();
rota.Permissions.Add("visualizar");
ListaRotas.Add(rota);
```

---

## CRITICAL FINDING

**BOTH routes already exist** in `ObterRotasDefault()`!
- `/chart` with `visualizar` permission ✅
- `/obra/cadastro` with `visualizar` permission ✅

**So why don't buttons appear?**

**Hypothesis**: Session data issue (not persisting or corrupted)

---

## PHASE 1: DEBUG SESSION DATA (NO CODE CHANGES)

### Goal:
Verify if session data exists and contains routes

### Approach:
Add temporary debug logging to `PermissionHelper.HasPermission()` to check:
1. Does session data exist?
2. Does Routes array have data?
3. Are `/chart` and `/obra/cadastro` in the Routes array?

### Debug Code to Add:
```csharp
// File: Utils/PermissionHelper.cs
// Method: HasPermission()
// Location: At the beginning of the method

public static bool HasPermission(HttpContext context, string permission, string route)
{
    // ========== DEBUG LOGGING START ==========
    var loginDataJson = context.Session.GetString("LoginData");
    
    Console.WriteLine("========== PERMISSION CHECK DEBUG ==========");
    Console.WriteLine($"[DEBUG] Checking permission: '{permission}' for route: '{route}'");
    Console.WriteLine($"[DEBUG] Session LoginData exists: {!string.IsNullOrEmpty(loginDataJson)}");
    
    if (string.IsNullOrEmpty(loginDataJson))
    {
        Console.WriteLine($"[DEBUG] ❌ Session data is NULL or EMPTY - returning false");
        Console.WriteLine("========================================");
        return false;
    }

    try
    {
        var loginData = JsonSerializer.Deserialize<LoginViewModel>(loginDataJson);
        
        Console.WriteLine($"[DEBUG] LoginData deserialized successfully");
        Console.WriteLine($"[DEBUG] Routes count: {loginData?.Routes?.Count ?? 0}");
        
        if (loginData?.Routes == null)
        {
            Console.WriteLine($"[DEBUG] ❌ Routes array is NULL - returning false");
            Console.WriteLine("========================================");
            return false;
        }

        // Log all routes
        Console.WriteLine($"[DEBUG] All routes in session:");
        foreach (var r in loginData.Routes)
        {
            var perms = r.Permissions != null ? string.Join(", ", r.Permissions) : "NONE";
            Console.WriteLine($"[DEBUG]   - {r.Path} → Permissions: [{perms}]");
        }

        // Check if requested route exists
        var foundRoute = loginData.Routes.FirstOrDefault(r => r.Path == route);
        if (foundRoute == null)
        {
            Console.WriteLine($"[DEBUG] ❌ Route '{route}' NOT FOUND in Routes array - returning false");
            Console.WriteLine("========================================");
            return false;
        }

        Console.WriteLine($"[DEBUG] ✅ Route '{route}' FOUND");
        Console.WriteLine($"[DEBUG] Route permissions: [{string.Join(", ", foundRoute.Permissions ?? new List<string>())}]");

        // Check if permission exists in route
        if (foundRoute.Permissions == null)
        {
            Console.WriteLine($"[DEBUG] ❌ Route has NO permissions array - returning false");
            Console.WriteLine("========================================");
            return false;
        }

        var hasPermission = foundRoute.Permissions.Contains(permission);
        Console.WriteLine($"[DEBUG] Permission '{permission}' in route: {hasPermission}");
        Console.WriteLine($"[DEBUG] Result: {(hasPermission ? "✅ TRUE" : "❌ FALSE")}");
        Console.WriteLine("========================================");

        return hasPermission;
    }
    catch (JsonException ex)
    {
        Console.WriteLine($"[DEBUG] ❌ JSON deserialization FAILED: {ex.Message}");
        Console.WriteLine("========================================");
        return false;
    }
    // ========== DEBUG LOGGING END ==========
}
```

### Testing Steps:
1. Add debug logging to `PermissionHelper.cs`
2. Rebuild project: `dotnet build`
3. Run application: `dotnet run`
4. Login with Ricardo's credentials
5. Navigate to Escolher page
6. Check console output for debug messages

### Expected Debug Output:

#### Scenario A: Session Data Missing
```
========== PERMISSION CHECK DEBUG ==========
[DEBUG] Checking permission: 'visualizar' for route: '/chart'
[DEBUG] Session LoginData exists: False
[DEBUG] ❌ Session data is NULL or EMPTY - returning false
========================================
```

**Diagnosis**: Session not persisting  
**Fix**: Configure session middleware properly

---

#### Scenario B: Routes Array Empty
```
========== PERMISSION CHECK DEBUG ==========
[DEBUG] Checking permission: 'visualizar' for route: '/chart'
[DEBUG] Session LoginData exists: True
[DEBUG] LoginData deserialized successfully
[DEBUG] Routes count: 0
[DEBUG] ❌ Routes array is NULL - returning false
========================================
```

**Diagnosis**: `ObterRotasDefault()` not being called or returning empty  
**Fix**: Verify `ObterRotasDefault()` is called in `AccountController.Login()`

---

#### Scenario C: Route Not in Array
```
========== PERMISSION CHECK DEBUG ==========
[DEBUG] Checking permission: 'visualizar' for route: '/chart'
[DEBUG] Session LoginData exists: True
[DEBUG] LoginData deserialized successfully
[DEBUG] Routes count: 13
[DEBUG] All routes in session:
[DEBUG]   - /obra/escolher → Permissions: [visualizar]
[DEBUG]   - /obra/cadastro → Permissions: [visualizar]
[DEBUG]   - /colaborador/alterarsenha → Permissions: [visualizar]
[DEBUG]   - /etapa/index → Permissions: [visualizar]
[DEBUG] ❌ Route '/chart' NOT FOUND in Routes array - returning false
========================================
```

**Diagnosis**: `/chart` route missing from `ObterRotasDefault()`  
**Fix**: Verify route is added in `ObterRotasDefault()` method

---

#### Scenario D: Permission Not in Route
```
========== PERMISSION CHECK DEBUG ==========
[DEBUG] Checking permission: 'visualizar' for route: '/chart'
[DEBUG] Session LoginData exists: True
[DEBUG] LoginData deserialized successfully
[DEBUG] Routes count: 13
[DEBUG] All routes in session:
[DEBUG]   - /chart → Permissions: [acessar]
[DEBUG] ✅ Route '/chart' FOUND
[DEBUG] Route permissions: [acessar]
[DEBUG] Permission 'visualizar' in route: False
[DEBUG] Result: ❌ FALSE
========================================
```

**Diagnosis**: Route has wrong permission  
**Fix**: Change permission to `visualizar` in `ObterRotasDefault()`

---

#### Scenario E: Everything Works (Expected)
```
========== PERMISSION CHECK DEBUG ==========
[DEBUG] Checking permission: 'visualizar' for route: '/chart'
[DEBUG] Session LoginData exists: True
[DEBUG] LoginData deserialized successfully
[DEBUG] Routes count: 13
[DEBUG] All routes in session:
[DEBUG]   - /chart → Permissions: [visualizar]
[DEBUG]   - /obra/cadastro → Permissions: [visualizar]
[DEBUG] ✅ Route '/chart' FOUND
[DEBUG] Route permissions: [visualizar]
[DEBUG] Permission 'visualizar' in route: True
[DEBUG] Result: ✅ TRUE
========================================
```

**Diagnosis**: Everything works correctly!  
**Expected**: Buttons should appear

---

## PHASE 2: FIX BASED ON DEBUG RESULTS

### Fix A: Session Not Persisting
**File**: `Program.cs`

**Check session configuration**:
```csharp
// Add session services
builder.Services.AddSession(options =>
{
    options.IdleTimeout = TimeSpan.FromHours(8);
    options.Cookie.HttpOnly = true;
    options.Cookie.IsEssential = true;
    options.Cookie.SecurePolicy = CookieSecurePolicy.None; // Or SameAsRequest
    options.Cookie.SameSite = SameSiteMode.Lax; // Important!
});

// Use session middleware (BEFORE UseAuthorization!)
app.UseSession();
app.UseAuthorization();
```

**Verify middleware order**:
1. `app.UseRouting()`
2. `app.UseAuthentication()`
3. `app.UseSession()` ← MUST be here
4. `app.UseAuthorization()`
5. `app.MapControllers()`

---

### Fix B: Routes Array Empty
**File**: `Controllers/AccountController.cs`

**Verify `ObterRotasDefault()` is called**:
```csharp
// In Login() method, after finding colaborador

var loginViewModel = new LoginViewModel
{
    Routes = ObterRotasDefault(colaborador),  // ← Verify this line exists
    Menu = ObterMenuDefault(colaborador),
    Usuario = new UsuarioViewModel { ... }
};

// Store in session
HttpContext.Session.SetString("LoginData", 
    System.Text.Json.JsonSerializer.Serialize(loginViewModel));
```

---

### Fix C: Route Not in Array
**File**: `Controllers/AccountController.cs`

**Verify `/chart` route exists in `ObterRotasDefault()`**:
```csharp
private List<RouteViewModel> ObterRotasDefault(Colaborador colaborador)
{
    var ListaRotas = new List<RouteViewModel>();

    // ... other routes ...

    // VERIFY THIS EXISTS:
    rota = new RouteViewModel();
    rota.Name = "Gráfico";
    rota.Path = "/chart";
    rota.Permissions = new List<string>();
    rota.Permissions.Add("visualizar");
    ListaRotas.Add(rota);

    return ListaRotas;
}
```

---

### Fix D: Permission Not in Route
**File**: `Controllers/AccountController.cs`

**Change permission to `visualizar`**:
```csharp
rota = new RouteViewModel();
rota.Name = "Gráfico";
rota.Path = "/chart";
rota.Permissions = new List<string>();
rota.Permissions.Add("visualizar");  // ← Ensure this is "visualizar"
ListaRotas.Add(rota);
```

---

## PHASE 3: REMOVE DEBUG LOGGING

After identifying and fixing the issue, remove debug logging:

```csharp
// File: Utils/PermissionHelper.cs
// Remove all Console.WriteLine() statements
// Keep only the core logic
```

---

## PHASE 4: FIX HEADER OVERLAP

**File**: `Views/Obra/Escolher.cshtml`

**Add `.conteudo` wrapper**:
```razor
<div class="conteudo">  <!-- ADD THIS -->
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-12">
                @* Existing content *@
            </div>
        </div>
    </div>
</div>  <!-- ADD THIS -->
```

**Why**: CSS rule `.topo + .conteudo { padding-top: 103px; }` will apply automatically

---

## IMPLEMENTATION CHECKLIST

### Phase 1: Debug (15 minutes)
- [ ] Add debug logging to `PermissionHelper.HasPermission()`
- [ ] Rebuild project
- [ ] Run application
- [ ] Login and navigate to Escolher
- [ ] Check console output
- [ ] Identify which scenario (A, B, C, D, or E)

### Phase 2: Fix (10-30 minutes depending on issue)
- [ ] Apply fix based on debug results
- [ ] Rebuild project
- [ ] Test login → Escolher
- [ ] Verify buttons appear

### Phase 3: Cleanup (5 minutes)
- [ ] Remove debug logging
- [ ] Rebuild project
- [ ] Final test

### Phase 4: Fix Overlap (5 minutes)
- [ ] Add `.conteudo` wrapper to Escolher.cshtml
- [ ] Test content is below header

---

## SUCCESS CRITERIA

### Buttons Visible:
- ✅ DASHBOARD GERAL button (bar chart icon) visible
- ✅ NOVA UNIDADE ESCOLAR button (plus icon) visible
- ✅ Buttons have hover effect
- ✅ Tooltips appear on hover

### Header Not Overlapping:
- ✅ Content starts 103px below header
- ✅ First row of cards fully visible
- ✅ No overlap

### Legacy Logic Respected:
- ✅ Uses existing routes (no new routes created)
- ✅ Uses permission system correctly
- ✅ Modern technology (ASP.NET Core, not AngularJS)

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

## NEXT STEPS

1. **User approves plan**
2. **Add debug logging** (Phase 1)
3. **Run and analyze** debug output
4. **Report findings** to user
5. **Apply fix** based on findings (Phase 2)
6. **Remove debug logging** (Phase 3)
7. **Fix overlap** (Phase 4)
8. **Move to Strategy 2** (Obra Cards - filters + enhanced cards)

---

**STATUS**: PLAN READY - AWAITING USER APPROVAL TO ADD DEBUG LOGGING
