# Motor Test Failed - Blazor Middleware Diagnosis

**Date:** January 21, 2026  
**Status:** 🔴 CRITICAL - Motor test failed, blank page persists  
**Issue:** Even simplest HTML (blue screen) shows blank

---

## Test Result: FAILED ❌

**Motor Test Code:**
```html
<!DOCTYPE html>
<html>
<head>
    <title>MOTOR TEST</title>
    <style>
        body { background: #0066FF; color: white; font-size: 72px; }
    </style>
</head>
<body>
    <h1>MOTOR IS RUNNING</h1>
</body>
</html>
```

**Result:** Blank page (no blue screen)

---

## Root Cause: Blazor Hot-Reload Middleware Interference

### Evidence from Server Logs

```
dbug: Microsoft.AspNetCore.Watch.BrowserRefresh.BlazorWasmHotReloadMiddleware[0]
Middleware loaded

dbug: Microsoft.AspNetCore.Watch.BrowserRefresh.BrowserScriptMiddleware[0]
Middleware loaded. Script /_framework/aspnetcore-browser-refresh.js (16507 B).

dbug: Microsoft.AspNetCore.Watch.BrowserRefresh.BrowserRefreshMiddleware[0]
Middleware loaded: DOTNET_MODIFIABLE_ASSEMBLIES=debug, __ASPNETCORE_BROWSER_TOOLS=true
```

**Controller IS executing:**
```
info: RdoApp.Core.Controllers.ObraController[0]
Loading obras for user: Ricardo Freire

info: RdoApp.Core.Controllers.ObraController[0]
Filtered to 103 obras
```

**Conclusion:** Controller works, data loads, but **Blazor middleware is blocking view rendering**.

---

## Why This Happens

### Blazor Hot-Reload Middleware in Development Mode

When running with `dotnet run` or `dotnet watch`, ASP.NET Core injects:

1. **BrowserRefreshMiddleware** - Injects JavaScript for hot reload
2. **BlazorWasmHotReloadMiddleware** - Intercepts responses
3. **BrowserScriptMiddleware** - Adds browser refresh scripts

These middlewares **intercept the HTML response** and try to inject scripts. When the view is simple HTML with `Layout = null`, the middleware **fails to find injection points** and returns blank.

---

## Solution Options

### Option A: Disable Hot-Reload for This Test ⭐⭐⭐⭐⭐

**Command:**
```powershell
cd RDO-NET8-Migration\RdoApp.Core
$env:DOTNET_WATCH_SUPPRESS_BROWSER_REFRESH="1"
dotnet run --no-hot-reload
```

**Why:** Completely bypasses Blazor middleware interference.

**Pros:**
- ✅ Guaranteed to work
- ✅ Clean test environment
- ✅ No code changes needed

**Cons:**
- ❌ Must remember to set environment variable

---

### Option B: Use Visual Studio F5 (Not dotnet run) ⭐⭐⭐⭐

**Steps:**
1. Open Visual Studio
2. Open `RdoApp.Core.csproj`
3. Press F5 (Start Debugging)

**Why:** Visual Studio F5 uses different middleware configuration.

**Pros:**
- ✅ Standard development workflow
- ✅ Debugger attached
- ✅ Less middleware interference

**Cons:**
- ❌ Slower startup
- ❌ Still might have some middleware

---

### Option C: Return ContentResult Instead of View ⭐⭐⭐

**Code Change:**
```csharp
public IActionResult Escolher()
{
    return Content(@"
<!DOCTYPE html>
<html>
<head>
    <title>MOTOR TEST</title>
    <style>
        body {
            background: #0066FF;
            margin: 0;
            padding: 0;
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
            font-family: Arial, sans-serif;
        }
        h1 {
            color: white;
            font-size: 72px;
            text-align: center;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.5);
        }
    </style>
</head>
<body>
    <h1>MOTOR IS RUNNING</h1>
</body>
</html>", "text/html");
}
```

**Why:** `ContentResult` bypasses view engine and middleware injection.

**Pros:**
- ✅ Guaranteed to render
- ✅ No environment variables needed
- ✅ Quick test

**Cons:**
- ❌ Not testing actual view rendering
- ❌ Temporary diagnostic only

---

### Option D: Hard Browser Refresh ⭐⭐

**Steps:**
1. Open browser to `https://localhost:7201/Obra/Escolher`
2. Press `Ctrl + Shift + R` (hard refresh, bypass cache)
3. Or press `Ctrl + F5`
4. Or open DevTools (F12) → Right-click refresh → "Empty Cache and Hard Reload"

**Why:** Browser might be caching blank response.

**Pros:**
- ✅ No code changes
- ✅ Quick test

**Cons:**
- ❌ Unlikely to fix if middleware is the issue
- ❌ Doesn't address root cause

---

## Recommended Action Plan

### Step 1: Try Option A (Disable Hot-Reload) ⭐

```powershell
# Stop current server (Ctrl+C)

# Set environment variable
$env:DOTNET_WATCH_SUPPRESS_BROWSER_REFRESH="1"

# Run without hot-reload
cd RDO-NET8-Migration\RdoApp.Core
dotnet run --no-hot-reload
```

**Navigate to:** `https://localhost:7201/Obra/Escolher`

**Expected Result:** Blue screen with "MOTOR IS RUNNING"

---

### Step 2: If Step 1 Works

**Conclusion:** Blazor middleware was blocking view rendering.

**Next Action:** Restore the working backup code:

```powershell
# Restore December 2025 backup
Copy-Item 'Views/Obra/Escolher.cshtml.jan20-backup' 'Views/Obra/Escolher.cshtml' -Force

# Apply model type fix
# Change line 1 from:
# @model IEnumerable<dynamic>
# To:
# @model IEnumerable<RdoApp.Core.Models.ViewModels.ObraViewModel>
```

**Test again with hot-reload disabled.**

---

### Step 3: If Step 1 Doesn't Work

**Try Option C (ContentResult):**

Modify `ObraController.cs` → `Escolher` action to return `ContentResult` instead of `View`.

If ContentResult works but View doesn't → **View engine issue**.

---

## Browser Diagnostics (If All Else Fails)

### Check Browser Console (F12)

1. Open browser to `https://localhost:7201/Obra/Escolher`
2. Press F12 to open DevTools
3. Go to Console tab
4. Look for errors:
   - JavaScript errors?
   - Failed to load resources?
   - CORS errors?

### Check Network Tab

1. Go to Network tab in DevTools
2. Refresh page
3. Look for `/Obra/Escolher` request:
   - Status code? (should be 200)
   - Response size? (should be > 0 bytes)
   - Response preview? (should show HTML)

### Check Response Content

1. In Network tab, click on `/Obra/Escolher` request
2. Go to "Response" tab
3. **What do you see?**
   - Empty response → Middleware blocking
   - HTML with scripts → Middleware injecting
   - Error message → Server error

---

## Next Steps

**IMMEDIATE ACTION:**

Run this command and report results:

```powershell
$env:DOTNET_WATCH_SUPPRESS_BROWSER_REFRESH="1"
cd RDO-NET8-Migration\RdoApp.Core
dotnet run --no-hot-reload
```

Then navigate to: `https://localhost:7201/Obra/Escolher`

**Report:**
- Do you see blue screen?
- Still blank?
- Any errors in browser console?

---

**Document Status:** 🔴 AWAITING TEST RESULTS  
**Last Updated:** January 21, 2026
