# ESCOLHER OBRA HEADER - CORRECTED TECHNICAL AUDIT

**Date**: January 27, 2026  
**Status**: 🔍 **CORRECTED ANALYSIS - NO CODE YET**  
**Critical Error Fixed**: I was analyzing the wrong context!

---

## ❌ MY MISTAKE

I analyzed the **FULL APPLICATION HEADER** (with all 6 navigation buttons) instead of the **ESCOLHER OBRA HEADER** (simplified version).

---

## ✅ CORRECT ANALYSIS - ESCOLHER OBRA HEADER

### Context Understanding

**Page Flow**:
1. User logs in → `LoginController.LoginUser()` → Returns user data
2. User redirected to `/obra/escolher` → **THIS IS WHERE WE ARE**
3. User selects obra → Redirected to main application

**Key State**:
- ✅ User IS authenticated (`Auth.isLoggedIn() = true`)
- ❌ NO obra selected yet (`obraColaborador = null`)
- ❌ Most navigation buttons HIDDEN (`desabilitarBotaoLogomarca = true`)

### Layout Structure

**File**: `Client/Views/Layout/layout-interno-azul.html`

```html
<div class="tema-azul base">
    <div ng-include="'client/nav.html'" class="topo"></div>
    <div class="conteudo" ui-view></div>
    <footer class="footer">...</footer>
</div>
```

**Routing** (from app.js line 854):
```javascript
$stateProvider.state({
    name: 'layoutinternoazul.obraescolher',
    url: '/obra/escolher',
    templateUrl: 'Client/Views/Obra/escolher.html',
});
```


### Header Elements (ESCOLHER CONTEXT)

The header uses the SAME `nav.html` file, but with different visibility:

#### 1. **Logo/Brand** (Left Side) - ✅ VISIBLE
```html
<a class="navbar-brand logo pointer" ng-click="controller.mudarObra()">
    <i class="icon-logo"></i>
    <span>Piscinas</span>
</a>
```
- **Action**: Click redirects to `/obra/escolher` (refresh page)
- **Always visible** on Escolher page

#### 2. **Obra Name** (Center) - ❌ HIDDEN
```html
<h2 id="tituloObra">{{ controller.userData.obraColaborador.nomeObra.toUpperCase() }}</h2>
```
- **Hidden** because `obraColaborador = null`
- Will only show AFTER obra selection

#### 3. **User Dropdown** (Right Side) - ✅ VISIBLE
```html
<li>
    <a class="dropdown-toggle pointer" data-toggle="dropdown">
        <span class="image">
            <img src="Assets/images/user.png" alt="">
        </span>
        <p>{{ controller.userData.usuario.nomeUsuario }}</p>
        <i class="caret"></i>
    </a>
    <ul class="dropdown-menu">
        <li><a class="pointer" ng-click="controller.mudarSenha()">TROCAR SENHA</a></li>
        <li><a href="sair">SAIR</a></li>
    </ul>
</li>
```
- **User Name**: Shows authenticated user (e.g., "Ricardo Freire")
- **Dropdown Items**:
  - "TROCAR SENHA" → `/colaborador/alterarsenha`
  - "SAIR" → `/sair` (logout)


#### 4. **Navigation Buttons** (Right Side) - ❌ MOSTLY HIDDEN

**From NavController.js**:
```javascript
controller.desabilitarBotaoLogomarca = Auth.getUser().obraColaborador == null;
```

**Button Visibility on Escolher Page**:

```html
<!-- HIDDEN (ng-hide="controller.desabilitarBotaoLogomarca") -->
<li ng-hide="controller.desabilitarBotaoLogomarca">
    <a ng-click="controller.listagemLaudos()">
        <i class="fa fa-folder"></i> <!-- Laudos -->
    </a>
</li>

<!-- HIDDEN (ng-hide="controller.desabilitarBotaoLogomarca") -->
<li ng-hide="controller.desabilitarBotaoLogomarca">
    <a ng-click="controller.listagemRdos()">
        <i class="icon-rdo-novo_2"></i> <!-- RDOs -->
    </a>
</li>

<!-- HIDDEN (ng-hide="controller.desabilitarBotaoLogomarca") -->
<li ng-hide="controller.desabilitarBotaoLogomarca">
    <a ng-click="controller.tarefaCards()">
        <i class="fa fa-th"></i> <!-- Tarefas -->
    </a>
</li>

<!-- VISIBLE (if user has permission) -->
<li permission="acessarDashboard" permission-route="/dashboard/index">
    <a ng-click="controller.dashboard()">
        <i class="icon-dashboard"></i> <!-- Dashboard Obra -->
    </a>
</li>

<!-- VISIBLE (if user has permission) -->
<li permission="visualizar" permission-route="/chart">
    <a ng-click="controller.redirectCharts()">
        <i class="fa fa-bar-chart"></i> <!-- Dashboard Geral -->
    </a>
</li>

<!-- VISIBLE (if user has permission) -->
<li permission="visualizar" permission-route="/obra/cadastro">
    <a ng-click="controller.novaObra()">
        <i class="fa fa-plus"></i> <!-- Nova Obra -->
    </a>
</li>
```

**Summary**:
- ❌ **3 buttons HIDDEN**: Laudos, RDOs, Tarefas (require obra selection)
- ✅ **3 buttons MAY BE VISIBLE**: Dashboard Obra, Dashboard Geral, Nova Obra (RBAC protected)


#### 5. **Mobile Menu** - ✅ VISIBLE (Same as Desktop)

Same hamburger menu with same visibility rules.

---

## 🎯 ESCOLHER OBRA HEADER - VISUAL SUMMARY

