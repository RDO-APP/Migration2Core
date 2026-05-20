# Design Document

## Overview

This design outlines the migration of the Etapa/Tarefa cards view from AngularJS to .NET 8 Razor Pages. The migration will eliminate JavaScript rendering issues while maintaining all existing functionality and visual design.

## Architecture

### Current Architecture (Legacy)
```
Browser → AngularJS Controller → API Endpoints → .NET 8 Backend → Database
```

### New Architecture (Target)
```
Browser → .NET 8 MVC Controller → Service Layer → Database → Razor View
```

### Key Changes
- **Frontend**: AngularJS SPA → Server-rendered Razor Pages
- **Data Flow**: AJAX API calls → Direct controller-to-view model binding
- **Rendering**: Client-side JavaScript → Server-side C# Razor
- **State Management**: JavaScript variables → Server-side ViewModels

## Components and Interfaces

### 1. MVC Controller
**File**: `Controllers/EtapaController.cs` (extend existing)

```csharp
public class EtapaController : Controller
{
    public IActionResult Cards(EtapaFilterViewModel filter = null)
    {
        // Load etapas with tarefas using existing model
        var etapas = EtapaModel.ObterEtapaTarefa(filter ?? new EtapaFilterViewModel());
        var viewModel = new EtapaCardsViewModel 
        {
            Etapas = etapas,
            Filter = filter,
            StatusOptions = GetStatusOptions(),
            CanEdit = User.HasPermission("editar"),
            CanDelete = User.HasPermission("deletar")
        };
        return View(viewModel);
    }
    
    [HttpPost]
    public IActionResult UpdateTaskStatus(int taskId, int statusId)
    {
        // Handle status updates
        // Redirect back to Cards view
    }
}
```

### 2. ViewModels
**File**: `ViewModels/EtapaCardsViewModel.cs`

```csharp
public class EtapaCardsViewModel
{
    public List<EtapaViewModel> Etapas { get; set; }
    public EtapaFilterViewModel Filter { get; set; }
    public List<StatusOption> StatusOptions { get; set; }
    public bool CanEdit { get; set; }
    public bool CanDelete { get; set; }
    public bool IsWorkFinalized { get; set; }
}

public class EtapaFilterViewModel
{
    public string Descricao { get; set; }
    public int StatusTarefa { get; set; }
    public DateTime? DataInicial { get; set; }
    public DateTime? DataFinalPlanejada { get; set; }
    public DateTime? DataInicialExecutada { get; set; }
    public DateTime? DataFinalExecutada { get; set; }
    public int? IdEtapa { get; set; }
}
```

### 3. Razor View Structure
**File**: `Views/Etapa/Cards.cshtml`

```html
@model EtapaCardsViewModel

<section class="etapa-cards">
    <!-- Filter Section -->
    <partial name="_FilterPartial" model="Model.Filter" />
    
    <!-- Cards Section -->
    <div class="lista-tarefas">
        @foreach (var etapa in Model.Etapas)
        {
            <partial name="_EtapaAccordionPartial" model="etapa" />
        }
    </div>
</section>
```

### 4. Partial Views
**Files**: 
- `Views/Etapa/_FilterPartial.cshtml`
- `Views/Etapa/_EtapaAccordionPartial.cshtml`
- `Views/Etapa/_TaskCardPartial.cshtml`

## Data Models

### Existing Models (Reuse)
- `EtapaViewModel`: Already contains Id, Titulo, Tarefas
- `TarefaViewModel`: Already contains all task properties
- `EtapaModel.ObterEtapaTarefa()`: Already returns correct data

### New Models (Create)
- `EtapaCardsViewModel`: Wrapper for view-specific data
- `EtapaFilterViewModel`: Filter parameters

## Error Handling

### Server-Side Validation
```csharp
public IActionResult Cards(EtapaFilterViewModel filter)
{
    try
    {
        // Validate filter parameters
        if (filter?.DataInicial > filter?.DataFinalPlanejada)
        {
            ModelState.AddModelError("", "Data final deve ser maior que data inicial");
        }
        
        // Load data with error handling
        var etapas = EtapaModel.ObterEtapaTarefa(filter);
        return View(new EtapaCardsViewModel { Etapas = etapas, Filter = filter });
    }
    catch (Exception ex)
    {
        // Log error and show user-friendly message
        return View("Error", new ErrorViewModel { Message = "Erro ao carregar etapas" });
    }
}
```

### Client-Side Enhancements
- Progressive enhancement with minimal JavaScript
- Form validation using HTML5 attributes
- Graceful degradation for accordion functionality

