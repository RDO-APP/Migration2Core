# ANÁLISE CÓDIGO GILBERTO - PÁGINA OBRAS/ESCOLHER

## Status: 📋 ANÁLISE COMPLETA - RECOMENDAÇÕES PRONTAS

**Data**: 28 Dec 2025  
**Objetivo**: Analisar código original do Gilberto para implementar funcionalidades faltantes na versão .NET 8

---

## 🔍 ANÁLISE DETALHADA DO CÓDIGO ORIGINAL

### 1. **ESTRUTURA FRONTEND - ANGULARJS**
- **Framework**: AngularJS 1.x com UI-Router
- **Arquitetura**: SPA (Single Page Application)
- **Padrão**: MVC com Controllers, Views e Services
- **Navegação**: Client-side routing com `$location.path()`

### 2. **PÁGINA ESCOLHER OBRAS - FUNCIONALIDADES IDENTIFICADAS**

#### A. **FILTROS FUNCIONAIS** ✅
```html
<!-- Filtros que funcionam no código original -->
<input class="form-control" type="text" name="unidade_escolar" 
       placeholder="Unidade escolar" ng-model="controller.filtroUnidade"/>
<input class="form-control" type="text" name="municipio" 
       placeholder="Município" ng-model="controller.filtroMunicipio"/>

<!-- Filtro aplicado na listagem -->
<div class="item" ng-repeat="obra in controller.obras | 
     filter:{ descricao: controller.filtroUnidade, cidadeEstado: controller.filtroMunicipio }">
```

#### B. **FUNÇÃO ESCOLHER OBRA** ✅
```javascript
this.escolherObra = function (obra) {
    var objLogin = { 
        idUsuario: Auth.getUser().usuario.id, 
        idObra: obra.idObra, 
        obra: obra, 
        user: Auth.getUser() 
    }

    $http({
        url: "api/login/LoginObra",
        method: "POST",
        data: objLogin
    }).success(function (data) {
        var found = false;
        for (var i in data.routes) {
            if (data.routes[i].path == '/tarefa/index') {
                found = true;
            }
        }
        if (found) {
            Auth.updateUser(data);
            $location.path('/tarefa/cards');  // ← NAVEGAÇÃO PARA TAREFAS
        }
        else {
            toastr.error('Seu usuário não tem permissão. Favor contate o administrador.');
        }
    });
}
```

#### C. **NAVEGAÇÃO TOP BAR** ✅
```javascript
// NavController.js - Funções dos botões superiores
this.dashboard = function () {
    $location.path('/dashboard/index');
}

this.novaObra = function () {
    ViewBag.set('obraId', 0);
    ViewBag.set('novaObra', true);
    $location.path('/obra/cadastro');
}

this.mudarObra = function () {
    Auth.updateUser(Auth.getLoginUser());
    $location.path('/obra/escolher');  // ← VOLTA PARA ESCOLHER OBRAS
}

this.tarefaCards = function () {
    $location.path('/tarefa/cards');
}
```

#### D. **BOTÃO USUÁRIO (Ricardo Freire)** ✅
```html
<!-- nav.html - Menu do usuário -->
<li>
    <a class="dropdown-toggle pointer" data-toggle="dropdown">
        <span class="image">
            <img src="Assets/images/user.png" alt="">
        </span>
        <p>{{ controller.userData.usuario.nomeUsuario }}</p>  <!-- ← NOME DINÂMICO -->
        <i class="caret"></i>
    </a>
    <ul class="dropdown-menu">
        <li><a class="pointer" ng-click="controller.mudarSenha()">TROCAR SENHA</a></li>
        <li><a href="sair">SAIR</a></li>
    </ul>
</li>
```

---

## 🚨 PROBLEMAS IDENTIFICADOS NA VERSÃO .NET 8

### 1. **FILTROS NÃO FUNCIONAM**
- **Problema**: Não há JavaScript para filtrar a lista de obras
- **Causa**: Falta implementação de filtros client-side ou server-side

### 2. **BOTÃO DASHBOARD NÃO FUNCIONA**
- **Problema**: Não há rota `/Dashboard/Index` implementada
- **Causa**: Controller e View de Dashboard não existem