**What User Sees on Escolher Page**:

```
┌─────────────────────────────────────────────────────────────┐
│  [🏊 Piscinas]                    [👤 Ricardo Freire ▼]    │
│                                    ├─ TROCAR SENHA          │
│                                    └─ SAIR                  │
└─────────────────────────────────────────────────────────────┘
```

**Minimal Header**:
- Logo (left)
- User dropdown (right)
- NO obra name (center is empty)
- NO navigation buttons (or only RBAC-protected ones if user is admin)

---

## 📋 IMPLEMENTATION PLAN FOR CLEAN MIGRATION

### Phase 1: Create Simplified Header Partial

**File**: `Views/Shared/_HeaderEscolher.cshtml`

```html
<div class="topo">
    <nav class="navbar bg-blue-default">
        <div class="no-padding">
            <!-- Logo -->
            <a class="navbar-brand logo pointer" href="/Obra/Escolher">
                <i class="icon-logo"></i>
                <span>Piscinas</span>
            </a>
        </div>
        
        <div class="no-padding">
            <div class="collapse navbar-collapse menu">
                <!-- User Dropdown ONLY -->
                <ul class="nav navbar-nav navbar-right user">
                    <li>
                        <a class="dropdown-toggle pointer" data-toggle="dropdown">
                            <span class="image">
                                <img src="~/images/user.png" alt="">
                            </span>
                            <p>@User.Identity.Name</p>
                            <i class="caret"></i>
                        </a>
                        <ul class="dropdown-menu">
                            <li><a href="/Account/ChangePassword">TROCAR SENHA</a></li>
                            <li><a href="/Account/Logout">SAIR</a></li>
                        </ul>
                    </li>
                </ul>
                
                <!-- Optional: RBAC-protected admin buttons -->
                @if (User.HasClaim("Permission", "visualizar"))
                {
                    <ul class="nav navbar-nav navbar-right ball-hover">
                        <li class="btn-tooltip pointer" title="NOVA UNIDADE ESCOLAR">
                            <a href="/Obra/Cadastro"><i class="fa fa-plus"></i></a>
                        </li>
                    </ul>
                }
            </div>
        </div>
    </nav>
</div>
```


### Phase 2: Create Layout for Escolher Page

**File**: `Views/Shared/_LayoutEscolher.cshtml`

```html
<!DOCTYPE html>
<html>
<head>
    <title>Escolher Unidade Escolar - RDO Piscinas</title>
    <link rel="stylesheet" href="~/css/bootstrap.min.css" />
    <link rel="stylesheet" href="~/css/fontello.css" />
    <link rel="stylesheet" href="~/css/custom.css" />
</head>
<body class="tema-azul base">
    @await Html.PartialAsync("_HeaderEscolher")
    
    <main class="conteudo">
        @RenderBody()
    </main>
    
    <footer class="footer">
        <div class="container">
            <p>RDO App Piscinas © 2025. Todos os direitos reservados.</p>
        </div>
    </footer>
    
    <script src="~/js/bootstrap.bundle.min.js"></script>
</body>
</html>
```

### Phase 3: Update Escolher.cshtml

**File**: `Views/Obra/Escolher.cshtml`

```csharp
@{
    Layout = "_LayoutEscolher";
    ViewData["Title"] = "Escolher Unidade Escolar";
}

<!-- Obra cards content here -->
```

---

## 🔑 KEY DIFFERENCES FROM MY PREVIOUS (WRONG) AUDIT

| Aspect | WRONG Audit | CORRECT Audit |
|--------|-------------|---------------|
| **Context** | Full application (obra selected) | Escolher page (no obra yet) |
| **Obra Name** | Visible in center | HIDDEN (no obra selected) |
| **Nav Buttons** | All 6 buttons visible | Only 0-3 buttons (RBAC only) |
| **Button Visibility** | Based on RBAC only | Based on `desabilitarBotaoLogomarca` + RBAC |
| **Layout File** | Generic `_Layout.cshtml` | Specific `_LayoutEscolher.cshtml` |

---

## ✅ CORRECT IMPLEMENTATION CHECKLIST

**Before Implementation**:
- [ ] Understand this is a SIMPLIFIED header (not full app header)
- [ ] Recognize most nav buttons are HIDDEN on this page
- [ ] Know that obra name is NOT displayed yet

**During Implementation**:
- [ ] Create `_HeaderEscolher.cshtml` (simplified header)
- [ ] Create `_LayoutEscolher.cshtml` (blue background layout)
- [ ] Update `Escolher.cshtml` to use new layout
- [ ] Copy icon fonts and user.png
- [ ] Extract minimal CSS (logo, user dropdown, blue background)

**After Implementation**:
- [ ] Verify logo displays and is clickable
- [ ] Verify user name shows from authentication
- [ ] Verify NO obra name in center
- [ ] Verify NO navigation buttons (except maybe admin buttons)
- [ ] Verify user dropdown works (Change Password, Logout)
- [ ] Test with CPF: 567.065.455-20, Password: 1234

---

## 🎯 SUCCESS CRITERIA

✅ **Minimal Header Displays**:
- Logo visible (left)
- User name visible (right)
- NO obra name (center empty)
- NO or minimal navigation buttons

✅ **Functionality Works**:
- Logo click → Refreshes Escolher page
- Logout → Clears session, redirects to login
- User dropdown opens/closes

✅ **Visual Match**:
- Blue background (`tema-azul`)
- Same logo and styling as legacy
- Clean, uncluttered header

---

**END OF CORRECTED AUDIT - READY FOR YOUR APPROVAL**
