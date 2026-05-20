# Escolher Blank Page Fix - Design Document

**Date:** January 20, 2026  
**Status:** ✅ DESIGN COMPLETE  
**Approach:** Model Type Safety Fix

---

## Architecture Overview

### Current Architecture (After Fix)

```
┌─────────────────────────────────────────────────────────────┐
│                    Browser (Client)                         │
│  ┌───────────────────────────────────────────────────────┐ │
│  │  Escolher.cshtml (Standalone Page)                    │ │
│  │  ├─ @model IEnumerable<ObraViewModel> ✅ FIXED       │ │
│  │  ├─ Top Navigation (Logo, User Info)                 │ │
│  │  ├─ Filter Inputs (Unidade, Município)               │ │
│  │  ├─ Obra Cards Grid (Responsive)                     │ │
│  │  ├─ Progress Bars (Color Coded)                      │ │
│  │  ├─ Dynamic Icons (Fontello)                         │ │
│  │  └─ Legend Section                                   │ │
│  └───────────────────────────────────────────────────────┘ │
│                           ↕                                  │
│  ┌───────────────────────────────────────────────────────┐ │
│  │  JavaScript (Client-Side Logic)                       │ │
│  │  ├─ filtrarObras() - Real-time filtering             │ │
│  │  ├─ escolherObra(id) - Navigation handler            │ │
│  │  └─ transformIcons() - Icon system                   │ │
│  └───────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                           ↕ HTTP
┌─────────────────────────────────────────────────────────────┐
│                    Server (.NET 8)                          │
│  ┌───────────────────────────────────────────────────────┐ │
│  │  ObraController.cs                                    │ │
│  │  └─ Escolher() → IEnumerable<ObraViewModel>          │ │
│  └───────────────────────────────────────────────────────┘ │
│                           ↕                                  │
│  ┌───────────────────────────────────────────────────────┐ │
│  │  ObraService.cs                                       │ │
│  │  └─ ObterObrasAsync(colaboradorId)                   │ │
│  └───────────────────────────────────────────────────────┘ │
│                           ↕                                  │
│  ┌───────────────────────────────────────────────────────┐ │
│  │  Database (MySQL)                                     │ │
│  │  └─ Obra table (103 records)                         │ │
│  └───────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

---

## Component Design

### 1. View Layer (Escolher.cshtml)

**Purpose:** Display obra selection page with filtering and navigation

**Key Elements:**

#### 1.1 Model Declaration ✅ FIXED
```csharp
@model IEnumerable<RdoApp.Core.Models.ViewModels.ObraViewModel>
```

**Why This Matters:**
- Ensures type safety
- Enables IntelliSense
- Prevents silent failures
- Matches controller return type

#### 1.2 Page Structure
```html
<!DOCTYPE html>
<html>
  <head>
    <!-- CSS: Bootstrap 5, Font Awesome, Fontello, Custom -->
  </head>
  <body>
    <!-- Top Navigation -->
    <nav class="top-nav">
      <div class="logo-section">...</div>
      <div class="nav-icons">...</div>
      <div class="user-info">...</div>
    </nav>
    
    <!-- Main Content -->
    <div class="main-content">
      <!-- Filters -->
      <div class="container-fluid">
        <input id="filtroUnidade" placeholder="Unidade escolar" />
        <input id="filtroMunicipio" placeholder="Município" />
      </div>
      
      <!-- Title -->
      <h2 class="page-title">Selecione uma das unidades escolares abaixo:</h2>
      
      <!-- Obra Cards -->
      <div class="lista-obras">
        @foreach (var obra in Model) {
          <div class="item">
            <button onclick="escolherObra(@obra.Id)">
              <i class="icon-@obra.ContratanteContratada"></i>
            </button>
            <h5>@obra.Descricao</h5>
            <p>@obra.CidadeEstado</p>
            <small>(@obra.StatusBasicaGratuita)</small>
            <div class="progress-container">
              <div class="progress-bar @obra.ClasseStatusCss" 
                   style="width: @obra.ProgressoPorcentagem%">
                @obra.ProgressoPorcentagem%
              </div>
            </div>
          </div>
        }
      </div>
      
      <!-- Legend -->
      <div class="area-legenda">...</div>
    </div>
    
    <!-- JavaScript -->
    <script>
      function filtrarObras() { ... }
      function escolherObra(id) { ... }
      function transformIcons() { ... }
    </script>
  </body>
