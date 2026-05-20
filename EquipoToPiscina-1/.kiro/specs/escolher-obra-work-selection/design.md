# ESCOLHER OBRA - Design Document

**Work Date**: January 17-18, 2026  
**Status**: ✅ IMPLEMENTED  
**Architecture**: Server-Side Razor with Legacy CSS

---

## ARCHITECTURE OVERVIEW

### Pattern: Server-Side Rendering
```
┌─────────────────────────────────────────────────────────────┐
│                        BROWSER                               │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  HTML (Escolher.cshtml rendered)                       │ │
│  │  + CSS (escolher-legacy.css)                           │ │
│  │  + Icons (fontello.css)                                │ │
│  │  + Forms (POST to /Etapa/Cards)                        │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                            ↑
                            │ HTTP GET /Obra/Escolher
                            │ HTTP POST /Etapa/Cards
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                    ASP.NET CORE SERVER                       │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  ObraController                                        │ │
│  │    ├─ Escolher() → GET                                 │ │
│  │    └─ EscolherObra() → POST (redirects to Tarefa)     │ │
│  └────────────────────────────────────────────────────────┘ │
│                            ↓                                 │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  IObraService                                          │ │
│  │    └─ ObterObrasAsync(colaboradorId)                  │ │
│  └────────────────────────────────────────────────────────┘ │
│                            ↓                                 │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  ObraRepository                                        │ │
│  │    └─ GetObrasByColaboradorAsync()                    │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                      DATABASE (MySQL)                        │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  Tables: Obra, Colaborador, ObraColaborador           │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

---

## COMPONENT DESIGN

### 1. Controller Layer

**File:** `Controllers/ObraController.cs`

**Responsibilities:**
- Authenticate user (via `[Authorize]` attribute)
- Extract `colaboradorId` from claims
- Call service to get obras
- Apply filters (if provided)
- Set ViewBag flags for layout
- Return view with data

**Key Method:**
```csharp
[Authorize]
public async Task<IActionResult> Escolher(
    string filtroUnidade = "", 
    string filtroMunicipio = "")
{
    // 1. Set layout flags
    ViewBag.IsObraSelection = true;
    ViewBag.CurrentObra = null;
    
    // 2. Get user ID from claims
    var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
    if (!int.TryParse(userIdClaim, out int colaboradorId))
        return RedirectToAction("Login", "Account");
    
    // 3. Get obras from service
    var obras = await _obraService.ObterObrasAsync(colaboradorId);
    
    // 4. Apply filters (server-side)
    var filteredObras = obras.AsEnumerable();
    if (!string.IsNullOrEmpty(filtroUnidade))
        filteredObras = filteredObras.Where(o => 
            o.Descricao.Contains(filtroUnidade, StringComparison.OrdinalIgnoreCase));
    
    // 5. Return view
    return View(filteredObras.ToList());
}
```

**Selection Handler:**
```csharp
[HttpPost]
public async Task<IActionResult> EscolherObra(int obraId)
{
    // 1. Store in session
    HttpContext.Session.SetInt32("ObraId", obraId);
    
    // 2. Get obra details
    var obra = await _obraService.ObterObraPorIdAsync(obraId);
    if (obra != null)
        HttpContext.Session.SetString("ObraNome", obra.Descricao);
    
    // 3. Redirect to workspace
    return RedirectToAction("Cards", "Tarefa", new { obraId });
}
```

---

### 2. Service Layer

**Interface:** `Services/Interfaces/IObraService.cs`

```csharp
public interface IObraService
{
    Task<List<ObraViewModel>> ObterObrasAsync(int colaboradorId);
    Task<ObraViewModel?> ObterObraPorIdAsync(int obraId);
}
```

**Implementation:** `Services/Implementations/ObraService.cs`

**Responsibilities:**
- Query database via repository
- Map entities to ViewModels
- Calculate progress percentages
- Determine status CSS classes
- Handle business logic

**Key Logic:**
```csharp
public async Task<List<ObraViewModel>> ObterObrasAsync(int colaboradorId)
{
    // 1. Get obras from repository
    var obras = await _repository.GetObrasByColaboradorAsync(colaboradorId);
    
    // 2. Map to ViewModels
    var viewModels = obras.Select(o => new ObraViewModel
    {
        Id = o.Id,
        Descricao = o.Descricao,
        CidadeEstado = $"{o.Cidade}/{o.Estado}",
        StatusBasicaGratuita = o.TipoObra,
        ContratanteContratada = o.TipoContrato,
        ProgressoPorcentagem = CalculateProgress(o),
        ClasseStatusCss = DetermineStatusClass(o),
        LogoPath = o.LogoPath
    }).ToList();
    
    return viewModels;
}

