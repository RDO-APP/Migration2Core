# RDO Clean Migration - Design Document
## Technical Architecture & Implementation Specifications

**Created:** January 22, 2026  
**Status:** 📐 Design Phase  
**Approach:** Clean Architecture with Lessons Learned Applied

---

## Architecture Overview

### Technology Stack

**Backend:**
- .NET 8.0 (LTS)
- ASP.NET Core MVC
- Entity Framework Core 8.0
- Pomelo.EntityFrameworkCore.MySql 8.0

**Frontend:**
- Razor Pages/Views
- Bootstrap 5.3 (local, not CDN)
- Vanilla JavaScript (separate files)
- CSS3 (separate files)

**Database:**
- MySQL 8.0
- Existing schema (48 tables, 62 foreign keys)

**Authentication:**
- ASP.NET Core Identity
- Cookie-based authentication
- Session management

**Testing:**
- xUnit for unit tests
- Integration tests with test database
- Browser testing (Chrome, Edge, Firefox)

---

## Project Structure

```
RdoApp.Core/
├── Controllers/          # MVC Controllers
├── Models/              # View Models & DTOs
├── Data/
│   ├── Entities/        # EF Core Entities
│   ├── Configurations/  # Fluent API Configurations
│   └── RdoDbContext.cs  # DbContext
├── Services/            # Business Logic
├── Repositories/        # Data Access
├── Middleware/          # Custom Middleware
├── Views/               # Razor Views
├── wwwroot/
│   ├── css/            # Stylesheets (NO inline styles)
│   ├── js/             # JavaScript (NO inline scripts)
│   ├── images/         # Static images
│   └── lib/            # Bootstrap 5 (local)
├── appsettings.json    # Configuration
└── Program.cs          # Application startup
```

---

## Critical Design Principles (From Lessons Learned)

### 1. NO Inline Scripts in Razor Views
**Rule:** All JavaScript must be in separate .js files

**Implementation:**
- Create dedicated .js files in wwwroot/js/
- Reference using `<script src="~/js/filename.js"></script>`
- Use data attributes for configuration
- NO `<script>` tags in .cshtml files
- NO console.log in Razor views

**Example:**
```html
<!-- ❌ WRONG - DO NOT DO THIS -->
<script>
    console.log("Model is null? @(Model == null)");
</script>

<!-- ✅ CORRECT -->
<div id="obra-list" data-count="@Model.Count()"></div>
<script src="~/js/obra-list.js"></script>
```

### 2. Server-Side Logging Only
**Rule:** Use ILogger for server-side logging, not console.log

**Implementation:**
```csharp
// In Controller
_logger.LogInformation("Loading {Count} obras for user {UserId}", 
    obras.Count, userId);
```

### 3. Proper Separation of Concerns
**Rule:** Keep server-side and client-side code separate

**Implementation:**
- Razor views: HTML + Razor syntax only
- JavaScript files: Client-side logic only
- Controllers: Server-side logic only
- No mixing of concerns



---

## Entity Framework Core Design

### DbContext Configuration

```csharp
public class RdoDbContext : DbContext
{
    public RdoDbContext(DbContextOptions<RdoDbContext> options)
        : base(options)
    {
    }

    // DbSets for all 48 entities
    public DbSet<Obra> Obras { get; set; }
    public DbSet<Etapa> Etapas { get; set; }
    public DbSet<Tarefa> Tarefas { get; set; }
    // ... (all other entities)

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);
        
        // Apply all configurations
        modelBuilder.ApplyConfigurationsFromAssembly(
            typeof(RdoDbContext).Assembly);
    }
}
```

### Entity Naming Convention

**Rule:** Preserve legacy table and column names exactly

**Implementation:**
- Use Fluent API to map to legacy names
- C# properties use PascalCase
- Database columns use legacy snake_case

**Example:**
```csharp
public class Obra
{
    public int ObrIdObra { get; set; }  // C# property
    // Maps to: obr_id_obra (database column)
}

// Configuration
modelBuilder.Entity<Obra>()
    .ToTable("obra")
    .Property(o => o.ObrIdObra)
    .HasColumnName("obr_id_obra");
```