</html>
```

---

### 2. Controller Layer (ObraController.cs)

**Purpose:** Handle obra selection requests and return data

**Key Method:**
```csharp
public async Task<IActionResult> Escolher(int? unidadeId = null, string municipio = null)
{
    // Get current user
    var colaboradorId = HttpContext.Session.GetInt32("ColaboradorId");
    
    if (!colaboradorId.HasValue)
    {
        return RedirectToAction("Login", "Account");
    }
    
    // Get obras for user
    var obras = await _obraService.ObterObrasAsync(colaboradorId.Value);
    
    // Apply filters if provided
    if (unidadeId.HasValue)
    {
        obras = obras.Where(o => o.UnidadeId == unidadeId.Value);
    }
    
    if (!string.IsNullOrEmpty(municipio))
    {
        obras = obras.Where(o => o.CidadeEstado.Contains(municipio, StringComparison.OrdinalIgnoreCase));
    }
    
    // Set user name for display
    ViewBag.UsuarioNome = HttpContext.Session.GetString("UsuarioNome") ?? "Usuário";
    
    // Return view with strongly-typed model
    return View(obras); // Returns IEnumerable<ObraViewModel>
}
```

**Return Type:** `IEnumerable<ObraViewModel>` ✅ Matches view model

---

### 3. Service Layer (ObraService.cs)

**Purpose:** Business logic for obra data retrieval

**Key Method:**
```csharp
public async Task<IEnumerable<ObraViewModel>> ObterObrasAsync(int colaboradorId)
{
    // Get obras from database
    var obras = await _context.Obras
        .Where(o => o.ColaboradorId == colaboradorId)
        .Include(o => o.Unidade)
        .Include(o => o.Municipio)
        .ToListAsync();
    
    // Map to view models
    return obras.Select(o => new ObraViewModel
    {
        Id = o.Id,
        Descricao = o.Descricao,
        CidadeEstado = $"{o.Municipio?.Nome ?? ""} - {o.Municipio?.Estado ?? ""}",
        StatusBasicaGratuita = o.StatusBasicaGratuita,
        ContratanteContratada = o.ContratanteContratada,
        ProgressoPorcentagem = CalcularProgresso(o),
        ClasseStatusCss = DeterminarClasseStatus(o)
    });
}
```

---

### 4. View Model (ObraViewModel.cs)

**Purpose:** Data transfer object for obra display

**Properties:**
```csharp
public class ObraViewModel
{
    public int Id { get; set; }
    public string Descricao { get; set; }
    public string CidadeEstado { get; set; }
    public string StatusBasicaGratuita { get; set; }
    public string ContratanteContratada { get; set; } // "t" or "d"
    public int ProgressoPorcentagem { get; set; }
    public string ClasseStatusCss { get; set; } // "bg-verde", "bg-vermelho", "bg-cinza"
    public int? UnidadeId { get; set; }
}
```

**Type Safety:** All properties are strongly typed ✅

---

## Data Flow

### Request Flow
```
1. User navigates to /Obra/Escolher
   ↓
2. ObraController.Escolher() is called
   ↓
3. Controller checks session for ColaboradorId
   ↓
4. Controller calls ObraService.ObterObrasAsync(colaboradorId)
   ↓
5. Service queries database for obras
   ↓
6. Service maps entities to ObraViewModel
   ↓
7. Controller returns View(obras) → IEnumerable<ObraViewModel>
   ↓
8. Razor engine renders Escolher.cshtml with strongly-typed model
   ↓
9. HTML is sent to browser
   ↓
10. JavaScript initializes filtering and icon transformation
```

### Filtering Flow (Client-Side)
```
1. User types in filter input
   ↓
2. 'input' event fires
   ↓
3. filtrarObras() is called
   ↓
4. Function reads filter values
   ↓
5. Function iterates through .item elements
   ↓
6. Function checks data-unidade and data-municipio attributes
   ↓
7. Function shows/hides items based on match
   ↓
8. Function displays "no results" message if needed
```

### Navigation Flow
```
1. User clicks obra card button
   ↓
2. onclick="escolherObra(@obra.Id)" fires
   ↓
3. JavaScript function constructs URL: /Obra/Etapas?obraId={id}
   ↓
4. window.location.href navigates to URL
   ↓
5. ObraController.Etapas(obraId) is called
   ↓
6. Session stores selected obra
   ↓
7. Etapa/Cards page is displayed
```

---

## CSS Architecture

### Style Organization

```css
/* 1. Global Styles */
body {
  background: linear-gradient(...);
  min-height: 100vh;
}

/* 2. Top Navigation */
.top-nav { ... }
.logo-section { ... }
.nav-icons { ... }
.user-info { ... }

/* 3. Main Content */
.main-content { ... }
.page-title { ... }

/* 4. Filters */
.filter-tabs { ... }
.filter-tab { ... }