private int CalculateProgress(Obra obra)
{
    if (obra.TotalTarefas == 0) return 0;
    return (obra.TarefasConcluidas * 100) / obra.TotalTarefas;
}

private string DetermineStatusClass(Obra obra)
{
    if (obra.DataConclusao < DateTime.Now && obra.ProgressoPorcentagem < 100)
        return "bg-vermelho"; // Overdue
    if (obra.ProgressoPorcentagem >= 80)
        return "bg-verde"; // On schedule
    return "bg-cinza"; // In progress
}
```

---

### 3. View Layer

**File:** `Views/Obra/Escolher.cshtml`

**Structure:**
```razor
@model IEnumerable<ObraViewModel>
@{
    Layout = "~/Views/Shared/_Layout.cshtml";
    ViewBag.IsObraSelection = true;
    ViewBag.CurrentObra = null;
}

@section Styles {
    <link rel="stylesheet" href="~/css/fontello.css" />
    <link rel="stylesheet" href="~/css/escolher-legacy.css" />
}

<section class="escolher-obra-section">
    <!-- Filters Section (future) -->
    <div class="rdo-filters-section">
        <h2>Selecione uma das unidades escolares abaixo:</h2>
    </div>
    
    <!-- Obra Cards Grid -->
    <div class="lista-obras">
        @foreach (var obra in Model)
        {
            <div class="item">
                <form method="post" action="/Etapa/Cards">
                    <input type="hidden" name="obraId" value="@obra.Id" />
                    <button type="submit" class="btn">
                        <!-- Icon -->
                        <i class="icon-@obra.ContratanteContratada"></i>
                        
                        <!-- Content -->
                        <h5>@obra.Descricao</h5>
                        <p>@obra.CidadeEstado</p>
                        <p>(@obra.StatusBasicaGratuita)</p>
                        
                        <!-- Progress Bar -->
                        <div class="progress @obra.ClasseStatusCss">
                            <div class="progress-bar" 
                                 style="width: @(100 - obra.ProgressoPorcentagem)%;">
                                <span class="branco">@obra.ProgressoPorcentagem%</span>
                            </div>
                            <span class="azul">@obra.ProgressoPorcentagem%</span>
                        </div>
                    </button>
                </form>
            </div>
        }
    </div>
    
    <!-- Legend -->
    <div class="area-legenda">
        <!-- Status color explanations -->
    </div>
</section>
```

**Key Design Decisions:**
1. **POST Form:** Each card is a form that POSTs to `/Etapa/Cards`
2. **Hidden Field:** `obraId` passed as hidden input
3. **Button Submit:** Entire card is clickable button
4. **No JavaScript:** Pure HTML form submission
5. **Server-Side:** All logic handled on server
6. **Razor Syntax Safety:** Use explicit concatenation or `@()` syntax in JavaScript strings

---

### 4. CSS Layer

**File:** `wwwroot/css/escolher-legacy.css`

**Architecture:** Pure CSS, No Bootstrap

**Key Patterns:**

#### Grid Layout (5 Cards Per Row)
```css
.lista-obras {
    display: flex;
    flex-wrap: wrap;
    gap: 20px;
    justify-content: flex-start;
}

