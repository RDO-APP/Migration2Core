# Header Technology Translation Guide
**Legacy AngularJS → Modern ASP.NET Core**  
**Date**: February 3, 2026  
**Purpose**: Exact mapping of how each legacy technology translates to modern equivalent

---

## 📊 TECHNOLOGY STACK COMPARISON

| Feature | Legacy (AngularJS) | Modern (ASP.NET Core) | Change Type |
|---------|-------------------|----------------------|-------------|
| **Framework** | AngularJS 1.x | ASP.NET Core 8 Razor | ✅ Complete replacement |
| **UI Library** | Bootstrap 3 | Bootstrap 5 | ⚠️ Upgrade (breaking changes) |
| **Data Binding** | Two-way `{{ }}` | Server-side `@` | ✅ Complete replacement |
| **Events** | `ng-click` | `href` / `onclick` | ✅ Simplified |
| **Conditionals** | `ng-if`, `ng-hide` | `@if`, `style="display:none"` | ✅ Complete replacement |
| **Loops** | `ng-repeat` | `@foreach` | ✅ Complete replacement |
| **Permissions** | Custom directive | Claims-based `@if` | ✅ Complete replacement |
| **Routing** | `$location.path()` | `@Url.Action()` | ✅ Complete replacement |
| **Session** | `Auth.getUser()` | `HttpContext.Session` | ✅ Complete replacement |
| **Icons** | Font Awesome 4 | Font Awesome 5/6 | ⚠️ Upgrade (class names changed) |
| **CSS** | Custom + Bootstrap 3 | Custom + Bootstrap 5 | ⚠️ Partial rewrite needed |
| **JavaScript** | AngularJS controllers | Minimal vanilla JS | ✅ Drastically reduced |

---

## 🔄 DETAILED TRANSLATIONS

### 1. DATA BINDING

#### Legacy (AngularJS):
```html
<p>{{ controller.userData.usuario.nomeUsuario }}</p>
<h2>{{ controller.userData.obraColaborador.nomeObra.toUpperCase() }}</h2>
```

#### Modern (Razor):
```razor
<p>@User.Identity.Name</p>
<h2>@ViewData["ObraName"]?.ToString().ToUpper()</h2>
```

**Key Changes**:
- `{{ }}` → `@`
- `controller.userData` → `@User` or `@ViewData`
- `.toUpperCase()` → `.ToUpper()`
- Server-side rendering (no client-side binding)

---

### 2. CLICK EVENTS

#### Legacy (AngularJS):
```html
<a ng-click="controller.mudarObra()">Logo</a>
<a ng-click="controller.listagemLaudos()">Laudos</a>
<a ng-click="controller.dashboard()">Dashboard</a>
```

#### Modern (Razor):
```razor
<a href="@Url.Action("Escolher", "Obra")">Logo</a>
<a href="@Url.Action("Index", "Laudo")">Laudos</a>
<a href="@Url.Action("Index", "Dashboard")">Dashboard</a>
```

**Key Changes**:
- `ng-click="controller.method()"` → `href="@Url.Action()"`
- No JavaScript functions needed
- Standard HTTP navigation
- Browser back button works automatically

---

### 3. CONDITIONAL VISIBILITY

#### Legacy (AngularJS):
```html
<!-- Hide if flag is true -->
<a ng-hide="controller.desabilitarBotaoLogomarca">Button</a>

<!-- Show if permission exists -->
<a permission="acessarDashboard" permission-route="/dashboard/index">Dashboard</a>
```

#### Modern (Razor):
```razor
<!-- Hide if no obra selected -->
@if (ViewData["HasObra"] as bool? ?? false)
{
    <a href="@Url.Action("Index", "Laudo")">Button</a>
}

<!-- Show if permission exists -->
@if (User.HasClaim("Permission", "acessarDashboard"))
{
    <a href="@Url.Action("Index", "Dashboard")">Dashboard</a>
}
```

**Key Changes**:
- `ng-hide` → `@if` with inverted logic
- Custom `permission` directive → `User.HasClaim()`
- Server-side evaluation (more secure)
- No client-side permission checks

