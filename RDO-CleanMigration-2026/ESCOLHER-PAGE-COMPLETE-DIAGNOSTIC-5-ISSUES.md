# ESCOLHER PAGE: COMPLETE DIAGNOSTIC - 5 CRITICAL ISSUES

**Date**: February 4, 2026  
**Status**: DIAGNOSTIC COMPLETE - NO CODE CHANGES  
**Scope**: Full analysis of Escolher page (Header + Obra Cards)

---

## EXECUTIVE SUMMARY

After deep analysis of legacy vs current implementation, I've identified **FIVE CRITICAL ISSUES**:

### HEADER ISSUES (3):
1. ❌ **BUTTONS NOT APPEARING** - PermissionHelper returns false (session data issue)
2. ✅ **HEADER OVERLAP CONFIRMED** - Missing `.conteudo` wrapper div
3. ✅ **ALIGNMENT WORKING** - Logo and user are horizontally aligned (fixed previously)

### OBRA CARDS ISSUES (2):
4. ❌ **FILTERS COMPLETELY MISSING** - No filter inputs for Unidade/Município
5. ❌ **CARDS OVERSIMPLIFIED** - Missing progress bars, status colors, municipality, legend

---

## ISSUE #1: BUTTONS NOT APPEARING (HEADER)

### Current Status:
- User confirmed: **ZERO buttons visible** after 4-5 fix attempts
- HTML source shows: `<ul class="nav navbar-nav navbar-right ball-hover"></ul>` is **EMPTY**
- PermissionHelper is implemented correctly (exact copy of legacy logic)
- **BUT**: Buttons still don't render

### Root Cause Analysis:

#### Legacy Permission System (app.js):
```javascript
app.factory('Permission', ['Auth', '$location', function (Auth, $location) {
    return {
        check: function (perm, route) {
            var currentPath = route == null ? $location.path() : route;
            var retorno = true;
            var routeFound = false;
            
            if (Auth.isLoggedIn()) {
                var user = Auth.getUser();  // ← Gets from localStorage
                
                if (!user.routes) {
                    return false;  // ← NO ROUTES = NO PERMISSION
                }
                
                for (var k in user.routes) {
                    var route = user.routes[k];
                    if (route.path == currentPath) {
                        routeFound = true;
                        if (!route.permissions) {
                            return false;
                        }
                        for (var i in route.permissions) {
                            if (route.permissions[i] == perm) {
                                return true;  // ← PERMISSION FOUND!
                            }
                        }
                        return false;  // ← ROUTE FOUND BUT NO PERMISSION
                    }
                }
            }
            
            if (routeFound == false) {
                return false;  // ← ROUTE NOT FOUND
            }
            
            return retorno;
        }
    }
}]);
```

**Key Points**:
1. Legacy uses `Auth.getUser()` which reads from **localStorage**
2. User object MUST have `routes` array
3. Each route has `path` and `permissions` array
4. Returns `false` if route not found OR permission not in array

#### Current Implementation (PermissionHelper.cs):
```csharp
public static bool HasPermission(HttpContext context, string permission, string route)
{
    // Get login data from session
    var loginDataJson = context.Session.GetString("LoginData");
    
    if (string.IsNullOrEmpty(loginDataJson))
    {
        return false; // ← NO SESSION DATA = NO PERMISSION
    }

    try
    {
        var loginData = JsonSerializer.Deserialize<LoginViewModel>(loginDataJson);
        
        if (loginData?.Routes == null)
        {
            return false; // ← NO ROUTES = NO PERMISSION
        }

        // Loop through routes to find matching route
        foreach (var userRoute in loginData.Routes)
        {
            if (userRoute.Path == route)
            {
                // Route found! Check permissions
                if (userRoute.Permissions == null)
                {
                    return false;
                }

                foreach (var routePermission in userRoute.Permissions)
                {
                    if (routePermission == permission)
                    {
                        return true; // ← PERMISSION FOUND!
                    }
                }
                
                return false; // ← ROUTE FOUND BUT NO PERMISSION
            }
        }

        return false; // ← ROUTE NOT FOUND
    }
    catch (JsonException)
    {
        return false;
    }
}
```

