# Blazor Logo Path Resolution Fix - Tasks

## 🎯 Implementation Tasks

### Phase 1: File Verification & Preparation
**Duration**: 15 minutes  
**Priority**: Critical

#### Task 1.1: Verify Logo File Existence
- [ ] Check if `RDO-NET8-Migration/RdoApp.Core/wwwroot/images/logo.jpg` exists
- [ ] Verify file size and format
- [ ] Test file permissions and accessibility
- [ ] Document current file location and properties

#### Task 1.2: Test Direct File Access
- [ ] Start application server
- [ ] Test HTTP GET request to `https://localhost:7201/images/logo.jpg`
- [ ] Verify 200 response code
- [ ] Document any access issues

#### Task 1.3: Audit Current Path Usage
- [ ] Search all Blazor components for `~/images/logo.jpg` references
- [ ] Identify all files that need path updates
- [ ] Create list of affected components

### Phase 2: Component Path Updates
**Duration**: 20 minutes  
**Priority**: Critical

#### Task 2.1: Update LoginPage.razor
- [ ] Open `RDO-NET8-Migration/RdoApp.Core/Components/LoginPage.razor`
- [ ] Find logo image tag with `~/images/logo.jpg`
- [ ] Replace with `/images/logo.jpg`
- [ ] Verify syntax and save changes

#### Task 2.2: Update HeaderEscolher.razor
- [ ] Open `RDO-NET8-Migration/RdoApp.Core/Components/HeaderEscolher.razor`
- [ ] Find logo image tag with `~/images/logo.jpg`
- [ ] Replace with `/images/logo.jpg`
- [ ] Verify syntax and save changes

#### Task 2.3: Update Additional Components
- [ ] Check `HeaderEtapaTarefa.razor` for logo references
- [ ] Check `UnifiedRdoHeader.razor` for logo references
- [ ] Update any other components found in audit
- [ ] Ensure consistent path usage across all components

### Phase 3: Static File Configuration Verification
**Duration**: 10 minutes  
**Priority**: High

#### Task 3.1: Verify Program.cs Configuration
- [ ] Open `RDO-NET8-Migration/RdoApp.Core/Program.cs`
- [ ] Verify `app.UseStaticFiles()` is called
- [ ] Ensure static files middleware comes before routing
- [ ] Check for any custom static file configurations

#### Task 3.2: Verify wwwroot Structure
- [ ] Confirm wwwroot directory structure is correct
- [ ] Check images subdirectory exists
- [ ] Verify file permissions on directories
- [ ] Test directory accessibility

### Phase 4: Build & Compilation Testing
**Duration**: 15 minutes  
**Priority**: High

#### Task 4.1: Clean Build Test
- [ ] Run `dotnet clean` to clear build cache
- [ ] Run `dotnet build` to verify no compilation errors
- [ ] Check for any warnings related to static files
- [ ] Verify build output includes wwwroot files

#### Task 4.2: Runtime Testing
- [ ] Start application with `dotnet run`
- [ ] Verify server starts without errors
- [ ] Check console output for static file serving logs
- [ ] Test application accessibility

### Phase 5: Browser Testing & Verification
**Duration**: 25 minutes  
**Priority**: Critical

#### Task 5.1: Chrome Testing
- [ ] Open Chrome and navigate to login page
- [ ] Open F12 Developer Tools
- [ ] Check Network tab for logo request
- [ ] Verify 200 response for `/images/logo.jpg`
- [ ] Check Console tab for any errors
- [ ] Verify logo displays correctly

#### Task 5.2: Incognito Mode Testing
- [ ] Open Chrome incognito window
- [ ] Navigate to login page
- [ ] Verify logo loads without cache
- [ ] Check for any console errors
- [ ] Confirm visual appearance

#### Task 5.3: Cross-Browser Testing
- [ ] Test in Firefox (normal + private mode)
- [ ] Test in Edge (normal + InPrivate mode)
- [ ] Verify consistent behavior across browsers
- [ ] Document any browser-specific issues

### Phase 6: End-to-End Flow Testing
**Duration**: 20 minutes  
**Priority**: High

#### Task 6.1: Complete Login Flow
- [ ] Test login page logo display
- [ ] Complete login process
- [ ] Navigate to obra selection page
- [ ] Verify logo displays in header
- [ ] Check for any console errors throughout flow

#### Task 6.2: Session Preservation Testing
- [ ] Test authentication state preservation
- [ ] Verify no session loss warnings in console
- [ ] Test page refresh behavior
- [ ] Confirm logo loads after navigation

### Phase 7: Documentation & Cleanup
**Duration**: 10 minutes  
**Priority**: Medium

#### Task 7.1: Create Test Script
- [ ] Create PowerShell script to verify logo loading
- [ ] Include HTTP request tests
- [ ] Add browser automation if needed
- [ ] Document test procedures

#### Task 7.2: Update Documentation
- [ ] Document path resolution changes
- [ ] Update any developer guides
- [ ] Create troubleshooting notes
- [ ] Record lessons learned

## 🧪 Testing Checklist

### Pre-Implementation Tests
- [ ] Current logo path returns 404
- [ ] F12 console shows logo loading error
- [ ] Direct file access test

### Post-Implementation Tests
- [ ] Logo path returns 200
- [ ] F12 console shows no logo errors
- [ ] Logo displays correctly in UI
- [ ] Cross-browser compatibility confirmed
- [ ] Incognito mode works correctly

## 🚨 Risk Mitigation

### Potential Issues
1. **File Not Found**: Logo file missing from wwwroot
   - **Mitigation**: Copy logo from production or create placeholder

2. **Permission Issues**: File access denied
   - **Mitigation**: Check and fix file permissions

3. **Caching Issues**: Browser cache showing old errors
   - **Mitigation**: Test in incognito mode, clear cache

4. **Build Issues**: Static files not included in build
   - **Mitigation**: Verify project file includes wwwroot

### Rollback Plan
1. Revert component changes to original `~/` syntax
2. Restore original files from backup
3. Investigate alternative path resolution methods

## 📊 Success Metrics

### Primary Metrics
- **Zero 404 errors** for logo.jpg in F12 console
- **Logo visible** in all tested browsers
- **HTTP 200 response** for logo endpoint

### Secondary Metrics
- **Load time < 2 seconds** for logo display
- **No JavaScript errors** related to image loading
- **Consistent appearance** across browsers

## 🎯 Definition of Done

- [ ] All component logo paths updated to use `/images/logo.jpg`
- [ ] Logo file verified to exist and be accessible
- [ ] Static file middleware properly configured
- [ ] Build completes without errors or warnings
- [ ] Logo displays correctly in Chrome, Firefox, and Edge
- [ ] F12 console shows no 404 errors for logo
- [ ] Incognito mode testing passes
- [ ] Complete login flow works end-to-end
- [ ] Test script created and documented
- [ ] Changes committed and documented