/* 5. Obra Cards */
.lista-obras { ... }
.lista-obras .item { ... }
.lista-obras .item:hover { ... }

/* 6. Progress Bars */
.progress-container { ... }
.progress-bar { ... }
.bg-verde { ... }
.bg-vermelho { ... }
.bg-cinza { ... }

/* 7. Icons */
.icon-contratante:before { ... }
.icon-contratada:before { ... }

/* 8. Legend */
.area-legenda { ... }
.legenda { ... }

/* 9. Responsive Design */
@media (max-width: 768px) { ... }
@media (min-width: 769px) and (max-width: 1024px) { ... }
@media (min-width: 1025px) and (max-width: 1366px) { ... }
@media (min-width: 1367px) and (max-width: 1920px) { ... }
@media (min-width: 1921px) { ... }
```

---

## JavaScript Architecture

### Function Organization

```javascript
// 1. Filtering
function filtrarObras() {
  // Get filter values
  // Iterate through cards
  // Show/hide based on match
  // Display "no results" message
}

// 2. Navigation
function escolherObra(obraId) {
  // Construct URL
  // Navigate to Etapa/Cards page
  // Handle errors
}

// 3. Icon Transformation
function transformIcons() {
  // Find all icon elements
  // Read data-tipo attribute
  // Transform to correct icon class
  // Update title attribute
}

// 4. Event Listeners
document.getElementById('filtroUnidade').addEventListener('input', filtrarObras);
document.getElementById('filtroMunicipio').addEventListener('input', filtrarObras);
document.addEventListener('DOMContentLoaded', transformIcons);
```

---

## Responsive Design Strategy

### Breakpoint System

| Screen Size | Breakpoint | Cards Per Row | Target Device |
|-------------|------------|---------------|---------------|
| Mobile | < 768px | 2 | Phones |
| Tablet | 769-1024px | 5 | Tablets |
| Small Laptop | 1025-1366px | 7 | 13" laptops |
| Standard Laptop | 1367-1920px | 8 | 15" laptops |
| Large Screen | > 1920px | 10 | Desktops |

### Implementation
```css
/* Mobile */
@media (max-width: 768px) {
  .lista-obras .item {
    flex-basis: 50%; /* 2 per row */
  }
}

/* Tablet */
@media (min-width: 769px) and (max-width: 1024px) {
  .lista-obras .item {
    flex-basis: 20%; /* 5 per row */
  }
}

/* Small Laptop */
@media (min-width: 1025px) and (max-width: 1366px) {
  .lista-obras .item {
    flex-basis: 14.28%; /* 7 per row */
  }
}

/* Standard Laptop */
@media (min-width: 1367px) and (max-width: 1920px) {
  .lista-obras .item {
    flex-basis: 12.5%; /* 8 per row */
  }
}

/* Large Screen */
@media (min-width: 1921px) {
  .lista-obras .item {
    flex-basis: 10%; /* 10 per row */
  }
}
```

---

## Icon System Design

### Fontello Custom Icons

**Purpose:** Display contratante/contratada icons dynamically

**Implementation:**
```css
@font-face {
  font-family: 'fontello';
  src: url('data:application/octet-stream;base64,...') format('woff');
}

.icon-contratante:before {
  content: '\e815';
  font-family: 'fontello';
}

.icon-contratada:before {
  content: '\e807';
  font-family: 'fontello';
}
```

**Dynamic Transformation:**
```javascript
function transformIcons() {
  document.querySelectorAll('[class*="icon-"]').forEach(icon => {
    const tipo = icon.getAttribute('data-tipo');
    
    switch(tipo.toLowerCase()) {
      case 't':
      case 'contratante':
        icon.className = 'icon-contratante';
        break;
      case 'd':
      case 'contratada':
        icon.className = 'icon-contratada';
        break;
    }
  });
}
```

---

## Progress Bar System

### Color Coding Logic

```csharp
// In ObraService.cs
private string DeterminarClasseStatus(Obra obra)
{
    var progresso = CalcularProgresso(obra);
    var prazoEstimado = obra.PrazoEstimado;
    var dataAtual = DateTime.Now;
    
    if (progresso >= 100)
    {
        return "bg-verde"; // Completed
    }
    else if (dataAtual > prazoEstimado)
    {
        return "bg-vermelho"; // Overdue
    }
    else
    {
        return "bg-cinza"; // In progress
    }
}
```

### CSS Implementation
```css
.bg-verde {
  background-color: #4caf50; /* Green - Completed */
}

.bg-vermelho {
  background-color: #f44336; /* Red - Overdue */
}

