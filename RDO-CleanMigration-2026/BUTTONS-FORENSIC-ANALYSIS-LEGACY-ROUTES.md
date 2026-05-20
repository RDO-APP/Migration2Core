# BUTTONS FORENSIC ANALYSIS - LEGACY ROUTES

**Date**: February 4, 2026  
**Status**: ANALYSIS COMPLETE - NO CODE CHANGES  
**Purpose**: Study legacy button routes to respect legacy rules

---

## USER CORRECTION

**User said**: "do not create new routes, respect the legacy rules! go study about the bottons routes and come back with a new plan"

**My mistake**: I suggested adding `/dashboard/index` route to `ObterRotasDefault()`, which would create a NEW route not in legacy.

**Correct approach**: Study what routes legacy ACTUALLY uses for buttons, then match them exactly.

---

## LEGACY HEADER BUTTONS (nav.html)

### Button 1: Laudos (Folder Icon)
```html
<li class="btn-tooltip pointer" title="Laudos">
    <a class="pointer" ng-hide="controller.desabilitarBotaoLogomarca" 
       ng-click="controller.listagemLaudos()">
        <i class="fa fa-folder"></i>
    </a>
</li>
```

**Function** (NavController.js):
```javascript
this.listagemLaudos = function () {
    $location.path('/laudos/index');
}
```

**Route**: `/laudos/index`  
**Permission**: NONE (no permission directive)  
**Visibility**: Hidden if `desabilitarBotaoLogomarca` (no obra selected)

---

### Button 2: Dashboard (Dashboard Icon)
```html
<li class="btn-tooltip pointer" 
    ng-click="controller.dashboard()" 
    permission="acessarDashboard" 
    permission-route="/dashboard/index" 
    title="DASHBOARD DA UINIDADE ESCOLAR">
    <a class="pointer">
        <i class="icon-dashboard"></i>
    </a>
</li>
```

**Function** (NavController.js):
```javascript
this.dashboard = function () {
    var data = this.userData;
    var found = false;
    
    // Check if user has /dashboard/index route
    for (var i in data.routes) {
        if (data.routes[i].path == '/dashboard/index') {
            found = true;
        }
    }
    
    if (found) {
        Auth.updateUser(data);
        $location.path('/dashboard/index');
    }
    else {
        toastr.error('Seu usuário não tem permissão. Favor contate o administrador.');
    }
}
```

**Route**: `/dashboard/index`  
**Permission**: `acessarDashboard` on route `/dashboard/index`  
**Visibility**: Always visible (permission directive hides if no permission)

**CRITICAL**: Function checks if route exists in `userData.routes` array!

---

### Button 3: RDOs (RDO Icon)
```html
<li class="btn-tooltip" title="Relatórios Diários">
    <a class="pointer" ng-hide="controller.desabilitarBotaoLogomarca" 
       ng-click="controller.listagemRdos()">
        <i class="icon-rdo-novo_2"></i>
    </a>
</li>
```

**Function** (NavController.js):
```javascript
this.listagemRdos = function () {
    $location.path('/rdo/index');
}
```

**Route**: `/rdo/index`  
**Permission**: NONE (no permission directive)  
**Visibility**: Hidden if `desabilitarBotaoLogomarca` (no obra selected)

---

### Button 4: Tarefas (Grid Icon)
```html
<li class="btn-tooltip" title="TAREFAS">
    <a class="pointer" ng-hide="controller.desabilitarBotaoLogomarca" 
       ng-click="controller.tarefaCards()">
        <i class="fa fa-th"></i>
    </a>
</li>
```

**Function** (NavController.js):
```javascript
this.tarefaCards = function () {
    $location.path('/tarefa/cards');
}
```

**Route**: `/tarefa/cards`  
**Permission**: NONE (no permission directive)  
**Visibility**: Hidden if `desabilitarBotaoLogomarca` (no obra selected)

---