---

### 4. LOOPS

#### Legacy (AngularJS):
```html
<li ng-repeat="pagina in controller.userData.menu.listaPagina">
    <a ng-click="controller.goto(pagina)">
        <i class="{{pagina.CssClass}}"></i>
        <span>{{pagina.titulo}}</span>
    </a>
</li>
```

#### Modern (Razor):
```razor
@foreach (var pagina in Model.MenuItems)
{
    <li>
        <a href="@Url.Action(pagina.Action, pagina.Controller)">
            <i class="@pagina.CssClass"></i>
            <span>@pagina.Titulo</span>
        </a>
    </li>
}
```

**Key Changes**:
- `ng-repeat` → `@foreach`
- `controller.userData.menu.listaPagina` → `Model.MenuItems`
- `{{variable}}` → `@variable`
- Server-side loop (rendered once)

---

### 5. USER DROPDOWN

#### Legacy (AngularJS):
```html
<a class="dropdown-toggle pointer" data-toggle="dropdown">
    <span class="image">
        <img src="Assets/images/user.png" alt="">
    </span>
    <p>{{ controller.userData.usuario.nomeUsuario }}</p>
    <i class="caret"></i>
</a>
<ul class="dropdown-menu">
    <li><a ng-click="controller.mudarSenha()">TROCAR SENHA</a></li>
    <li><a href="sair">SAIR</a></li>
</ul>
```

#### Modern (Razor):
```razor
<a href="#" class="dropdown-toggle pointer" data-toggle="dropdown">
    <span class="image">
        <img src="~/images/user.png" alt="User Avatar">
    </span>
    <p>@User.Identity.Name</p>
    <i class="caret"></i>
</a>
<ul class="dropdown-menu">
    <li><a href="@Url.Action("ChangePassword", "Account")">TROCAR SENHA</a></li>
    <li>
        <form asp-action="Logout" asp-controller="Account" method="post">
            @Html.AntiForgeryToken()
            <button type="submit">SAIR</button>
        </form>
    </li>
</ul>
```

**Key Changes**:
- `{{ controller.userData.usuario.nomeUsuario }}` → `@User.Identity.Name`
- `Assets/images/` → `~/images/`
- `ng-click="controller.mudarSenha()"` → `href="@Url.Action()"`
- Logout: `href="sair"` → POST form with antiforgery token
- Bootstrap dropdown still works (same HTML structure)

---

### 6. SESSION/STATE MANAGEMENT

#### Legacy (AngularJS):
```javascript
// In controller
var user = Auth.getUser();
var obraId = user.obra.idObra;
var userName = user.usuario.nomeUsuario;

// Update user
Auth.updateUser(data);
```

#### Modern (C#):
```csharp
// In controller
var userName = User.Identity.Name;
var obraId = HttpContext.Session.GetInt32("ObraId");

// Store in session
HttpContext.Session.SetInt32("ObraId", selectedObraId);
HttpContext.Session.SetString("ObraName", obraName);

// Pass to view
ViewData["ObraName"] = obraName;
ViewData["HasObra"] = obraId.HasValue;
```

**Key Changes**:
- `Auth.getUser()` → `User.Identity` + `HttpContext.Session`
- Client-side state → Server-side session
- `Auth.updateUser()` → `Session.Set*()`
- More secure (server-side only)

---

### 7. PERMISSIONS/RBAC

#### Legacy (AngularJS):
```html
<!-- Custom directive -->
<a permission="acessarDashboard" permission-route="/dashboard/index">
    Dashboard
</a>

<!-- In JavaScript -->
if (data.routes.find(r => r.path == '/tarefa/index')) {
    // User has permission
}
```

#### Modern (Razor + C#):
```razor
<!-- Claims-based -->
@if (User.HasClaim("Permission", "acessarDashboard"))
{
    <a href="@Url.Action("Index", "Dashboard")">Dashboard</a>
}
```

```csharp
// In controller - Add claims during login
var claims = new List<Claim>
{
    new Claim(ClaimTypes.NameIdentifier, colaboradorId.ToString()),
    new Claim(ClaimTypes.Name, colaboradorName),
    new Claim("Permission", "acessarDashboard"),
    new Claim("Permission", "visualizar")
};
```