### Complex Relationship Configurations

#### 1. Multiple Foreign Keys to Same Table (OBRA → EMPRESA)

```csharp
public class ObraConfiguration : IEntityTypeConfiguration<Obra>
{
    public void Configure(EntityTypeBuilder<Obra> builder)
    {
        builder.ToTable("obra");
        
        // Primary Key
        builder.HasKey(o => o.ObrIdObra);
        
        // Multiple relationships to EMPRESA
        builder.HasOne(o => o.EmpresaDono)
            .WithMany(e => e.ObrasComoDono)
            .HasForeignKey(o => o.ObrIdDono)
            .OnDelete(DeleteBehavior.Restrict);
            
        builder.HasOne(o => o.EmpresaContratante)
            .WithMany(e => e.ObrasComoContratante)
            .HasForeignKey(o => o.ObrIdEmpresaContratante)
            .OnDelete(DeleteBehavior.Restrict);
            
        builder.HasOne(o => o.EmpresaContratada)
            .WithMany(e => e.ObrasComoContratada)
            .HasForeignKey(o => o.ObrIdEmpresaContratada)
            .OnDelete(DeleteBehavior.Restrict);
    }
}
```

#### 2. Self-Referencing Relationship (MENU_PAGINA)

```csharp
public class MenuPaginaConfiguration : IEntityTypeConfiguration<MenuPagina>
{
    public void Configure(EntityTypeBuilder<MenuPagina> builder)
    {
        builder.ToTable("menu_pagina");
        
        builder.HasKey(mp => mp.MpaIdMenuPagina);
        
        // Self-referencing relationship
        builder.HasOne(mp => mp.MenuPaginaPai)
            .WithMany(mp => mp.MenuPaginasFilhas)
            .HasForeignKey(mp => mp.MpaIdPaginaPai)
            .OnDelete(DeleteBehavior.Restrict);
    }
}
```

#### 3. Composite Key (HISTORICO_LOGIN)

```csharp
public class HistoricoLoginConfiguration : IEntityTypeConfiguration<HistoricoLogin>
{
    public void Configure(EntityTypeBuilder<HistoricoLogin> builder)
    {
        builder.ToTable("historico_login");
        
        // Composite key
        builder.HasKey(hl => new { 
            hl.ColIdColaborador, 
            hl.DataLogin 
        });
    }
}
```

### Entity Design Patterns

#### Base Entity Pattern

```csharp
public abstract class BaseEntity
{
    // Common audit fields if needed
}

public class Obra : BaseEntity
{
    // Entity-specific properties
}
```

#### Navigation Properties

```csharp
public class Obra
{
    // Scalar properties
    public int ObrIdObra { get; set; }
    public string ObrDsObra { get; set; }
    
    // Foreign keys
    public int? ObrIdDono { get; set; }
    public int? ObrIdEmpresaContratante { get; set; }
    public int? ObrIdEmpresaContratada { get; set; }
    
    // Navigation properties (explicit names for clarity)
    public virtual Empresa EmpresaDono { get; set; }
    public virtual Empresa EmpresaContratante { get; set; }
    public virtual Empresa EmpresaContratada { get; set; }
    
    // Collections
    public virtual ICollection<Etapa> Etapas { get; set; }
    public virtual ICollection<ObraColaborador> ObraColaboradores { get; set; }
}
```

---

## Authentication & Authorization Design

### ASP.NET Core Identity Integration

**Strategy:** Extend IdentityUser to include legacy fields

```csharp
public class ApplicationUser : IdentityUser
{
    // Link to legacy USUARIO table
    public int? UsuIdUsuario { get; set; }
    
    // Link to GRUPO (security group)
    public int GrupoId { get; set; }
    public virtual Grupo Grupo { get; set; }
    
    // Additional fields
    public int? StatusAtivo { get; set; }
    public int? AlterarSenha { get; set; }
}
```