.lista-obras .item {
    flex-basis: 100%;  /* Start at full width */
    flex-shrink: 1;    /* Allow shrinking */
    min-width: 250px;  /* Minimum card width */
}
```

**Why This Works:**
- `flex-basis: 100%` tells each card to start at full container width
- `flex-shrink: 1` allows flexbox to shrink cards to fit multiple per row
- On 1920px screen: Cards shrink to ~360px each → 5 cards fit
- On 1366px screen: Cards shrink to ~250px each → 5 cards fit
- On 1024px screen: Cards shrink to ~320px each → 3 cards fit

#### Icon System
```css
.lista-obras .item .btn i {
    font-size: 97px;           /* Large icon */
    color: #0088DD;            /* Default blue */
    margin-bottom: -20px;      /* Pull up into card */
}

.lista-obras .item .btn i.icon-contratante {
    color: #00bcd4;            /* Cyan */
}

.lista-obras .item .btn i.icon-contratada {
    color: #ff9800;            /* Orange */
}

.lista-obras .item .btn:hover i {
    color: #28496F;            /* Dark blue on hover */
}
```

#### Progress Bar System
```css
/* Container - flipped horizontally */
.progress {
    transform: scaleX(-1);     /* Flip entire bar */
    height: 20px;
    border-radius: 4px;
}

/* Text - flipped back to readable */
.progress .branco,
.progress .azul {
    transform: scaleX(-1);     /* Flip text back */
    position: absolute;
    left: 9px;
    font-size: 14px;
    font-weight: bold;
}

/* Color classes with !important */
.progress.bg-verde {
    background: #57B257 !important;  /* Green */
}

.progress.bg-vermelho {
    background: #D04541 !important;  /* Red */
}

.progress.bg-cinza {
    background: #999999 !important;  /* Gray */
}
```

**Why Flip Progress Bar:**
- Legacy system uses this pattern
- Creates visual effect of bar filling right-to-left
- Maintains exact visual parity with production

#### Hover Effects
```css
.lista-obras .item .btn:hover {
    transform: translateY(-5px);           /* Lift up */
    box-shadow: 0 5px 15px rgba(0,0,0,0.2); /* Shadow */
    border-color: #00bcd4;                 /* Cyan border */
}

.lista-obras .item .btn:hover h5,
.lista-obras .item .btn:hover p {
    color: #fff;                           /* White text */
}
```

---

### 5. ViewModel Design

**File:** `Models/ViewModels/ObraViewModel.cs`

```csharp
public class ObraViewModel
{
    // Identity
    public int Id { get; set; }
    
    // Display Information
    public string Descricao { get; set; }           // "EMEF João Silva"
    public string CidadeEstado { get; set; }        // "São Paulo/SP"
    public string StatusBasicaGratuita { get; set; } // "Básica" or "Gratuita"
    
    // Type Indicator
    public string ContratanteContratada { get; set; } // "contratante" or "contratada"
    
    // Progress Information
    public int ProgressoPorcentagem { get; set; }    // 0-100
    public string ClasseStatusCss { get; set; }      // "bg-verde", "bg-vermelho", "bg-cinza"
    
    // Dates (for future use)
    public string DataInicio { get; set; }
    public string DataConclusao { get; set; }
    public bool ObraFinalizada { get; set; }
    
    // Two Figures Logic (future)
    public string? LogoPath { get; set; }            // Path to company logo
}
```

**Design Rationale:**
- **Flat Structure:** No nested objects, easy to bind in Razor
- **String Dates:** Pre-formatted for display, no date parsing in view
- **CSS Class:** Pre-calculated status class, no logic in view
- **Icon Class:** Pre-determined icon type, direct binding
- **Percentage:** Pre-calculated, ready for display

---

## LAYOUT INTEGRATION

### Two-World Architecture

**World A: Obra Selection (Gateway)**
- User is choosing which obra to work on
- Header shows: Logo + Brand + "Selecione uma obra..." + User
- Header hides: 6-button toolbar (no obra context)
- Triggered by: `ViewBag.IsObraSelection = true`

**World B: Workspace (Etapa/Tarefa)**
- User is working within a specific obra
- Header shows: Logo + Brand + Obra Name + 6-button toolbar + User
- Header hides: Selection message
- Triggered by: `ViewBag.IsObraSelection = false` (or not set)

### Layout File Logic

**File:** `Views/Shared/_Layout.cshtml`

```razor
@if (ViewBag.IsObraSelection == true)
{
    <!-- SIMPLIFIED HEADER -->
    <header class="rdo-header-selection">
        <div class="rdo-logo">
            <img src="~/images/rdo-logo.png" alt="RDO" />
        </div>
        <div class="rdo-brand">
            <h1>Piscinas</h1>
        </div>
        <div class="rdo-selection-message">
            <p>Selecione uma obra para continuar</p>
        </div>
        <div class="rdo-user-profile">
            <span>@ViewBag.UsuarioNome</span>
            <a href="/Account/Logout">Sair</a>
        </div>
    </header>
}
else
{
    <!-- FULL HEADER WITH TOOLBAR -->
    <header class="rdo-header-workspace">
        <!-- Logo + Brand + Obra Name + 6-button toolbar + User -->
    </header>
}