## Testing Strategy

### Unit Tests
- Controller action tests with mock data
- ViewModel validation tests
- Model binding tests for filter parameters

### Integration Tests
- End-to-end page rendering tests
- Form submission tests
- Authentication and authorization tests

### Manual Testing
- Cross-browser compatibility
- Mobile responsiveness
- Performance comparison with AngularJS version

## Migration Plan

### Phase 1: Core Infrastructure
1. Create new controller actions
2. Create ViewModels
3. Set up basic Razor view structure

### Phase 2: UI Implementation
1. Create main Cards.cshtml view
2. Implement partial views for reusable components
3. Port CSS and styling from existing implementation

### Phase 3: Interactive Features
1. Implement filtering with form submissions
2. Add task action handlers (edit, delete, status change)
3. Implement accordion behavior with minimal JavaScript

### Phase 4: Testing and Deployment
1. Comprehensive testing
2. Performance optimization
3. Gradual rollout with feature flags

## Performance Considerations

### Server-Side Rendering Benefits
- Faster initial page load (no JavaScript parsing)
- Better SEO and accessibility
- Reduced client-side memory usage
- Elimination of JavaScript errors

### Optimization Strategies
- Efficient database queries (already implemented)
- Partial view caching for repeated elements
- Lazy loading for large task lists
- Minimal JavaScript for enhanced UX

## Security Considerations

### Authentication & Authorization
- Reuse existing authentication middleware
- Implement action-level authorization attributes
- Validate user permissions for task operations

### Input Validation
- Server-side validation for all form inputs
- CSRF protection for form submissions
- SQL injection prevention (already handled by Entity Framework)

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Server-Side Rendering Independence
*For any* valid user request to the Etapa/Tarefa page, the system should render complete task cards without requiring JavaScript execution
**Validates: Requirements 1.2, 5.1, 5.4**

### Property 2: AngularJS Elimination
*For any* rendered HTML page, the output should contain no AngularJS directives, controllers, or dependencies
**Validates: Requirements 1.5**

### Property 3: Filter Parameter Processing
*For any* valid combination of filter parameters (description, dates, status), the system should return appropriately filtered results server-side
**Validates: Requirements 2.4, 4.1, 4.2**

### Property 4: Data Model Consistency
*For any* etapa and tarefa data, the Razor view model should contain the same properties and structure as the current API response
**Validates: Requirements 2.5**

### Property 5: Task Action Availability
*For any* task displayed in the cards view, all required action buttons (edit, delete, view history, new measurement) should be present and functional
**Validates: Requirements 3.1, 3.2**

### Property 6: Status Change Functionality
*For any* valid status transition, the system should successfully update task status and reflect changes in the view
**Validates: Requirements 3.3, 3.5**

### Property 7: Accordion Behavior Preservation
*For any* etapa accordion, the expand/collapse functionality should work using CSS and minimal JavaScript
**Validates: Requirements 3.4**

### Property 8: Filter State Persistence
*For any* applied filter criteria, the system should maintain filter state across page reloads and navigation
**Validates: Requirements 4.3**

### Property 9: Performance Improvement
*For any* page load request, the new Razor implementation should load faster than the equivalent AngularJS version
**Validates: Requirements 5.3**

### Property 10: Error Elimination
*For any* user interaction with the cards view, the system should not generate "container not found" or "key mismatch" JavaScript errors
**Validates: Requirements 5.2**

### Property 11: Cross-Browser Compatibility
*For any* supported browser, the cards view should function correctly without JavaScript dependencies
**Validates: Requirements 5.4**

### Property 12: Authentication Compatibility
*For any* authenticated user, the authorization and permission system should work identically to the current implementation
**Validates: Requirements 6.2**

### Property 13: CSS Class Preservation
*For any* rendered task card, the HTML should contain the same CSS classes as the current implementation
**Validates: Requirements 6.3**

### Property 14: Data Flow Consistency
*For any* task operation (create, update, delete), the data flow and processing should remain identical to the current implementation
**Validates: Requirements 6.4**

### Property 15: Regression Prevention
*For any* existing functionality, the migrated system should maintain the same behavior and capabilities as before migration
**Validates: Requirements 6.5**

## Backward Compatibility

### URL Routing
- Maintain existing routes: `/tarefa/cards`
- Redirect old AngularJS routes to new Razor pages
- Preserve query parameters for filtering

### API Endpoints
- Keep existing API endpoints for other parts of the application
- Gradually deprecate unused endpoints after migration