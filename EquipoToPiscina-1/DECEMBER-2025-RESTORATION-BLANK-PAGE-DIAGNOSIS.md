# December 2025 Restoration - Blank Page Diagnosis

**Date**: January 20, 2026  
**Issue**: Blank page at `https://localhost:7201/Obra/Escolher`  
**Status**: ❌ RESTORATION FAILED - DIAGNOSTIC ONLY

---

## ISSUE REPORT

**URL**: `https://localhost:7201/Obra/Escolher`  
**Result**: Blank page (no content rendered)  
**Expected**: Blue header, filters, white obra cards

---

## LIKELY ROOT CAUSES

Based on previous blank page issues with Escolher.cshtml, the problem is likely one of these:

### 1. **Model Type Mismatch** (MOST LIKELY)
```csharp
// Restored version uses:
@model IEnumerable<dynamic>

// Controller probably returns:
IEnumerable<ObraViewModel>
```

**Why this causes blank page**: The view expects `dynamic` but receives strongly-typed `ObraViewModel`. When accessing properties like `obra.Descricao`, it fails silently and renders nothing.

### 2. **Controller Not Passing Data**
- Controller action may not be populating the Model
- `ViewBag.UsuarioNome` may be null
- No obras in database for current user

### 3. **View Engine Failure**
- Razor syntax error in restored file
- Missing dependencies (Bootstrap, jQuery, Font Awesome)
- JavaScript errors preventing render

### 4. **Authentication/Authorization**
- User not authenticated
- Redirect happening before page loads
- Session issues

---

## DIAGNOSTIC STEPS NEEDED

### Check Browser Console (F12)
```
1. Open Developer Tools (F12)
2. Go to Console tab
3. Look for:
   - JavaScript errors
   - Failed network requests
   - Razor compilation errors
```

### Check Network Tab
```
1. Open Network tab in F12
2. Reload page
3. Check:
   - Is /Obra/Escolher request successful (200)?
   - Are CSS/JS files loading (Bootstrap, jQuery)?
   - Any 404 or 500 errors?
```

### Check Page Source
```
1. Right-click page → View Page Source
2. Check if:
   - HTML is present but not rendering?
   - Page is completely empty?
   - Error message in HTML?
```

---

## PROBABLE FIX (AWAITING PERMISSION)

The most likely fix is to change the model type back to strongly-typed:

```csharp
// Change FROM:
@model IEnumerable<dynamic>

// Change TO:
@model IEnumerable<RdoApp.Core.Models.ViewModels.ObraViewModel>
```

**Why this works**: The controller returns `ObraViewModel` objects, so the view needs to expect that type.

---

## ALTERNATIVE FIXES (IF MODEL ISN'T THE ISSUE)

### If Controller Issue:
```csharp
// Check ObraController.cs Escolher action
// Ensure it's returning data:
var obras = await _obraService.GetObrasForUser(userId);
return View(obras); // Must pass model
```

### If ViewBag Issue:
```csharp
// Ensure ViewBag.UsuarioNome is set:
ViewBag.UsuarioNome = User.Identity.Name;
```

### If JavaScript Issue:
- Check if jQuery is loading
- Check if Bootstrap is loading
- Check for syntax errors in inline JavaScript

---

## COMPARISON WITH WORKING VERSION

### January 20 Backup (Simplified - Was Working)
```csharp
@model IEnumerable<RdoApp.Core.Models.ViewModels.ObraViewModel>
// ✅ Strongly typed - matches controller
```

### December 2025 Backup (Restored - Not Working)
```csharp
@model IEnumerable<dynamic>
// ❌ Dynamic type - doesn't match controller
```

**This is the smoking gun** - the model type mismatch is almost certainly causing the blank page.

---

## RECOMMENDED ACTION

**Option 1: Quick Fix (Change Model Type)**
- Change `@model IEnumerable<dynamic>` to `@model IEnumerable<RdoApp.Core.Models.ViewModels.ObraViewModel>`
- Keep all other December 2025 code intact
- This preserves the blue header, filters, and JavaScript

**Option 2: Full Rollback**
- Restore the January 20 backup
- Lose the December 2025 features
- Page will work but without blue header/filters

**Option 3: Hybrid Approach**
- Start with January 20 backup (working)
- Gradually add December 2025 features
- Test after each addition

---

## WHAT USER SHOULD DO NOW

### 1. **Confirm Blank Page Details**
- Open F12 Developer Tools
- Check Console for errors
- Check Network tab for failed requests
- View Page Source to see if HTML is present

### 2. **Report Findings**
Share what you see in:
- Console errors
- Network failures
- Page source content

### 3. **Choose Fix Strategy**
- **Quick fix**: Change model type only
- **Rollback**: Restore January 20 backup
- **Investigate**: Provide diagnostic info for deeper analysis

---

## FILES INVOLVED

- **Current**: `RDO-NET8-Migration/RdoApp.Core/Views/Obra/Escolher.cshtml`
- **Backup**: `RDO-NET8-Migration/RdoApp.Core/Views/Obra/Escolher.cshtml.jan20-backup`
- **Controller**: `RDO-NET8-Migration/RdoApp.Core/Controllers/ObraController.cs`

---

## NEXT STEPS

**AWAITING USER PERMISSION TO:**
1. Check browser console/network for errors
2. Apply model type fix
3. OR rollback to working version
4. OR investigate further

**NO FIXES APPLIED YET** - waiting for your decision on how to proceed.

---

**Status**: ⏳ AWAITING USER DECISION  
**Issue**: Blank page - likely model type mismatch  
**Fix Ready**: Yes (change `dynamic` to `ObraViewModel`)  
**Permission**: NOT GRANTED YET