### 3. **BOTÃO NOVA OBRA NÃO FUNCIONA**
- **Problema**: Não há rota `/Obra/Cadastro` implementada
- **Causa**: Action `Cadastro` não existe no `ObraController`

### 4. **BOTÃO USUÁRIO NÃO FUNCIONA**
- **Problema**: Nome estático "Ricardo Freire" em vez de dinâmico
- **Causa**: Não há integração com dados do usuário logado

### 5. **NAVEGAÇÃO APÓS ESCOLHER OBRA**
- **Problema**: Não há redirecionamento para `/Obra/Etapas`
- **Causa**: Função `EscolherObra` não implementada corretamente

---

## 📋 RECOMENDAÇÕES DE IMPLEMENTAÇÃO

### **PRIORIDADE 1: FUNCIONALIDADES CRÍTICAS**

#### 1. **IMPLEMENTAR FILTROS FUNCIONAIS**
```csharp
// ObraController.cs - Action Escolher
public async Task<IActionResult> Escolher(string filtroUnidade = "", string filtroMunicipio = "")
{
    var obras = await _obraService.GetObrasUsuarioAsync(GetCurrentUserId());
    
    if (!string.IsNullOrEmpty(filtroUnidade))
        obras = obras.Where(o => o.Descricao.Contains(filtroUnidade, StringComparison.OrdinalIgnoreCase));
        
    if (!string.IsNullOrEmpty(filtroMunicipio))
        obras = obras.Where(o => o.CidadeEstado.Contains(filtroMunicipio, StringComparison.OrdinalIgnoreCase));
    
    return View(obras);
}
```

#### 2. **IMPLEMENTAR ESCOLHER OBRA COM REDIRECIONAMENTO**
```csharp
// ObraController.cs
[HttpPost]
public async Task<IActionResult> EscolherObra(int obraId)
{
    var obra = await _obraService.GetObraAsync(obraId);
    if (obra == null) return NotFound();
    
    // Salvar obra selecionada na sessão/claims
    HttpContext.Session.SetInt32("ObraId", obraId);
    HttpContext.Session.SetString("ObraNome", obra.Descricao);
    
    return RedirectToAction("Etapas", new { obraId });
}
```

#### 3. **IMPLEMENTAR DASHBOARD**
```csharp
// DashboardController.cs (CRIAR)
public class DashboardController : Controller
{
    public async Task<IActionResult> Index()
    {
        var obraId = HttpContext.Session.GetInt32("ObraId");
        if (!obraId.HasValue) return RedirectToAction("Escolher", "Obra");
        
        var dashboardData = await _dashboardService.GetDashboardDataAsync(obraId.Value);
        return View(dashboardData);
    }
}
```

#### 4. **IMPLEMENTAR NOVA OBRA**
```csharp
// ObraController.cs
public IActionResult Cadastro(int? id = null)
{
    if (id.HasValue)
    {
        // Edição
        var obra = await _obraService.GetObraAsync(id.Value);
        return View(obra);
    }
    
    // Nova obra
    return View(new ObraDto());
}

[HttpPost]
public async Task<IActionResult> Cadastro(ObraDto dto)
{
    if (!ModelState.IsValid) return View(dto);
    
    var result = await _obraService.SalvarObraAsync(dto);
    if (result.Success)
    {
        return RedirectToAction("EscolherObra", new { obraId = result.ObraId });
    }
    
    return View(dto);
}
```

### **PRIORIDADE 2: MELHORIAS DE UX**

#### 5. **IMPLEMENTAR USUÁRIO DINÂMICO**
```csharp
// _Layout.cshtml ou componente de navegação
<li class="dropdown">
    <a href="#" class="dropdown-toggle" data-toggle="dropdown">
        <span class="image">
            <img src="~/images/user.png" alt="">
        </span>
        <p>@User.Identity.Name</p>  <!-- ← NOME DINÂMICO -->
        <i class="caret"></i>
    </a>
    <ul class="dropdown-menu">
        <li><a asp-action="AlterarSenha" asp-controller="Usuario">TROCAR SENHA</a></li>
        <li><a asp-action="Logout" asp-controller="Auth">SAIR</a></li>
    </ul>
</li>
```

