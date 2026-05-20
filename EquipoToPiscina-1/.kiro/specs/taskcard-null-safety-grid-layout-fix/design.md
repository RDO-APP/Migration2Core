# Design Document

## Overview

This design addresses two critical issues in the task card system: null reference errors during task rendering and width stretching caused by flexbox layout overriding the Hard Lock constraints. The solution implements comprehensive null safety checks and replaces the flexbox container with CSS Grid to maintain the Legacy Standard 300px card width.

## Architecture

### Current Issues Analysis

1. **Null Reference Error**: The `_EtapaAccordionPartial.cshtml` iterates through `Model.SafeTarefas` without validating individual task items, causing null reference exceptions when the collection contains null entries.

2. **Width Stretching**: The current flexbox layout with `display: flex; flex-wrap: wrap` allows cards to stretch beyond 300px when fewer cards exist than can fill a row, despite the Hard Lock CSS constraints.

### Solution Architecture

```
┌─────────────────────────────────────────┐
│           Grid Container                │
│  display: grid                          │
│  grid-template-columns: repeat(         │
│    auto-fill, 300px)                    │
│                                         │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐   │
│  │Task Card│ │Task Card│ │Task Card│   │
│  │ 300px   │ │ 300px   │ │ 300px   │   │
│  │ Fixed   │ │ Fixed   │ │ Fixed   │   │
│  └─────────┘ └─────────┘ └─────────┘   │
│                                         │
│  ┌─────────┐ ┌─────────┐               │
│  │Task Card│ │Task Card│   [Empty]     │
│  │ 300px   │ │ 300px   │   [Space]     │
│  │ Fixed   │ │ Fixed   │               │
│  └─────────┘ └─────────┘               │
└─────────────────────────────────────────┘
```

## Components and Interfaces

### 1. Enhanced EtapaViewModel Safety

**File**: `RDO-NET8-Migration/RdoApp.Core/Models/ViewModels/EtapaViewModel.cs`

Add additional safety properties:

```csharp
public class EtapaViewModel
{
    // Existing properties...
    
    // Enhanced null safety
    public List<TarefaViewModel> ValidTarefas => 
        SafeTarefas?.Where(t => t != null && t.Id > 0).ToList() ?? new List<TarefaViewModel>();
    
    public bool HasValidTarefas => ValidTarefas.Any();
    
    public string SafeIterationDebug => 
        $"Total: {SafeTarefas?.Count ?? 0}, Valid: {ValidTarefas.Count}, Nulls: {(SafeTarefas?.Count(t => t == null) ?? 0)}";
}
```

### 2. Null-Safe Accordion Partial

**File**: `RDO-NET8-Migration/RdoApp.Core/Views/Etapa/_EtapaAccordionPartial.cshtml`

Replace the task iteration with null-safe approach:

