# Requirements Document

## Introduction

Fix critical frontend JavaScript and Razor view integrity issues causing blank pages in the Etapas (Stages) functionality. The system must display 4 stages for Obra 233 with proper error handling and UI resilience.

## Glossary

- **Etapa**: Stage/Phase in the construction project workflow
- **Tarefa**: Task within a stage
- **EtapaViewModel**: C# model containing stage data for Razor views
- **Renzo_Logic**: Legacy JavaScript code from previous developer
- **Safety_Render**: Defensive UI rendering that prevents crashes
- **Browser_Console**: F12 developer tools for JavaScript debugging

## Requirements

### Requirement 1: JavaScript Error Detection and Resolution

**User Story:** As a developer, I want to identify and fix JavaScript crashes, so that the Etapas page renders properly.

#### Acceptance Criteria

1. WHEN the Etapas page loads, THE Browser_Console SHALL display no red JavaScript errors
2. WHEN JavaScript encounters undefined properties, THE System SHALL log descriptive error messages instead of crashing
3. WHEN legacy Renzo_Logic references missing DOM elements, THE System SHALL handle gracefully without breaking the page
4. THE System SHALL validate all JavaScript object properties before accessing them

### Requirement 2: Model-View Synchronization

**User Story:** As a developer, I want EtapaViewModel properties to match exactly what Etapas.cshtml expects, so that data binding works correctly.

#### Acceptance Criteria

1. WHEN EtapaViewModel is passed to Etapas.cshtml, THE View SHALL find all expected properties
2. WHEN a property is renamed in the model, THE Razor_View SHALL be updated to match
3. WHEN the view expects a field that doesn't exist, THE System SHALL provide a default value instead of null
4. THE System SHALL validate model-view property alignment before rendering

### Requirement 3: Safety Render Implementation

**User Story:** As a user, I want to see stage headers even when tasks fail to load, so that the page remains functional.

#### Acceptance Criteria

1. WHEN task loading fails, THE UI SHALL still render the 4 stage headers for Obra 233
2. WHEN a null task list is encountered, THE Razor_Page SHALL not crash the entire rendering
3. WHEN data is missing, THE UI SHALL display placeholder content instead of blank sections
4. THE System SHALL implement defensive null checks in all Razor views

### Requirement 4: Legacy JavaScript Compatibility

**User Story:** As a developer, I want legacy Renzo JavaScript to work with the new UI, so that existing functionality is preserved.

#### Acceptance Criteria

1. WHEN legacy JavaScript looks for specific IDs or classes, THE New_UI SHALL provide compatible elements
2. WHEN the "+" expansion functionality is triggered, THE System SHALL find the correct DOM elements
3. WHEN CSS classes or IDs are changed, THE Legacy_JS SHALL be updated to match
4. THE System SHALL maintain backward compatibility for all interactive elements

### Requirement 5: Obra 233 Stage Visibility

**User Story:** As a user, I want to see all 4 stages for Obra 233, so that I can manage the project workflow.

#### Acceptance Criteria

1. THE System SHALL display exactly 4 stages for Obra 233
2. WHEN stages load, THE UI SHALL show stage headers, descriptions, and task counts
3. WHEN individual stages fail to load, THE Other_Stages SHALL remain visible
4. THE System SHALL provide clear visual feedback for loading states and errors

### Requirement 6: Comprehensive Error Handling

**User Story:** As a developer, I want comprehensive error handling in the frontend, so that partial failures don't break the entire interface.

#### Acceptance Criteria

1. WHEN any JavaScript function encounters an error, THE System SHALL log it and continue execution
2. WHEN Razor rendering fails for one section, THE Other_Sections SHALL render normally  
3. WHEN AJAX calls fail, THE UI SHALL display user-friendly error messages
4. THE System SHALL implement try-catch blocks around all critical JavaScript operations

### Requirement 7: Browser Console Debugging Support

**User Story:** As a developer, I want clear browser console output, so that I can quickly identify and fix frontend issues.

#### Acceptance Criteria

1. THE System SHALL log all AJAX requests and responses to the console in debug mode
2. WHEN JavaScript errors occur, THE Console SHALL show the exact line and file causing the issue
3. WHEN model binding fails, THE System SHALL log which properties are missing or mismatched
4. THE System SHALL provide console commands for testing UI components manually