**Key Points**:
1. Current uses `HttpContext.Session.GetString("LoginData")`
2. Exact same logic as legacy
3. **BUT**: Returns `false` if session data is missing/invalid

### Why Buttons Don't Appear - 3 Possible Causes:

#### Cause A: Session Data Not Persisting
**Symptom**: Session cleared between login and Escolher page  
**Evidence**: AccountController stores session data correctly:
```csharp
HttpContext.Session.SetString("LoginData", 
    System.Text.Json.JsonSerializer.Serialize(loginViewModel));
```

**Possible Issues**:
- Session middleware not configured properly
- Session cookie not being sent
- Session timeout too short
- Browser blocking session cookies

#### Cause B: Routes Array Missing Dashboard Route
**Symptom**: Routes array doesn't contain `/dashboard/index` route  
**Evidence**: AccountController's `ObterRotasDefault()` does NOT include dashboard route:
```csharp
private List<RouteViewModel> ObterRotasDefault(Colaborador colaborador)
{
    var ListaRotas = new List<RouteViewModel>();

    // ✅ Has /obra/escolher
    rota = new RouteViewModel();
    rota.Name = "Escolher Obra";
    rota.Path = "/obra/escolher";
    rota.Permissions = new List<string>();
    rota.Permissions.Add("visualizar");
    ListaRotas.Add(rota);

    // ✅ Has /obra/cadastro
    rota = new RouteViewModel();
    rota.Name = "Adicionar Obra";
    rota.Path = "/obra/cadastro";
    rota.Permissions = new List<string>();
    rota.Permissions.Add("visualizar");
    ListaRotas.Add(rota);

    // ✅ Has /chart
    rota = new RouteViewModel();
    rota.Name = "Gráfico";
    rota.Path = "/chart";
    rota.Permissions = new List<string>();
    rota.Permissions.Add("visualizar");
    ListaRotas.Add(rota);

    // ❌ MISSING /dashboard/index !!!
    // ❌ MISSING acessarDashboard permission !!!

    return ListaRotas;
}
```

**SMOKING GUN**: The header checks for:
```csharp
@if (PermissionHelper.HasPermission(Context, "acessarDashboard", "/dashboard/index"))
{
    <li class="btn-tooltip pointer" title="DASHBOARD DA UNIDADE ESCOLAR">
        <a href="@Url.Action("Index", "Dashboard")">
            <i class="icon-dashboard"></i>
        </a>
    </li>
}
```

But `ObterRotasDefault()` **NEVER adds** a route with:
- `Path = "/dashboard/index"`
- `Permissions = ["acessarDashboard"]`

**RESULT**: `HasPermission()` returns `false` → Button doesn't render!

#### Cause C: Wrong Route Paths in Header
**Symptom**: Header checks for routes that don't exist in Routes array  
**Evidence**: Header checks:
- `/dashboard/index` with permission `acessarDashboard` ❌ NOT IN ROUTES
- `/chart` with permission `visualizar` ✅ IN ROUTES
- `/obra/cadastro` with permission `visualizar` ✅ IN ROUTES

**VERDICT**: **CAUSE B IS THE ROOT CAUSE** - Missing dashboard route in `ObterRotasDefault()`

### Solution for Issue #1:

**Option 1: Add Missing Routes** (RECOMMENDED)
Add dashboard route to `ObterRotasDefault()`:
```csharp
rota = new RouteViewModel();
rota.Name = "Dashboard";
rota.Path = "/dashboard/index";
rota.Permissions = new List<string>();
rota.Permissions.Add("acessarDashboard");
rota.Permissions.Add("visualizar");
ListaRotas.Add(rota);
```