#### 6. **IMPLEMENTAR FILTROS CLIENT-SIDE (JAVASCRIPT)**
```javascript
// Escolher.cshtml - JavaScript para filtros
function filtrarObras() {
    const filtroUnidade = document.getElementById('filtroUnidade').value.toLowerCase();
    const filtroMunicipio = document.getElementById('filtroMunicipio').value.toLowerCase();
    
    const cards = document.querySelectorAll('.lista-obras .item');
    
    cards.forEach(card => {
        const titulo = card.querySelector('h5').textContent.toLowerCase();
        const cidade = card.querySelector('p').textContent.toLowerCase();
        
        const matchUnidade = !filtroUnidade || titulo.includes(filtroUnidade);
        const matchMunicipio = !filtroMunicipio || cidade.includes(filtroMunicipio);
        
        card.style.display = (matchUnidade && matchMunicipio) ? 'block' : 'none';
    });
}

// Aplicar filtros em tempo real
document.getElementById('filtroUnidade').addEventListener('input', filtrarObras);
document.getElementById('filtroMunicipio').addEventListener('input', filtrarObras);
```

### **PRIORIDADE 3: NAVEGAÇÃO COMPLETA**

#### 7. **IMPLEMENTAR TODAS AS ROTAS NECESSÁRIAS**
```csharp
// Program.cs ou Startup.cs - Rotas
app.MapControllerRoute(
    name: "dashboard",
    pattern: "Dashboard/{action=Index}",
    defaults: new { controller = "Dashboard" });

app.MapControllerRoute(
    name: "obra-cadastro",
    pattern: "Obra/Cadastro/{id?}",
    defaults: new { controller = "Obra", action = "Cadastro" });

app.MapControllerRoute(
    name: "obra-escolher",
    pattern: "Obra/Escolher",
    defaults: new { controller = "Obra", action = "Escolher" });
```

---

## 🎯 ESTRATÉGIA DE IMPLEMENTAÇÃO

### **FASE 1: FUNCIONALIDADES BÁSICAS (1-2 horas)**
1. ✅ Implementar filtros JavaScript client-side
2. ✅ Implementar função EscolherObra com redirecionamento
3. ✅ Implementar usuário dinâmico na navegação

### **FASE 2: CONTROLLERS E VIEWS (2-3 horas)**
1. ✅ Criar DashboardController e View
2. ✅ Implementar Obra/Cadastro (nova obra)
3. ✅ Implementar navegação completa entre páginas

### **FASE 3: REFINAMENTOS (1 hora)**
1. ✅ Melhorar UX dos filtros
2. ✅ Implementar feedback visual
3. ✅ Testes de integração

---

## 🔧 ARQUIVOS QUE PRECISAM SER MODIFICADOS/CRIADOS

### **MODIFICAR:**
1. `RDO-NET8-Migration/RdoApp.Core/Views/Obra/Escolher.cshtml` - Adicionar filtros funcionais
2. `RDO-NET8-Migration/RdoApp.Core/Controllers/ObraController.cs` - Implementar actions
3. `RDO-NET8-Migration/RdoApp.Core/Views/Shared/_Layout.cshtml` - Usuário dinâmico

### **CRIAR:**
1. `RDO-NET8-Migration/RdoApp.Core/Controllers/DashboardController.cs`
2. `RDO-NET8-Migration/RdoApp.Core/Views/Dashboard/Index.cshtml`
3. `RDO-NET8-Migration/RdoApp.Core/Views/Obra/Cadastro.cshtml`
4. `RDO-NET8-Migration/RdoApp.Core/Services/IDashboardService.cs`

---

## ✅ CONCLUSÃO

O código do Gilberto usa **AngularJS com client-side routing** enquanto nossa versão .NET 8 usa **server-side MVC**. As funcionalidades não funcionam porque:

1. **Filtros**: Precisam de JavaScript ou server-side filtering
2. **Navegação**: Precisa de Controllers e Actions correspondentes  
3. **Estado**: Precisa de sessão/claims para manter obra selecionada
4. **Usuário**: Precisa integrar com sistema de autenticação .NET

**PRÓXIMO PASSO**: Implementar as recomendações em ordem de prioridade, começando pelos filtros e navegação básica.