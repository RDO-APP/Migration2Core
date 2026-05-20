# RDO Application - Detailed Next Steps Plan

**Date**: January 26, 2026  
**Current Status**: ✅ All 48 entities migrated (100% complete)  
**Next Phase**: Application Development & Production Deployment

---

## Overview

This document provides a comprehensive, step-by-step plan for taking the RDO application from completed entity migration to a fully functional, production-ready system.

---

## Phase 1: Navigation Properties Activation (Week 1)

### Objective
Uncomment and activate all navigation properties across 48 entities to enable EF Core relationship features.

### Tasks

#### 1.1 Prepare for Navigation Property Activation
**Duration**: 1 day

**Steps**:
1. Create a backup branch: `git checkout -b backup-before-navigation-properties`
2. Review all entity relationships in documentation
3. Create a checklist of all navigation properties to uncomment
4. Plan testing strategy for each relationship type

**Deliverables**:
- Git backup branch
- Navigation properties checklist
- Test plan document


#### 1.2 Uncomment Navigation Properties by Phase
**Duration**: 2 days

**Phase 1 Entities** (Day 1):
- UF → Municipios collection
- Municipio → UF reference
- Licenca → Empresas collection
- Empresa → Licenca, UF, Municipio references
- Colaborador → Empresa, Cargo, Setor references
- Equipamento → Empresa, TipoEquipamento, Marca, Modelo references
- Marca → Equipamentos collection
- Modelo → Marca reference, Equipamentos collection

**Phase 2-3 Entities** (Day 2):
- Obra → Empresa (3 references), Municipio, Ramo
- Etapa → Obra, Tarefas collection
- Tarefa → Etapa, Obra, StatusTarefa, UnidadeDeMedida
- ObraColaborador → Obra, Colaborador, Grupo
- ObraEquipamento → Obra, Equipamento
- ObraTarefaColaborador → Tarefa, ObraColaborador
- ObraTarefaEquipamento → Tarefa, ObraEquipamento

**Testing After Each Phase**:
```bash
dotnet build
dotnet test
curl http://localhost:5229/Home/TestAllEntities
```


#### 1.3 Uncomment Remaining Navigation Properties
**Duration**: 2 days

**Phase 4-6 Entities** (Day 3):
- Rdo → Obra, StatusRdo, Colaborador
- RdoTarefa → Rdo, Tarefa, StatusTarefa
- RdoImagem → Rdo, Imagem
- AssinaturaRdo → Rdo, Colaborador
- Improdutividade → Rdo, TarefaCodigoParalizacao
- Laudo → Tarefa, Colaborador
- Efetivo → Obra, EfetivoStatus
- Acidente → Obra
- AcidenteColaborador → Acidente, Colaborador
- HistoricoTarefaRdo → Tarefa, Rdo, StatusTarefa
- HistoricoTarefaColaborador → HistoricoTarefaRdo, ObraColaborador
- HistoricoTarefaEquipamento → HistoricoTarefaRdo, ObraEquipamento
- HistoricoLogin → Colaborador, Obra

**Phase 7-8 Entities** (Day 4):
- Usuario → Grupo
- Grupo → Licenca, Menu, GrupoPaginaAcoes, ObraColaboradores, Usuarios
- Menu → Grupos, MenuPaginas
- MenuPagina → Menu, Pagina, MenuPaginaPai (self-reference), MenuPaginasFilhas
- Pagina → MenuPaginas, PaginaAcoes
- Acao → PaginaAcoes
- PaginaAcao → Acao, Pagina, GrupoPaginaAcoes
- GrupoPaginaAcao → Grupo, PaginaAcao
- Imagem → Tarefa, RdoImagens

**Deliverables**:
- All navigation properties uncommented
- Compilation successful
- All tests passing


#### 1.4 Test Navigation Properties
**Duration**: 1 day

