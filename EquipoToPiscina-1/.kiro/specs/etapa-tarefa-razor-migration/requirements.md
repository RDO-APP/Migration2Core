# Requirements Document

## Introduction

Migration of the Etapa/Tarefa (Stage/Task) cards view from legacy AngularJS frontend to modern .NET 8 Razor Pages to eliminate JavaScript rendering issues and improve maintainability.

## Glossary

- **Etapa**: A stage or phase in a construction project
- **Tarefa**: A task within a stage
- **Card**: Visual representation of a task with status, progress, and actions
- **Accordion**: Collapsible sections showing tasks grouped by stage
- **RDO_System**: The construction management system
- **Legacy_Frontend**: Current AngularJS-based frontend
- **Modern_Backend**: .NET 8 backend with correct data models

## Requirements

### Requirement 1: Razor View Migration

**User Story:** As a project manager, I want to view task cards rendered server-side, so that I can avoid JavaScript rendering issues and have reliable task visibility.

#### Acceptance Criteria

1. THE RDO_System SHALL render task cards using Razor @foreach loops instead of AngularJS ng-repeat
2. WHEN a user navigates to the Etapa/Tarefa page, THE RDO_System SHALL display all stages with their tasks without JavaScript dependencies
3. THE RDO_System SHALL maintain the same visual design and layout as the current cards
4. THE RDO_System SHALL use the existing .NET 8 backend models (EtapaViewModel, TarefaViewModel)
5. THE RDO_System SHALL eliminate all AngularJS controller dependencies for card rendering

### Requirement 2: Server-Side Data Loading

**User Story:** As a system administrator, I want task data loaded server-side, so that rendering is reliable and doesn't depend on client-side JavaScript execution.

#### Acceptance Criteria

1. THE RDO_System SHALL load etapa and tarefa data in the controller action method
2. THE RDO_System SHALL pass populated models directly to the Razor view
3. THE RDO_System SHALL use the existing EtapaModel.ObterEtapaTarefa method for data retrieval
4. THE RDO_System SHALL handle filtering parameters (description, dates, status) server-side
5. THE RDO_System SHALL maintain the same data structure and properties as the current API

### Requirement 3: Interactive Functionality Preservation

**User Story:** As a project manager, I want to perform task actions (edit, delete, status change), so that I can manage tasks effectively from the new Razor view.

#### Acceptance Criteria

1. THE RDO_System SHALL provide action buttons for each task (edit, delete, view history, new measurement)
2. WHEN a user clicks an action button, THE RDO_System SHALL navigate to the appropriate page or modal
3. THE RDO_System SHALL maintain status change functionality with proper form submissions
4. THE RDO_System SHALL preserve the accordion expand/collapse behavior using CSS and minimal JavaScript
5. THE RDO_System SHALL handle bulk status changes for selected tasks

### Requirement 4: Filtering and Search

**User Story:** As a project manager, I want to filter tasks by various criteria, so that I can find specific tasks quickly.

#### Acceptance Criteria

1. THE RDO_System SHALL provide server-side filtering by description, dates, and status
2. WHEN a user submits filter criteria, THE RDO_System SHALL reload the page with filtered results
3. THE RDO_System SHALL maintain filter state in the URL or form data
4. THE RDO_System SHALL use standard HTML forms instead of AngularJS form binding
5. THE RDO_System SHALL preserve the current filter UI layout and functionality

### Requirement 5: Performance and Reliability

**User Story:** As a system user, I want fast and reliable task card loading, so that I can work efficiently without JavaScript errors.

#### Acceptance Criteria

1. THE RDO_System SHALL render cards server-side for immediate visibility on page load
2. THE RDO_System SHALL eliminate "container not found" and "key mismatch" JavaScript errors
3. THE RDO_System SHALL load faster than the current AngularJS implementation
4. THE RDO_System SHALL work consistently across all browsers without JavaScript dependencies
5. THE RDO_System SHALL maintain responsive design for mobile and desktop views

### Requirement 6: Migration Compatibility

**User Story:** As a developer, I want the migration to be seamless, so that existing functionality is preserved without breaking changes.

#### Acceptance Criteria

1. THE RDO_System SHALL use the same URL routes as the current implementation
2. THE RDO_System SHALL maintain compatibility with existing authentication and authorization
3. THE RDO_System SHALL preserve all current CSS classes and styling
4. THE RDO_System SHALL maintain the same data flow for task operations (create, update, delete)
5. THE RDO_System SHALL ensure no regression in existing functionality during migration