# Requirements Document: Escolher Obra Blank Page - Root Cause Analysis & Clean Fix

## Introduction

After one week of attempting to fix the blank page issue on the Escolher Obra page, we need a systematic root cause analysis and a clean, permanent solution. Multiple "fixes" have been attempted, but the problem persists, indicating that we have not identified the true root cause.

## Glossary

- **Escolher Obra Page**: The work selection page where users choose which construction project to work on
- **Blank Page**: A page that loads but displays no content (white screen)
- **Legacy Pollution**: Code patterns, inline scripts, or dependencies from the old AngularJS system that interfere with the new .NET 8 implementation
- **View Component**: ASP.NET Core pattern for reusable UI components in MVC views
- **Blazor Component**: Interactive UI component using Blazor Server
- **Layout Dependency**: When a view relies on _Layout.cshtml for rendering
- **Standalone Page**: A view with `Layout = null` that includes its own HTML structure

## Requirements

### Requirement 1: Root Cause Identification

**User Story:** As a developer, I want to identify the true root cause of the blank page issue, so that I can implement a permanent fix.

#### Acceptance Criteria

1. THE System SHALL document all previous fix attempts and their outcomes
2. THE System SHALL identify common patterns in failed fixes
3. THE System SHALL analyze the current code for legacy pollution
4. THE System SHALL identify any inline JavaScript/Razor mixing issues
5. THE System SHALL verify that CSS files exist and are correctly referenced
6. THE System SHALL verify that the controller executes and returns data
7. THE System SHALL verify that the view file is not empty or corrupted
8. THE System SHALL identify any layout dependency issues

### Requirement 2: Legacy Pollution Removal

**User Story:** As a developer, I want to remove all legacy pollution from the Escolher page, so that it uses clean .NET 8 patterns.

#### Acceptance Criteria

1. THE System SHALL remove all inline JavaScript console.log statements from Razor views
2. THE System SHALL remove all mixed JavaScript/Razor syntax
3. THE System SHALL remove any AngularJS remnants
4. THE System SHALL remove any Bootstrap 3 dependencies
5. THE System SHALL use pure Razor syntax for server-side rendering
6. THE System SHALL use separate JavaScript files if client-side logging is needed
7. THE System SHALL follow ASP.NET Core MVC best practices

### Requirement 3: Clean Architecture Implementation

**User Story:** As a developer, I want the Escolher page to use clean ASP.NET Core MVC architecture, so that it is maintainable and reliable.

#### Acceptance Criteria

1. THE System SHALL use either standalone page (Layout = null) OR proper layout inheritance
2. IF using standalone page, THE System SHALL include complete HTML structure
3. IF using layout, THE System SHALL use View Components (not Blazor components in MVC views)
4. THE System SHALL separate concerns (HTML structure, CSS styling, JavaScript behavior)
5. THE System SHALL use proper Razor syntax without inline scripts
6. THE System SHALL load CSS files in the head section
7. THE System SHALL load JavaScript files at the end of body (if needed)

### Requirement 4: Rendering Verification

**User Story:** As a developer, I want to verify that the page renders correctly, so that I can confirm the fix works.

#### Acceptance Criteria

1. WHEN the user navigates to /Obra/Escolher, THE System SHALL render the page without blank screen
2. WHEN the page loads, THE System SHALL display the title "Selecione uma das unidades escolares abaixo:"
3. WHEN the page loads, THE System SHALL display all obra cards in a grid
4. WHEN the page loads, THE System SHALL display icons for each obra
5. WHEN the page loads, THE System SHALL display progress bars with correct colors
6. WHEN the page loads, THE System SHALL display the legend section
7. WHEN the user opens F12 console, THE System SHALL show no errors
8. WHEN the user checks Network tab, THE System SHALL show all CSS files loaded successfully

### Requirement 5: Diagnostic Approach

**User Story:** As a developer, I want a systematic diagnostic approach, so that I can identify issues quickly.

#### Acceptance Criteria

