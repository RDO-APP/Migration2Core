# ASSET PATH CRISIS - REAL AUDIT & FIX

**Date**: January 19, 2026  
**Status**: 🔴 CRITICAL - 404 Errors Breaking Visual Identity

## EVIDENCE FROM F12 CONSOLE

```
fontello.css:1  Failed to load resource: the server responded with a status of 404 ()
user.png:1      Failed to load resource: the server responded with a status of 404 ()
```

## ROOT CAUSE ANALYSIS

### TASK 1: Legacy vs New Path Architecture Comparison

| Resource | Legacy Path (Gilberto) | New .NET 8 Path (Actual) | Status |
|----------|------------------------|--------------------------|--------|
| **fontello.css** | `Assets/Styles/fonts.css` (contains @font-face) | `~/css/fontello.css` | ✅ EXISTS |
| **fontello fonts** | `Assets/Fonts/fontello.*` | `~/fonts/fontello.*` | ✅ EXISTS |
| **user.png** | `Assets/images/user.png` | `~/Assets/images/user.png` | ✅ EXISTS |
| **logo.png** | `Assets/images/logo.png` | `~/images/logo.png` | ✅ EXISTS |

### KEY DISCOVERY

**THE FILES EXIST!** The 404 errors are NOT because files are missing. The problem is:

1. **Static File Middleware Configuration** - May not be serving `/Assets/` path correctly
2. **Case Sensitivity** - Windows is case-insensitive, but production Linux servers are not
3. **Path Resolution** - Blazor components vs Razor views handle paths differently

## ACTUAL FILE LOCATIONS (VERIFIED)

```
✅ RDO-NET8-Migration/RdoApp.Core/wwwroot/css/fontello.css
✅ RDO-NET8-Migration/RdoApp.Core/wwwroot/fonts/fontello.eot
✅ RDO-NET8-Migration/RdoApp.Core/wwwroot/fonts/fontello.woff
✅ RDO-NET8-Migration/RdoApp.Core/wwwroot/fonts/fontello.woff2
✅ RDO-NET8-Migration/RdoApp.Core/wwwroot/fonts/fontello.ttf
✅ RDO-NET8-Migration/RdoApp.Core/wwwroot/fonts/fontello.svg
✅ RDO-NET8-Migration/RdoApp.Core/wwwroot/Assets/images/user.png
✅ RDO-NET8-Migration/RdoApp.Core/wwwroot/images/logo.png
```

## TASK 2: IMMEDIATE STRUCTURAL FIX

### Issue 1: Header Layout Vertical Instead of Horizontal

**Problem**: The header appears as a vertical list instead of horizontal row  
**Root Cause**: CSS not loading OR Flexbox/Grid styles not applied

**Evidence from Legacy**:
```html
<!-- Legacy nav.html uses horizontal flexbox layout -->
<nav class="navbar bg-blue-default">
    <div class="no-padding">
        <a class="navbar-brand logo pointer">
            <i class="icon-logo"></i>
            <span>Piscinas</span>
        </a>
        <div class="menu-lateral">
            <h2 id="tituloObra">{{ controller.userData.obraColaborador.nomeObra.toUpperCase() }}</h2>
        </div>
    </div>
</nav>
```

### Issue 2: 103 Cards Ghosting

**Problem**: Backend returns 103 obras, but frontend shows empty screen  
**Root Cause**: Cards are being rendered but hidden OR loop not executing

## CORRECTED PATH TABLE

| Asset Type | Correct Path | Used In | Fix Required |
|------------|--------------|---------|--------------|
| **fontello.css** | `/css/fontello.css` | All layouts | ✅ Already correct |
| **fontello fonts** | `/fonts/fontello.*` | fontello.css @font-face | ✅ Already correct |
| **user.png** | `/Assets/images/user.png` | UnifiedRdoHeader | ⚠️ Case-sensitive path |
| **logo.png** | `/images/logo.png` | Login, Headers | ✅ Already correct |

## DIAGNOSIS PLAN

### Step 1: Verify Static File Middleware
Check `Program.cs` for proper static file configuration

### Step 2: Test Asset Loading
Create diagnostic endpoint to verify file serving

### Step 3: Fix Header CSS
Ensure horizontal layout CSS is properly applied

### Step 4: Debug Card Rendering
Verify the loop in Escolher.cshtml is executing

## NEXT ACTIONS

1. ✅ Audit complete - Files exist, paths are mostly correct
2. 🔄 Check Program.cs static file middleware configuration
3. 🔄 Verify case sensitivity on `/Assets/` path
4. 🔄 Fix header horizontal layout CSS
5. 🔄 Debug 103 cards rendering issue
