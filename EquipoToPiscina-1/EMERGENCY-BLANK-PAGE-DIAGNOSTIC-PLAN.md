# EMERGENCY BLANK PAGE DIAGNOSTIC PLAN

**Date**: January 18, 2026  
**Status**: 🔴 **CRITICAL - PAGE STILL BLANK AFTER SCRIPT REMOVAL**  
**Symptom**: Blank page + Empty F12 console = Silent failure

---

## CRITICAL FACTS

1. ✅ Removed all inline scripts - **PAGE STILL BLANK**
2. ✅ F12 console is EMPTY - **No JavaScript errors**
3. ✅ Project compiles successfully
4. ✅ Controller logs show 103 obras retrieved

**This means**: The problem is NOT JavaScript. It's something else.

---

## WHAT EMPTY CONSOLE MEANS

**Empty F12 console = One of these**:
1. Page never reaches the browser (server error)
2. View engine fails silently
3. Razor syntax error (server-side)
4. Model binding issue
5. HTTP 500 error (check Network tab!)

---

## IMMEDIATE DIAGNOSTIC STEPS

### Step 1: Check Network Tab (CRITICAL!)

**Open F12 → Network tab → Refresh page**

**Look for**:
- What HTTP status code? (200, 404, 500?)
- Does /Obra/Escolher request complete?
- What's the response size? (0 bytes = problem!)

**Report back**:
- HTTP status: ___
- Response size: ___
- Any red requests: ___

---

### Step 2: Check Server Logs

**Look at console where `dotnet run` is running**

**Look for**:
- Any exceptions?
- Any error messages?
- Does controller action execute?

---

### Step 3: View Source

**Right-click page → View Page Source**

**What do you see**:
- Empty HTML?
- Error message?
- Partial HTML?
- Complete HTML but not rendering?

---

## MOST LIKELY CAUSES (Based on Empty Console)

### Cause 1: HTTP 500 Error (Server Exception)
**Symptom**: Network tab shows 500 status
**Why**: Razor view has syntax error or Model is wrong type
**Fix**: Check server logs for exception

### Cause 2: Model Type Mismatch
**Symptom**: View expects different model type
**Why**: Controller returns `List<ObraViewModel>` but view expects something else
**Fix**: Verify @model declaration matches controller return type

### Cause 3: Razor Syntax Error
**Symptom**: View fails to compile on server
**Why**: Invalid Razor syntax in view
**Fix**: Check for unclosed tags, missing @, etc.

### Cause 4: CSS Files Block Rendering
**Symptom**: Page waits forever for CSS
**Why**: CSS files return 404 or take too long
**Fix**: Check Network tab for CSS file status

### Cause 5: View Engine Silent Failure
**Symptom**: No error, no content
**Why**: View engine can't find or render view
**Fix**: Check view file path and name

---

## EMERGENCY ACTIONS

### Action 1: Create Minimal Test View

**Create**: `RDO-NET8-Migration/RdoApp.Core/Views/Obra/EscolherTest.cshtml`

```html
<!DOCTYPE html>
<html>
<head>
    <title>TEST</title>
</head>
<body>
    <h1>MINIMAL TEST - IF YOU SEE THIS, VIEW ENGINE WORKS</h1>
    <p>Model count: @Model?.Count() ?? 0</p>
</body>
</html>
```

**Add controller action**:
```csharp
public async Task<IActionResult> EscolherTest()
{
    var obras = await _obraService.ObterObrasAsync(1);
    return View("EscolherTest", obras);
}
```

**Navigate to**: `/Obra/EscolherTest`

**Does it work?**
- YES → Problem is in Escolher.cshtml content
- NO → Problem is deeper (routing, auth, etc.)

---

### Action 2: Check If Controller Executes

**Add this to Escolher action** (temporarily):

```csharp
public async Task<IActionResult> Escolher()
{
    System.IO.File.WriteAllText("C:\\temp\\escolher-debug.txt", 
        $"Controller executed at {DateTime.Now}");
    
    // ... rest of code
}
```

**Check**: Does `C:\temp\escolher-debug.txt` get created?
- YES → Controller runs, problem is in view
- NO → Controller doesn't execute (routing/auth issue)

---

### Action 3: Return Plain Text

**Temporarily change Escolher action**:

```csharp
public async Task<IActionResult> Escolher()
{
    var obras = await _obraService.ObterObrasAsync(colaboradorId);
    return Content($"OBRAS COUNT: {obras.Count}", "text/plain");
}
```

**Does it show text?**
- YES → Controller works, problem is View() call
- NO → Controller doesn't execute

---

## WHAT I NEED FROM YOU

**Please provide**:

1. **Network Tab Info**:
   - HTTP status code for /Obra/Escolher
   - Response size
   - Any 404 or 500 errors

2. **View Page Source**:
   - Right-click → View Page Source
   - What do you see? (empty, error, HTML?)

3. **Server Console**:
   - Any error messages in console where dotnet run is?
   - Any exceptions?

4. **Browser Info**:
   - Which browser? (Chrome, Edge, Firefox?)
   - Incognito or normal mode?

---

## NEXT STEPS BASED ON YOUR ANSWERS

**If HTTP 500**:
→ Check server logs for exception
→ Fix Razor syntax error or model mismatch

**If HTTP 200 but empty**:
→ View renders but CSS blocks display
→ Check CSS file loading

**If HTTP 404**:
→ Routing issue
→ Check route configuration

**If Controller doesn't execute**:
→ Authentication redirect
→ Check if redirected to login

---

## MY HYPOTHESIS

**Based on "blank page + empty console"**, I suspect:

1. **Most likely**: HTTP 500 error (Razor syntax issue)
2. **Second**: Model type mismatch
3. **Third**: CSS files block rendering
4. **Fourth**: View engine can't find view

**But I need your diagnostic info to confirm.**

---

## STOP WASTING CREDITS

I will NOT make more changes until we have diagnostic data.

**Please run diagnostics and report**:
1. Network tab HTTP status
2. View page source content
3. Server console errors

**Then we'll know exactly what to fix.**

---

**Date**: January 18, 2026  
**Status**: Awaiting diagnostic data
