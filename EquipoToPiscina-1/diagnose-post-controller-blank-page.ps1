# POST-CONTROLLER BLANK PAGE DIAGNOSIS
# The controller executes successfully but the page is still blank

Write-Host "=== POST-CONTROLLER BLANK PAGE DIAGNOSIS ===" -ForegroundColor Cyan
Write-Host "Controller executes successfully, but page is blank" -ForegroundColor Yellow

# Step 1: Check if the view file exists and is correct
Write-Host "`n1. CHECKING VIEW FILE EXISTENCE..." -ForegroundColor Green
$escolherView = "RDO-NET8-Migration/RdoApp.Core/Views/Obra/Escolher.cshtml"

if (Test-Path $escolherView) {
    Write-Host "   ✅ Escolher.cshtml exists" -ForegroundColor Green
    
    $viewContent = Get-Content $escolherView -Raw
    if ($viewContent -match '@model IEnumerable') {
        Write-Host "   ✅ View has correct model declaration" -ForegroundColor Green
    } else {
        Write-Host "   ❌ View missing model declaration" -ForegroundColor Red
    }
    
    if ($viewContent -match 'Layout.*_LayoutSelection') {
        Write-Host "   ✅ View uses _LayoutSelection layout" -ForegroundColor Green
    } else {
        Write-Host "   ❌ View not using _LayoutSelection layout" -ForegroundColor Red
    }
    
    if ($viewContent -match 'DEBUG.*Found.*obras') {
        Write-Host "   ✅ Debug section present" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Debug section missing" -ForegroundColor Red
    }
    
    if ($viewContent -match 'component.*RdoObraCards') {
        Write-Host "   ✅ RdoObraCards component reference present" -ForegroundColor Green
    } else {
        Write-Host "   ❌ RdoObraCards component reference missing" -ForegroundColor Red
    }
} else {
    Write-Host "   ❌ Escolher.cshtml does NOT exist" -ForegroundColor Red
}

# Step 2: Check if the layout file exists
Write-Host "`n2. CHECKING LAYOUT FILE..." -ForegroundColor Green
$layoutSelection = "RDO-NET8-Migration/RdoApp.Core/Views/Shared/_LayoutSelection.cshtml"

if (Test-Path $layoutSelection) {
    Write-Host "   ✅ _LayoutSelection.cshtml exists" -ForegroundColor Green
    
    $layoutContent = Get-Content $layoutSelection -Raw
    if ($layoutContent -match '@RenderBody\(\)') {
        Write-Host "   ✅ Layout has @RenderBody()" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Layout missing @RenderBody()" -ForegroundColor Red
    }
    
    if ($layoutContent -match 'blazor\.server\.js') {
        Write-Host "   ✅ Layout has Blazor Server script" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Layout missing Blazor Server script" -ForegroundColor Red
    }
} else {
    Write-Host "   ❌ _LayoutSelection.cshtml does NOT exist" -ForegroundColor Red
}

# Step 3: Check if the component file exists
Write-Host "`n3. CHECKING COMPONENT FILE..." -ForegroundColor Green
$rdoObraCards = "RDO-NET8-Migration/RdoApp.Core/Components/RdoObraCards.razor"

if (Test-Path $rdoObraCards) {
    Write-Host "   ✅ RdoObraCards.razor exists" -ForegroundColor Green
    
    $componentContent = Get-Content $rdoObraCards -Raw
    if ($componentContent -match '\[Parameter\].*List<ObraViewModel>') {
        Write-Host "   ✅ Component has correct parameter" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Component missing parameter declaration" -ForegroundColor Red
    }
} else {
    Write-Host "   ❌ RdoObraCards.razor does NOT exist" -ForegroundColor Red
}

# Step 4: Check ViewStart configuration
Write-Host "`n4. CHECKING VIEWSTART CONFIGURATION..." -ForegroundColor Green
$viewStart = "RDO-NET8-Migration/RdoApp.Core/Views/_ViewStart.cshtml"