<main>
    @RenderBody()
</main>
```

---

## DATA FLOW

### Request Flow (GET /Obra/Escolher)

```
1. Browser → GET /Obra/Escolher
2. ASP.NET Core → [Authorize] check
3. If not authenticated → Redirect to /Account/Login
4. If authenticated → ObraController.Escolher()
5. Controller → Extract colaboradorId from claims
6. Controller → Call IObraService.ObterObrasAsync(colaboradorId)
7. Service → Call Repository.GetObrasByColaboradorAsync()
8. Repository → Query database (JOIN Obra, ObraColaborador)
9. Repository → Return List<Obra> entities
10. Service → Map entities to List<ObraViewModel>
11. Service → Calculate progress, determine CSS classes
12. Service → Return List<ObraViewModel>
13. Controller → Set ViewBag.IsObraSelection = true
14. Controller → Return View(viewModels)
15. Razor Engine → Render Escolher.cshtml with data
16. Browser → Display HTML + CSS
```

### Selection Flow (POST /Etapa/Cards)

```
1. User clicks obra card
2. Browser → POST /Etapa/Cards with obraId in form data
3. ASP.NET Core → Route to TarefaController.Cards()
4. Controller → Extract obraId from form
5. Controller → Store in session:
   - HttpContext.Session.SetInt32("ObraId", obraId)
   - HttpContext.Session.SetString("ObraNome", obra.Descricao)
6. Controller → Load etapas for selected obra
7. Controller → Return View with etapas
8. Browser → Display task workspace
```

**Note:** The POST goes directly to `/Etapa/Cards`, not to `ObraController.EscolherObra()`. This is intentional for simplicity.

---

## SESSION MANAGEMENT

### Session Storage

**Keys:**
- `ObraId` (int): Selected obra identifier
- `ObraNome` (string): Selected obra description

**Lifetime:**
- Until user logs out
- Until session timeout (default 20 minutes)
- Until browser closes (if not persistent)

**Usage:**
```csharp
// Store
HttpContext.Session.SetInt32("ObraId", obraId);
HttpContext.Session.SetString("ObraNome", obra.Descricao);

// Retrieve
var obraId = HttpContext.Session.GetInt32("ObraId");
var obraNome = HttpContext.Session.GetString("ObraNome");