**Option 2: Change Header to Use Existing Routes**
Change header to check for routes that exist:
```csharp
@if (PermissionHelper.HasPermission(Context, "visualizar", "/chart"))
{
    <li class="btn-tooltip pointer" title="DASHBOARD DA UNIDADE ESCOLAR">
        <a href="@Url.Action("Index", "Dashboard")">
            <i class="icon-dashboard"></i>
        </a>
    </li>
}
```

**Option 3: Remove Permission Checks** (NOT RECOMMENDED)
Show buttons without permission checks (security risk)

---

## ISSUE #2: HEADER OVERLAP (HEADER)

### Current Status:
- User observation: "impression that header is over the obras cards"
- **CONFIRMED**: Header overlaps first row of cards

### Root Cause:

#### Legacy CSS Pattern (escolher.css):
```css
.topo {
    position: fixed;
    z-index: 10 !important;
    width: 100%;
}

.topo + .conteudo {
    padding-top: 103px;  /* ← PUSHES CONTENT BELOW HEADER */
}
```

**How it works**:
- Header is `position: fixed` (stays at top, removed from document flow)
- Content needs `padding-top: 103px` to start below header
- The `+` selector = "immediately following sibling"
- `.topo + .conteudo` = "content div that comes RIGHT AFTER header"

#### Current Implementation:
```razor
<div class="container">
    <div class="row justify-content-center">
        <div class="col-12">
            @* NO .conteudo WRAPPER! *@
```

**Missing**:
1. No wrapper div with class `.conteudo`
2. CSS rule `.topo + .conteudo` exists but never applies
3. Content starts at `top: 0`, header overlaps it

### Solution for Issue #2:

**Add wrapper div with `.conteudo` class**:
```razor
<div class="conteudo">  <!-- ← ADD THIS -->
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-12">
                @* Content here *@
            </div>
        </div>
    </div>
</div>  <!-- ← ADD THIS -->
```

**Result**: CSS rule `.topo + .conteudo { padding-top: 103px; }` will apply automatically!

---

## ISSUE #3: ALIGNMENT WORKING ✅ (HEADER)

### Current Status:
- User confirmed: "they are aligned, logo and user"
- Flexbox fix applied successfully
- **NO ACTION NEEDED**

---

## ISSUE #4: FILTERS COMPLETELY MISSING (OBRA CARDS)

### Current Status:
- User observation: "I can not see the filters yet"
- **CONFIRMED**: Filters are 100% missing from current implementation

### Legacy Filter Structure (escolher.html):
```html
<div class="container text-center">
    <div class="row">
        <!-- Label -->
        <div class="col">
            <label class="control-label filtro">Filtros</label>
        </div>

        <!-- Filter 1: Unidade Escolar -->
        <div class="col-md-3 col-md-offset-3">
            <input class="form-control" 
                   type="text" 
                   name="unidade_escolar" 
                   placeholder="Unidade escolar" 
                   autofocus 
                   ng-model="controller.filtroUnidade"/>
        </div>
        
        <!-- Filter 2: Município -->
        <div class="col-md-3">
            <input class="form-control" 
                   type="text" 
                   name="municipio" 
                   placeholder="Município" 
                   ng-model="controller.filtroMunicipio"/>
        </div>
    </div>
</div>
```

**Key Elements**:
- Label "Filtros" on the left
- Two text inputs side-by-side
- Bootstrap 3 grid: `col-md-3 col-md-offset-3` + `col-md-3`
- AngularJS bindings for filtering

### Legacy Filter Logic (escolher.html):
```html
<div class="item" ng-repeat="obra in controller.obras | filter:{ 
    descricao: controller.filtroUnidade, 
    cidadeEstado: controller.filtroMunicipio 
}">
```

**How it works**:
- AngularJS `filter` pipe filters array client-side
- Filters by `descricao` (obra name) matching `filtroUnidade` input
- Filters by `cidadeEstado` (municipality) matching `filtroMunicipio` input
- Real-time filtering as user types

### Current Implementation (Escolher.cshtml):
```razor
<div class="container">
    <div class="row justify-content-center">
        <div class="col-12">
            @* NO FILTERS AT ALL *@
            
            @if (Model != null && Model.Any())
            {
                <div class="lista-obras">
                    @* Cards here *@
```

