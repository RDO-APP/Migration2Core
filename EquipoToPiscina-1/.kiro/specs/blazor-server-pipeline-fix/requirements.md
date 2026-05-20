# Requirements Document

## Introduction

Fix the fundamental architectural flaws in the .NET 8 Blazor Server pipeline that are causing the "Empty Screen Paradox" where backend data loads successfully but frontend rendering fails completely.

## Glossary

- **Blazor_Server**: Server-side Blazor rendering with SignalR circuits
- **Static_File_Middleware**: .NET middleware responsible for serving CSS, JS, images
- **Custom_Middleware**: Application-specific middleware for legacy route handling
- **Pipeline_Order**: The sequence of middleware execution in Program.cs
- **MIME_Type_Mapping**: Server configuration for file type recognition

## Requirements

### Requirement 1: Blazor Server Runtime Initialization

**User Story:** As a user, I want Blazor Server components to render properly, so that the header and card components display correctly.

#### Acceptance Criteria

1. WHEN the layout loads, THE Blazor_Server SHALL initialize the SignalR circuit connection
2. WHEN a Blazor component is rendered, THE Blazor_Server SHALL provide the necessary JavaScript runtime
3. THE Layout SHALL include the Blazor Server script bundle before any component rendering
4. WHEN the UnifiedRdoHeader component initializes, THE Blazor_Server SHALL maintain the connection for interactive features

### Requirement 2: Static File Pipeline Correction

**User Story:** As a browser, I want to load CSS and asset files without interference, so that styling and icons display correctly.

#### Acceptance Criteria

1. WHEN a request is made for static files, THE Static_File_Middleware SHALL process it before custom middleware
2. WHEN fontello.css is requested, THE Static_File_Middleware SHALL serve it with correct MIME type
3. THE Custom_Middleware SHALL NOT intercept requests for /css/, /js/, /Assets/, or _content/ paths
4. WHEN static files are served, THE Pipeline_Order SHALL ensure no authentication interference

### Requirement 3: Middleware Pipeline Order Fix

**User Story:** As the application, I want middleware to execute in the correct order, so that static files and authentication work properly.

#### Acceptance Criteria

1. THE Pipeline_Order SHALL be: Static Files → Routing → Session → Authentication → Custom Logic
2. WHEN UseStaticFiles is called, THE Static_File_Middleware SHALL have priority over all custom middleware
3. THE Custom_Middleware SHALL only handle page-level redirects, never asset requests
4. WHEN a static file request occurs, THE Custom_Middleware SHALL be bypassed completely

### Requirement 4: MIME Type and File Serving Configuration

**User Story:** As the server, I want to properly serve all asset types, so that fonts, CSS, and images load correctly.

#### Acceptance Criteria

1. THE Static_File_Middleware SHALL recognize .css files in /css/ directory
2. WHEN custom font files are requested, THE Static_File_Middleware SHALL serve them with appropriate headers
3. THE Static_File_Middleware SHALL serve Blazor framework files from _content/ paths
4. WHEN development mode is active, THE Static_File_Middleware SHALL disable caching for CSS files

### Requirement 5: Component Rendering Integration

**User Story:** As a Blazor component, I want to render with proper styling and interactivity, so that the 103 obras cards display correctly.

#### Acceptance Criteria

1. WHEN RdoObraCards component renders, THE Blazor_Server SHALL apply scoped CSS from the bundle
2. THE Component SHALL receive data from the controller without rendering failures
3. WHEN component CSS is missing, THE Blazor_Server SHALL log specific error messages
4. THE Component SHALL maintain interactivity through the SignalR circuit