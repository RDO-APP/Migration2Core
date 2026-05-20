# Blazor Logo Path Resolution Fix - Requirements

## 🎯 Problem Statement

The ESCOLHER OBRA page shows a 404 error for the logo image: `GET https://localhost:7201/~/images/logo.jpg 404 (Not Found)`. This is caused by Blazor Server-Side Rendering incorrectly interpreting the `~/` path prefix.

## 👤 User Stories

### US1: Logo Display Fix
**As a** user accessing the obra selection page  
**I want** the RDO logo to display correctly  
**So that** I can see the proper branding and the page loads without errors

### US2: Asset Path Consistency
**As a** developer maintaining the application  
**I want** all asset paths to use consistent, Blazor-compatible syntax  
**So that** static files load reliably across all components

### US3: Console Error Elimination
**As a** user or developer  
**I want** the browser console to be free of 404 errors  
**So that** the application appears professional and debugging is easier

## 🎯 Acceptance Criteria

### AC1: Logo Path Resolution
- [ ] Logo image loads successfully without 404 errors
- [ ] Path uses Blazor-compatible syntax (`/images/logo.jpg` instead of `~/images/logo.jpg`)
- [ ] Logo displays correctly in all browsers (Chrome, Firefox, Edge)

### AC2: Static File Verification
- [ ] Logo file exists in `wwwroot/images/logo.jpg`
- [ ] Static file middleware is properly configured
- [ ] File permissions allow web server access

### AC3: Blazor Component Integration
- [ ] Logo renders correctly in LoginPage.razor
- [ ] Logo renders correctly in HeaderEscolher.razor
- [ ] No JavaScript errors related to image loading

### AC4: Cross-Browser Compatibility
- [ ] Logo loads in normal browsing mode
- [ ] Logo loads in incognito/private browsing mode
- [ ] Logo loads with browser cache disabled

## 🔍 Technical Requirements

### TR1: Path Syntax
- Use absolute paths starting with `/` for all static assets in Blazor components
- Avoid `~/` syntax which can cause resolution issues in Blazor SSR

### TR2: File Structure
- Logo must be located at `RDO-NET8-Migration/RdoApp.Core/wwwroot/images/logo.jpg`
- File must be accessible via HTTP GET request

### TR3: Middleware Configuration
- `app.UseStaticFiles()` must be configured before routing
- Static file serving must be enabled for `/images/` path

## 🚫 Out of Scope

- Logo design changes or optimization
- Alternative image formats (PNG, SVG)
- CDN or external hosting solutions
- Image caching strategies

## 🧪 Testing Strategy

### Manual Testing
1. Start application with `dotnet run`
2. Navigate to login page
3. Check F12 console for 404 errors
4. Verify logo displays correctly
5. Test in incognito mode

### Automated Testing
1. HTTP request test for logo endpoint
2. Build verification (no compilation errors)
3. Static file serving test

## 📊 Success Metrics

- **Primary**: Zero 404 errors for logo.jpg in F12 console
- **Secondary**: Logo visible in UI within 2 seconds of page load
- **Tertiary**: No JavaScript errors related to image loading

## 🔗 Dependencies

- Static file middleware configuration in Program.cs
- Correct file permissions on wwwroot directory
- Blazor Server-Side Rendering pipeline

## 🎯 Priority: CRITICAL

This fix is critical because:
1. It's causing visible console errors
2. It affects user perception of application quality
3. It's a prerequisite for other UI fixes
4. It's blocking the complete user flow testing