### RBAC Implementation

**5-Level Permission Check:**

```csharp
public interface IPermissionService
{
    Task<bool> UserHasPermissionAsync(
        int userId, 
        string pageName, 
        string actionName);
        
    Task<List<MenuItem>> GetUserMenuAsync(int userId);
}

public class PermissionService : IPermissionService
{
    // Check: USUARIO → GRUPO → GRUPO_PAGINA_ACAO → PAGINA_ACAO → PAGINA + ACAO
    public async Task<bool> UserHasPermissionAsync(
        int userId, string pageName, string actionName)
    {
        // 1. Get user's grupo
        var user = await _context.Usuarios
            .Include(u => u.Grupo)
            .FirstOrDefaultAsync(u => u.UsuIdUsuario == userId);
            
        // 2. Get grupo's permissions
        var hasPermission = await _context.GrupoPaginaAcao
            .Include(gpa => gpa.PaginaAcao)
                .ThenInclude(pa => pa.Pagina)
            .Include(gpa => gpa.PaginaAcao)
                .ThenInclude(pa => pa.Acao)
            .AnyAsync(gpa => 
                gpa.GpaIdGrupo == user.Grupo.GruIdGrupo &&
                gpa.PaginaAcao.Pagina.PagDsPagina == pageName &&
                gpa.PaginaAcao.Acao.AcaDsAcao == actionName);
                
        return hasPermission;
    }
}
```

### Authorization Attribute

```csharp
[AttributeUsage(AttributeTargets.Class | AttributeTargets.Method)]
public class RdoAuthorizeAttribute : TypeFilterAttribute
{
    public RdoAuthorizeAttribute(string pageName, string actionName)
        : base(typeof(RdoAuthorizationFilter))
    {
        Arguments = new object[] { pageName, actionName };
    }
}

// Usage in controller
[RdoAuthorize("Obras", "Visualizar")]
public async Task<IActionResult> Index()
{
    // Controller action
}
```

---

## Service Layer Design

### Repository Pattern

```csharp
public interface IRepository<T> where T : class
{
    Task<T> GetByIdAsync(int id);
    Task<IEnumerable<T>> GetAllAsync();
    Task<T> AddAsync(T entity);
    Task UpdateAsync(T entity);
    Task DeleteAsync(int id);
}

public class Repository<T> : IRepository<T> where T : class
{
    protected readonly RdoDbContext _context;
    protected readonly DbSet<T> _dbSet;
    
    public Repository(RdoDbContext context)
    {
        _context = context;
        _dbSet = context.Set<T>();
    }
    
    // Implementation...
}
```

### Service Pattern

```csharp
public interface IObraService
{
    Task<IEnumerable<ObraDto>> GetObrasForUserAsync(int userId);
    Task<ObraDto> GetObraByIdAsync(int obraId);
    Task<ObraDto> CreateObraAsync(CreateObraDto dto);
    Task UpdateObraAsync(int obraId, UpdateObraDto dto);
}

public class ObraService : IObraService
{
    private readonly IRepository<Obra> _obraRepository;
    private readonly ILogger<ObraService> _logger;
    
    public ObraService(
        IRepository<Obra> obraRepository,
        ILogger<ObraService> logger)
    {
        _obraRepository = obraRepository;
        _logger = logger;
    }
    
    public async Task<IEnumerable<ObraDto>> GetObrasForUserAsync(int userId)
    {
        _logger.LogInformation(
            "Getting obras for user {UserId}", userId);
            
        // Business logic here
    }
}
```

---

## Controller Design

### Base Controller

```csharp
public class BaseController : Controller
{
    protected readonly ILogger _logger;
    
    public BaseController(ILogger logger)
    {
        _logger = logger;
    }
    
    protected int GetCurrentUserId()
    {
        // Get user ID from claims
        var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier);
        return int.Parse(userIdClaim.Value);
    }
}
```

### Example Controller