**Create Test Endpoints**:
```csharp
// Test eager loading
public async Task<IActionResult> TestNavigationProperties()
{
    // Test 1: Obra with related entities
    var obra = await _context.Obras
        .Include(o => o.EmpresaProprietaria)
        .Include(o => o.EmpresaContratante)
        .Include(o => o.EmpresaContratada)
        .Include(o => o.Municipio)
            .ThenInclude(m => m.UF)
        .Include(o => o.Etapas)
            .ThenInclude(e => e.Tarefas)
        .FirstOrDefaultAsync();
    
    // Test 2: Usuario with permissions
    var usuario = await _context.Usuarios
        .Include(u => u.Grupo)
            .ThenInclude(g => g.GrupoPaginaAcoes)
                .ThenInclude(gpa => gpa.PaginaAcao)
                    .ThenInclude(pa => pa.Pagina)
        .FirstOrDefaultAsync();
    
    // Test 3: Rdo with all related data
    var rdo = await _context.Rdos
        .Include(r => r.Obra)
        .Include(r => r.Colaborador)
        .Include(r => r.RdoTarefas)
            .ThenInclude(rt => rt.Tarefa)
        .Include(r => r.RdoImagens)
        .Include(r => r.AssinaturaRdos)
        .FirstOrDefaultAsync();
    
    return Ok("Navigation properties working!");
}
```

**Deliverables**:
- Navigation property test endpoint
- Test results documented
- Performance baseline established

---


## Phase 2: Service Layer & Business Logic (Weeks 2-3)

### Objective
Create a clean service layer that encapsulates business logic and provides a clear API for controllers.

### Architecture Pattern
```
Controllers → Services → Repositories → DbContext → Database
```

### Tasks

#### 2.1 Create Repository Pattern Infrastructure
**Duration**: 2 days

**Generic Repository**:
```csharp
public interface IRepository<T> where T : class
{
    Task<T?> GetByIdAsync(int id);
    Task<IEnumerable<T>> GetAllAsync();
    Task<IEnumerable<T>> FindAsync(Expression<Func<T, bool>> predicate);
    Task<T> AddAsync(T entity);
    Task UpdateAsync(T entity);
    Task DeleteAsync(T entity);
    Task<bool> ExistsAsync(int id);
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

**Specific Repositories**:
- `IObraRepository` / `ObraRepository`
- `IColaboradorRepository` / `ColaboradorRepository`
- `IRdoRepository` / `RdoRepository`
- `IUsuarioRepository` / `UsuarioRepository`

**Deliverables**:
- Generic repository interface and implementation
- 10+ specific repository interfaces
- Unit of Work pattern implementation
- Repository registration in DI container


#### 2.2 Create DTOs (Data Transfer Objects)
**Duration**: 3 days

**DTO Categories**:

1. **Request DTOs** (for creating/updating):
   - `CreateObraRequest`
   - `UpdateObraRequest`
   - `CreateRdoRequest`
   - `CreateTarefaRequest`
   - `AssignColaboradorRequest`

2. **Response DTOs** (for reading):
   - `ObraResponse` (with nested data)
   - `RdoResponse` (with tasks, images, signatures)
   - `ColaboradorResponse`
   - `TarefaResponse`
   - `UsuarioResponse` (without password)

3. **List DTOs** (for grids/lists):
   - `ObraListItem`
   - `RdoListItem`
   - `ColaboradorListItem`

**Example DTO**:
```csharp
public class ObraResponse
{
    public int Id { get; set; }
    public string Descricao { get; set; }
    public string Codigo { get; set; }
    public DateTime DataInicio { get; set; }
    public DateTime? DataTermino { get; set; }
    
    // Nested data
    public EmpresaDto EmpresaProprietaria { get; set; }
    public EmpresaDto EmpresaContratante { get; set; }
    public MunicipioDto Municipio { get; set; }
    
    // Aggregated data
    public int TotalEtapas { get; set; }
    public int TotalTarefas { get; set; }
    public int TarefasConcluidas { get; set; }
    public decimal PercentualConclusao { get; set; }
}
```

**Deliverables**:
- 50+ DTO classes
- AutoMapper configuration
- DTO validation attributes


#### 2.3 Implement Core Services
**Duration**: 5 days

**Service Structure**:
```csharp
public interface IObraService
{
    Task<ObraResponse> GetByIdAsync(int id);
    Task<PagedResult<ObraListItem>> GetPagedAsync(ObraFilter filter);
    Task<ObraResponse> CreateAsync(CreateObraRequest request);
    Task<ObraResponse> UpdateAsync(int id, UpdateObraRequest request);
    Task DeleteAsync(int id);
    Task<bool> CanDeleteAsync(int id);
    Task<IEnumerable<EtapaResponse>> GetEtapasAsync(int obraId);
    Task<IEnumerable<ColaboradorResponse>> GetColaboradoresAsync(int obraId);
}

public class ObraService : IObraService
{
    private readonly IObraRepository _obraRepository;
    private readonly IMapper _mapper;
    private readonly ILogger<ObraService> _logger;
    
