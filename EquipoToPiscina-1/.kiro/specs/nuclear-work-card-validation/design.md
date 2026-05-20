# Nuclear Work Card Validation - Design Document

## Design Overview
This document outlines the design approach for validating and testing the Nuclear Work Card implementation to ensure production readiness and adherence to Gilberto's original specifications.

## Architecture Design

### Testing Strategy Architecture
```
┌─────────────────────────────────────────────────────────────┐
│                    VALIDATION LAYERS                        │
├─────────────────────────────────────────────────────────────┤
│ 1. Visual Validation    │ 2. Functional Testing             │
│   - Progress Bar Style  │   - Navigation Flow                │
│   - Icon Display        │   - Filter Operations              │
│   - Layout Grid         │   - Error Handling                 │
│   - Color Accuracy      │   - Session Management             │
├─────────────────────────────────────────────────────────────┤
│ 3. Data Integration     │ 4. Performance Testing            │
│   - Database Mapping    │   - Load Time Metrics             │
│   - Field Population    │   - Memory Usage                   │
│   - Query Efficiency    │   - Browser Compatibility         │
│   - Status Calculation  │   - Responsive Behavior            │
└─────────────────────────────────────────────────────────────┘
```

### Component Validation Framework
```
Work Card Component
├── Visual Elements
│   ├── Progress Bar (12px thick, correct colors)
│   ├── Icon System (custom font + fallback)
│   ├── Typography (uppercase titles, proper sizing)
│   └── Layout Grid (5 cards per row)
├── Interactive Elements  
│   ├── Click Navigation (to /Etapa/Cards)
│   ├── Hover Effects (transform + shadow)
│   ├── Loading States (during navigation)
│   └── Filter Integration (real-time search)
├── Data Binding
│   ├── ContratanteContratada (from database)
│   ├── ProgressoPorcentagem (calculated value)
│   ├── ClasseStatusCss (server-side logic)
│   └── Obra Details (description, location, status)
└── Responsive Behavior
    ├── Desktop (5 cards/row)
    ├── Laptop (4 cards/row)
    ├── Tablet (2 cards/row)
    └── Mobile (1 card/row)
```

## Visual Design Validation

### Progress Bar Design Specifications
```css
/* EXACT SPECIFICATIONS TO VALIDATE */
.progress-container {
    width: 100%;
    height: 12px; /* MUST BE 12px - not 8px or 10px */
    background-color: #f1f5f9;
    border-radius: 6px;
    overflow: hidden;
    margin-top: 15px;
    border: 1px solid rgba(0, 0, 0, 0.1); /* MUST HAVE BORDER */
}

.progress-bar {
    height: 100%; /* MUST FILL CONTAINER */
    transition: width 0.3s ease;
    border-radius: 6px;
}
```

### Color Validation Matrix
| Status | CSS Class | Hex Value | Visual Test | Business Rule |
|--------|-----------|-----------|-------------|---------------|
| Completed | bg-verde | #57B257 | ✅ Green | Project on time + all tasks done |
| Overdue | bg-vermelho | #D04541 | ✅ Red | 100% time elapsed + tasks pending |
| In Progress | bg-cinza | #999999 | ✅ Gray | < 100% time elapsed |
| Executing | bg-azul | #51BCDC | ✅ Blue | Active execution phase |
| Paused | bg-laranja | #FF8000 | ✅ Orange | Temporarily stopped |

### Icon System Validation
```css
/* CUSTOM ICON FONT - PRIMARY */
.icon-contratante:before { 
    font-family: 'rdo-icons';
    content: '\e815'; /* Client/Owner figure */
}
.icon-contratada:before { 
    font-family: 'rdo-icons';
    content: '\e807'; /* Contractor figure */
}

/* FONTAWESOME FALLBACK - SECONDARY */
.icon-contratante:before { 
    font-family: 'Font Awesome 6 Free';
    content: '\f1ad'; /* Building icon */
    font-weight: 900;
}
.icon-contratada:before { 
    font-family: 'Font Awesome 6 Free';
    content: '\f7d9'; /* Tools icon */
    font-weight: 900;
}
```

### Layout Grid Validation
```css
/* RESPONSIVE GRID SPECIFICATIONS */
/* Desktop: 5 cards per row */
.row-cols-md-5 > * {
    flex: 0 0 auto;
    width: 20%; /* EXACTLY 20% for 5 cards */
}

/* Laptop: 4 cards per row */
@media (max-width: 1200px) {
    .row-cols-md-5 > * {
        width: 25%; /* EXACTLY 25% for 4 cards */
    }
}

/* Tablet: 2 cards per row */
@media (max-width: 768px) {
    .row-cols-md-5 > * {
        width: 50%; /* EXACTLY 50% for 2 cards */
    }
}

/* Mobile: 1 card per row */
@media (max-width: 576px) {
    .row-cols-md-5 > * {
        width: 100%; /* EXACTLY 100% for 1 card */
    }
}
```

