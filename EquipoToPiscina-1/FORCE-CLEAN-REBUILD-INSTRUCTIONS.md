# FORCE CLEAN REBUILD INSTRUCTIONS - VIEW COMPILATION ISSUE

## PROBLEM IDENTIFIED
- "EM EXECUÇÃO" bar still appears (should be gone)
- Hand icons missing (should appear in header)
- **LIKELY CAUSE**: View compilation/caching issue in ASP.NET Core

## STEP 1: VERIFY FILE CHANGES WERE SAVED

### 1.1 Check _TaskCardPartial.cshtml Content
**Open in Visual Studio**: `RDO-NET8-Migration/RdoApp.Core/Views/Etapa/_TaskCardPartial.cshtml`

**VERIFY THIS CODE EXISTS** around line 8-22:
```razor
@switch (Model.StatusId)
{
    case 1: // Planejada
        <i class="fa fa-hand-paper-o" title="Planejada" style="color: #999;"></i>
        break;
    case 2: // Em Execução
        <i class="fa fa-hand-rock-o" title="Em Execução" style="color: #337ab7;"></i>
        break;
    case 3: // Finalizada
        <i class="fa fa-hand-peace-o" title="Finalizada" style="color: #5cb85c;"></i>
        break;
    case 4: // Paralisada
        <i class="fa fa-hand-stop-o" title="Paralisada" style="color: #f0ad4e;"></i>
        break;
    case 5: // Cancelada
        <i class="fa fa-hand-scissors-o" title="Cancelada" style="color: #d9534f;"></i>
        break;
    default:
        <i class="fa fa-hand-paper-o" title="Status Desconhecido" style="color: #999;"></i>
        break;
}
```

**❌ IF CODE IS MISSING**: The file wasn't saved properly - manually add the code above
**✅ IF CODE EXISTS**: Continue to Step 2

### 1.2 Check File Timestamp
- Right-click `_TaskCardPartial.cshtml` → Properties
- **Verify "Modified" timestamp** is recent (within last few minutes)
- **If timestamp is old**: File wasn't saved - manually save (Ctrl+S)

## STEP 2: FORCE CLEAN REBUILD

### 2.1 Stop All Running Processes
```cmd
# Stop IIS Express / Kestrel
# Close all browser tabs
# Stop Visual Studio debugging (Shift+F5)
```

### 2.2 Clean Solution (Visual Studio)
```
Build Menu → Clean Solution
Wait for completion message
```

### 2.3 Delete Compiled View Cache
**Delete these folders if they exist**:
```
RDO-NET8-Migration/RdoApp.Core/bin/
RDO-NET8-Migration/RdoApp.Core/obj/
RDO-NET8-Migration/RdoApp.Core/Views/Shared/_ViewImports.cshtml.g.cs (if exists)
```

**PowerShell Command** (run from project root):
```powershell
Remove-Item -Recurse -Force "RDO-NET8-Migration/RdoApp.Core/bin" -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force "RDO-NET8-Migration/RdoApp.Core/obj" -ErrorAction SilentlyContinue
Write-Host "Cache folders deleted"
```

### 2.4 Rebuild Solution
```
Build Menu → Rebuild Solution
Wait for "Rebuild All succeeded" message
```

### 2.5 Force View Recompilation
**Add this to appsettings.Development.json** (temporary):
```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*",
  "Microsoft.AspNetCore.Mvc.Razor.RuntimeCompilation": true
}
```

**Or add to Program.cs** (temporary):
```csharp
#if DEBUG
builder.Services.AddRazorPages().AddRazorRuntimeCompilation();
#endif
```

## STEP 3: VERIFY CHANGES TOOK EFFECT

### 3.1 Start Application
```
Press F5 in Visual Studio
Wait for application to fully load
```

### 3.2 Navigate to Cards Page
```
Go to: /Etapa/Cards or /Etapa/CardsRazor
```

### 3.3 Inspect HTML Source
**Right-click on card → Inspect Element**

**LOOK FOR**:
```html
<!-- SHOULD EXIST: Hand icon in header -->
<i class="fa fa-hand-rock-o" title="Em Execução" style="color: #337ab7;"></i>

<!-- SHOULD NOT EXIST: Bottom status bar -->
<div class="status">
    <a class="btn bg-azul">
        <span>EM EXECUÇÃO</span>
    </a>
</div>
```

### 3.4 Check Browser Developer Tools
**F12 → Console Tab**
- Look for JavaScript errors
- Look for CSS loading errors
- Check if FontAwesome is loaded

## STEP 4: ALTERNATIVE DEBUGGING

### 4.1 Check Which View is Actually Loading
**Add temporary debug code** to _TaskCardPartial.cshtml:
```razor
@model TarefaViewModel
<!-- DEBUG: TaskCardPartial loaded at @DateTime.Now -->
<div style="background: red; color: white; padding: 5px;">
    DEBUG: StatusId = @Model.StatusId
</div>
```

**Expected Result**: Red debug bar should appear on cards

### 4.2 Check Route/Controller
**Verify you're hitting the right endpoint**:
- Check URL in browser
- Ensure you're on `/Etapa/Cards` (Razor version)
- NOT on old AngularJS version

### 4.3 Check for Multiple View Files
**Search for duplicate files**:
```
Search in Solution Explorer for: "_TaskCardPartial"
Ensure only ONE file exists in Views/Etapa/
```

## STEP 5: NUCLEAR OPTION - MANUAL VERIFICATION

### 5.1 Create Test View
**Create**: `Views/Etapa/TestCards.cshtml`
```razor
@{
    ViewData["Title"] = "Test Cards";
}

<h1>TEST HAND ICONS</h1>

<div style="background: #5bc0de; color: white; padding: 10px;">
    <i class="fa fa-hand-rock-o" style="color: white; margin-right: 10px;"></i>
    <span>Test Hand Icon</span>
</div>
```

### 5.2 Add Test Action
**In EtapaController.cs**:
```csharp
public IActionResult TestCards()
{
    return View();
}
```

### 5.3 Navigate to Test
```
Go to: /Etapa/TestCards
```

**Expected**: Should see blue bar with hand icon
**If missing**: FontAwesome not loaded or CSS issue

## TROUBLESHOOTING CHECKLIST

- [ ] ✅ File contains hand icon @switch code
- [ ] ✅ File timestamp is recent
- [ ] ✅ Solution cleaned and rebuilt
- [ ] ✅ bin/obj folders deleted
- [ ] ✅ No compilation errors
- [ ] ✅ Correct URL (/Etapa/Cards not old AngularJS)
- [ ] ✅ No duplicate _TaskCardPartial files
- [ ] ✅ FontAwesome CSS loaded (check F12 Network tab)
- [ ] ✅ No JavaScript errors in console

## EXPECTED FINAL RESULT

**BEFORE (Current Issue)**:
```
[Cyan Header: LIMPEZA                    [5 buttons]]
[Card Body with progress, dates, etc.              ]
[Blue Bar: ▶ EM EXECUÇÃO                          ] ← Should be GONE
```

**AFTER (Fixed)**:
```
[Cyan Header: ✊ LIMPEZA                 [5 buttons]] ← Hand icon added
[Card Body with progress, dates, etc.              ]
                                                     ← Bottom bar GONE
```

**If still not working after all steps**: The issue may be that you're viewing the old AngularJS version instead of the new Razor version.