// Check
if (!HttpContext.Session.Keys.Contains("ObraId"))
{
    // No obra selected, redirect to selection
    return RedirectToAction("Escolher", "Obra");
}
```

---

## ERROR HANDLING

### Error Scenarios

#### 1. User Not Authenticated
```csharp
// Handled by [Authorize] attribute
// Automatic redirect to /Account/Login
```

#### 2. Invalid User ID
```csharp
var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out int colaboradorId))
{
    _logger.LogWarning("Invalid or missing user ID claim");
    return RedirectToAction("Login", "Account");
}
```

#### 3. Database Error
```csharp
try
{
    var obras = await _obraService.ObterObrasAsync(colaboradorId);
    return View(obras);
}
catch (Exception ex)
{
    _logger.LogError(ex, "Error loading obras");
    return View(new List<ObraViewModel>()); // Empty list
}
```

#### 4. No Obras Available
```razor
@if (Model != null && Model.Any())
{
    <!-- Display obra cards -->
}
else
{
    <div class="rdo-no-obras">
        <label>Você deve cadastrar uma unidade escolar para começar a usar o sistema.</label>
    </div>
}
```

#### 5. Selection Error
```csharp
[HttpPost]
public async Task<IActionResult> EscolherObra(int obraId)
{
    try
    {
        // Store and redirect
    }
    catch (Exception ex)
    {
        _logger.LogError(ex, "Error selecting obra {ObraId}", obraId);
        TempData["ErrorMessage"] = "Erro ao selecionar obra. Tente novamente.";
        return RedirectToAction("Escolher");
    }
}
```

---

## PERFORMANCE CONSIDERATIONS

### Optimization Strategies

#### 1. Database Query
```csharp
// Use projection to select only needed fields
var obras = await _context.Obras
    .Where(o => o.ObraColaboradores.Any(oc => oc.ColaboradorId == colaboradorId))
    .Select(o => new ObraViewModel
    {
        Id = o.Id,
        Descricao = o.Descricao,
        // ... other fields
    })
    .ToListAsync();
```

#### 2. Caching (Future Enhancement)
```csharp
// Cache obras per user for 5 minutes
var cacheKey = $"obras_{colaboradorId}";
if (!_cache.TryGetValue(cacheKey, out List<ObraViewModel> obras))
{
    obras = await _obraService.ObterObrasAsync(colaboradorId);
    _cache.Set(cacheKey, obras, TimeSpan.FromMinutes(5));
}
```

#### 3. Icon Font Loading
```html
<!-- Preload icon font for faster rendering -->
<link rel="preload" href="~/css/fontello.woff2" as="font" type="font/woff2" crossorigin>
```

#### 4. CSS Optimization
```css
/* Use CSS containment for better rendering performance */
.lista-obras .item {
    contain: layout style paint;
}
```

---

## SECURITY CONSIDERATIONS

### 1. Authorization
- **Requirement:** User must be authenticated
- **Implementation:** `[Authorize]` attribute on controller
- **Validation:** Check claims for valid colaboradorId

### 2. Data Access Control
- **Requirement:** User can only see their assigned obras
- **Implementation:** Filter by colaboradorId in database query
- **Validation:** Never trust client-side data

### 3. Session Security
- **Requirement:** Prevent session hijacking
- **Implementation:** Use secure cookies, HTTPS only
- **Validation:** Regenerate session ID on login

### 4. CSRF Protection
- **Requirement:** Prevent cross-site request forgery
- **Implementation:** ASP.NET Core anti-forgery tokens
- **Validation:** Automatic validation on POST

### 5. Input Validation
- **Requirement:** Validate all user inputs
- **Implementation:** Model validation, parameter checks
- **Validation:** Server-side validation always

---

## ACCESSIBILITY CONSIDERATIONS

### Current Implementation
- **Keyboard Navigation:** All cards accessible via Tab key
- **Semantic HTML:** Proper use of `<button>`, `<form>`, `<section>`
- **Color Contrast:** Meets WCAG AA standards

### Future Enhancements
- **ARIA Labels:** Add descriptive labels for screen readers
- **Focus Indicators:** Enhance visible focus states
- **Skip Links:** Add "skip to content" link
- **Alt Text:** Add descriptive alt text for icons

---

## TESTING STRATEGY

### Unit Tests
```csharp
[Fact]
public async Task Escolher_WithValidUser_ReturnsViewWithObras()
{
    // Arrange
    var mockService = new Mock<IObraService>();
    mockService.Setup(s => s.ObterObrasAsync(It.IsAny<int>()))
        .ReturnsAsync(new List<ObraViewModel> { /* test data */ });
    
    var controller = new ObraController(mockLogger, mockService.Object, mockEtapaService);
    
    // Act
    var result = await controller.Escolher();
    
    // Assert
    var viewResult = Assert.IsType<ViewResult>(result);
    var model = Assert.IsAssignableFrom<List<ObraViewModel>>(viewResult.Model);
    Assert.NotEmpty(model);
}
```

### Integration Tests
```csharp
[Fact]
public async Task Escolher_EndToEnd_DisplaysObras()
{
    // Arrange
    var client = _factory.CreateClient();
    await AuthenticateClient(client);
    
    // Act
    var response = await client.GetAsync("/Obra/Escolher");
    
    // Assert
    response.EnsureSuccessStatusCode();
    var content = await response.Content.ReadAsStringAsync();
    Assert.Contains("lista-obras", content);
}
```

### Visual Regression Tests
```powershell
# Compare screenshots with baseline
.\test-escolher-visual-fixes.ps1
```

---

## DEPLOYMENT CONSIDERATIONS

### Pre-Deployment Checklist
- [ ] Verify view file size > 5KB
- [ ] Verify CSS file exists and is valid
- [ ] Verify fontello.css is deployed
- [ ] Verify icon font files are deployed
- [ ] Test in production-like environment
- [ ] Clear browser cache after deployment
- [ ] Monitor error logs for first 24 hours

### Rollback Plan
1. Restore previous view file from backup
2. Restore previous CSS file from backup
3. Clear server-side cache
4. Restart application pool
5. Verify rollback successful

---

## RAZOR SYNTAX BEST PRACTICES

### Inline JavaScript with Razor Variables

**Problem:** Razor parser can get confused when variables are embedded in JavaScript strings.

#### ❌ AVOID: Ambiguous Syntax
```razor
<script>console.log("Rendering obra ID @obra.Id");</script>
```
**Issue:** Razor parser doesn't know if `@obra.Id` is inside the string or separate code. This causes the view engine to crash during rendering, resulting in a blank page.

#### ✅ SOLUTION 1: JavaScript Concatenation
```razor
<script>console.log("Rendering obra ID " + @obra.Id);</script>
```
**Why It Works:** The `+` operator makes it clear to Razor that we're concatenating a JavaScript string with a Razor value.

#### ✅ SOLUTION 2: Explicit Razor Syntax
```razor
<script>console.log("Rendering obra ID @(obra.Id)");</script>
```
**Why It Works:** The `@()` syntax explicitly tells Razor to interpolate the value.

#### ✅ BEST PRACTICE: Data Attributes
```razor
@foreach (var obra in Model)
{
    <div data-obra-id="@obra.Id">...</div>
}