```csharp
public class ObraController : BaseController
{
    private readonly IObraService _obraService;
    
    public ObraController(
        IObraService obraService,
        ILogger<ObraController> logger) : base(logger)
    {
        _obraService = obraService;
    }
    
    [RdoAuthorize("Obras", "Visualizar")]
    public async Task<IActionResult> Index()
    {
        _logger.LogInformation("Loading obras list");
        
        var userId = GetCurrentUserId();
        var obras = await _obraService.GetObrasForUserAsync(userId);
        
        _logger.LogInformation(
            "Loaded {Count} obras for user {UserId}", 
            obras.Count(), userId);
            
        return View(obras);
    }
}
```

---

## View Design (Critical - Lessons Learned)

### Layout Structure

**_Layout.cshtml:**
```html
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>@ViewData["Title"] - RDO App</title>
    
    <!-- Local Bootstrap (NOT CDN - for incognito mode) -->
    <link rel="stylesheet" href="~/lib/bootstrap/css/bootstrap.min.css" />
    <link rel="stylesheet" href="~/css/site.css" />
</head>
<body>
    <header>
        <!-- Navigation -->
    </header>
    
    <main>
        @RenderBody()
    </main>
    
    <footer>
        <!-- Footer -->
    </footer>
    
    <!-- Local JavaScript (NOT CDN) -->
    <script src="~/lib/bootstrap/js/bootstrap.bundle.min.js"></script>
    @await RenderSectionAsync("Scripts", required: false)
</body>
</html>
```

### View Best Practices

**✅ CORRECT - Clean Razor View:**
```html
@model IEnumerable<ObraDto>

@{
    ViewData["Title"] = "Escolher Obra";
}

<div class="container">
    <h1>Selecione uma Obra</h1>
    
    <div class="row" id="obra-list" data-count="@Model.Count()">
        @foreach (var obra in Model)
        {
            <div class="col-md-4 mb-3">
                <div class="card" data-obra-id="@obra.Id">
                    <div class="card-body">
                        <h5 class="card-title">@obra.Nome</h5>
                        <p class="card-text">@obra.Cidade</p>
                        <a href="#" class="btn btn-primary select-obra">
                            Acessar
                        </a>
                    </div>
                </div>
            </div>
        }
    </div>
</div>

@section Scripts {
    <script src="~/js/obra-selection.js"></script>
}
```

**❌ WRONG - DO NOT DO THIS:**
```html
<!-- ❌ NEVER DO THIS -->
<script>
    console.log("Model count: @Model.Count()");
    console.log("User ID: @User.FindFirst(ClaimTypes.NameIdentifier).Value");
</script>

<!-- ❌ NEVER MIX RAZOR AND JAVASCRIPT -->
<script>
    var obras = @Html.Raw(Json.Serialize(Model));
</script>
```

### JavaScript File Structure

**obra-selection.js:**
```javascript
// Pure JavaScript - NO Razor syntax
document.addEventListener('DOMContentLoaded', function() {
    const obraList = document.getElementById('obra-list');
    const obraCount = obraList.dataset.count;
    
    console.log(`Loaded ${obraCount} obras`);
    
    // Event delegation for obra selection
    obraList.addEventListener('click', function(e) {
        if (e.target.classList.contains('select-obra')) {
            e.preventDefault();
            const card = e.target.closest('.card');
            const obraId = card.dataset.obraId;
            selectObra(obraId);
        }
    });
});

function selectObra(obraId) {
    // AJAX call to select obra
    fetch(`/Obra/Select/${obraId}`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        }
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            window.location.href = '/Obra/Dashboard';
        }
    });
}
```

---

## Data Transfer Objects (DTOs)

### Purpose
- Separate database entities from API/View models
- Control what data is exposed
- Add computed properties
- Validation attributes

### Example DTOs