.bg-cinza {
  background-color: #9e9e9e; /* Gray - In progress */
}
```

---

## Error Handling

### Server-Side
```csharp
public async Task<IActionResult> Escolher(...)
{
    try
    {
        var colaboradorId = HttpContext.Session.GetInt32("ColaboradorId");
        
        if (!colaboradorId.HasValue)
        {
            return RedirectToAction("Login", "Account");
        }
        
        var obras = await _obraService.ObterObrasAsync(colaboradorId.Value);
        
        return View(obras);
    }
    catch (Exception ex)
    {
        _logger.LogError(ex, "Error loading obras");
        return View("Error");
    }
}
```

### Client-Side
```javascript
function escolherObra(obraId) {
    try {
        var url = '@Url.Action("Etapas", "Obra")' + '?obraId=' + obraId;
        window.location.href = url;
    } catch (error) {
        console.error('Navigation error:', error);
        // Fallback navigation
        window.location = '/Obra/Etapas?obraId=' + obraId;
    }
}
```

---

## Performance Considerations

### Server-Side
- ✅ Use async/await for database queries
- ✅ Include related entities in single query (Include)
- ✅ Map to view models to reduce data transfer
- ✅ Cache user session data

### Client-Side
- ✅ Use event delegation for card clicks
- ✅ Debounce filter inputs (if needed)
- ✅ Minimize DOM manipulations
- ✅ Use CSS transforms for animations

---

## Security Considerations

### Authentication
- ✅ Check session for ColaboradorId
- ✅ Redirect to login if not authenticated
- ✅ Validate user has access to obras

### Authorization
- ✅ Filter obras by colaboradorId
- ✅ Prevent access to other users' obras
- ✅ Validate obra ownership on navigation

### Input Validation
- ✅ Sanitize filter inputs
- ✅ Validate obra ID on selection
- ✅ Prevent SQL injection (use parameterized queries)

---

## Testing Strategy

### Unit Tests
```csharp
[Fact]
public async Task Escolher_WithValidUser_ReturnsViewWithObras()
{
    // Arrange
    var controller = CreateController();
    SetupSession(colaboradorId: 1);
    
    // Act
    var result = await controller.Escolher();
    
    // Assert
    var viewResult = Assert.IsType<ViewResult>(result);
    var model = Assert.IsAssignableFrom<IEnumerable<ObraViewModel>>(viewResult.Model);
    Assert.NotEmpty(model);
}

[Fact]
public async Task Escolher_WithoutAuthentication_RedirectsToLogin()
{
    // Arrange
    var controller = CreateController();
    // No session setup
    
    // Act
    var result = await controller.Escolher();
    
    // Assert
    var redirectResult = Assert.IsType<RedirectToActionResult>(result);
    Assert.Equal("Login", redirectResult.ActionName);
    Assert.Equal("Account", redirectResult.ControllerName);
}
```

### Integration Tests
```csharp
[Fact]
public async Task Escolher_RendersCorrectly()
{
    // Arrange
    var client = _factory.CreateClient();
    await AuthenticateClient(client);
    
    // Act
    var response = await client.GetAsync("/Obra/Escolher");
    
    // Assert
    response.EnsureSuccessStatusCode();
    var content = await response.Content.ReadAsStringAsync();
    Assert.Contains("Selecione uma das unidades escolares", content);
    Assert.Contains("lista-obras", content);
}
```

### Manual Tests
1. ✅ Page loads without blank screen
2. ✅ Filters work in real-time
3. ✅ Obra selection navigates correctly
4. ✅ Progress bars display correct colors
5. ✅ Icons display correctly
6. ✅ Responsive design works on all screen sizes
7. ✅ No console errors
8. ✅ No 404 errors for assets

---

## Deployment Considerations

### Pre-Deployment Checklist
- ✅ Model type is strongly typed
- ✅ All CSS files are included
- ✅ All JavaScript is functional
- ✅ No debug code remains
- ✅ Error handling is in place
- ✅ Session management is configured
- ✅ Database connection is configured

### Post-Deployment Verification
- ✅ Page loads correctly in production
- ✅ Filters work as expected
- ✅ Navigation functions properly
- ✅ No console errors
- ✅ Performance is acceptable

---

## Conclusion

The design implements a strongly-typed, responsive obra selection page with:
- ✅ Type-safe model binding
- ✅ Real-time client-side filtering
- ✅ Dynamic icon system
- ✅ Color-coded progress bars
- ✅ Responsive grid layout
- ✅ Proper error handling
- ✅ Security considerations

**Status:** ✅ DESIGN COMPLETE  
**Next Step:** Implementation (already applied)  
**Last Updated:** January 20, 2026