### Button 5: Charts (Bar Chart Icon)
```html
<li class="btn-tooltip" title="DASHBOARD GERAL" 
    permission="visualizar" 
    permission-route="/chart">
    <a class="pointer btn-icon-topo" ng-click="controller.redirectCharts()">
        <i class="fa fa-bar-chart"></i>
    </a>
</li>
```

**Function** (NavController.js):
```javascript
this.redirectCharts = function () {
    $location.path('/chart');
}
```

**Route**: `/chart`  
**Permission**: `visualizar` on route `/chart`  
**Visibility**: Always visible (permission directive hides if no permission)

---

### Button 6: Nova Obra (Plus Icon)
```html
<li class="btn-tooltip" title="NOVA UNIDADE ESCOLAR" 
    permission="visualizar" 
    permission-route="/obra/cadastro">
    <a class="pointer btn-icon-topo" ng-click="controller.novaObra()">
        <i class="fa fa-plus"></i>
    </a>
</li>
```

**Function** (NavController.js):
```javascript
this.novaObra = function () {
    ViewBag.set('obraId', 0);
    ViewBag.set('novaObra', true);
    ViewBag.set('last-page', $location.path());
    $location.path('/obra/cadastro');
}
```

**Route**: `/obra/cadastro`  
**Permission**: `visualizar` on route `/obra/cadastro`  
**Visibility**: Always visible (permission directive hides if no permission)

---

## LEGACY BUTTON SUMMARY

| # | Icon | Title | Route | Permission | Permission Route | Visibility Logic |
|---|------|-------|-------|------------|------------------|------------------|
| 1 | fa-folder | Laudos | `/laudos/index` | NONE | NONE | Hidden if no obra |
| 2 | icon-dashboard | Dashboard | `/dashboard/index` | `acessarDashboard` | `/dashboard/index` | Permission check |
| 3 | icon-rdo-novo_2 | RDOs | `/rdo/index` | NONE | NONE | Hidden if no obra |
| 4 | fa-th | Tarefas | `/tarefa/cards` | NONE | NONE | Hidden if no obra |
| 5 | fa-bar-chart | Charts | `/chart` | `visualizar` | `/chart` | Permission check |
| 6 | fa-plus | Nova Obra | `/obra/cadastro` | `visualizar` | `/obra/cadastro` | Permission check |

---

## CURRENT HEADER BUTTONS (_HeaderEscolher.cshtml)

```csharp
<ul class="nav navbar-nav navbar-right ball-hover">
    @if (PermissionHelper.HasPermission(Context, "acessarDashboard", "/dashboard/index"))
    {
        <li class="btn-tooltip pointer" title="DASHBOARD DA UNIDADE ESCOLAR">
            <a href="@Url.Action("Index", "Dashboard")">
                <i class="icon-dashboard"></i>
            </a>
        </li>
    }
    
    @if (PermissionHelper.HasPermission(Context, "visualizar", "/chart"))
    {
        <li class="btn-tooltip pointer" title="DASHBOARD GERAL">
            <a href="@Url.Action("Index", "Chart")">
                <i class="fa fa-bar-chart"></i>
            </a>
        </li>
    }
    
    @if (PermissionHelper.HasPermission(Context, "visualizar", "/obra/cadastro"))
    {
        <li class="btn-tooltip pointer" title="NOVA UNIDADE ESCOLAR">
            <a href="@Url.Action("Cadastro", "Obra")">
                <i class="fa fa-plus"></i>
            </a>
        </li>
    }
</ul>
```

**Current buttons**: 3 (Dashboard, Charts, Nova Obra)  
**Legacy buttons**: 6 (Laudos, Dashboard, RDOs, Tarefas, Charts, Nova Obra)

---

## CURRENT ROUTES IN ObterRotasDefault()