1. THE System SHALL provide a diagnostic checklist for blank page issues
2. THE System SHALL verify controller execution first
3. THE System SHALL verify view file integrity second
4. THE System SHALL verify CSS file loading third
5. THE System SHALL verify JavaScript errors fourth
6. THE System SHALL verify layout rendering fifth
7. THE System SHALL document each diagnostic step
8. THE System SHALL provide clear pass/fail criteria for each step

### Requirement 6: Prevention Strategy

**User Story:** As a developer, I want to prevent blank page issues in the future, so that we don't waste time on repeated fixes.

#### Acceptance Criteria

1. THE System SHALL document the root cause once identified
2. THE System SHALL document the correct architecture pattern to use
3. THE System SHALL provide code review guidelines
4. THE System SHALL provide testing guidelines
5. THE System SHALL identify anti-patterns to avoid
6. THE System SHALL create a reference implementation
7. THE System SHALL document lessons learned

### Requirement 7: Testing Protocol

**User Story:** As a developer, I want a comprehensive testing protocol, so that I can verify the fix works before claiming completion.

#### Acceptance Criteria

1. THE System SHALL require visual verification (page renders)
2. THE System SHALL require functional verification (clicking works)
3. THE System SHALL require console verification (no errors)
4. THE System SHALL require network verification (CSS loads)
5. THE System SHALL require multiple browser testing
6. THE System SHALL require incognito mode testing
7. THE System SHALL require cache-cleared testing
8. THE System SHALL document test results with screenshots

## Current State Analysis

### What We Know

1. **Controller Works**: Logs show "103 obras retrieved" - backend is functioning
2. **View File Exists**: File is not empty (has content)
3. **CSS Files Exist**: fontello.css and escolher-legacy.css are present
4. **Layout = null**: Page is configured as standalone
5. **HTML Structure Present**: Has <!DOCTYPE html>, <html>, <head>, <body> tags

### What's Wrong

1. **Inline JavaScript in Razor**: Multiple `<script>console.log()</script>` tags mixed with Razor syntax
2. **JavaScript/Razor Mixing**: Attempting to use Razor variables inside JavaScript strings
3. **Legacy Pollution**: Code patterns that don't follow .NET 8 best practices
4. **Diagnostic Code in Production**: Console.log statements should not be in production code

### Previous Fix Attempts (All Failed)

1. **Attempt 1**: Created View Component wrapper for Blazor component
2. **Attempt 2**: Removed layout dependency, made standalone page
3. **Attempt 3**: Created escolher-legacy.css with pure CSS
4. **Attempt 4**: Removed UnifiedRdoHeader component
5. **Attempt 5**: Added debug console.log statements (current state)
6. **Attempt 6**: Created EscolherNuclear.cshtml test page
7. **Attempt 7**: Multiple "forensic audits" and "root cause" documents

### Pattern in Failed Fixes

All fixes focused on **architecture changes** (layout, components, CSS) but never addressed the **code quality issues** (inline scripts, mixed syntax, legacy pollution).

## Success Criteria

The fix will be considered successful when:

1. ✅ Page renders without blank screen
2. ✅ All 103 obra cards display
3. ✅ No console errors in F12
4. ✅ All CSS files load successfully
5. ✅ Clicking obra cards navigates correctly
6. ✅ Code follows .NET 8 best practices
7. ✅ No inline JavaScript in Razor views
8. ✅ No legacy pollution
9. ✅ Works in multiple browsers
10. ✅ Works in incognito mode
11. ✅ Works after cache clear
12. ✅ User confirms it works

## Out of Scope

- Adding new features to the Escolher page
- Redesigning the visual appearance
- Optimizing performance
- Adding filtering functionality
- Adding sorting functionality
- Migrating to Blazor components

## Constraints

- Must maintain current visual appearance
- Must work with existing database schema
- Must work with existing controller logic
- Must not break other pages
- Must follow ASP.NET Core MVC patterns
- Must be production-ready (no debug code)
