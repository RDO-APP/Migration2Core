# Requirements Document

## Introduction

This specification defines the complete modernization of the "Etapa Tarefa" (Task Management) page, implementing a Modern Equivalent Migration strategy to eliminate the "Dependency Desert" identified in the Nuclear Clean Slate audit [cite: 2026-01-05]. The system will abandon all legacy jQuery and AngularJS dependencies in favor of pure .NET 8 + Blazor Server + Bootstrap 5 CSS-only architecture.

## Glossary

- **Modern_Equivalent_Migration**: Strategy to replace legacy dependencies with modern equivalents
- **Nuclear_Clean_Slate**: Approach to eliminate all legacy code and rebuild from scratch
- **Dependency_Desert**: State where 80% of original dependencies are missing [cite: 2026-01-05]
- **Task_Card**: Individual task display component with 5-button toolbar
- **Nova_Medicao_Modal**: Blazor modal component for adding new task measurements
- **Bootstrap_5_CSS_Only**: Using Bootstrap 5 CSS without JavaScript dependencies
- **Pure_Blazor_Components**: Blazor Server components with zero JavaScript
- **RDO_UI_Components**: Official RDO-branded Blazor user interface elements

## Requirements

### Requirement 1: Immediate Nova Medição Button Fix

**User Story:** As a project manager, I want to click the "Nova Medição" (+) button on any task card, so that I can immediately add new measurements without null reference errors.

#### Acceptance Criteria