```razor
@model EtapaViewModel

<div class="accordion-item">
    <!-- Accordion header remains the same -->
    <h2 class="accordion-header" id="heading-etapa-@Model.Id">
        <button class="accordion-button collapsed" 
                type="button" 
                data-bs-toggle="collapse" 
                data-bs-target="#collapse-etapa-@Model.Id" 
                aria-expanded="false" 
                aria-controls="collapse-etapa-@Model.Id">
            
            <div class="card kiro-compact-card" style="margin: 0; display: block; width: 100%; border: none; background: transparent;">
                <div class="head kiro-card-header" style="display: flex; align-items: center; padding: 8px 12px; border-radius: 4px;">
                    <i class="fa fa-hand-paper-o" style="margin-right: 8px;"></i>
                    <span class="task-title">@Model.SafeDescricao</span>
                    <span class="badge bg-primary ms-auto" style="margin-left: auto;">@Model.BadgeText</span>
                </div>
            </div>
        </button>
    </h2>
    
    <div id="collapse-etapa-@Model.Id" 
         class="accordion-collapse collapse" 
         aria-labelledby="heading-etapa-@Model.Id" 
         data-bs-parent="#accordion">
        <div class="accordion-body">
            @if (Model.HasValidTarefas)
            {
                <!-- FIXED: CSS Grid Container instead of Flexbox -->
                <div class="task-cards-grid-container">
                    @foreach (var tarefa in Model.ValidTarefas)
                    {
                        @if (tarefa != null && tarefa.Id > 0)
                        {
                            <component type="typeof(RdoApp.Core.Components.TaskCard)" 
                                       render-mode="ServerPrerendered" 
                                       param-Task="tarefa" 
                                       param-CanEdit="@(ViewBag.CanEdit == true)" 
                                       param-IsWorkFinalized="@(ViewBag.IsWorkFinalized == true)" />
                        }
                    }
                </div>
                
                <!-- Add Task Button -->
                @if (ViewBag.CanCreateNew == true && ViewBag.IsWorkFinalized != true)
                {
                    <div class="add-task-button-container">
                        <button id="btn-adicionar-nova-tarefa-@Model.Id" class="btn btn-outline-primary" onclick="novaTarefa(@Model.Id)">
                            <i class="fa fa-clipboard" aria-hidden="true"></i>
                            <span>Adicionar nova tarefa</span>
                        </button>
                    </div>
                }
            }
            else
            {
                <!-- Empty state with debug info -->
                <div class="empty-state-container">
                    <i class="fa fa-info-circle fa-2x text-muted mb-2"></i>
                    <p class="text-muted">Nenhuma tarefa válida encontrada nesta etapa.</p>
                    <small class="text-muted">Debug: @Model.SafeIterationDebug</small>
                </div>
                
                @if (ViewBag.CanCreateNew == true && ViewBag.IsWorkFinalized != true)
                {
                    <div class="text-center mt-3">
                        <button id="btn-adicionar-nova-tarefa-@Model.Id" class="btn btn-outline-primary" onclick="novaTarefa(@Model.Id)">
                            <i class="fa fa-clipboard" aria-hidden="true"></i>
                            <span>Adicionar nova tarefa</span>
                        </button>
                    </div>
                }
            }
        </div>
    </div>
</div>
```

### 3. CSS Grid Layout Styles

**File**: `RDO-NET8-Migration/RdoApp.Core/wwwroot/css/task-cards-compact.css`

Add CSS Grid container styles:

```css
/* CSS GRID LAYOUT - LEGACY STANDARD 300PX ENFORCEMENT */
.task-cards-grid-container {
    display: grid !important;
    grid-template-columns: repeat(auto-fill, 300px) !important;
    gap: 10px !important;
    padding: 8px 0 !important;
    justify-content: start !important; /* Align to left instead of center */
    width: 100% !important;
    box-sizing: border-box !important;
}

/* Ensure grid items don't stretch */
.task-cards-grid-container > * {
    width: 300px !important;
    max-width: 300px !important;
    min-width: 300px !important;
    justify-self: start !important;
}

/* Add Task Button Styling */
.add-task-button-container {
    margin-top: 16px !important;
    text-align: center !important;
    grid-column: 1 / -1 !important; /* Span full width if inside grid */
}

/* Empty State Styling */
.empty-state-container {
    text-align: center !important;
    width: 100% !important;
    padding: 20px !important;
    grid-column: 1 / -1 !important; /* Span full width */
}

/* Debug info styling */
.empty-state-container small {
    display: block !important;
    margin-top: 8px !important;
    font-family: monospace !important;
    background: #f8f9fa !important;
    padding: 4px 8px !important;
    border-radius: 4px !important;
    border: 1px solid #dee2e6 !important;
}

/* Responsive behavior - maintain 300px cards */
@media (max-width: 768px) {
    .task-cards-grid-container {
        grid-template-columns: repeat(auto-fill, 300px) !important;
        justify-content: center !important; /* Center on mobile */
    }
}

@media (max-width: 320px) {
    .task-cards-grid-container {
        grid-template-columns: 1fr !important; /* Single column on very small screens */
        justify-items: center !important;
    }
    
    .task-cards-grid-container > * {
        width: 300px !important; /* Still maintain 300px even on small screens */
        max-width: 300px !important;
    }
}
```

## Data Models

### Enhanced TarefaViewModel Safety

**File**: `RDO-NET8-Migration/RdoApp.Core/Models/ViewModels/TarefaViewModel.cs`