    public ObraService(
        IObraRepository obraRepository,
        IMapper mapper,
        ILogger<ObraService> logger)
    {
        _obraRepository = obraRepository;
        _mapper = mapper;
        _logger = logger;
    }
    
    public async Task<ObraResponse> CreateAsync(CreateObraRequest request)
    {
        // Validation
        await ValidateObraAsync(request);
        
        // Business logic
        var obra = _mapper.Map<Obra>(request);
        obra.ObrDtCadastro = DateTime.Now;
        obra.ObrStAtivo = 1;
        
        // Save
        await _obraRepository.AddAsync(obra);
        
        // Return
        return _mapper.Map<ObraResponse>(obra);
    }
    
    // Other methods...
}
```

**Services to Implement**:
1. `ObraService` - Project management
2. `TarefaService` - Task management
3. `ColaboradorService` - Worker management
4. `EquipamentoService` - Equipment management
5. `RdoService` - Daily report management
6. `LaudoService` - Quality inspection management
7. `UsuarioService` - User management
8. `AuthenticationService` - Login/logout
9. `PermissionService` - RBAC checks
10. `MenuService` - Dynamic menu generation

**Deliverables**:
- 10+ service interfaces
- 10+ service implementations
- Business validation logic
- Service registration in DI


#### 2.4 Implement Business Rules & Validations
**Duration**: 3 days

**Validation Categories**:

1. **Entity Validation**:
   - Required fields
   - String length limits
   - Date range validations
   - Numeric range validations

2. **Business Rule Validation**:
   - Obra must have at least one Etapa
   - Tarefa dates must be within Etapa dates
   - Colaborador can only be assigned to active Obras
   - RDO can only be created for current or past dates
   - Only authorized users can sign RDOs

3. **Cross-Entity Validation**:
   - Empresa must be active to create Obra
   - Colaborador must be assigned to Obra before task assignment
   - Equipment must be assigned to Obra before task assignment

**Example Validator**:
```csharp
public class CreateRdoValidator : AbstractValidator<CreateRdoRequest>
{
    private readonly IObraRepository _obraRepository;
    private readonly IColaboradorRepository _colaboradorRepository;
    
    public CreateRdoValidator(
        IObraRepository obraRepository,
        IColaboradorRepository colaboradorRepository)
    {
        _obraRepository = obraRepository;
        _colaboradorRepository = colaboradorRepository;
        
        RuleFor(x => x.ObraId)
            .NotEmpty()
            .MustAsync(ObraExists).WithMessage("Obra não encontrada")
            .MustAsync(ObraIsActive).WithMessage("Obra inativa");
            
        RuleFor(x => x.DataRdo)
            .NotEmpty()
            .LessThanOrEqualTo(DateTime.Today)
            .WithMessage("RDO não pode ser criado para data futura");
            
        RuleFor(x => x.ColaboradorId)
            .NotEmpty()
            .MustAsync(ColaboradorAssignedToObra)
            .WithMessage("Colaborador não está atribuído a esta obra");
    }
    
    private async Task<bool> ObraExists(int obraId, CancellationToken ct)
        => await _obraRepository.ExistsAsync(obraId);
    
    // Other validation methods...
}
```

**Deliverables**:
- FluentValidation package installed
- 20+ validator classes
- Custom validation rules
- Validation error handling

---


## Phase 3: Authentication & Authorization (Week 4)

### Objective
Implement secure authentication and role-based authorization using the existing RBAC entities.

### Tasks

#### 3.1 Implement Authentication Service
**Duration**: 2 days

**Features**:
- Email/password login
- JWT token generation
- Refresh token support
- Password hashing (BCrypt)
- Account lockout after failed attempts
- Password reset functionality

**Implementation**:
```csharp
public interface IAuthenticationService
{
    Task<LoginResponse> LoginAsync(LoginRequest request);
    Task<LoginResponse> RefreshTokenAsync(string refreshToken);
    Task LogoutAsync(int usuarioId);
    Task<bool> ChangePasswordAsync(int usuarioId, ChangePasswordRequest request);
    Task<bool> ResetPasswordAsync(ResetPasswordRequest request);
}

public class AuthenticationService : IAuthenticationService
{
    private readonly IUsuarioRepository _usuarioRepository;
    private readonly IConfiguration _configuration;
    private readonly ILogger<AuthenticationService> _logger;
    
