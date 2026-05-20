# ESCOLHER OBRA - WHITE SCREEN CRITICAL DIAGNOSTIC
# Date: 2026-01-16
# Purpose: Find why page is completely blank despite 103 obras in database

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "ESCOLHER OBRA - WHITE SCREEN DIAGNOSTIC" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Test 1: Check if Blazor script is referenced
Write-Host "TEST 1: Checking Blazor script reference..." -ForegroundColor Yellow
$escolherPath = "RDO-NET8-Migration\RdoApp.Core\Views\Obra\Escolher.cshtml"
$layoutPath = "RDO-NET8-Migration\RdoApp.Core\Views\Shared\_LayoutSelection.cshtml"

if (Test-Path $escolherPath) {
    $content = Get-Content $escolherPath -Raw
    if ($content -match "blazor\.server\.js") {
        Write-Host "  ✅ Blazor script referenced in Escolher.cshtml" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️ Blazor script NOT in Escolher.cshtml" -ForegroundColor Yellow
    }
}

if (Test-Path $layoutPath) {
    $content = Get-Content $layoutPath -Raw
    if ($content -match "blazor\.server\.js") {
        Write-Host "  ✅ Blazor script referenced in _LayoutSelection.cshtml" -ForegroundColor Green
    } else {
        Write-Host "  ❌ Blazor script NOT in _LayoutSelection.cshtml" -ForegroundColor Red
    }
}

Write-Host ""

# Test 2: Check RdoObraCards component exists
Write-Host "TEST 2: Checking RdoObraCards component..." -ForegroundColor Yellow
$componentPath = "RDO-NET8-Migration\RdoApp.Core\Components\RdoObraCards.razor"

if (Test-Path $componentPath) {
    Write-Host "  ✅ RdoObraCards.razor exists" -ForegroundColor Green
    
    # Check for common errors
    $componentContent = Get-Content $componentPath -Raw
    
    if ($componentContent -match "@code") {
        Write-Host "  ✅ Component has @code block" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️ Component missing @code block" -ForegroundColor Yellow
    }
    
    if ($componentContent -match "Obras") {
        Write-Host "  ✅ Component references Obras parameter" -ForegroundColor Green
    } else {
        Write-Host "  ❌ Component doesn't reference Obras parameter" -ForegroundColor Red
    }
} else {
    Write-Host "  ❌ RdoObraCards.razor NOT FOUND" -ForegroundColor Red
}

Write-Host ""

# Test 3: Check UnifiedRdoHeader component
Write-Host "TEST 3: Checking UnifiedRdoHeader component..." -ForegroundColor Yellow
$headerPath = "RDO-NET8-Migration\RdoApp.Core\Components\UnifiedRdoHeader.razor"

if (Test-Path $headerPath) {
    Write-Host "  ✅ UnifiedRdoHeader.razor exists" -ForegroundColor Green
} else {
    Write-Host "  ❌ UnifiedRdoHeader.razor NOT FOUND" -ForegroundColor Red
}

Write-Host ""

# Test 4: Check for CSS that might hide content
Write-Host "TEST 4: Checking for CSS issues..." -ForegroundColor Yellow
$cssPath = "RDO-NET8-Migration\RdoApp.Core\wwwroot\css\rdo-selection.css"

if (Test-Path $cssPath) {
    $cssContent = Get-Content $cssPath -Raw
    
    if ($cssContent -match "display:\s*none") {
        Write-Host "  ⚠️ Found 'display: none' in rdo-selection.css" -ForegroundColor Yellow
    }
    
    if ($cssContent -match "visibility:\s*hidden") {
        Write-Host "  ⚠️ Found 'visibility: hidden' in rdo-selection.css" -ForegroundColor Yellow
    }
}

Write-Host ""

# Test 5: Check Program.cs for Blazor configuration
Write-Host "TEST 5: Checking Program.cs Blazor configuration..." -ForegroundColor Yellow
$programPath = "RDO-NET8-Migration\RdoApp.Core\Program.cs"

if (Test-Path $programPath) {
    $programContent = Get-Content $programPath -Raw
    
    if ($programContent -match "AddServerSideBlazor") {
        Write-Host "  ✅ Blazor Server configured" -ForegroundColor Green
    } else {
        Write-Host "  ❌ Blazor Server NOT configured" -ForegroundColor Red
    }
    
    if ($programContent -match "MapBlazorHub") {
        Write-Host "  ✅ Blazor Hub mapped" -ForegroundColor Green
    } else {
        Write-Host "  ❌ Blazor Hub NOT mapped" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "DIAGNOSTIC COMPLETE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "NEXT STEPS:" -ForegroundColor Yellow
Write-Host "1. Run this script and share results" -ForegroundColor White
Write-Host "2. Open browser F12 Console and check for errors" -ForegroundColor White
Write-Host "3. Check Network tab for failed requests" -ForegroundColor White
Write-Host "4. View page source (Ctrl+U) to see what HTML is rendered" -ForegroundColor White
Write-Host ""