```csharp
public class ObraDto
{
    public int Id { get; set; }
    public string Nome { get; set; }
    public string Cidade { get; set; }
    public string Estado { get; set; }
    public DateTime DataInicio { get; set; }
    public DateTime? DataFim { get; set; }
    public string Status { get; set; }
    
    // Computed properties
    public int DiasDecorridos => 
        (DateTime.Now - DataInicio).Days;
}

public class CreateObraDto
{
    [Required]
    [StringLength(100)]
    public string Nome { get; set; }
    
    [Required]
    public int MunicipioId { get; set; }
    
    public int? EmpresaDonoId { get; set; }
    public int? EmpresaContratanteId { get; set; }
    public int? EmpresaContratadaId { get; set; }
    
    [Required]
    public DateTime DataInicio { get; set; }
}
```

---

## Configuration Management

### appsettings.json Structure

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Database=piscinas_rdoapp;User=root;Password=***;"
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning",
      "Microsoft.EntityFrameworkCore": "Warning"
    }
  },
  "Authentication": {
    "CookieExpiration": 60,
    "RequireConfirmedEmail": false
  },
  "Application": {
    "Name": "RDO App",
    "Version": "2.0.0"
  }
}
```

### User Secrets (Development)

```bash
dotnet user-secrets init
dotnet user-secrets set "ConnectionStrings:DefaultConnection" "Server=localhost;..."
```

---

## Error Handling Design

### Global Exception Handler

```csharp
public class GlobalExceptionMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<GlobalExceptionMiddleware> _logger;
    
    public GlobalExceptionMiddleware(
        RequestDelegate next,
        ILogger<GlobalExceptionMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }
    
    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await _next(context);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Unhandled exception occurred");
            await HandleExceptionAsync(context, ex);
        }
    }
    
    private static Task HandleExceptionAsync(
        HttpContext context, Exception exception)
    {
        context.Response.StatusCode = 500;
        context.Response.ContentType = "application/json";
        
        return context.Response.WriteAsync(new
        {
            error = "An error occurred processing your request.",
            details = exception.Message
        }.ToString());
    }
}
```

---

## Testing Strategy

### Unit Testing

```csharp
public class ObraServiceTests
{
    private readonly Mock<IRepository<Obra>> _mockRepository;
    private readonly Mock<ILogger<ObraService>> _mockLogger;
    private readonly ObraService _service;
    
    public ObraServiceTests()
    {
        _mockRepository = new Mock<IRepository<Obra>>();
        _mockLogger = new Mock<ILogger<ObraService>>();
        _service = new ObraService(_mockRepository.Object, _mockLogger.Object);
    }
    
    [Fact]
    public async Task GetObrasForUser_ReturnsObras()
    {
        // Arrange
        var userId = 1;
        var obras = new List<Obra> { /* test data */ };
        _mockRepository.Setup(r => r.GetAllAsync())
            .ReturnsAsync(obras);
            
        // Act
        var result = await _service.GetObrasForUserAsync(userId);
        
        // Assert
        Assert.NotNull(result);
        Assert.NotEmpty(result);
    }
}
```

### Integration Testing

```csharp
public class ObraControllerIntegrationTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly WebApplicationFactory<Program> _factory;
    
    public ObraControllerIntegrationTests(WebApplicationFactory<Program> factory)
    {
        _factory = factory;
    }
    
    [Fact]
    public async Task Index_ReturnsSuccessAndCorrectContentType()
    {
        // Arrange
        var client = _factory.CreateClient();
        
        // Act
        var response = await client.GetAsync("/Obra/Index");
        
        // Assert
        response.EnsureSuccessStatusCode();
        Assert.Equal("text/html; charset=utf-8", 
            response.Content.Headers.ContentType.ToString());
    }
}
```

---

## Performance Optimization

### Query Optimization

```csharp
// ✅ GOOD - Eager loading
var obras = await _context.Obras
    .Include(o => o.Municipio)
    .Include(o => o.EmpresaDono)
    .Where(o => o.ObrIdColaborador == userId)
    .ToListAsync();

// ❌ BAD - N+1 queries
var obras = await _context.Obras
    .Where(o => o.ObrIdColaborador == userId)
    .ToListAsync();
// Each obra.Municipio access triggers a query
```

### Caching Strategy

```csharp
public class CachedPermissionService : IPermissionService
{
    private readonly IMemoryCache _cache;
    private readonly IPermissionService _innerService;
    