if (Test-Path $viewStart) {
    Write-Host "   ✅ _ViewStart.cshtml exists" -ForegroundColor Green
    
    $viewStartContent = Get-Content $viewStart -Raw
    if ($viewStartContent -match 'isEscolherObra') {
        Write-Host "   ✅ ViewStart has ESCOLHER OBRA detection" -ForegroundColor Green
    } else {
        Write-Host "   ❌ ViewStart missing ESCOLHER OBRA detection" -ForegroundColor Red
    }
} else {
    Write-Host "   ❌ _ViewStart.cshtml does NOT exist" -ForegroundColor Red
}

# Step 5: Check Program.cs Blazor configuration
Write-Host "`n5. CHECKING BLAZOR CONFIGURATION..." -ForegroundColor Green
$programCs = Get-Content "RDO-NET8-Migration/RdoApp.Core/Program.cs" -Raw

if ($programCs -match 'AddServerSideBlazor') {
    Write-Host "   ✅ Blazor Server services added" -ForegroundColor Green
} else {
    Write-Host "   ❌ Blazor Server services missing" -ForegroundColor Red
}

if ($programCs -match 'MapBlazorHub') {
    Write-Host "   ✅ Blazor Hub mapped" -ForegroundColor Green
} else {
    Write-Host "   ❌ Blazor Hub not mapped" -ForegroundColor Red
}

# Step 6: Analyze the logs for clues
Write-Host "`n6. LOG ANALYSIS FROM PROVIDED OUTPUT..." -ForegroundColor Green
Write-Host "   ✅ Controller reached: ObraController.Escolher()" -ForegroundColor Green
Write-Host "   ✅ Service executed: ObraService.ObterObrasAsync()" -ForegroundColor Green
Write-Host "   ✅ Database query successful: Found 103 obras" -ForegroundColor Green
Write-Host "   ✅ Controller returned: return View(filteredObras.ToList())" -ForegroundColor Green
Write-Host "   ❌ MISSING: No view rendering logs" -ForegroundColor Red
Write-Host "   ❌ MISSING: No Blazor component logs" -ForegroundColor Red

# Step 7: Possible causes
Write-Host "`n=== POSSIBLE CAUSES ===" -ForegroundColor Cyan
Write-Host "1. VIEW ENGINE FAILURE:" -ForegroundColor White
Write-Host "   - View file corrupted or has syntax errors" -ForegroundColor Yellow
Write-Host "   - Layout file missing or corrupted" -ForegroundColor Yellow
Write-Host "   - ViewStart override causing issues" -ForegroundColor Yellow

Write-Host "`n2. BLAZOR COMPONENT FAILURE:" -ForegroundColor White
Write-Host "   - Component has compilation errors" -ForegroundColor Yellow
Write-Host "   - Component parameter binding issues" -ForegroundColor Yellow
Write-Host "   - Blazor Server circuit not connecting" -ForegroundColor Yellow

Write-Host "`n3. EXCEPTION SWALLOWING:" -ForegroundColor White
Write-Host "   - Silent exception in view rendering" -ForegroundColor Yellow
Write-Host "   - Exception in component initialization" -ForegroundColor Yellow
Write-Host "   - Layout rendering exception" -ForegroundColor Yellow

# Step 8: Next steps
Write-Host "`n=== IMMEDIATE NEXT STEPS ===" -ForegroundColor Cyan
Write-Host "1. Add try-catch to controller action to catch view exceptions" -ForegroundColor White
Write-Host "2. Create minimal test view without Blazor components" -ForegroundColor White
Write-Host "3. Test if layout renders without @RenderBody() content" -ForegroundColor White
Write-Host "4. Check browser F12 for JavaScript errors" -ForegroundColor White
Write-Host "5. Add server-side logging to view rendering" -ForegroundColor White

Write-Host "`n=== POST-CONTROLLER DIAGNOSIS COMPLETE ===" -ForegroundColor Cyan