Add null safety validation:

```csharp
public class TarefaViewModel
{
    // Existing properties...
    
    // Validation properties
    public bool IsValid => Id > 0 && !string.IsNullOrEmpty(Descricao);
    public bool HasNullProperties => 
        string.IsNullOrEmpty(Descricao) || 
        string.IsNullOrEmpty(StatusDescricao) ||
        DataInicio == default(DateTime);
    
    // Safe property access with fallbacks
    public string SafeDescricao => Descricao ?? $"Tarefa {Id}";
    public string SafeStatusDescricao => StatusDescricao ?? "Status Desconhecido";
    public int SafeStatusId => StatusId > 0 ? StatusId : 1; // Default to status 1
    
    // Constructor to ensure basic properties are set
    public TarefaViewModel()
    {
        Descricao = string.Empty;
        StatusDescricao = string.Empty;
        StatusCssClass = string.Empty;
        StatusIcon = string.Empty;
        DataInicio = DateTime.Now;
        DataMedicao = DateTime.Now;
    }
}
```

## Error Handling

### 1. Null Reference Prevention

- **Collection Validation**: Check if `Model.SafeTarefas` is null before iteration
- **Item Validation**: Validate each task item is not null and has valid ID
- **Property Validation**: Use safe property accessors with fallback values
- **Component Parameter Validation**: Ensure all component parameters have valid values

### 2. Grid Layout Fallback

- **CSS Grid Support**: Modern browsers support CSS Grid, but provide flexbox fallback
- **Responsive Behavior**: Maintain 300px width across all screen sizes
- **Empty State Handling**: Proper display when no valid tasks exist

### 3. Debug Information

- **Development Mode**: Show debug information about null tasks and collection state
- **Production Mode**: Hide debug info but log errors to console
- **Error Boundaries**: Prevent single task errors from breaking entire accordion

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Null Task Collection Safety
*For any* task collection that may contain null items, iterating through the collection should never throw null reference exceptions and should only process valid task items
**Validates: Requirements 1.1, 1.5**

### Property 2: Task Property Default Values
*For any* task object with null or missing properties, accessing display properties should return safe default values instead of null or throwing exceptions
**Validates: Requirements 1.2, 1.3**

### Property 3: Card Width Consistency
*For any* number of task cards rendered in the grid container, each card should maintain exactly 300px width regardless of container size or number of cards per row
**Validates: Requirements 2.3, 2.4, 3.1, 3.2, 3.3, 3.4, 4.1**

### Property 4: Grid Layout Responsiveness
*For any* screen width, the grid container should adjust the number of columns while preserving 300px card width and proper grid cell sizing
**Validates: Requirements 2.5, 3.5, 4.3**

### Property 5: Legacy Standard Dimensions
*For any* rendered task card, the card should maintain exactly 300px width and 130px height as specified in the Legacy Standard
**Validates: Requirements 4.1, 4.2**

## Testing Strategy

### Unit Tests

1. **Null Safety Tests**:
   - Test iteration with null task items
   - Test iteration with empty collections  
   - Test component parameter validation
   - Test property access with null values
   - Test empty state display for null/empty collections

2. **CSS Grid Layout Tests**:
   - Test CSS Grid container has correct `display: grid` property
   - Test grid template columns uses `repeat(auto-fill, 300px)`
   - Test card width constraints (`width`, `min-width`, `max-width: 300px !important`)
   - Test appropriate spacing between cards (gap property)

### Property-Based Tests

1. **Property 1: Null Task Collection Safety** - Generate collections with varying numbers of null items mixed with valid tasks
2. **Property 2: Task Property Default Values** - Generate tasks with randomly null properties  
3. **Property 3: Card Width Consistency** - Generate varying numbers of cards (1-20) and test width consistency
4. **Property 4: Grid Layout Responsiveness** - Generate different screen widths and test column adjustment
5. **Property 5: Legacy Standard Dimensions** - Generate random task data and verify consistent dimensions

### Integration Tests

1. **End-to-End Rendering**:
   - Test complete accordion with mixed valid/null tasks
   - Test grid layout with various numbers of cards
   - Test responsive behavior across screen sizes
   - Test add task button functionality