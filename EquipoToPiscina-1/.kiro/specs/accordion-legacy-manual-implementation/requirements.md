# Requirements Document: Accordion Legacy Manual Implementation

## Introduction

Replace Bootstrap 5 accordion with Gilberto's legacy manual accordion implementation to restore proper expand/collapse functionality for Etapa cards.

## Glossary

- **Accordion**: Expandable/collapsible panel system for displaying Etapas and their Tarefas
- **Etapa**: Work phase containing multiple tasks
- **Legacy Pattern**: Gilberto's original manual JavaScript implementation without Bootstrap dependency
- **Manual Collapse**: JavaScript-controlled expand/collapse without Bootstrap Collapse API

## Requirements

### Requirement 1: Remove Bootstrap Accordion Dependency

**User Story:** As a developer, I want to remove Bootstrap 5 accordion dependencies, so that the system uses Gilberto's proven legacy pattern.

#### Acceptance Criteria

1. THE System SHALL remove all `data-bs-toggle="collapse"` attributes from accordion buttons
2. THE System SHALL remove all `data-bs-target` attributes from accordion buttons  
3. THE System SHALL remove all Bootstrap 5 Collapse API initialization code
4. THE System SHALL remove all `accordion-button` and `accordion-collapse` Bootstrap 5 classes
5. THE System SHALL preserve the visual appearance using custom CSS

### Requirement 2: Implement Manual Accordion Behavior

**User Story:** As a user, I want to click Etapa headers to expand/collapse them, so that I can view tasks within each phase.

#### Acceptance Criteria

1. WHEN a user clicks an Etapa header, THE System SHALL toggle the visibility of that Etapa's task list
2. WHEN an Etapa is expanded, THE System SHALL add a visual indicator (e.g., rotate icon)
3. WHEN an Etapa is collapsed, THE System SHALL hide all tasks within that Etapa
4. THE System SHALL use pure JavaScript onclick handlers (no Bootstrap dependencies)
5. THE System SHALL maintain expand/collapse state during page interactions

### Requirement 3: Preserve Legacy Visual DNA

**User Story:** As a user, I want the accordion to look identical to Gilberto's production system, so that the interface remains familiar.

#### Acceptance Criteria

1. THE System SHALL use `panel-group` and `panel-heading` class structure from legacy code
2. THE System SHALL use `panel-collapse` class for collapsible content
3. THE System SHALL apply legacy CSS styling (cyan header, card layout)
4. THE System SHALL maintain the same spacing, padding, and layout as production
5. THE System SHALL use inline styles where Gilberto used them

### Requirement 4: Manual JavaScript Implementation

**User Story:** As a developer, I want pure JavaScript accordion control, so that there are no Bootstrap conflicts.

#### Acceptance Criteria

1. THE System SHALL implement a `toggleEtapa(etapaId)` JavaScript function
2. WHEN `toggleEtapa` is called, THE System SHALL find the target collapse element by ID
3. WHEN the element is hidden, THE System SHALL set `display: block` to show it
4. WHEN the element is visible, THE System SHALL set `display: none` to hide it
5. THE System SHALL update button aria-expanded attribute to reflect state

### Requirement 5: Remove Bootstrap Compatibility Layer

**User Story:** As a developer, I want to remove Bootstrap compatibility code, so that the system is cleaner and faster.

#### Acceptance Criteria

1. THE System SHALL remove `bootstrap-compatibility.js` script references
2. THE System SHALL remove Bootstrap 5 bundle script references from accordion pages
3. THE System SHALL remove all Bootstrap 5 data attribute conversion code
4. THE System SHALL use only jQuery and custom JavaScript
5. THE System SHALL maintain functionality without any Bootstrap dependencies

### Requirement 6: Preserve Task Card Rendering

**User Story:** As a user, I want task cards to render correctly inside expanded Etapas, so that I can see all task information.

#### Acceptance Criteria

1. WHEN an Etapa is expanded, THE System SHALL render all TaskCard Blazor components
2. THE System SHALL maintain the grid layout for task cards (4 per row)
3. THE System SHALL preserve all task card interactions (buttons, modals)
4. THE System SHALL ensure TaskCard components are not affected by accordion changes
5. THE System SHALL maintain the same visual appearance as before

### Requirement 7: Debug and Logging

**User Story:** As a developer, I want clear console logging, so that I can verify accordion behavior.

#### Acceptance Criteria

1. WHEN an Etapa is clicked, THE System SHALL log the toggle action to console
2. WHEN an Etapa expands, THE System SHALL log "Etapa {id} expanded"
3. WHEN an Etapa collapses, THE System SHALL log "Etapa {id} collapsed"
4. THE System SHALL log any errors during toggle operations
5. THE System SHALL provide clear diagnostic information in F12 Console

---

**STATUS**: ✅ REQUIREMENTS COMPLETE - Ready for design phase