1. WHEN a user clicks the (+) button on any task card, THE System SHALL open the Nova Medição modal using Blazor EventCallback communication
2. WHEN the modal opens, THE System SHALL populate smart defaults (today's date, current task status, task ID) using Blazor OnInitialized() method
3. WHEN the modal displays, THE System SHALL show all form fields (status, date, time, quantity, water quality parameters) using Blazor InputDate, InputSelect, and InputNumber components
4. THE System SHALL use pure Blazor component communication with zero JavaScript dependencies
5. WHEN the modal closes, THE System SHALL clean up all state using Blazor component lifecycle methods

### Requirement 2: Native Bootstrap 5 Architecture Foundation

**User Story:** As a developer, I want a clean Blazor Server + Bootstrap 5 CSS architecture, so that the system is maintainable and free from JavaScript dependencies.

#### Acceptance Criteria

1. THE System SHALL use only Blazor EventCallback communication for all component interactions
2. THE System SHALL implement all event handling using Blazor @onclick event handlers
3. THE System SHALL eliminate all JavaScript selectors and replace with Blazor component references
4. THE System SHALL use Bootstrap 5 CSS classes for styling without JavaScript functionality
5. THE System SHALL implement proper error handling using Blazor try-catch blocks and conditional rendering
6. THE System SHALL use modern C# features (async/await, LINQ, pattern matching) throughout

### Requirement 3: Five-Button Toolbar Event System

**User Story:** As a project manager, I want all five toolbar buttons (View, History, Edit, Delete, Add Measurement) on each task card to work reliably, so that I can manage tasks efficiently.

#### Acceptance Criteria

1. WHEN a user clicks the "View" button, THE System SHALL navigate to the task detail page using Blazor NavigationManager
2. WHEN a user clicks the "History" button, THE System SHALL open the task history modal using Blazor EventCallback communication
3. WHEN a user clicks the "Edit" button, THE System SHALL navigate to the task edit page using Blazor NavigationManager with proper task ID
4. WHEN a user clicks the "Delete" button, THE System SHALL show a Blazor confirmation dialog and submit deletion via C# service methods
5. WHEN a user clicks the "Add Measurement" (+) button, THE System SHALL trigger the Nova Medição modal using Blazor EventCallback with task context
6. THE System SHALL handle all button events using Blazor @onclick event handlers without JavaScript dependencies

### Requirement 4: Business Logic Migration to Backend Services

**User Story:** As a system architect, I want all calculation logic (percentages, totals, validations) moved to C# backend services, so that the frontend is lightweight and the business logic is centralized.

#### Acceptance Criteria

1. THE System SHALL move all percentage calculations from AngularJS to C# EtapaService methods
2. THE System SHALL move all total calculations from client-side to server-side ViewModels
3. THE System SHALL implement all form validations using .NET 8 model validation attributes
4. THE System SHALL use C# services for all water quality parameter calculations
5. THE System SHALL return calculated values in ViewModels rather than computing them in JavaScript
6. WHERE client-side calculations are necessary, THE System SHALL use C# methods in Blazor components without external libraries

### Requirement 5: Modern RDO UI Components

**User Story:** As a user, I want modern, mobile-friendly date pickers and form controls that maintain the Official RDO brand identity, so that the interface feels professional and works on all devices.

#### Acceptance Criteria

1. THE System SHALL replace legacy datepicker with Blazor InputDate component for maximum compatibility
2. THE System SHALL implement custom RDO-branded styling for all Blazor form controls using CSS custom properties
3. THE System SHALL ensure all Blazor form inputs work natively on mobile devices without additional libraries
4. THE System SHALL maintain the Official RDO color scheme (#1e3a8a, #3b82f6, #57B257) throughout Blazor components
5. THE System SHALL implement responsive design using Bootstrap 5 grid system with Blazor components exclusively
6. THE System SHALL provide visual feedback for form interactions using CSS transitions and Blazor conditional rendering

### Requirement 6: MVP Verification Milestone

**User Story:** As a project stakeholder, I want one fully functional task card with working buttons and form inputs, so that I can verify the new architecture before scaling to the entire system.

#### Acceptance Criteria

1. THE System SHALL deliver one complete task card with all five buttons functional using Blazor EventCallback communication
2. THE System SHALL demonstrate the Nova Medição modal opening, form submission, and closing cycle using pure Blazor components
3. THE System SHALL show proper error handling for network failures and validation errors using Blazor conditional rendering
4. THE System SHALL maintain visual consistency with the existing RDO design system using Blazor components
5. THE System SHALL perform all operations without console errors or Blazor exceptions
6. THE System SHALL complete the full measurement creation workflow (open modal → fill form → save → close → refresh data) using pure Blazor component communication

### Requirement 7: Legacy Dependency Elimination

**User Story:** As a system administrator, I want complete elimination of jQuery and AngularJS dependencies, so that the system has no security vulnerabilities from outdated libraries.

#### Acceptance Criteria

1. THE System SHALL remove all jQuery script references from _Layout.cshtml
2. THE System SHALL remove all AngularJS script references and directives from templates
3. THE System SHALL eliminate all `ng-*` attributes from HTML templates
4. THE System SHALL replace all `$scope` variables with Blazor component properties
5. THE System SHALL convert all jQuery AJAX calls to Blazor HttpClient service calls
6. THE System SHALL verify zero 404 errors for missing legacy script files

### Requirement 8: Performance and Reliability Standards

**User Story:** As a user, I want fast, reliable task management operations, so that I can work efficiently without system delays or failures.

#### Acceptance Criteria

1. THE System SHALL load the Etapa/Tarefa page in under 2 seconds using Blazor Server prerendering
2. THE System SHALL open modals in under 200ms using Blazor component state changes
3. THE System SHALL submit forms and return responses in under 1 second using Blazor HttpClient operations
4. THE System SHALL handle network failures gracefully with user-friendly error messages using Blazor conditional rendering
5. THE System SHALL maintain responsive UI during all asynchronous operations using Blazor loading states
6. THE System SHALL work consistently across Chrome, Firefox, Safari, and Edge browsers using Blazor Server components

### Requirement 9: Data Integrity and Validation

**User Story:** As a data manager, I want robust validation for all measurement inputs, so that only valid data enters the system.

#### Acceptance Criteria

1. THE System SHALL validate all required fields (Status, Date, Task ID) before form submission
2. THE System SHALL validate date inputs to prevent future dates beyond reasonable limits
3. THE System SHALL validate numeric inputs (quantity, water quality parameters) for proper ranges
4. THE System SHALL validate water quality radio button selections for completeness
5. THE System SHALL provide immediate visual feedback for validation errors using Blazor ValidationMessage components and Bootstrap 5 validation classes
6. THE System SHALL prevent duplicate submissions using Blazor button state management and conditional rendering

### Requirement 10: Mobile Responsiveness and Accessibility

**User Story:** As a mobile user, I want full task management functionality on my smartphone or tablet, so that I can work from any location.

#### Acceptance Criteria

1. THE System SHALL display task cards in responsive grid layout (1 column on mobile, multiple on desktop) using Blazor components
2. THE System SHALL ensure all buttons are touch-friendly with minimum 44px touch targets in Blazor components
3. THE System SHALL make modals fully functional on mobile devices with proper viewport handling using Blazor components
4. THE System SHALL implement keyboard navigation for all interactive Blazor elements
5. THE System SHALL provide proper ARIA labels and roles for screen reader compatibility in Blazor components
6. THE System SHALL maintain readability and usability at all screen sizes from 320px to 1920px using Blazor responsive components