```csharp
✅ /obra/escolher (visualizar)
✅ /obra/cadastro (visualizar)  ← Button 6 uses this
✅ /colaborador/alterarsenha (visualizar)
✅ /convidada (visualizar)
✅ /etapa/index (visualizar)
✅ /etapa/cadastro (visualizar)
✅ /chart (visualizar)  ← Button 5 uses this
✅ /chart/rdos (visualizar)
✅ /chart/atrasado (visualizar)
✅ /chart/diaimprodutivo (visualizar)
✅ /chart/tarefa (visualizar)
✅ /chart/comentario (visualizar)
✅ /tarefa/paralizacoes/index (visualizar)

❌ /dashboard/index (acessarDashboard)  ← Button 2 needs this
❌ /laudos/index (no permission)  ← Button 1 needs this
❌ /rdo/index (no permission)  ← Button 3 needs this
❌ /tarefa/cards (no permission)  ← Button 4 needs this
```

---

## ROOT CAUSE ANALYSIS

### Why Button 2 (Dashboard) Doesn't Appear:
**Route needed**: `/dashboard/index` with permission `acessarDashboard`  
**Current routes**: Does NOT have `/dashboard/index`  
**Result**: `PermissionHelper.HasPermission(Context, "acessarDashboard", "/dashboard/index")` returns `false`

### Why Button 5 (Charts) Doesn't Appear:
**Route needed**: `/chart` with permission `visualizar`  
**Current routes**: ✅ HAS `/chart` with permission `visualizar`  
**Result**: `PermissionHelper.HasPermission(Context, "visualizar", "/chart")` should return `true`

**WAIT**: If Charts button should work, why doesn't it appear?

### Why Button 6 (Nova Obra) Doesn't Appear:
**Route needed**: `/obra/cadastro` with permission `visualizar`  
**Current routes**: ✅ HAS `/obra/cadastro` with permission `visualizar`  
**Result**: `PermissionHelper.HasPermission(Context, "visualizar", "/obra/cadastro")` should return `true`

**WAIT**: If Nova Obra button should work, why doesn't it appear?

---

## HYPOTHESIS: SESSION DATA ISSUE

If `ObterRotasDefault()` already has `/chart` and `/obra/cadastro` routes, but buttons still don't appear, then the problem is NOT missing routes.

**Possible causes**:
1. Session data not persisting between login and Escolher page
2. Session data corrupted/invalid JSON
3. Routes array empty in session
4. PermissionHelper not reading session correctly

**Test needed**: Check if session data exists and contains routes.

---

## CORRECTED STRATEGY

### Option A: Debug Session Data First (RECOMMENDED)
**Before adding routes**, verify session data exists:

1. Add debug logging to `PermissionHelper.HasPermission()`
2. Check if `loginDataJson` is null/empty
3. Check if `loginData.Routes` is null/empty
4. Check if routes array contains expected routes

**If session data is missing**: Fix session persistence issue  
**If session data exists**: Then we can add missing routes

### Option B: Add Missing Routes (IF session data works)
**Only if** session data is confirmed working, add missing routes:

1. `/dashboard/index` with `acessarDashboard` permission
2. `/laudos/index` with `visualizar` permission (or no permission?)
3. `/rdo/index` with `visualizar` permission (or no permission?)
4. `/tarefa/cards` with `visualizar` permission (or no permission?)

**Question**: Do Laudos, RDOs, and Tarefas buttons need permissions?
- Legacy has NO permission directive on these buttons
- They use `ng-hide="controller.desabilitarBotaoLogomarca"` instead
- This means: Show if obra is selected, hide if no obra

### Option C: Match Legacy Exactly (CONSERVATIVE)
**Show only 3 buttons** that have permission checks:
1. Dashboard (if has `/dashboard/index` route)
2. Charts (if has `/chart` route)
3. Nova Obra (if has `/obra/cadastro` route)

**Hide 3 buttons** that depend on obra selection:
1. Laudos (show only after obra selected)
2. RDOs (show only after obra selected)
3. Tarefas (show only after obra selected)

---

## RECOMMENDED PLAN

### Phase 1: Debug Session Data (15 minutes)
**Goal**: Verify session data exists and contains routes

