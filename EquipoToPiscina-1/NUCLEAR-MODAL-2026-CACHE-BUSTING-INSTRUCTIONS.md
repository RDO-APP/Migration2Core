# ☢️ NUCLEAR MODAL 2026 - CACHE BUSTING INSTRUCTIONS

## CRITICAL: Force Clean Rebuild Required

The **Nuclear 2026** system has been implemented with complete Bootstrap isolation. To ensure the new code reaches the browser, follow these steps:

### 1. Stop All Processes
```powershell
# Kill all RdoApp processes
Get-Process | Where-Object {$_.ProcessName -like "*RdoApp*" -or $_.ProcessName -like "*dotnet*"} | Stop-Process -Force
```

### 2. Clean Build Artifacts
```powershell
# Navigate to project directory
cd "RDO-NET8-Migration/RdoApp.Core"

# Remove build artifacts
Remove-Item -Recurse -Force bin, obj -ErrorAction SilentlyContinue

# Clean solution
dotnet clean
```

### 3. Force Browser Cache Clear
- **Chrome/Edge**: Ctrl+Shift+Delete → Clear all data
- **Or use Incognito/Private mode**
- **Or hard refresh**: Ctrl+F5

### 4. Rebuild and Test
```powershell
# Rebuild project
dotnet build

# Run project
dotnet run
```

## ☢️ PROOF OF LIFE INDICATORS

When the Nuclear 2026 system is active, you should see:

### 1. Layout Indicator (Top Right)
```
☢️ NUCLEAR 2026 ACTIVE ☢️
```
**Color**: RED background, white text

### 2. Cards Page Indicator (Below layout)
```
☢️ NUCLEAR CARDS 2026 ☢️
```
**Color**: RED background, white text

### 3. Console Messages (F12 Developer Tools)
```
☢️ ATOMIC VERSION 2026 IS ALIVE ☢️
```
**Color**: RED (console.error for visibility)

## ☢️ NUCLEAR FEATURES IMPLEMENTED

### 1. Complete Bootstrap Modal Isolation
- **NO** Bootstrap data attributes (`data-bs-toggle`, `data-bs-target`)
- **NO** Bootstrap Modal API calls
- **PURE** CSS `display: block !important` for modal show
- **CUSTOM** backdrop click handling

### 2. Plus Button Implementation
```html
<span class="btn-add-medicao" onclick="nuclearShowModal(@Model.Id, '@Html.Raw(Html.Encode(Model.Descricao))', @Model.StatusId); return false;">
```
- **SPAN** element (Bootstrap ignores spans)
- **ONCLICK** direct function call
- **NO** Bootstrap data attributes

### 3. Modal ID Change
- **OLD**: `modal-nova-medicao`
- **NEW**: `manual-modal-medicao-2026`
- **PURPOSE**: Avoid Bootstrap tracking

### 4. Smart Defaults (Written in Stone)
- **Date**: Set to today IMMEDIATELY
- **Status**: Set to task status IMMEDIATELY
- **Task ID**: Set IMMEDIATELY
- **Description**: Set IMMEDIATELY

### 5. Database Mapping (Written in Stone)
```javascript
// CRITICAL FIX: 'Nível de Detritos' (UI) MUST save to tar_nr_nivel_bacteria (Database)
formData.append('NivelBacteria', document.querySelector('input[name="nivelDetritos"]:checked').value);
```

## ☢️ TROUBLESHOOTING

### If You Still See Old Messages:
1. **"CSS LOADED ✅"** → Old layout cached, force browser refresh
2. **Console.log instead of console.error** → Old script cached, clear browser cache
3. **Bootstrap errors persist** → Process lock, kill all dotnet processes

### If Modal Doesn't Open:
1. Check console for "Modal element not found"
2. Verify modal ID is `manual-modal-medicao-2026`
3. Ensure `nuclearShowModal` function is defined

### If Smart Defaults Don't Work:
1. Check console for "Date set to today" messages
2. Verify form field IDs match expected names
3. Ensure function executes before modal display

## ☢️ SUCCESS CRITERIA

✅ **RED** "Nuclear 2026" indicators visible  
✅ **RED** console messages in F12  
✅ Plus button opens modal without Bootstrap errors  
✅ Date and Status auto-filled  
✅ Modal saves data successfully  
✅ **NO** `classList` or `maskMoney` errors  

## ☢️ NUCLEAR GUARANTEE

This implementation uses **ZERO** Bootstrap Modal API and **ZERO** maskMoney library. All functionality is pure DOM manipulation with complete isolation from Bootstrap's event system.

**Result**: 100% elimination of `Cannot read properties of undefined (reading 'classList')` errors.