## Functional Design Validation

### Navigation Flow Design
```
User Journey: Work Selection → Task Management
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Login Page    │ -> │ Escolher Obra   │ -> │  Etapa/Cards    │
│                 │    │                 │    │                 │
│ - Authentication│    │ - Work Cards    │    │ - Task Cards    │
│ - Session Start │    │ - Filters       │    │ - Task Actions  │
│                 │    │ - Selection     │    │ - Progress View │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                              │
                              ▼
                       ┌─────────────────┐
                       │ Session Storage │
                       │                 │
                       │ - ObraId: 233   │
                       │ - UserId: X     │
                       │ - Timestamp     │
                       └─────────────────┘
```

### Filter System Design
```javascript
// REAL-TIME FILTER VALIDATION LOGIC
function filtrarObras() {
    const unidadeValue = filtroUnidade.value.toLowerCase();
    const municipioValue = filtroMunicipio.value.toLowerCase();
    
    // VALIDATION POINTS:
    // 1. Case-insensitive matching
    // 2. Partial string matching
    // 3. Independent filter operation
    // 4. Real-time response (no delay)
    // 5. Visual feedback (show/hide cards)
    // 6. Counter update (visible cards)
    
    cards.forEach(card => {
        const unidade = card.getAttribute('data-unidade') || '';
        const municipio = card.getAttribute('data-municipio') || '';
        
        const matchUnidade = !unidadeValue || unidade.includes(unidadeValue);
        const matchMunicipio = !municipioValue || municipio.includes(municipioValue);
        
        // CRITICAL: Hide parent column, not just card
        const parentCol = card.closest('.col');
        if (matchUnidade && matchMunicipio) {
            if (parentCol) parentCol.style.display = 'block';
            visibleCount++;
        } else {
            if (parentCol) parentCol.style.display = 'none';
        }
    });
}
```

## Data Integration Design

### Database Mapping Validation
```sql
-- CRITICAL FIELD MAPPINGS TO VALIDATE
SELECT 
    o.obr_id,
    o.obr_ds_descricao,
    o.obr_ds_cidade_estado,
    g.gru_st_contratante,  -- CRITICAL: 1=contratante, 0=contratada
    -- Progress calculation logic
    -- Status calculation logic
FROM obra o
JOIN obra_colaborador oc ON o.obr_id = oc.oco_id_obra
JOIN grupo g ON oc.oco_id_grupo = g.gru_id
WHERE oc.oco_id_colaborador = @currentUserId
```

### ViewModel Mapping Design
```csharp
// VALIDATION POINTS FOR OBRAVIEWMODEL
public class ObraViewModel
{
    public int Id { get; set; }                    // ✅ obr_id
    public string Descricao { get; set; }          // ✅ obr_ds_descricao
    public string CidadeEstado { get; set; }       // ✅ obr_ds_cidade_estado
    public string ContratanteContratada { get; set; } // ✅ CRITICAL MAPPING
    public decimal ProgressoPorcentagem { get; set; }  // ✅ Complex calculation
    public string ClasseStatusCss { get; set; }       // ✅ Server-side logic
    public string StatusBasicaGratuita { get; set; }  // ✅ Status description
}

// CRITICAL VALIDATION: ContratanteContratada mapping
ContratanteContratada = grupo?.gru_st_contratante == 1 ? "contratante" : "contratada"
```

## Performance Design Validation

### Load Time Optimization
```
Performance Budget:
├── First Contentful Paint: < 1.5s
├── Largest Contentful Paint: < 2.5s  
├── Time to Interactive: < 3.0s
├── Cumulative Layout Shift: < 0.1
└── First Input Delay: < 100ms

Resource Loading Strategy:
├── Critical CSS: Inline (< 14KB)
├── Bootstrap CSS: CDN with integrity
├── FontAwesome: CDN with fallback
├── Custom Icons: Base64 embedded or fast CDN
└── JavaScript: Defer non-critical scripts
```

### Memory Usage Design
```
Memory Optimization:
├── DOM Elements: Minimize unnecessary nodes
├── Event Listeners: Use delegation pattern
├── CSS Animations: Use transform/opacity only
├── Image Loading: Lazy load if many cards
└── Filter Operations: Debounce if needed
```

## Testing Design Framework