    public async Task<LoginResponse> LoginAsync(LoginRequest request)
    {
        // 1. Find user by email
        var usuario = await _usuarioRepository.GetByEmailAsync(request.Email);
        if (usuario == null)
            throw new UnauthorizedException("Credenciais inválidas");
        
        // 2. Verify password
        if (!BCrypt.Net.BCrypt.Verify(request.Password, usuario.UsuDsSenha))
        {
            await _usuarioRepository.IncrementFailedLoginAsync(usuario.UsuIdUsuario);
            throw new UnauthorizedException("Credenciais inválidas");
        }
        
        // 3. Check if account is active
        if (usuario.UsuStStatus != 1)
            throw new UnauthorizedException("Conta inativa");
        
        // 4. Generate JWT token
        var token = GenerateJwtToken(usuario);
        var refreshToken = GenerateRefreshToken();
        
        // 5. Save refresh token
        await _usuarioRepository.SaveRefreshTokenAsync(
            usuario.UsuIdUsuario, 
            refreshToken);
        
        // 6. Reset failed login count
        await _usuarioRepository.ResetFailedLoginAsync(usuario.UsuIdUsuario);
        
        return new LoginResponse
        {
            Token = token,
            RefreshToken = refreshToken,
            ExpiresIn = 3600,
            Usuario = _mapper.Map<UsuarioResponse>(usuario)
        };
    }
    
    private string GenerateJwtToken(Usuario usuario)
    {
        var claims = new[]
        {
            new Claim(ClaimTypes.NameIdentifier, usuario.UsuIdUsuario.ToString()),
            new Claim(ClaimTypes.Email, usuario.UsuDsEmail),
            new Claim("GrupoId", usuario.UsuIdGrupo.ToString())
        };
        
        var key = new SymmetricSecurityKey(
            Encoding.UTF8.GetBytes(_configuration["Jwt:Secret"]));
        var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);
        
        var token = new JwtSecurityToken(
            issuer: _configuration["Jwt:Issuer"],
            audience: _configuration["Jwt:Audience"],
            claims: claims,
            expires: DateTime.Now.AddHours(1),
            signingCredentials: creds);
        
        return new JwtSecurityTokenHandler().WriteToken(token);
    }
}
```

**Deliverables**:
- Authentication service implementation
- JWT configuration
- Login/logout endpoints
- Password management endpoints


#### 3.2 Implement Authorization Service
**Duration**: 3 days

**RBAC Implementation**:
```csharp
public interface IPermissionService
{
    Task<bool> UserHasPermissionAsync(int usuarioId, string paginaAlias, string acaoAlias);
    Task<IEnumerable<string>> GetUserPermissionsAsync(int usuarioId);
    Task<IEnumerable<PaginaResponse>> GetUserPagesAsync(int usuarioId);
    Task<MenuResponse> GetUserMenuAsync(int usuarioId);
}

public class PermissionService : IPermissionService
{
    private readonly RdoDbContext _context;
    private readonly IMemoryCache _cache;
    
    public async Task<bool> UserHasPermissionAsync(
        int usuarioId, 
        string paginaAlias, 
        string acaoAlias)
    {
        // Check cache first
        var cacheKey = $"permission_{usuarioId}_{paginaAlias}_{acaoAlias}";
        if (_cache.TryGetValue(cacheKey, out bool hasPermission))
            return hasPermission;
        
        // Query database
        var result = await _context.Usuarios
            .Where(u => u.UsuIdUsuario == usuarioId)
            .SelectMany(u => u.Grupo.GrupoPaginaAcoes)
            .AnyAsync(gpa => 
                gpa.PaginaAcao.Pagina.PagDsAlias == paginaAlias &&
                gpa.PaginaAcao.Acao.AcaDsAlias == acaoAlias);
        
        // Cache for 5 minutes
        _cache.Set(cacheKey, result, TimeSpan.FromMinutes(5));
        
        return result;
    }
    
