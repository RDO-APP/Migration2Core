# Requirements Document

## Introduction

The Nuclear 2026 system is active and functional, but the layout structure is broken with misaligned elements. The system needs CSS/HTML structure fixes while preserving all JavaScript functionality that was recently implemented.

## Glossary

- **Nuclear_System**: The current active 2026 system with working JavaScript functionality
- **Login_Container**: The login form container that needs proper centering
- **Obra_Cards_Grid**: The grid layout for obra selection cards that appears "bagunçados" (messy)
- **Nuclear_Banner**: The red "☢️ NUCLEAR 2026 ACTIVE ☢️" indicator at top-right
- **Layout_Structure**: The overall CSS and HTML organization

## Requirements

### Requirement 1: Login Page Centering

**User Story:** As a user, I want the login form to be properly centered on the screen, so that it appears professional and accessible.

#### Acceptance Criteria

1. THE Login_Container SHALL have a maximum width constraint to prevent excessive stretching
2. WHEN the login page loads, THE Login_Container SHALL be horizontally and vertically centered using modern CSS techniques
3. THE Login_Container SHALL use either margin auto with max-width OR Flexbox wrapper with justify-content-center and align-items-center
4. THE Login_Container SHALL maintain min-vh-100 for full viewport height centering
5. THE Login_Container SHALL remain responsive on mobile devices

### Requirement 2: Obra Cards Grid Organization

**User Story:** As a user, I want the obra selection cards to be properly organized in a clean grid layout, so that I can easily browse and select obras.

#### Acceptance Criteria

1. THE Obra_Cards_Grid SHALL use either standard Bootstrap Row/Col structure OR CSS Grid layout
2. WHEN using CSS Grid, THE system SHALL implement display: grid with grid-template-columns: repeat(auto-fill, minmax(250px, 1fr))
3. THE Obra_Cards_Grid SHALL maintain consistent gap spacing of 1rem between cards
4. THE Obra_Cards_Grid SHALL ensure cards are properly aligned and not "bagunçados" (messy)
5. THE Obra_Cards_Grid SHALL remain responsive across different screen sizes

### Requirement 3: Nuclear Banner Positioning

**User Story:** As a system administrator, I want the Nuclear banner to stay fixed at the top-right without affecting other content, so that the system status is visible without layout disruption.

#### Acceptance Criteria

1. THE Nuclear_Banner SHALL remain fixed at the top-right corner of the viewport
2. THE Nuclear_Banner SHALL NOT push other content down or cause layout shifts
3. THE Nuclear_Banner SHALL have appropriate z-index to stay above other elements
4. THE Nuclear_Banner SHALL maintain its red background and white text styling
5. THE Nuclear_Banner SHALL be positioned using fixed positioning with top and right properties

### Requirement 4: JavaScript Preservation

**User Story:** As a developer, I want all existing JavaScript functionality to remain intact, so that the Nuclear 2026 system continues to work properly.

#### Acceptance Criteria

1. THE system SHALL NOT modify any JavaScript logic or event handlers
2. THE system SHALL preserve all existing onclick handlers and form submissions
3. THE system SHALL maintain all filter functionality and modal triggers
4. THE system SHALL keep all console.error logging and debug functionality
5. THE system SHALL ensure no JavaScript errors are introduced by CSS changes

### Requirement 5: CSS Structure Cleanup

**User Story:** As a developer, I want clean and maintainable CSS structure, so that future modifications are easier to implement.

#### Acceptance Criteria

1. THE system SHALL remove duplicate or conflicting CSS rules
2. THE system SHALL use consistent CSS methodologies (Bootstrap classes where appropriate)
3. THE system SHALL maintain existing color schemes and visual styling
4. THE system SHALL ensure CSS specificity doesn't conflict with existing styles
5. THE system SHALL preserve all existing responsive breakpoints and media queries