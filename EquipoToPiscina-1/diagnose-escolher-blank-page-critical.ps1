# CRITICAL DIAGNOSTIC: ESCOLHER OBRA BLANK PAGE
# User reports: Page blank, F12 Console empty
# Last change: Removed Blazor component, added direct Razor rendering

Write-Host "=== ESCOLHER OBRA BLANK PAGE DIAGNOSTIC ===" -ForegroundColor Cyan
Write-Host ""

# TEST 1: Check if CSS file exists
Write-Host "TEST 1: CSS File Existence" -ForegroundColor Yellow
$cssPath = "RDO-NET8-Migration/RdoApp.Core/wwwroot/css/escolher-legacy.css"
if (Test-Path $cssPath) {
    Write-Host "  ✅ escolher-legacy.css EXISTS" -ForegroundColor Green
    $cssSize = (Get-Item $cssPath).Length
    Write-Host "  📊 Size: $cssSize bytes" -ForegroundColor Gray
} else {
    Write-Host "  ❌ escolher-legacy.css NOT FOUND" -ForegroundColor Red
}
Write-Host ""

# TEST 2: Check Escolher.cshtml structure
Write-Host "TEST 2: Escolher.cshtml Structure" -ForegroundColor Yellow
$viewPath = "RDO-NET8-Migration/RdoApp.Core/Views/Obra/Escolher.cshtml"
if (Test-Path $viewPath) {
    Write-Host "  ✅ Escolher.cshtml EXISTS" -ForegroundColor Green
    
    $content = Get-Content $viewPath -Raw
    
    # Check for Layout = null
    if ($content -match 'Layout\s*=\s*null') {
        Write-Host "  ✅ Layout = null (standalone page)" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️  Layout NOT null (using layout)" -ForegroundColor Yellow
    }
    
    # Check for DOCTYPE
    if ($content -match '<!DOCTYPE html>') {
        Write-Host "  ✅ Has DOCTYPE" -ForegroundColor Green
    } else {
        Write-Host "  ❌ Missing DOCTYPE" -ForegroundColor Red
    }
    
    # Check for CSS link
    if ($content -match 'escolher-legacy\.css') {
        Write-Host "  ✅ Links to escolher-legacy.css" -ForegroundColor Green
    } else {
        Write-Host "  ❌ Missing escolher-legacy.css link" -ForegroundColor Red
    }
    
    # Check for Blazor component
    if ($content -match '<component') {
        Write-Host "  ⚠️  Uses Blazor component (may not work with Layout=null)" -ForegroundColor Yellow
    } else {
        Write-Host "  ✅ No Blazor component (direct rendering)" -ForegroundColor Green
    }
    
    # Check for @foreach loop
    if ($content -match '@foreach') {
        Write-Host "  ✅ Has @foreach loop (direct rendering)" -ForegroundColor Green
    } else {
        Write-Host "  ❌ Missing @foreach loop" -ForegroundColor Red
    }
    
    # Check for Model
    if ($content -match '@model') {
        Write-Host "  ✅ Has @model declaration" -ForegroundColor Green
    } else {
        Write-Host "  ❌ Missing @model declaration" -ForegroundColor Red
    }
    
} else {
    Write-Host "  ❌ Escolher.cshtml NOT FOUND" -ForegroundColor Red
}
Write-Host ""

# TEST 3: Check ObraController
Write-Host "TEST 3: ObraController.Escolher Action" -ForegroundColor Yellow
$controllerPath = "RDO-NET8-Migration/RdoApp.Core/Controllers/ObraController.cs"
if (Test-Path $controllerPath) {
    Write-Host "  ✅ ObraController.cs EXISTS" -ForegroundColor Green
    
    $content = Get-Content $controllerPath -Raw
    
    # Check for Escolher action
    if ($content -match 'public async Task<IActionResult> Escolher') {
        Write-Host "  ✅ Escolher action exists" -ForegroundColor Green
    } else {
        Write-Host "  ❌ Escolher action NOT FOUND" -ForegroundColor Red
    }
    
    # Check for ViewBag.IsObraSelection
    if ($content -match 'ViewBag\.IsObraSelection') {
        Write-Host "  ✅ Sets ViewBag.IsObraSelection" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️  Missing ViewBag.IsObraSelection" -ForegroundColor Yellow
    }
    
} else {
    Write-Host "  ❌ ObraController.cs NOT FOUND" -ForegroundColor Red
}
Write-Host ""

# TEST 4: Suggest View Source test
Write-Host "TEST 4: Manual Testing Instructions" -ForegroundColor Yellow
Write-Host "  1. Start application (F5 in Visual Studio)" -ForegroundColor Cyan
Write-Host "  2. Login with: ricardo / senha123" -ForegroundColor Cyan
Write-Host "  3. Navigate to: https://localhost:7201/Obra/Escolher" -ForegroundColor Cyan
Write-Host "  4. Press Ctrl+U (View Source) in browser" -ForegroundColor Cyan
Write-Host "  5. Check if HTML is rendered or empty" -ForegroundColor Cyan
Write-Host ""

# TEST 5: Possible causes
Write-Host "TEST 5: Possible Causes of Blank Page" -ForegroundColor Yellow
Write-Host "  CAUSE 1: Model is null or empty" -ForegroundColor Gray
Write-Host "    - Controller returns empty list" -ForegroundColor Gray
Write-Host "    - Check: Backend logs show '103 obras found'" -ForegroundColor Gray
Write-Host ""
Write-Host "  CAUSE 2: View rendering fails silently" -ForegroundColor Gray
Write-Host "    - Razor syntax error" -ForegroundColor Gray
Write-Host "    - Missing @model declaration" -ForegroundColor Gray
Write-Host "    - Check: View Source (Ctrl+U) shows HTML or empty" -ForegroundColor Gray
Write-Host ""
Write-Host "  CAUSE 3: CSS not loading" -ForegroundColor Gray
Write-Host "    - 404 error for escolher-legacy.css" -ForegroundColor Gray
Write-Host "    - Check: F12 Network tab" -ForegroundColor Gray
Write-Host ""
Write-Host "  CAUSE 4: JavaScript error blocking render" -ForegroundColor Gray
Write-Host "    - But user says F12 Console is empty" -ForegroundColor Gray
Write-Host "    - This is UNLIKELY" -ForegroundColor Gray
Write-Host ""

Write-Host "=== DIAGNOSTIC COMPLETE ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "NEXT STEP: User needs to check View Source (Ctrl+U)" -ForegroundColor Yellow
Write-Host "  - If HTML is there: CSS issue" -ForegroundColor Gray
Write-Host "  - If HTML is empty: View rendering issue" -ForegroundColor Gray