    public async Task<MenuResponse> GetUserMenuAsync(int usuarioId)
    {
        var usuario = await _context.Usuarios
            .Include(u => u.Grupo)
                .ThenInclude(g => g.Menu)
                    .ThenInclude(m => m.MenuPaginas)
                        .ThenInclude(mp => mp.Pagina)
            .Include(u => u.Grupo)
                .ThenInclude(g => g.GrupoPaginaAcoes)
                    .ThenInclude(gpa => gpa.PaginaAcao)
                        .ThenInclude(pa => pa.Pagina)
            .FirstOrDefaultAsync(u => u.UsuIdUsuario == usuarioId);
        
        if (usuario == null)
            return null;
        
        // Build menu structure with only pages user has access to
        var menu = usuario.Grupo.Menu;
        var userPages = usuario.Grupo.GrupoPaginaAcoes
            .Select(gpa => gpa.PaginaAcao.Pagina.PagIdPagina)
            .Distinct()
            .ToHashSet();
        
        var menuItems = menu.MenuPaginas
            .Where(mp => userPages.Contains(mp.MpaIdPagina))
            .OrderBy(mp => mp.MpaVlOrdem)
            .Select(mp => new MenuItemResponse
            {
                Id = mp.MpaIdMenuPagina,
                Titulo = mp.Pagina.PagNmTitulo,
                Url = mp.Pagina.PagDsUrl,
                Nivel = mp.MpaVlNivel,
                Ordem = mp.MpaVlOrdem,
                CssClass = mp.MpaDsClass,
                PaginaPaiId = mp.MpaIdPaginaPai
            })
            .ToList();
        
        return new MenuResponse
        {
            MenuId = menu.MenIdMenu,
            Titulo = menu.MenNmTitulo,
            Items = BuildMenuHierarchy(menuItems)
        };
    }
}
```

**Custom Authorization Attributes**:
```csharp
[AttributeUsage(AttributeTargets.Class | AttributeTargets.Method)]
public class RequirePermissionAttribute : Attribute, IAuthorizationFilter
{
    private readonly string _paginaAlias;
    private readonly string _acaoAlias;
    
    public RequirePermissionAttribute(string paginaAlias, string acaoAlias)
    {
        _paginaAlias = paginaAlias;
        _acaoAlias = acaoAlias;
    }
    
    public void OnAuthorization(AuthorizationFilterContext context)
    {
        var permissionService = context.HttpContext
            .RequestServices.GetService<IPermissionService>();
        
        var usuarioId = int.Parse(context.HttpContext.User
            .FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "0");
        
        var hasPermission = permissionService
            .UserHasPermissionAsync(usuarioId, _paginaAlias, _acaoAlias)
            .GetAwaiter()
            .GetResult();
        
        if (!hasPermission)
        {
            context.Result = new ForbidResult();
        }
    }
}

// Usage:
[RequirePermission("obras", "criar")]
public async Task<IActionResult> CreateObra([FromBody] CreateObraRequest request)
{
    // Only users with "criar" permission on "obras" page can access
}
```

**Deliverables**:
- Permission service implementation
- Custom authorization attributes
- Permission caching
- Menu generation based on permissions


#### 3.3 Configure JWT Authentication
**Duration**: 1 day

**Program.cs Configuration**:
```csharp
// Add JWT Authentication
builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidateLifetime = true,
        ValidateIssuerSigningKey = true,
        ValidIssuer = builder.Configuration["Jwt:Issuer"],
        ValidAudience = builder.Configuration["Jwt:Audience"],
        IssuerSigningKey = new SymmetricSecurityKey(
            Encoding.UTF8.GetBytes(builder.Configuration["Jwt:Secret"]))
    };
});

// Add Authorization
builder.Services.AddAuthorization();
```

**appsettings.json**:
```json
{
  "Jwt": {
    "Secret": "your-super-secret-key-min-32-characters",
    "Issuer": "RdoApp",
    "Audience": "RdoAppUsers",
    "ExpirationMinutes": 60
  }
}
```

**Deliverables**:
- JWT configuration
- Authentication middleware
- Secure secret management
- Token expiration handling

---


## Phase 4: RESTful API Development (Weeks 5-6)

### Objective
Create comprehensive RESTful API endpoints for all major entities.

### Tasks

#### 4.1 Create API Controllers
**Duration**: 5 days

**Controller Structure**:
```csharp
[ApiController]
[Route("api/[controller]")]
[Authorize]
public class ObrasController : ControllerBase
{
    private readonly IObraService _obraService;
    private readonly ILogger<ObrasController> _logger;
    
    public ObrasController(IObraService obraService, ILogger<ObrasController> logger)
    {
        _obraService = obraService;
        _logger = logger;
    }
    
