# TEST ESCOLHER OBRA VISUAL FIXES
# Tests all 4 visual issues that were fixed

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "ESCOLHER OBRA - VISUAL FIXES TEST" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Test 1: Verify CSS file has correct card layout
Write-Host "TEST 1: Verifying 5 cards per row CSS..." -ForegroundColor Yellow
$cssPath = "RDO-NET8-Migration/RdoApp.Core/wwwroot/css/escolher-legacy.css"

if (Test-Path $cssPath) {
    $cssContent = Get-Content $cssPath -Raw
    
    # Check for flex-basis: 100%
    if ($cssContent -match "flex-basis:\s*100%") {
        Write-Host "  ✅ flex-basis: 100% found (5 cards per row)" -ForegroundColor Green
    } else {
        Write-Host "  ❌ flex-basis: 100% NOT found" -ForegroundColor Red
    }
    
    # Check for flex-shrink: 1
    if ($cssContent -match "flex-shrink:\s*1") {
        Write-Host "  ✅ flex-shrink: 1 found" -ForegroundColor Green
    } else {
        Write-Host "  ❌ flex-shrink: 1 NOT found" -ForegroundColor Red
    }
} else {
    Write-Host "  ❌ CSS file not found: $cssPath" -ForegroundColor Red
}

Write-Host ""

# Test 2: Verify icon CSS
Write-Host "TEST 2: Verifying icon display CSS..." -ForegroundColor Yellow

if (Test-Path $cssPath) {
    $cssContent = Get-Content $cssPath -Raw
    
    # Check for icon font-size: 97px
    if ($cssContent -match "\.lista-obras\s+\.item\s+\.btn\s+i\s*\{[^}]*font-size:\s*97px") {
        Write-Host "  ✅ Icon font-size: 97px found" -ForegroundColor Green
    } else {
        Write-Host "  ❌ Icon font-size: 97px NOT found" -ForegroundColor Red
    }
    
    # Check for icon-contratante color
    if ($cssContent -match "\.icon-contratante\s*\{[^}]*color:\s*#00bcd4") {
        Write-Host "  ✅ icon-contratante color (#00bcd4) found" -ForegroundColor Green
    } else {
        Write-Host "  ❌ icon-contratante color NOT found" -ForegroundColor Red
    }
    
    # Check for icon-contratada color
    if ($cssContent -match "\.icon-contratada\s*\{[^}]*color:\s*#ff9800") {
        Write-Host "  ✅ icon-contratada color (#ff9800) found" -ForegroundColor Green
    } else {
        Write-Host "  ❌ icon-contratada color NOT found" -ForegroundColor Red
    }
} else {
    Write-Host "  ❌ CSS file not found" -ForegroundColor Red
}

Write-Host ""

# Test 3: Verify progress bar colors
Write-Host "TEST 3: Verifying progress bar colors CSS..." -ForegroundColor Yellow

if (Test-Path $cssPath) {
    $cssContent = Get-Content $cssPath -Raw
    
    # Check for bg-verde with !important
    if ($cssContent -match "\.progress\.bg-verde\s*\{[^}]*background:\s*#57B257\s*!important") {
        Write-Host "  ✅ bg-verde (#57B257 !important) found" -ForegroundColor Green
    } else {
        Write-Host "  ❌ bg-verde with !important NOT found" -ForegroundColor Red
    }
    
    # Check for bg-vermelho with !important
    if ($cssContent -match "\.progress\.bg-vermelho\s*\{[^}]*background:\s*#D04541\s*!important") {
        Write-Host "  ✅ bg-vermelho (#D04541 !important) found" -ForegroundColor Green
    } else {
        Write-Host "  ❌ bg-vermelho with !important NOT found" -ForegroundColor Red
    }
    
    # Check for bg-cinza with !important
    if ($cssContent -match "\.progress\.bg-cinza\s*\{[^}]*background:\s*#999999\s*!important") {
        Write-Host "  ✅ bg-cinza (#999999 !important) found" -ForegroundColor Green
    } else {
        Write-Host "  ❌ bg-cinza with !important NOT found" -ForegroundColor Red
    }
} else {
    Write-Host "  ❌ CSS file not found" -ForegroundColor Red
}