### Automated Testing Strategy
```
Testing Pyramid:
├── Unit Tests (40%)
│   ├── Filter logic functions
│   ├── Navigation helper functions
│   ├── Data mapping utilities
│   └── CSS class calculations
├── Integration Tests (40%)
│   ├── Database to ViewModel mapping
│   ├── Controller action flows
│   ├── Session management
│   └── Error handling paths
└── E2E Tests (20%)
    ├── Complete user journeys
    ├── Cross-browser compatibility
    ├── Responsive behavior
    └── Performance benchmarks
```

### Manual Testing Checklist Design
```
Visual Validation Checklist:
□ Progress bars are exactly 12px thick
□ Colors match hex values exactly
□ Icons display correctly (custom + fallback)
□ Grid shows exactly 5 cards per row (desktop)
□ Typography is uppercase and properly sized
□ Spacing matches design specifications
□ Hover effects work smoothly
□ Loading states appear during navigation

Functional Validation Checklist:
□ Clicking cards navigates to correct URL
□ Filters work in real-time
□ Session stores obra ID correctly
□ Error handling displays appropriate messages
□ Responsive design works on all screen sizes
□ Keyboard navigation is functional
□ Screen readers can access content
□ Performance meets benchmark targets
```

## Error Handling Design

### Error State Management
```javascript
// ERROR SCENARIOS TO VALIDATE
const errorScenarios = {
    noData: {
        condition: "Model is null or empty",
        display: "Você deve cadastrar uma obra para começar a usar o sistema.",
        icon: "fas fa-building"
    },
    noResults: {
        condition: "Filters return no matches",
        display: "Nenhuma obra encontrada com os filtros aplicados.",
        icon: "fas fa-search"
    },
    navigationError: {
        condition: "Invalid obra ID or navigation failure",
        action: "Show error message and stay on current page",
        fallback: "Redirect to login if session expired"
    },
    loadingError: {
        condition: "Database or service unavailable",
        display: "Erro ao carregar obras. Tente novamente.",
        action: "Provide retry button"
    }
};
```

## Accessibility Design

### WCAG 2.1 AA Compliance
```css
/* ACCESSIBILITY VALIDATION POINTS */
.obra-card {
    /* Color contrast: 4.5:1 minimum */
    color: #1e3a8a; /* Passes contrast test */
    background: white;
    
    /* Focus indicators */
    outline: 2px solid transparent;
    outline-offset: 2px;
}

.obra-card:focus {
    outline-color: #3b82f6;
    box-shadow: 0 0 0 2px rgba(59, 130, 246, 0.25);
}

/* Screen reader support */
.obra-card[aria-label] {
    /* Descriptive labels for screen readers */
}
```

### Keyboard Navigation Design
```
Tab Order Validation:
1. Filter: Nome da obra (autofocus)
2. Filter: Cidade
3. Work Card 1
4. Work Card 2
5. Work Card N...

Keyboard Shortcuts:
- Enter/Space: Select work card
- Escape: Clear filters
- Tab: Navigate forward
- Shift+Tab: Navigate backward
```

## Success Criteria Matrix

| Component | Validation Method | Success Criteria | Priority |
|-----------|------------------|------------------|----------|
| Progress Bar | Visual + Measurement | 12px height, correct colors | High |
| Icons | Visual + Fallback Test | Custom font + FontAwesome backup | High |
| Grid Layout | Responsive Testing | 5/4/2/1 cards per breakpoint | High |
| Navigation | Functional Testing | Correct URL with obraId | High |
| Filters | Interactive Testing | Real-time, case-insensitive | Medium |
| Performance | Automated Testing | < 2s load time | Medium |
| Accessibility | Audit Tools | WCAG 2.1 AA compliance | Medium |
| Data Accuracy | Database Testing | 100% correct mapping | High |

## Implementation Phases

### Phase 1: Visual Validation (Days 1-2)
- Measure progress bar dimensions
- Verify color hex values
- Test icon font loading and fallback
- Validate grid layout on all screen sizes
- Check typography and spacing

### Phase 2: Functional Testing (Days 3-4)
- Test navigation flow end-to-end
- Validate filter operations
- Verify session management
- Test error handling scenarios
- Check responsive behavior

### Phase 3: Data Integration (Days 5-6)
- Verify database field mapping
- Test with production-like data
- Validate business logic calculations
- Check performance with large datasets
- Test concurrent user scenarios

### Phase 4: Production Readiness (Days 7-8)
- Cross-browser compatibility testing
- Accessibility audit and fixes
- Performance optimization
- Security testing
- Final stakeholder review

This design document provides the comprehensive framework for validating the Nuclear Work Card implementation and ensuring it meets all production requirements while maintaining fidelity to Gilberto's original specifications.