    /// <summary>
    /// Get all obras with pagination and filtering
    /// </summary>
    [HttpGet]
    [RequirePermission("obras", "listar")]
    public async Task<ActionResult<PagedResult<ObraListItem>>> GetAll(
        [FromQuery] ObraFilter filter)
    {
        var result = await _obraService.GetPagedAsync(filter);
        return Ok(result);
    }
    
    /// <summary>
    /// Get obra by ID with full details
    /// </summary>
    [HttpGet("{id}")]
    [RequirePermission("obras", "visualizar")]
    public async Task<ActionResult<ObraResponse>> GetById(int id)
    {
        var obra = await _obraService.GetByIdAsync(id);
        if (obra == null)
            return NotFound();
        
        return Ok(obra);
    }
    
    /// <summary>
    /// Create new obra
    /// </summary>
    [HttpPost]
    [RequirePermission("obras", "criar")]
    public async Task<ActionResult<ObraResponse>> Create(
        [FromBody] CreateObraRequest request)
    {
        var obra = await _obraService.CreateAsync(request);
        return CreatedAtAction(nameof(GetById), new { id = obra.Id }, obra);
    }
    
    /// <summary>
    /// Update existing obra
    /// </summary>
    [HttpPut("{id}")]
    [RequirePermission("obras", "editar")]
    public async Task<ActionResult<ObraResponse>> Update(
        int id, 
        [FromBody] UpdateObraRequest request)
    {
        var obra = await _obraService.UpdateAsync(id, request);
        return Ok(obra);
    }
    
    /// <summary>
    /// Delete obra
    /// </summary>
    [HttpDelete("{id}")]
    [RequirePermission("obras", "excluir")]
    public async Task<IActionResult> Delete(int id)
    {
        await _obraService.DeleteAsync(id);
        return NoContent();
    }
    
    /// <summary>
    /// Get etapas for obra
    /// </summary>
    [HttpGet("{id}/etapas")]
    [RequirePermission("obras", "visualizar")]
    public async Task<ActionResult<IEnumerable<EtapaResponse>>> GetEtapas(int id)
    {
        var etapas = await _obraService.GetEtapasAsync(id);
        return Ok(etapas);
    }
    
    /// <summary>
    /// Get colaboradores assigned to obra
    /// </summary>
    [HttpGet("{id}/colaboradores")]
    [RequirePermission("obras", "visualizar")]
    public async Task<ActionResult<IEnumerable<ColaboradorResponse>>> GetColaboradores(int id)
    {
        var colaboradores = await _obraService.GetColaboradoresAsync(id);
        return Ok(colaboradores);
    }
}
```

**Controllers to Create**:
1. `ObrasController` - Project management
2. `TarefasController` - Task management
3. `ColaboradoresController` - Worker management
4. `EquipamentosController` - Equipment management
5. `RdosController` - Daily reports
6. `LaudosController` - Quality inspections
7. `EtapasController` - Project phases
8. `UsuariosController` - User management
9. `GruposController` - Group management
10. `EmpresasController` - Company management

**Deliverables**:
- 10+ API controllers
- Swagger documentation
- API versioning
- Error handling middleware


#### 4.2 Implement Swagger/OpenAPI Documentation
**Duration**: 1 day

**Configuration**:
```csharp
// Program.cs
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "RDO API",
        Version = "v1",
        Description = "API para gerenciamento de Relatórios Diários de Obra",
        Contact = new OpenApiContact
        {
            Name = "RDO Team",
            Email = "support@rdoapp.com"
        }
    });
    
    // Add JWT authentication to Swagger
    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Description = "JWT Authorization header using the Bearer scheme",
        Name = "Authorization",
        In = ParameterLocation.Header,
        Type = SecuritySchemeType.ApiKey,
        Scheme = "Bearer"
    });
    
    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            Array.Empty<string>()
        }
    });
    
    // Include XML comments
    var xmlFile = $"{Assembly.GetExecutingAssembly().GetName().Name}.xml";
    var xmlPath = Path.Combine(AppContext.BaseDirectory, xmlFile);
    c.IncludeXmlComments(xmlPath);
});

app.UseSwagger();
app.UseSwaggerUI(c =>
{
    c.SwaggerEndpoint("/swagger/v1/swagger.json", "RDO API V1");
    c.RoutePrefix = "api-docs";
});
```

**Deliverables**:
- Swagger UI configured
- XML documentation enabled
- JWT authentication in Swagger
- API examples and descriptions


#### 4.3 Implement Error Handling & Logging
**Duration**: 2 days

**Global Exception Handler**:
```csharp
public class GlobalExceptionHandler : IExceptionHandler
{
    private readonly ILogger<GlobalExceptionHandler> _logger;
    