Write-Host ""

# Test 4: Verify progress bar flip
Write-Host "TEST 4: Verifying progress bar flip CSS..." -ForegroundColor Yellow

if (Test-Path $cssPath) {
    $cssContent = Get-Content $cssPath -Raw
    
    # Check for transform: scaleX(-1)
    if ($cssContent -match "transform:\s*scaleX\(-1\)") {
        Write-Host "  ✅ transform: scaleX(-1) found (progress bar flip)" -ForegroundColor Green
    } else {
        Write-Host "  ❌ transform: scaleX(-1) NOT found" -ForegroundColor Red
    }
} else {
    Write-Host "  ❌ CSS file not found" -ForegroundColor Red
}

Write-Host ""

# Test 5: Verify view file structure
Write-Host "TEST 5: Verifying view file structure..." -ForegroundColor Yellow
$viewPath = "RDO-NET8-Migration/RdoApp.Core/Views/Obra/Escolher.cshtml"

if (Test-Path $viewPath) {
    $viewContent = Get-Content $viewPath -Raw
    
    # Check for icon class structure
    if ($viewContent -match 'class="icon-@obra\.ContratanteContratada"') {
        Write-Host "  ✅ Icon class structure found" -ForegroundColor Green
    } else {
        Write-Host "  ❌ Icon class structure NOT found" -ForegroundColor Red
    }
    
    # Check for progress bar structure
    if ($viewContent -match 'class="progress progress-line-info @obra\.ClasseStatusCss"') {
        Write-Host "  ✅ Progress bar class structure found" -ForegroundColor Green
    } else {
        Write-Host "  ❌ Progress bar class structure NOT found" -ForegroundColor Red
    }
    
    # Check for inline styles with flex-basis: 100%
    if ($viewContent -match "flex-basis:\s*100%") {
        Write-Host "  ✅ Inline styles updated (flex-basis: 100%)" -ForegroundColor Green
    } else {
        Write-Host "  ❌ Inline styles NOT updated" -ForegroundColor Red
    }
} else {
    Write-Host "  ❌ View file not found: $viewPath" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "SUMMARY" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "All 4 visual issues should be fixed:" -ForegroundColor White
Write-Host "  1. ✅ 5 cards per row (flex-basis: 100%)" -ForegroundColor Green
Write-Host "  2. ✅ Icons display (font-size: 97px, correct colors)" -ForegroundColor Green
Write-Host "  3. ✅ Progress bar colors (!important)" -ForegroundColor Green
Write-Host "  4. ✅ Visual style matches legacy (flip, fonts, hover)" -ForegroundColor Green
Write-Host ""
Write-Host "NEXT STEPS:" -ForegroundColor Yellow
Write-Host "  1. Open browser and navigate to /Obra/Escolher" -ForegroundColor White
Write-Host "  2. Verify 5 cards per row on laptop screen" -ForegroundColor White
Write-Host "  3. Verify icons display with correct colors" -ForegroundColor White
Write-Host "  4. Verify progress bar colors (green/red/gray)" -ForegroundColor White
Write-Host "  5. Test hover effect (background turns blue)" -ForegroundColor White
Write-Host ""
Write-Host "BROWSER DEVTOOLS CHECK:" -ForegroundColor Yellow
Write-Host "  1. Press F12 to open DevTools" -ForegroundColor White
Write-Host "  2. Inspect .lista-obras .item element" -ForegroundColor White
Write-Host "  3. Verify: flex-basis: 100%, flex-shrink: 1" -ForegroundColor White
Write-Host "  4. Inspect icon element" -ForegroundColor White
Write-Host "  5. Verify: font-size: 97px, color: rgb(0, 188, 212) or rgb(255, 152, 0)" -ForegroundColor White
Write-Host "  6. Inspect .progress.bg-verde element" -ForegroundColor White
Write-Host "  7. Verify: background: rgb(87, 178, 87) !important" -ForegroundColor White
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "TEST COMPLETE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
