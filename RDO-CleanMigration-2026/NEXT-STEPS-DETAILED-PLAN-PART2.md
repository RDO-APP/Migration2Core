# RDO Application - Detailed Next Steps Plan (Part 2)

**Continuation from NEXT-STEPS-DETAILED-PLAN.md**

---

## Phase 5: UI Development (Continued)

#### 5.2 Implement Core Pages
**Duration**: 10 days

**Priority 1 Pages** (Days 1-4):
1. **Login Page** (`/Account/Login`)
   - Email/password form
   - Remember me checkbox
   - Forgot password link
   - Error messages

2. **Dashboard** (`/Home/Index`)
   - Summary cards (total obras, active RDOs, pending tasks)
   - Recent activity feed
   - Quick actions
   - Charts (using Chart.js or ApexCharts)

3. **Obras List** (`/Obras/Index`)
   - Searchable/filterable grid
   - Pagination
   - Status indicators
   - Action buttons (view, edit, delete)

4. **Obra Details** (`/Obras/Details/{id}`)
   - Obra information
   - Etapas accordion
   - Tarefas list
   - Colaboradores assigned
   - Equipamentos assigned
   - Recent RDOs

5. **Create/Edit Obra** (`/Obras/Create`, `/Obras/Edit/{id}`)
   - Multi-step form
   - Validation
   - Empresa selection (3 dropdowns)
   - Municipio selection with UF filter
   - Date pickers


**Priority 2 Pages** (Days 5-7):
6. **RDO List** (`/Rdos/Index`)
   - Filter by obra, date range, status
   - Export to PDF
   - Signature status indicators

7. **Create RDO** (`/Rdos/Create`)
   - Obra selection
   - Date picker (max today)
   - Weather conditions
   - Task list with hours worked
   - Worker assignment
   - Equipment assignment
   - Photo upload
   - Comments

8. **RDO Details** (`/Rdos/Details/{id}`)
   - Full RDO information
   - Task details with photos
   - Signatures section
   - Print/PDF export button

9. **Colaboradores Management** (`/Colaboradores/Index`, `/Create`, `/Edit`)
   - CRUD operations
   - Photo upload
   - Document management
   - Assignment history

10. **Tarefas Management** (`/Tarefas/Index`, `/Create`, `/Edit`)
    - Task creation within etapas
    - Progress tracking
    - Water quality fields (for pool projects)
    - Equipment/worker requirements

**Priority 3 Pages** (Days 8-10):
11. **Laudo (Quality Inspection)** pages
12. **Equipment Management** pages
13. **User Management** pages (admin only)
14. **Group/Permission Management** pages (admin only)
15. **Reports** pages (various reports)

**Deliverables**:
- 15+ functional pages
- Responsive design
- Form validation
- AJAX operations
- File upload functionality


#### 5.3 Implement Dynamic Menu System
**Duration**: 2 days

**Menu View Component**:
```csharp
public class MenuViewComponent : ViewComponent
{
    private readonly IPermissionService _permissionService;
    
    public MenuViewComponent(IPermissionService permissionService)
    {
        _permissionService = permissionService;
    }
    
    public async Task<IViewComponentResult> InvokeAsync()
    {
        var usuarioId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "0");
        var menu = await _permissionService.GetUserMenuAsync(usuarioId);
        
        return View(menu);
    }
}
```

**Menu View** (`Views/Shared/Components/Menu/Default.cshtml`):
```html
@model MenuResponse

<nav class="sidebar">
    <ul class="nav flex-column">
        @foreach (var item in Model.Items.Where(i => i.Nivel == 1))
        {
            <li class="nav-item">
                @if (item.HasChildren)
                {
                    <a class="nav-link" data-bs-toggle="collapse" href="#menu-@item.Id">
                        <i class="@item.CssClass"></i>
                        <span>@item.Titulo</span>
                        <i class="fas fa-chevron-down ms-auto"></i>
                    </a>
                    <div class="collapse" id="menu-@item.Id">
                        <ul class="nav flex-column ms-3">
                            @foreach (var child in Model.Items.Where(i => i.PaginaPaiId == item.Id))
                            {
                                <li class="nav-item">
                                    <a class="nav-link" href="@child.Url">
                                        <i class="@child.CssClass"></i>
                                        <span>@child.Titulo</span>
                                    </a>
                                </li>
                            }
                        </ul>
                    </div>
                }
                else
                {
                    <a class="nav-link" href="@item.Url">
                        <i class="@item.CssClass"></i>
                        <span>@item.Titulo</span>
                    </a>
                }
            </li>
        }
    </ul>
</nav>
```

**Deliverables**:
- Dynamic menu component
- Hierarchical menu rendering
- Permission-based menu filtering
- Active page highlighting


#### 5.4 Implement File Upload & Management
**Duration**: 3 days