<script>
    document.querySelectorAll('[data-obra-id]').forEach(el => {
        console.log("Obra ID " + el.dataset.obraId);
    });
</script>
```
**Why It's Better:** Separates data from logic, avoids inline scripts in loops, easier to maintain.

### Symptoms of Razor Syntax Errors

When Razor parser crashes due to ambiguous syntax:
- ✅ HTTP 200 OK response
- ❌ Response size: 0.1 kB (instead of 50-100 kB)
- ❌ Page completely blank
- ❌ F12 Console empty (no JavaScript executes)
- ✅ Backend logs show success (controller executes)
- ❌ View rendering fails silently

### Resolution: January 18, 2026

**File:** `Views/Obra/Escolher.cshtml`  
**Line:** 43  
**Issue:** `<script>console.log("🟢 LIFE SIGN 10: Rendering obra ID @obra.Id");</script>`  
**Fix:** `<script>console.log("🟢 LIFE SIGN 10: Rendering obra ID " + @obra.Id);</script>`  
**Result:** View renders successfully, all Life Signs execute

---

## MAINTENANCE GUIDELINES

### Code Review Checklist
- [ ] No Bootstrap CSS classes used
- [ ] ViewBag.IsObraSelection set correctly
- [ ] Error handling implemented
- [ ] Logging statements added
- [ ] No client-side JavaScript added
- [ ] CSS follows legacy patterns
- [ ] Visual parity maintained

### Common Modifications
1. **Add New Filter:** Update controller, add filter UI, apply filter logic
2. **Change Card Layout:** Update CSS only, no view changes
3. **Add New Field:** Update ViewModel, Service, View
4. **Change Colors:** Update CSS only, use exact hex codes

---

**Status:** ✅ DESIGN COMPLETE  
**Next:** Review tasks.md for implementation steps