**Key Changes**:
- Custom directive → Built-in Claims system
- Client-side check → Server-side check
- `permission="..."` → `User.HasClaim("Permission", "...")`
- More secure (can't be bypassed)

---

### 8. ROUTING/NAVIGATION

#### Legacy (AngularJS):
```javascript
// In controller
this.escolherObra = function(obra) {
    $location.path('/tarefa/cards');
}

this.dashboard = function() {
    $location.path('/dashboard/index');
}
```

#### Modern (Razor + C#):
```razor
<!-- In view -->
<a href="@Url.Action("Cards", "Tarefa")">Tarefas</a>
<a href="@Url.Action("Index", "Dashboard")">Dashboard</a>
```

```csharp
// In controller
return RedirectToAction("Cards", "Tarefa");
return RedirectToAction("Index", "Dashboard");
```

**Key Changes**:
- `$location.path()` → `@Url.Action()` or `RedirectToAction()`
- Client-side routing → Server-side routing
- Hash-based URLs → Clean URLs
- No SPA routing needed

---

### 9. BOOTSTRAP CHANGES (3 → 5)

#### Legacy (Bootstrap 3):
```html
<div class="col-xs-12 col-md-6">Content</div>
<button class="btn btn-default">Button</button>
<div class="navbar-right">Menu</div>
```

#### Modern (Bootstrap 5):
```html
<div class="col-12 col-md-6">Content</div>
<button class="btn btn-secondary">Button</button>
<div class="ms-auto">Menu</div>
```

**Key Changes**:
- `col-xs-*` → `col-*` (xs is default)
- `btn-default` → `btn-secondary`
- `navbar-right` → `ms-auto` (margin-start: auto)
- `pull-right` → `float-end`
- `pull-left` → `float-start`
- jQuery not required (uses vanilla JS)

---

### 10. MOBILE MENU

#### Legacy (AngularJS):
```html
<input id="menu-toggle" type="checkbox">
<label for="menu-toggle" class="menu-button">
    <svg class="icon-open">...</svg>
    <svg class="icon-close">...</svg>
</label>

<div class="menu-sidebar">
    <!-- Menu content -->
</div>
```

#### Modern (Same HTML, Different CSS):
```html
<!-- EXACT SAME HTML STRUCTURE -->
<input id="menu-toggle" type="checkbox">
<label for="menu-toggle" class="menu-button">
    <svg class="icon-open">...</svg>
    <svg class="icon-close">...</svg>
</label>

<div class="menu-sidebar">
    <!-- Menu content -->
</div>
```

**Key Changes**:
- HTML structure: **NO CHANGE** (pure CSS solution)
- CSS: Update for Bootstrap 5 compatibility
- JavaScript: **NOT NEEDED** (checkbox toggle)
- Works without AngularJS

---

## 🎨 CSS CHANGES

### Font Awesome Icons

#### Legacy (Font Awesome 4):
```html
<i class="fa fa-folder"></i>
<i class="fa fa-th"></i>
<i class="fa fa-bar-chart"></i>
<i class="fa fa-plus"></i>
```

#### Modern (Font Awesome 5/6):
```html
<!-- Option 1: Keep FA 4 classes (use FA 5 compatibility mode) -->
<i class="fa fa-folder"></i>
<i class="fa fa-th"></i>
<i class="fa fa-chart-bar"></i>  <!-- Changed -->
<i class="fa fa-plus"></i>

<!-- Option 2: Use FA 5/6 classes -->
<i class="fas fa-folder"></i>
<i class="fas fa-th"></i>
<i class="fas fa-chart-bar"></i>
<i class="fas fa-plus"></i>
```

**Key Changes**:
- `fa-bar-chart` → `fa-chart-bar` (name changed)
- Add `fas` prefix for solid icons (FA 5+)
- Or use FA 4 shim for compatibility

---

### Custom Icons

#### Legacy & Modern (NO CHANGE):
```html
<i class="icon-logo"></i>
<i class="icon-dashboard"></i>
<i class="icon-rdo-novo_2"></i>
<i class="icon-contratante"></i>
<i class="icon-contratada"></i>
```

**Key Changes**:
- **NONE** - Custom icon fonts work the same
- Just copy the font files
- CSS classes remain identical

---

## 📦 DEPENDENCIES

### Legacy Dependencies:
```html
<!-- AngularJS -->
<script src="angular.min.js"></script>
<script src="angular-route.min.js"></script>

<!-- Bootstrap 3 -->
<link href="bootstrap-3.css" rel="stylesheet">
<script src="bootstrap-3.js"></script>

<!-- jQuery (required for Bootstrap 3) -->
<script src="jquery.min.js"></script>

<!-- Font Awesome 4 -->
<link href="font-awesome-4.css" rel="stylesheet">
```

### Modern Dependencies:
```html
<!-- Bootstrap 5 -->
<link href="bootstrap-5.css" rel="stylesheet">
<script src="bootstrap.bundle.min.js"></script>

<!-- Font Awesome 5/6 -->
<link href="font-awesome-6.css" rel="stylesheet">

<!-- NO AngularJS -->
<!-- NO jQuery (Bootstrap 5 doesn't need it) -->
<!-- NO routing library -->
```

**Key Changes**:
- ❌ Remove: AngularJS, jQuery, angular-route
- ⚠️ Upgrade: Bootstrap 3 → 5, Font Awesome 4 → 6
- ✅ Keep: Custom fonts, custom CSS

---

## 🔧 IMPLEMENTATION STRATEGY

### Phase 1-2: HTML Structure
- Copy HTML structure from legacy
- Replace AngularJS directives with Razor syntax
- Keep CSS classes identical
- **NO JavaScript needed yet**

### Phase 3-4: Functionality
- Replace `ng-click` with `href`
- Replace `{{ }}` with `@`
- Add server-side data passing
- **Minimal JavaScript (only for mobile menu)**

### Phase 5: Visibility Logic
- Replace `ng-hide` with `@if`
- Replace custom directives with Claims
- Add session checks
- **All server-side, no client-side logic**

### Phase 6: Polish
- Update Bootstrap 3 → 5 classes
- Update Font Awesome 4 → 6 classes
- Test responsive behavior
- **Final CSS adjustments**

---

## ⚠️ BREAKING CHANGES TO WATCH

### 1. Bootstrap 3 → 5
- Grid classes changed (`col-xs-*` removed)
- Button classes changed (`btn-default` removed)
- Utility classes changed (`pull-*` → `float-*`)
- Dropdown HTML structure slightly different

### 2. Font Awesome 4 → 6
- Some icon names changed
- Prefix required (`fas`, `far`, `fab`)
- CSS class structure different

### 3. AngularJS → Razor
- No two-way binding (server-side only)
- No client-side routing (full page loads)
- No client-side state management
- Forms require antiforgery tokens

---

## ✅ WHAT STAYS THE SAME

1. **HTML Structure**: 90% identical
2. **CSS Classes**: Most custom classes unchanged
3. **Custom Icons**: Exact same font files
4. **Visual Design**: Pixel-perfect match possible
5. **User Experience**: Same clicks, same navigation
6. **Mobile Menu**: Same checkbox technique

---

## 🎯 SUMMARY

| Aspect | Change Level | Effort |
|--------|-------------|--------|
| **HTML Structure** | Low (10%) | 1-2 hours |
| **CSS** | Medium (30%) | 3-4 hours |
| **JavaScript** | High (90% removal) | 2-3 hours |
| **Data Binding** | Complete replacement | 4-5 hours |
| **Routing** | Complete replacement | 2-3 hours |
| **Permissions** | Complete replacement | 3-4 hours |
| **Session** | Complete replacement | 2-3 hours |

**Total Effort**: 17-24 hours (matches plan estimate)

---

**Key Takeaway**: We're not "translating" AngularJS to Razor. We're **recreating the same UI** using modern server-side rendering. The visual result is identical, but the underlying technology is completely different.