**VERDICT**: Filters are **100% missing**.

### Solution for Issue #4:

**Option A: Client-Side Filtering (JavaScript)**
Add filter inputs + JavaScript to filter cards:
```razor
<div class="container text-center">
    <div class="row">
        <div class="col">
            <label class="control-label filtro">Filtros</label>
        </div>
        <div class="col-md-3 offset-md-3">
            <input class="form-control" 
                   type="text" 
                   id="filtroUnidade"
                   placeholder="Unidade escolar" 
                   autofocus />
        </div>
        <div class="col-md-3">
            <input class="form-control" 
                   type="text" 
                   id="filtroMunicipio"
                   placeholder="Município" />
        </div>
    </div>
</div>

<script>
    // Filter logic here
</script>
```

**Option B: Server-Side Filtering (AJAX)**
Add filter inputs + AJAX call to filter on server:
- More scalable for large datasets
- Requires API endpoint
- More complex implementation

**RECOMMENDATION**: Option A (client-side) for MVP, matches legacy behavior

---

## ISSUE #5: CARDS OVERSIMPLIFIED (OBRA CARDS)

### Current Status:
- Cards show only: Icon + Name + ID
- **MISSING**: Progress bars, status colors, municipality, status text, legend

### Legacy Card Structure (escolher.html):
```html
<div class="item" ng-repeat="obra in controller.obras | filter:...">
    <button class="btn change-background" ng-click="controller.escolherObra(obra)">
        <!-- 1. Dynamic Icon -->
        <i class="icon-{{obra.contratanteContratada}}"></i>
        
        <!-- 2. Obra Name -->
        <H5>{{obra.descricao}}</H5>
        
        <!-- 3. Municipality + State -->
        <p>{{obra.cidadeEstado}}</p>
        
        <!-- 4. Status Text -->
        <p>({{obra.statusBasicaGratuita}})</p>

        <!-- 5. Progress Bar with Status Color -->
        <small>STATUS</small>
        <div class="progress progress-line-info {{ obra.classeStatusCss }}">
            <i class="fa fa-exclamation-triangle ng-hide" ng-hide="true"></i>
            <div class="progress-bar progress-bar-info" 
                 style="width: {{ 100 - obra.progressoPorcentagem }}%;">
                <span class="branco">{{ obra.progressoPorcentagem }}%</span>
            </div>
            <span class="azul">{{ obra.progressoPorcentagem }}%</span>
        </div>
    </button>
</div>
```

**Data Fields Used**:
1. `contratanteContratada` - Icon type (e.g., "contratante", "contratada")
2. `descricao` - Obra name
3. `cidadeEstado` - Municipality + State (e.g., "São Paulo - SP")
4. `statusBasicaGratuita` - Status text (e.g., "Básica", "Gratuita")
5. `progressoPorcentagem` - Progress percentage (0-100)
6. `classeStatusCss` - CSS class for status color:
   - `bg-verde` (green) - Deadline met
   - `bg-vermelho` (red) - Deadline exceeded
   - `bg-cinza` (gray) - In progress

### Legacy Legend (escolher.html):
```html
<div class="col-xs-12 no-padding area-legenda" ng-if="controller.obras.length > 0">
    <label>BARRA DE PROGRESSO DA UNIDADE ESCOLAR:</label>
    
    <div class="legenda">
        <i class="status bg-verde"></i>
        <small>UNIDADE ESCOLAR COM PRAZO ESTIMADO ATINGIDO</small>
    </div>
    
    <div class="legenda">
        <i class="status bg-vermelho"></i>
        <small>UNIDADE ESCOLAR COM PRAZO ESTIMADO ULTRAPASSADO</small>
    </div>
    
    <div class="legenda">
        <i class="status bg-cinza"></i>
        <small>UNIDADE ESCOLAR EM ANDAMENTO</small>
    </div>
</div>
```

