# Requirements Document: Auth Bridge Ghost Elimination

## Introduction

The Blazor-First Authentication Bridge implementation is failing due to missing JavaScript dependencies and legacy UI contamination. The `rdoAuth.submitAuthBridge` function is undefined because the `rdo-auth-bridge.js` script is NOT loaded in `_LayoutSelection.cshtml` (the layout used by the LOGIN page). Additionally, legacy diagnostic code (session survival banners, heartbeat monitoring, "PHASE 2" comments) is contaminating the clean Blazor UI.

**ROOT CAUSE IDENTIFIED:**
- `LoginBlazor.cshtml` explicitly uses: `Layout = "~/Views/Shared/_LayoutSelection.cshtml"`
- `_LayoutSelection.cshtml` loads `rdo-login.js` but NOT `rdo-auth-bridge.js`
- `LoginPage.razor` calls `rdoAuth.submitAuthBridge()` which doesn't exist in the page's JavaScript context
- Legacy diagnostic code (session survival banners, blazorHeartbeat, rdoObraCards) still present in layout

## Glossary

- **Auth_Bridge**: JavaScript module that handles secure form submission from Blazor to MVC controller
- **Layout_Selection**: The `_LayoutSelection.cshtml` layout file used for login and obra selection pages
- **Legacy_Contamination**: Unwanted CSS/JS from old system appearing in new Blazor UI
- **Script_Load_Order**: The sequence in which JavaScript files are loaded and executed
- **rdoAuth_Object**: Global JavaScript object containing authentication bridge functions

## Requirements

### Requirement 1: JavaScript Bridge Availability

**User Story:** As a user attempting to log in, I want the authentication bridge to be available when I click the login button, so that I can successfully authenticate and access the system.

#### Acceptance Criteria

1. WHEN the login page loads, THE System SHALL ensure the `rdo-auth-bridge.js` script is loaded before Blazor components render
2. WHEN the Blazor component calls `rdoAuth.submitAuthBridge`, THE rdoAuth object SHALL exist and be callable
3. WHEN the auth bridge script loads, THE System SHALL log confirmation to the browser console
4. THE System SHALL load the auth bridge script in `_LayoutSelection.cshtml` layout
5. THE System SHALL load the auth bridge script AFTER Blazor runtime but BEFORE component initialization

### Requirement 2: Script Load Order Correctness

**User Story:** As a developer, I want scripts to load in the correct order, so that dependencies are available when needed and no undefined errors occur.

#### Acceptance Criteria

1. THE System SHALL load scripts in this order: Blazor runtime → Auth bridge → Login module → Component rendering
2. WHEN Blazor Server runtime loads, THE System SHALL wait for connection before initializing auth bridge
3. WHEN the auth bridge initializes, THE System SHALL verify all required functions exist
4. THE System SHALL provide console logging for each script load event
5. IF any script fails to load, THEN THE System SHALL log a clear error message

### Requirement 3: Legacy Contamination Elimination

**User Story:** As a user, I want to see only the clean Blazor UI without legacy artifacts, so that the interface is consistent and professional.

#### Acceptance Criteria

1. THE System SHALL NOT load legacy CSS files that create blue bars or old menu styles
2. WHEN the login page renders, THE System SHALL use only `rdo-login.css` and `rdo-unified-theme.css`
3. THE System SHALL remove or disable any CSS that conflicts with Blazor component styles
4. WHEN inspecting the page, THE System SHALL show no legacy class names or inline styles from old system
5. THE System SHALL maintain visual consistency between login and obra selection pages

### Requirement 4: Layout Script Consolidation

**User Story:** As a developer, I want authentication scripts available in all relevant layouts, so that the auth bridge works consistently across the application.

#### Acceptance Criteria

1. THE System SHALL include `rdo-auth-bridge.js` in `_LayoutSelection.cshtml`
2. THE System SHALL include `rdo-auth-bridge.js` in `_Layout.cshtml` (already done)
3. THE System SHALL NOT duplicate script loading if multiple layouts are used
4. WHEN a page uses any layout, THE auth bridge SHALL be available if authentication is required
5. THE System SHALL use `asp-append-version` cache busting for all JavaScript files

### Requirement 5: Error Handling and Diagnostics

**User Story:** As a developer, I want clear error messages when the auth bridge fails, so that I can quickly diagnose and fix issues.

#### Acceptance Criteria

1. WHEN the auth bridge script fails to load, THE System SHALL log a specific error message
2. WHEN `rdoAuth` is undefined, THE System SHALL provide a fallback error message to the user
3. WHEN authentication fails, THE System SHALL distinguish between bridge errors and credential errors
4. THE System SHALL log all authentication attempts with timestamps
5. THE System SHALL provide a debug function to verify auth bridge availability

### Requirement 6: Clean Blazor UI Preservation

**User Story:** As a user, I want the login page to display only modern Blazor UI elements, so that the experience is clean and professional.

#### Acceptance Criteria

1. THE System SHALL remove the session diagnostic blue banner from production
2. THE System SHALL remove or hide legacy UI elements (old headers, blue bars, outdated menus)
3. WHEN the login page renders, THE System SHALL show only: logo, login form, and minimal branding
4. THE System SHALL use consistent spacing and alignment matching the Blazor design
5. THE System SHALL NOT show any "Two Worlds" or "DNA transition" diagnostic messages to end users