**Step 1**: Add debug logging to `PermissionHelper.HasPermission()`:
```csharp
public static bool HasPermission(HttpContext context, string permission, string route)
{
    var loginDataJson = context.Session.GetString("LoginData");
    
    // DEBUG: Log session data
    Console.WriteLine($"[DEBUG] Session LoginData: {(string.IsNullOrEmpty(loginDataJson) ? "NULL/EMPTY" : "EXISTS")}");
    
    if (string.IsNullOrEmpty(loginDataJson))
    {
        Console.WriteLine($"[DEBUG] No session data - returning false");
        return false;
    }

    try
    {
        var loginData = JsonSerializer.Deserialize<LoginViewModel>(loginDataJson);
        
        // DEBUG: Log routes count
        Console.WriteLine($"[DEBUG] Routes count: {loginData?.Routes?.Count ?? 0}");
        
        if (loginData?.Routes == null)
        {
            Console.WriteLine($"[DEBUG] Routes is null - returning false");
            return false;
        }

        // DEBUG: Log all routes
        foreach (var r in loginData.Routes)
        {
            Console.WriteLine($"[DEBUG] Route: {r.Path} - Permissions: {string.Join(", ", r.Permissions ?? new List<string>())}");
        }

        // ... rest of function
    }
    catch (JsonException ex)
    {
        Console.WriteLine($"[DEBUG] JSON deserialization failed: {ex.Message}");
        return false;
    }
}
```

**Step 2**: Run application and check console output

**Step 3**: Analyze results:
- If "NULL/EMPTY": Session not persisting → Fix session middleware
- If "Routes count: 0": Routes array empty → Check `ObterRotasDefault()`
- If routes exist: Check if `/chart` and `/obra/cadastro` are in list

---

### Phase 2: Fix Based on Debug Results

#### If Session Data Missing:
**Fix session middleware configuration** in `Program.cs`:
```csharp
builder.Services.AddSession(options =>
{
    options.IdleTimeout = TimeSpan.FromHours(8);
    options.Cookie.HttpOnly = true;
    options.Cookie.IsEssential = true;
    options.Cookie.SecurePolicy = CookieSecurePolicy.None; // Or SameAsRequest
});
```

#### If Routes Array Empty:
**Check `ObterRotasDefault()` is being called** in `AccountController.Login()`:
```csharp
var loginViewModel = new LoginViewModel
{
    Routes = ObterRotasDefault(colaborador),  // ← Verify this is called
    Menu = ObterMenuDefault(colaborador),
    Usuario = new UsuarioViewModel { ... }
};
```

#### If Routes Exist But Buttons Don't Appear:
**Then we can add missing routes**:
```csharp
// Add to ObterRotasDefault() method

// Dashboard route (for Button 2)
rota = new RouteViewModel();
rota.Name = "Dashboard";
rota.Path = "/dashboard/index";
rota.Permissions = new List<string>();
rota.Permissions.Add("acessarDashboard");
ListaRotas.Add(rota);
```

---

## QUESTIONS FOR USER

Before proceeding, I need to know:

1. **Should I add debug logging first** to verify session data?
   - YES: Add logging, run app, check console
   - NO: Skip to adding routes

2. **Which buttons should appear on Escolher page?**
   - All 6 legacy buttons?
   - Only 3 buttons with permissions (Dashboard, Charts, Nova Obra)?
   - Only buttons that work without obra selected?

3. **Should I respect the "no obra selected" logic?**
   - Legacy hides Laudos, RDOs, Tarefas if no obra selected
   - Escolher page = no obra selected yet
   - Should these 3 buttons be hidden on Escolher page?

---

## CONCLUSION

**My mistake**: I suggested creating new routes without studying legacy.

**Correct approach**: 
1. Study legacy buttons (DONE ✅)
2. Debug session data (NEXT STEP)
3. Add missing routes ONLY if session data works
4. Respect legacy visibility logic (obra-dependent buttons)

**Status**: ANALYSIS COMPLETE - AWAITING USER DIRECTION ON DEBUG APPROACH