### Current Card Structure (Escolher.cshtml):
```razor
<div class="item col-md-6 col-lg-4">
    <form asp-action="Selecionar" asp-controller="Obra" method="post">
        <button type="submit" class="btn">
            <i class="icon-obras"></i>  <!-- ← Static icon -->
            <h5>@obra.NomeObra</h5>     <!-- ← Only name -->
            <p><small>ID: @obra.IdObra</small></p>  <!-- ← ID (not in legacy!) -->
        </button>
    </form>
</div>
```

**VERDICT**: Cards are **severely simplified** - missing 80% of visual information.

### Solution for Issue #5:

**Step 1: Update Controller to Return Additional Fields**
```csharp
public async Task<IActionResult> Escolher()
{
    var obras = await _context.Obras
        .Select(o => new
        {
            IdObra = o.ObrIdObra,
            NomeObra = o.ObrDsObra,
            CidadeEstado = o.ObrDsCidade + " - " + o.ObrDsEstado,  // ← ADD
            StatusBasicaGratuita = "Básica",  // ← ADD (or calculate)
            ContratanteContratada = "contratante",  // ← ADD (or from DB)
            ProgressoPorcentagem = 60,  // ← ADD (calculate from tasks)
            ClasseStatusCss = "bg-cinza"  // ← ADD (calculate from deadline)
        })
        .ToListAsync();
    
    return View(obras);
}
```

**Step 2: Update Card HTML**
```razor
<div class="item">
    <form asp-action="Selecionar" asp-controller="Obra" method="post">
        <button type="submit" class="btn change-background">
            <i class="icon-@obra.ContratanteContratada"></i>
            <h5>@obra.NomeObra</h5>
            <p>@obra.CidadeEstado</p>
            <p>(@obra.StatusBasicaGratuita)</p>
            
            <small>STATUS</small>
            <div class="progress progress-line-info @obra.ClasseStatusCss">
                <div class="progress-bar progress-bar-info" 
                     style="width: @(100 - obra.ProgressoPorcentagem)%;">
                    <span class="branco">@obra.ProgressoPorcentagem%</span>
                </div>
                <span class="azul">@obra.ProgressoPorcentagem%</span>
            </div>
        </button>
    </form>
</div>
```

**Step 3: Add Legend**
```razor
@if (Model != null && Model.Any())
{
    <div class="col-xs-12 no-padding area-legenda">
        <label>BARRA DE PROGRESSO DA UNIDADE ESCOLAR:</label>
        
        <div class="legenda">
            <i class="status bg-verde"></i>
            <small>UNIDADE ESCOLAR COM PRAZO ESTIMADO ATINGIDO</small>
        </div>
        
        <div class="legenda">
            <i class="status bg-vermelho"></i>
            <small>UNIDADE ESCOLAR COM PRAZO ESTIMADO ULTRAPASSADO</small>
        </div>
        
        <div class="legenda">
            <i class="status bg-cinza"></i>
            <small>UNIDADE ESCOLAR EM ANDAMENTO</small>
        </div>
    </div>
}
```

---

## COMPARISON TABLE

| Feature | Legacy | Current | Status |
|---------|--------|---------|--------|
| **HEADER** ||||
| Logo + "Piscinas" | Left side | Left side | ✅ WORKING |
| User dropdown | Right side | Right side | ✅ WORKING |
| Alignment | Horizontal | Horizontal | ✅ FIXED |
| Dashboard button | Visible (if permission) | Not visible | ❌ BROKEN |
| Charts button | Visible (if permission) | Not visible | ❌ BROKEN |
| New Obra button | Visible (if permission) | Not visible | ❌ BROKEN |
| Content padding | 103px top | 0px | ❌ BROKEN |
| **OBRA CARDS** ||||
| Filters | 2 inputs (Unidade + Município) | None | ❌ MISSING |
| Card Icon | Dynamic (`icon-{{type}}`) | Static (`icon-obras`) | ⚠️ SIMPLIFIED |
| Card Name | `descricao` | `NomeObra` | ✅ PRESENT |
| Card Municipality | `cidadeEstado` | None | ❌ MISSING |
| Card Status Text | `statusBasicaGratuita` | None | ❌ MISSING |
| Progress Bar | With percentage + color | None | ❌ MISSING |
| Status Colors | 3 colors (green/red/gray) | None | ❌ MISSING |
| Legend | 3-item legend at bottom | None | ❌ MISSING |
| Grid Layout | Responsive flex grid | Bootstrap grid | ⚠️ DIFFERENT |
| Click Action | AngularJS function | POST form | ⚠️ DIFFERENT |

