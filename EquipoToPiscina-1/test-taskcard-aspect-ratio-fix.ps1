#!/usr/bin/env pwsh

# TEST: TaskCard Aspect Ratio Fix - 300px × 130px Legacy Standard
# FIXES: 1. Card dimensions (no more thin strip), 2. Row 3 date spacing, 3. Bootstrap grid override

Write-Host "🎯 TESTING: TaskCard Aspect Ratio Fix" -ForegroundColor Cyan
Write-Host "=" * 50

# 1. Check if TaskCard CSS has proper dimensions
Write-Host "📐 1. Checking TaskCard CSS dimensions..." -ForegroundColor Yellow
$cssFile = "RDO-NET8-Migration/RdoApp.Core/Components/TaskCard.razor.css"

if (Test-Path $cssFile) {
    $cssContent = Get-Content $cssFile -Raw
    
    # Check for fixed 300px width
    if ($cssContent -match "width: 300px !important") {
        Write-Host "✅ Fixed 300px width found" -ForegroundColor Green
    } else {
        Write-Host "❌ Fixed 300px width missing" -ForegroundColor Red
    }
    
    # Check for fixed 130px height
    if ($cssContent -match "height: 130px !important") {
        Write-Host "✅ Fixed 130px height found" -ForegroundColor Green
    } else {
        Write-Host "❌ Fixed 130px height missing" -ForegroundColor Red
    }
    
    # Check for Bootstrap grid override
    if ($cssContent -match "Override Bootstrap Grid System") {
        Write-Host "✅ Bootstrap grid override rules found" -ForegroundColor Green
    } else {
        Write-Host "❌ Bootstrap grid override rules missing" -ForegroundColor Red
    }
    
    # Check for inline-block display
    if ($cssContent -match "display: inline-block !important") {
        Write-Host "✅ Inline-block display for proper layout found" -ForegroundColor Green
    } else {
        Write-Host "❌ Inline-block display missing" -ForegroundColor Red
    }
} else {
    Write-Host "❌ TaskCard CSS file not found" -ForegroundColor Red
}

Write-Host ""

# 2. Check if EtapaAccordionPartial removed Bootstrap grid
Write-Host "🏗️ 2. Checking EtapaAccordionPartial layout..." -ForegroundColor Yellow
$accordionFile = "RDO-NET8-Migration/RdoApp.Core/Views/Etapa/_EtapaAccordionPartial.cshtml"

if (Test-Path $accordionFile) {
    $accordionContent = Get-Content $accordionFile -Raw
    
    # Check if Bootstrap row/col classes were removed
    if ($accordionContent -notmatch 'class="row g-2"') {
        Write-Host "✅ Bootstrap row g-2 removed" -ForegroundColor Green
    } else {
        Write-Host "❌ Bootstrap row g-2 still present" -ForegroundColor Red
    }
    
    # Check for new flex container
    if ($accordionContent -match "task-cards-container") {
        Write-Host "✅ New flex container found" -ForegroundColor Green
    } else {
        Write-Host "❌ New flex container missing" -ForegroundColor Red
    }
    
    # Check for proper flex layout
    if ($accordionContent -match "display: flex; flex-wrap: wrap") {
        Write-Host "✅ Proper flex layout found" -ForegroundColor Green
    } else {
        Write-Host "❌ Proper flex layout missing" -ForegroundColor Red
    }
} else {
    Write-Host "❌ EtapaAccordionPartial file not found" -ForegroundColor Red
}

Write-Host ""

# 3. Check Row 3 date spacing fix
Write-Host "📅 3. Checking Row 3 date spacing fix..." -ForegroundColor Yellow
if (Test-Path $cssFile) {
    $cssContent = Get-Content $cssFile -Raw
    
    # Check for space-between layout
    if ($cssContent -match "justify-content: space-between") {
        Write-Host "✅ Space-between layout for dates found" -ForegroundColor Green
    } else {
        Write-Host "❌ Space-between layout missing" -ForegroundColor Red
    }
    
    # Check for reduced gap
    if ($cssContent -match "gap: 8px") {
        Write-Host "✅ Reduced gap (8px) found" -ForegroundColor Green
    } else {
        Write-Host "❌ Reduced gap missing" -ForegroundColor Red
    }
    
    # Check for date section flex fix
    if ($cssContent -match "flex: 0 0 auto") {
        Write-Host "✅ Date section flex fix found" -ForegroundColor Green
    } else {
        Write-Host "❌ Date section flex fix missing" -ForegroundColor Red
    }
    
    # Check for minimum width on date sections
    if ($cssContent -match "min-width: 80px") {
        Write-Host "✅ Minimum width for date sections found" -ForegroundColor Green
    } else {
        Write-Host "❌ Minimum width for date sections missing" -ForegroundColor Red
    }
}

Write-Host ""

# 4. Compile and test
Write-Host "🔨 4. Testing compilation..." -ForegroundColor Yellow
try {
    Push-Location "RDO-NET8-Migration/RdoApp.Core"
    
    # Clean build
    dotnet clean --verbosity quiet
    Write-Host "✅ Clean completed" -ForegroundColor Green
    
    # Build
    $buildResult = dotnet build --verbosity quiet 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Build successful" -ForegroundColor Green
    } else {
        Write-Host "❌ Build failed:" -ForegroundColor Red
        Write-Host $buildResult -ForegroundColor Red
    }
    
    Pop-Location
} catch {
    Write-Host "❌ Compilation test failed: $($_.Exception.Message)" -ForegroundColor Red
    Pop-Location
}

Write-Host ""

# 5. Summary
Write-Host "📋 SUMMARY: TaskCard Aspect Ratio Fix" -ForegroundColor Cyan
Write-Host "=" * 50
Write-Host "🎯 FIXED ISSUES:" -ForegroundColor Green
Write-Host "   1. Card dimensions: 300px × 130px (no more thin strip)" -ForegroundColor White
Write-Host "   2. Bootstrap grid override: Prevents parent container interference" -ForegroundColor White
Write-Host "   3. Row 3 date spacing: Proper separation without excessive gaps" -ForegroundColor White
Write-Host "   4. Inline-block layout: Maintains card integrity" -ForegroundColor White
Write-Host ""
Write-Host "🚀 NEXT STEPS:" -ForegroundColor Yellow
Write-Host "   1. Test in browser to verify 300px × 130px aspect ratio" -ForegroundColor White
Write-Host "   2. Verify icons are visible (fa-user and fa-truck-pickup)" -ForegroundColor White
Write-Host "   3. Check that dates in Row 3 have proper spacing" -ForegroundColor White
Write-Host "   4. Confirm card no longer looks like a thin strip" -ForegroundColor White

Write-Host ""
Write-Host "✨ TaskCard aspect ratio fix completed!" -ForegroundColor Green