**Image Upload Service**:
```csharp
public interface IFileUploadService
{
    Task<string> UploadImageAsync(IFormFile file, string folder);
    Task<bool> DeleteImageAsync(string filePath);
    Task<byte[]> GetImageAsync(string filePath);
    string GetImageUrl(string filePath);
}

public class FileUploadService : IFileUploadService
{
    private readonly IWebHostEnvironment _environment;
    private readonly IConfiguration _configuration;
    
    public async Task<string> UploadImageAsync(IFormFile file, string folder)
    {
        // Validate file
        if (file == null || file.Length == 0)
            throw new ValidationException("Arquivo inválido");
        
        // Validate file type
        var allowedExtensions = new[] { ".jpg", ".jpeg", ".png", ".gif" };
        var extension = Path.GetExtension(file.FileName).ToLowerInvariant();
        if (!allowedExtensions.Contains(extension))
            throw new ValidationException("Tipo de arquivo não permitido");
        
        // Validate file size (max 5MB)
        if (file.Length > 5 * 1024 * 1024)
            throw new ValidationException("Arquivo muito grande (máximo 5MB)");
        
        // Generate unique filename
        var fileName = $"{Guid.NewGuid()}{extension}";
        var relativePath = Path.Combine(folder, fileName);
        var fullPath = Path.Combine(_environment.WebRootPath, "uploads", relativePath);
        
        // Ensure directory exists
        Directory.CreateDirectory(Path.GetDirectoryName(fullPath));
        
        // Save file
        using (var stream = new FileStream(fullPath, FileMode.Create))
        {
            await file.CopyToAsync(stream);
        }
        
        return relativePath;
    }
    
    public string GetImageUrl(string filePath)
    {
        return $"/uploads/{filePath}";
    }
}
```

**Image Upload Component**:
```html
<div class="image-upload">
    <input type="file" 
           id="imageUpload" 
           accept="image/*" 
           multiple 
           onchange="handleImageUpload(this)" />
    <div id="imagePreview" class="image-preview-container"></div>
</div>

<script>
async function handleImageUpload(input) {
    const files = input.files;
    const formData = new FormData();
    
    for (let file of files) {
        formData.append('files', file);
    }
    
    try {
        const response = await fetch('/api/upload/images', {
            method: 'POST',
            headers: {
                'Authorization': `Bearer ${getToken()}`
            },
            body: formData
        });
        
        const result = await response.json();
        displayImagePreviews(result.filePaths);
    } catch (error) {
        console.error('Upload failed:', error);
        alert('Erro ao fazer upload das imagens');
    }
}
</script>
```

**Deliverables**:
- File upload service
- Image validation
- Thumbnail generation
- File storage management
- Upload progress indicator

---


## Phase 6: Testing (Week 11)

### Objective
Implement comprehensive testing strategy covering unit, integration, and end-to-end tests.

### Tasks

#### 6.1 Unit Testing
**Duration**: 3 days

**Test Projects**:
- `RdoApp.Core.Tests` - Unit tests for services
- `RdoApp.Core.IntegrationTests` - Integration tests with database

**Example Unit Test**:
```csharp
public class ObraServiceTests
{
    private readonly Mock<IObraRepository> _mockRepository;
    private readonly Mock<IMapper> _mockMapper;
    private readonly Mock<ILogger<ObraService>> _mockLogger;
    private readonly ObraService _service;
    
    public ObraServiceTests()
    {
        _mockRepository = new Mock<IObraRepository>();
        _mockMapper = new Mock<IMapper>();
        _mockLogger = new Mock<ILogger<ObraService>>();
        _service = new ObraService(_mockRepository.Object, _mockMapper.Object, _mockLogger.Object);
    }
    
    [Fact]
    public async Task CreateAsync_ValidRequest_ReturnsObraResponse()
    {
        // Arrange
        var request = new CreateObraRequest
        {
            Descricao = "Test Obra",
            Codigo = "OBR-001",
            EmpresaProprietariaId = 1,
            MunicipioId = 1
        };
        
        var obra = new Obra { ObrIdObra = 1, ObrDsObra = "Test Obra" };
        var response = new ObraResponse { Id = 1, Descricao = "Test Obra" };
        
        _mockMapper.Setup(m => m.Map<Obra>(request)).Returns(obra);
        _mockRepository.Setup(r => r.AddAsync(obra)).ReturnsAsync(obra);
        _mockMapper.Setup(m => m.Map<ObraResponse>(obra)).Returns(response);
        
        // Act
        var result = await _service.CreateAsync(request);
        
        // Assert
        Assert.NotNull(result);
        Assert.Equal(1, result.Id);
        Assert.Equal("Test Obra", result.Descricao);
        _mockRepository.Verify(r => r.AddAsync(It.IsAny<Obra>()), Times.Once);
    }
    
    [Fact]
    public async Task GetByIdAsync_NonExistentId_ReturnsNull()
    {
        // Arrange
        _mockRepository.Setup(r => r.GetByIdAsync(999)).ReturnsAsync((Obra)null);
        
        // Act
        var result = await _service.GetByIdAsync(999);
        
        // Assert
        Assert.Null(result);
    }
}
```

**Test Coverage Goals**:
- Services: 80%+ coverage
- Repositories: 70%+ coverage
- Validators: 90%+ coverage

**Deliverables**:
- 100+ unit tests
- Test coverage reports
- CI/CD integration

