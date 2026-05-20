# Implementation Plan: Etapa/Tarefa Razor Migration

## Overview

Migration of the Etapa/Tarefa cards view from AngularJS to .NET 8 Razor Pages to eliminate JavaScript rendering issues and improve reliability.

## Tasks

- [x] 1. Set up core infrastructure and ViewModels
  - Create EtapaCardsViewModel and EtapaFilterViewModel classes
  - Set up proper model binding for filter parameters
  - _Requirements: 2.1, 2.2, 2.4_

- [ ]* 1.1 Write unit tests for ViewModels
  - Test model validation and binding
  - Test filter parameter handling
  - _Requirements: 2.4_

- [x] 2. Extend EtapaController for Razor rendering
  - Add Cards action method to handle GET requests
  - Implement server-side data loading using Entity Framework and AWS MySQL
  - Add error handling and validation
  - _Requirements: 2.1, 2.3, 6.2_

- [ ]* 2.1 Write property test for server-side filtering
  - **Property 3: Filter Parameter Processing**
  - **Validates: Requirements 2.4, 4.1, 4.2**

- [ ]* 2.2 Write unit tests for controller actions
  - Test Cards action with various filter parameters
  - Test error handling scenarios
  - _Requirements: 2.1, 2.4_

- [x] 3. Create main Razor view structure
  - Create Views/Etapa/Cards.cshtml with @model EtapaCardsViewModel
  - Implement @foreach loops for etapas and tarefas rendering
  - Set up basic HTML structure matching current design
  - _Requirements: 1.1, 1.2, 1.4_

- [ ]* 3.1 Write property test for server-side rendering
  - **Property 1: Server-Side Rendering Independence**
  - **Validates: Requirements 1.2, 5.1, 5.4**

- [x] 4. Implement filter partial view
  - Create Views/Etapa/_FilterPartial.cshtml
  - Convert AngularJS form to standard HTML form with server-side submission
  - Maintain existing filter UI layout and functionality
  - _Requirements: 4.1, 4.2, 4.4_

- [ ]* 4.1 Write property test for filter functionality
  - **Property 8: Filter State Persistence**
  - **Validates: Requirements 4.3**

- [x] 5. Create accordion partial views
  - Create Views/Etapa/_EtapaAccordionPartial.cshtml for stage sections
  - Create Views/Etapa/_TaskCardPartial.cshtml for individual task cards
  - Implement accordion behavior with CSS and minimal JavaScript
  - _Requirements: 1.3, 3.4_

- [ ]* 5.1 Write property test for accordion behavior
  - **Property 7: Accordion Behavior Preservation**
  - **Validates: Requirements 3.4**

- [x] 6. Implement task action functionality
  - Add action buttons (edit, delete, view history, new measurement) to task cards
  - Implement POST action methods for status changes and bulk operations
  - Ensure proper authorization and permission checks
  - _Requirements: 3.1, 3.2, 3.3, 3.5_

- [ ]* 6.1 Write property test for task actions
  - **Property 5: Task Action Availability**
  - **Validates: Requirements 3.1, 3.2**

- [ ]* 6.2 Write property test for status changes
  - **Property 6: Status Change Functionality**
  - **Validates: Requirements 3.3, 3.5**

- [ ] 7. Port CSS and styling
  - Ensure all existing CSS classes are preserved in Razor templates
  - Maintain responsive design for mobile and desktop
  - Remove AngularJS-specific styling dependencies
  - _Requirements: 1.3, 6.3_

- [ ]* 7.1 Write property test for CSS preservation
  - **Property 13: CSS Class Preservation**
  - **Validates: Requirements 6.3**

- [ ] 8. Checkpoint - Basic functionality complete
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 9. Implement URL routing and compatibility
  - Set up routing to maintain existing URLs (/tarefa/cards)
  - Implement redirect from old AngularJS routes if needed
  - Preserve query parameter handling for filters
  - _Requirements: 6.1_

- [ ]* 9.1 Write unit tests for routing
  - Test URL routing and parameter binding
  - Test backward compatibility
  - _Requirements: 6.1_

- [ ] 10. Remove AngularJS dependencies
  - Remove AngularJS controller references from the cards view
  - Clean up unused JavaScript files and dependencies
  - Ensure no AngularJS directives remain in HTML
  - _Requirements: 1.5_

- [ ]* 10.1 Write property test for AngularJS elimination
  - **Property 2: AngularJS Elimination**
  - **Validates: Requirements 1.5**

- [ ] 11. Performance optimization and testing
  - Implement caching for frequently accessed data
  - Optimize database queries and view rendering
  - Add performance monitoring and comparison with AngularJS version
  - _Requirements: 5.1, 5.3_

- [ ]* 11.1 Write property test for performance improvement
  - **Property 9: Performance Improvement**
  - **Validates: Requirements 5.3**

- [ ]* 11.2 Write property test for error elimination
  - **Property 10: Error Elimination**
  - **Validates: Requirements 5.2**

- [ ] 12. Cross-browser compatibility testing
  - Test functionality across major browsers (Chrome, Firefox, Safari, Edge)
  - Verify JavaScript-free operation works correctly
  - Test responsive design on various screen sizes
  - _Requirements: 5.4, 5.5_

- [ ]* 12.1 Write property test for cross-browser compatibility
  - **Property 11: Cross-Browser Compatibility**
  - **Validates: Requirements 5.4**

- [ ] 13. Integration and regression testing
  - Verify authentication and authorization work correctly
  - Test all task operations (create, update, delete) maintain same behavior
  - Ensure no regression in existing functionality
  - _Requirements: 6.2, 6.4, 6.5_

- [ ]* 13.1 Write property test for authentication compatibility
  - **Property 12: Authentication Compatibility**
  - **Validates: Requirements 6.2**

- [ ]* 13.2 Write property test for data flow consistency
  - **Property 14: Data Flow Consistency**
  - **Validates: Requirements 6.4**

- [ ]* 13.3 Write property test for regression prevention
  - **Property 15: Regression Prevention**
  - **Validates: Requirements 6.5**

- [ ] 14. Final checkpoint and deployment preparation
  - Ensure all tests pass, ask the user if questions arise.
  - Prepare deployment scripts and rollback procedures
  - Document migration process and any breaking changes

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation
- Property tests validate universal correctness properties
- Unit tests validate specific examples and edge cases
- Focus on maintaining existing functionality while eliminating JavaScript dependencies