---

## VISUAL LAYOUT COMPARISON

### Legacy Layout:
```
┌─────────────────────────────────────────────────────────┐
│ HEADER (fixed, 54px height)                             │
│ [Logo] Piscinas          [Dashboard][Charts][+] [User▼] │
└─────────────────────────────────────────────────────────┘
                                                            ← 103px padding-top
┌─────────────────────────────────────────────────────────┐
│                        Filtros                          │
│         [Unidade escolar input] [Município input]       │
└─────────────────────────────────────────────────────────┘

        Selecione uma das unidades escolares abaixo:

┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐
│ [icon]   │ │ [icon]   │ │ [icon]   │ │ [icon]   │
│ Obra 1   │ │ Obra 2   │ │ Obra 3   │ │ Obra 4   │
│ São Paulo│ │ Rio      │ │ Curitiba │ │ Salvador │
│ (Básica) │ │ (Básica) │ │ (Básica) │ │ (Básica) │
│ STATUS   │ │ STATUS   │ │ STATUS   │ │ STATUS   │
│ [▓▓▓░░]  │ │ [▓▓▓▓░]  │ │ [▓▓░░░]  │ │ [▓▓▓▓▓]  │
│ 60%      │ │ 80%      │ │ 40%      │ │ 100%     │
└──────────┘ └──────────┘ └──────────┘ └──────────┘

BARRA DE PROGRESSO DA UNIDADE ESCOLAR:
[■] UNIDADE ESCOLAR COM PRAZO ESTIMADO ATINGIDO
[■] UNIDADE ESCOLAR COM PRAZO ESTIMADO ULTRAPASSADO
[■] UNIDADE ESCOLAR EM ANDAMENTO
```

### Current Layout:
```
┌─────────────────────────────────────────────────────────┐
│ HEADER (fixed, 54px height)                             │
│ [Logo] Piscinas                              [User▼]    │
│                                              (NO BUTTONS)│
└─────────────────────────────────────────────────────────┘
                                                            ← 0px padding (OVERLAP!)
┌──────────┐ ┌──────────┐ ┌──────────┐  ← HIDDEN UNDER HEADER
│ [icon]   │ │ [icon]   │ │ [icon]   │  (NO FILTERS)
│ Obra 1   │ │ Obra 2   │ │ Obra 3   │
│ ID: 1    │ │ ID: 2    │ │ ID: 3    │
└──────────┘ └──────────┘ └──────────┘

(No progress bars, no legend)
```

---

## CONCLUSION

**FIVE CRITICAL ISSUES CONFIRMED**:

### HEADER (3 issues):
1. ❌ **Buttons not appearing** - Missing `/dashboard/index` route in `ObterRotasDefault()`
2. ❌ **Header overlap** - Missing `.conteudo` wrapper div
3. ✅ **Alignment working** - No action needed

### OBRA CARDS (2 issues):
4. ❌ **Filters missing** - Need to add filter section with 2 inputs
5. ❌ **Cards oversimplified** - Need to add progress bars, status colors, municipality, legend

**NEXT STEP**: Create separate implementation plans for:
1. **STRATEGY 1: HEADER** (fix buttons + overlap)
2. **STRATEGY 2: OBRA CARDS** (add filters + enhance cards)

---

**STATUS**: DIAGNOSTIC COMPLETE - AWAITING USER DIRECTION