    public GlobalExceptionHandler(ILogger<GlobalExceptionHandler> logger)
    {
        _logger = logger;
    }
    
    public async ValueTask<bool> TryHandleAsync(
        HttpContext httpContext,
        Exception exception,
        CancellationToken cancellationToken)
    {
        var problemDetails = new ProblemDetails();
        
        switch (exception)
        {
            case ValidationException validationException:
                problemDetails.Status = StatusCodes.Status400BadRequest;
                problemDetails.Title = "Validation Error";
                problemDetails.Detail = validationException.Message;
                problemDetails.Extensions["errors"] = validationException.Errors;
                break;
                
            case NotFoundException notFoundException:
                problemDetails.Status = StatusCodes.Status404NotFound;
                problemDetails.Title = "Not Found";
                problemDetails.Detail = notFoundException.Message;
                break;
                
            case UnauthorizedException unauthorizedException:
                problemDetails.Status = StatusCodes.Status401Unauthorized;
                problemDetails.Title = "Unauthorized";
                problemDetails.Detail = unauthorizedException.Message;
                break;
                
            case ForbiddenException forbiddenException:
                problemDetails.Status = StatusCodes.Status403Forbidden;
                problemDetails.Title = "Forbidden";
                problemDetails.Detail = forbiddenException.Message;
                break;
                
            default:
                problemDetails.Status = StatusCodes.Status500InternalServerError;
                problemDetails.Title = "Internal Server Error";
                problemDetails.Detail = "An unexpected error occurred";
                _logger.LogError(exception, "Unhandled exception occurred");
                break;
        }
        
        httpContext.Response.StatusCode = problemDetails.Status.Value;
        await httpContext.Response.WriteAsJsonAsync(problemDetails, cancellationToken);
        
        return true;
    }
}
```

**Structured Logging with Serilog**:
```csharp
// Program.cs
builder.Host.UseSerilog((context, configuration) =>
{
    configuration
        .ReadFrom.Configuration(context.Configuration)
        .Enrich.FromLogContext()
        .Enrich.WithMachineName()
        .Enrich.WithEnvironmentName()
        .WriteTo.Console()
        .WriteTo.File(
            path: "logs/rdoapp-.log",
            rollingInterval: RollingInterval.Day,
            retainedFileCountLimit: 30)
        .WriteTo.MySQL(
            connectionString: context.Configuration.GetConnectionString("DefaultConnection"),
            tableName: "logs");
});
```

**Deliverables**:
- Global exception handler
- Custom exception types
- Structured logging
- Log aggregation

---


## Phase 5: UI Development (Weeks 7-10)

### Objective
Build modern, responsive UI using Razor Pages or Blazor Server.

### Technology Decision

**Option A: Razor Pages** (Recommended for this project)
- Server-side rendering
- Better SEO
- Simpler architecture
- Easier to maintain
- Good for form-heavy applications

**Option B: Blazor Server**
- Real-time updates
- Rich interactivity
- Component-based
- Better for dashboard-heavy apps

**Recommendation**: Use **Razor Pages** for main application, **Blazor Server** for dashboard/real-time features.

### Tasks

#### 5.1 Setup UI Infrastructure
**Duration**: 2 days

**Layout Structure**:
```
Views/
├── Shared/
│   ├── _Layout.cshtml (Main layout)
│   ├── _LoginLayout.cshtml (Login page layout)
│   ├── _Sidebar.cshtml (Navigation sidebar)
│   ├── _Header.cshtml (Top header)
│   ├── _Footer.cshtml (Footer)
│   └── Components/
│       ├── MenuViewComponent.cs (Dynamic menu)
│       ├── BreadcrumbViewComponent.cs
│       └── NotificationViewComponent.cs
├── Home/
│   ├── Index.cshtml (Dashboard)
│   └── Privacy.cshtml
├── Account/
│   ├── Login.cshtml
│   ├── ForgotPassword.cshtml
│   └── ChangePassword.cshtml
└── [Entity folders...]
```

**CSS Framework**: Bootstrap 5 + Custom CSS
**JavaScript**: jQuery + Alpine.js for interactivity
**Icons**: Font Awesome or Bootstrap Icons

**Deliverables**:
- Layout templates
- CSS framework setup
- JavaScript libraries
- Component infrastructure

