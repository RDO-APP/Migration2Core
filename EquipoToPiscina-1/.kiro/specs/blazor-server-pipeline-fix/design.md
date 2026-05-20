# Design Document

## Overview

This design addresses the "Empty Screen Paradox" by reconstructing the entire .NET 8 Blazor Server pipeline. The core issue is a three-way architectural failure: missing Blazor runtime, incorrect middleware order, and static file serving problems.

## Architecture

### Current Broken Pipeline
```
Request → UseRouting → UseSession → UseAuthentication → Custom Middleware → Static Files (TOO LATE)
```

### Fixed Pipeline Architecture
```
Request → UseStaticFiles (FIRST) → UseRouting → UseSession → UseAuthentication → Custom Middleware (PAGE ONLY)
```

## Components and Interfaces

### 1. Static File Middleware Configuration
- **Purpose**: Serve CSS, JS, fonts, and Blazor framework files
- **Position**: FIRST in pipeline, before any custom logic
- **Configuration**: Explicit MIME type mapping, development cache control

### 2. Blazor Server Runtime Integration
- **Purpose**: Initialize SignalR circuits for component interactivity
- **Components**: Script bundle, hub mapping, circuit management
- **Integration**: Layout must include `_framework/blazor.server.js`

### 3. Custom Middleware Scope Limitation
- **Purpose**: Handle ONLY legacy page redirects
- **Exclusions**: Never intercept /css/, /js/, /Assets/, /_content/
- **Logic**: Path-based filtering with explicit static file bypass

### 4. Component Rendering Pipeline
- **Purpose**: Render Blazor components with proper CSS and interactivity
- **Dependencies**: Blazor runtime, scoped CSS bundle, SignalR connection
- **Error Handling**: Graceful degradation when CSS fails to load

## Data Models

### Static File Request Flow
```
Browser Request → Static File Middleware → Physical File Check → MIME Type → Response
```

### Blazor Component Lifecycle
```
Layout Load → Blazor Script → SignalR Connect → Component Render → CSS Apply → Interactive
```

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Static File Priority
*For any* request to /css/, /js/, /Assets/, or /_content/ paths, the static file middleware should process it before any custom middleware executes
**Validates: Requirements 2.1, 3.1**

### Property 2: Blazor Runtime Availability
*For any* page that contains Blazor components, the Blazor Server JavaScript runtime should be loaded before component rendering begins
**Validates: Requirements 1.1, 1.3**

### Property 3: Middleware Bypass Consistency
*For any* static asset request, the custom middleware should never intercept or modify the request
**Validates: Requirements 2.3, 3.3**

### Property 4: Component CSS Integration
*For any* Blazor component with scoped CSS, the component should render with its styles applied correctly
**Validates: Requirements 5.1, 5.2**

### Property 5: Pipeline Order Invariant
*For any* request, the middleware execution order should be: Static Files → Routing → Session → Authentication → Custom Logic
**Validates: Requirements 3.1, 3.2**

## Error Handling

### Static File 404 Handling
- Log specific file path and MIME type issues
- Provide fallback for missing CSS files
- Never redirect static file requests to login pages

### Blazor Circuit Failures
- Graceful degradation when SignalR connection fails
- Server-side rendering fallback for components
- Clear error messages for missing JavaScript runtime

### Component Rendering Errors
- Detailed logging when CSS bundles fail to load
- Fallback rendering without scoped styles
- Maintain functionality even with styling issues

## Testing Strategy

### Unit Tests
- Test middleware order configuration
- Test static file MIME type mapping
- Test component rendering with and without CSS
- Test custom middleware path filtering logic

### Property Tests
- Test static file serving across all asset types
- Test Blazor component rendering with random data sets
- Test middleware pipeline order with various request types
- Test CSS bundle loading with different component combinations

### Integration Tests
- Full request lifecycle from browser to rendered page
- Static file serving under load
- Blazor component interactivity testing
- Authentication flow with static file access