    public async Task<bool> UserHasPermissionAsync(
        int userId, string pageName, string actionName)
    {
        var cacheKey = $"permission_{userId}_{pageName}_{actionName}";
        
        if (_cache.TryGetValue(cacheKey, out bool hasPermission))
        {
            return hasPermission;
        }
        
        hasPermission = await _innerService.UserHasPermissionAsync(
            userId, pageName, actionName);
            
        _cache.Set(cacheKey, hasPermission, TimeSpan.FromMinutes(10));
        
        return hasPermission;
    }
}
```

---

## Deployment Configuration

### Program.cs Setup

```csharp
var builder = WebApplication.CreateBuilder(args);

// Add services
builder.Services.AddControllersWithViews();
builder.Services.AddDbContext<RdoDbContext>(options =>
    options.UseMySql(
        builder.Configuration.GetConnectionString("DefaultConnection"),
        ServerVersion.AutoDetect(builder.Configuration.GetConnectionString("DefaultConnection"))));

builder.Services.AddIdentity<ApplicationUser, IdentityRole>()
    .AddEntityFrameworkStores<RdoDbContext>()
    .AddDefaultTokenProviders();

// Configure authentication
builder.Services.ConfigureApplicationCookie(options =>
{
    options.LoginPath = "/Account/Login";
    options.LogoutPath = "/Account/Logout";
    options.AccessDeniedPath = "/Account/AccessDenied";
    options.ExpireTimeSpan = TimeSpan.FromMinutes(60);
    options.SlidingExpiration = true;
});

// Register services
builder.Services.AddScoped(typeof(IRepository<>), typeof(Repository<>));
builder.Services.AddScoped<IObraService, ObraService>();
builder.Services.AddScoped<IPermissionService, PermissionService>();

// Add memory cache
builder.Services.AddMemoryCache();

var app = builder.Build();

// Configure middleware pipeline
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseStaticFiles();
app.UseRouting();
app.UseAuthentication();
app.UseAuthorization();

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}");

app.Run();
```

---

## Migration Checklist

### Phase 1: Foundation
- [ ] Project structure created
- [ ] DbContext configured
- [ ] 15 foundation entities implemented
- [ ] Fluent API configurations complete
- [ ] Database connection working
- [ ] Initial migration created

### Phase 2: Work Management
- [ ] OBRA entity with 3 empresa FKs
- [ ] ETAPA entity
- [ ] TAREFA entity with water quality fields
- [ ] Assignment entities
- [ ] All relationships working

### Phase 3: Authentication
- [ ] ASP.NET Core Identity configured
- [ ] Legacy users migrated
- [ ] RBAC system implemented
- [ ] Login/logout working
- [ ] Permissions enforced

### Phase 4: Reporting
- [ ] RDO entities implemented
- [ ] Task history system
- [ ] Signature workflow
- [ ] Image attachments

### Phase 5: UI
- [ ] Layouts created (NO inline scripts)
- [ ] Login page
- [ ] Project selection page
- [ ] Dashboard
- [ ] All JavaScript in separate files

### Phase 6: Testing
- [ ] Unit tests passing
- [ ] Integration tests passing
- [ ] Browser testing complete
- [ ] User acceptance testing

### Phase 7: Deployment
- [ ] Production configuration
- [ ] Database migration scripts
- [ ] Security hardening
- [ ] Monitoring configured

---

## Success Criteria

### Code Quality
✅ No inline scripts in Razor views  
✅ Proper separation of concerns  
✅ Clean, maintainable code  
✅ Follows .NET 8 best practices  

### Functionality
✅ 100% feature parity with legacy  
✅ All pages work correctly  
✅ Works in incognito mode  
✅ No data loss  

### Testing
✅ All tests pass  
✅ Multiple browser testing complete  
✅ User confirms success  

---

**Status:** ✅ Design Complete  
**Ready for:** Task List Creation  
**Next Step:** Create detailed implementation tasks
