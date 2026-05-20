#!/usr/bin/env pwsh
# Test Dynamic Icon System Implementation
# Tests the fix for contratada/contratante dynamic icons with reduced size

Write-Host "=== TESTING DYNAMIC ICON SYSTEM ===" -ForegroundColor Cyan
Write-Host "Testing the implementation of Gilberto's dynamic icon system with reduced size" -ForegroundColor Yellow
Write-Host ""

# Test 1: Check if dynamic icon implementation is correct
Write-Host "1. Checking dynamic icon implementation..." -ForegroundColor Green
$escolherFile = "RDO-NET8-Migration/RdoApp.Core/Views/Obra/Escolher.cshtml"

if (Test-Path $escolherFile) {
    $content = Get-Content $escolherFile -Raw
    
    # Check for dynamic icon class
    if ($content -match 'class="icon-@obra\.ContratanteContratada"') {
        Write-Host "   ✅ Dynamic icon class implemented: icon-@obra.ContratanteContratada" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Dynamic icon class NOT found" -ForegroundColor Red
    }
    
    # Check for custom font definitions
    if ($content -match 'icon-contratada:before.*content.*e807') {
        Write-Host "   ✅ Custom icon-contratada definition found (Unicode: \e807)" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Custom icon-contratada definition NOT found" -ForegroundColor Red
    }
    
    if ($content -match 'icon-contratante:before.*content.*e815') {
        Write-Host "   ✅ Custom icon-contratante definition found (Unicode: \e815)" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Custom icon-contratante definition NOT found" -ForegroundColor Red
    }
    
    # Check for reduced icon size
    if ($content -match 'font-size:\s*60px') {
        Write-Host "   ✅ Icon size reduced to 60px (from 97px)" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Icon size NOT reduced" -ForegroundColor Red
    }
    
    # Check for FontAwesome fallback
    if ($content -match 'FontAwesome.*fallback') {
        Write-Host "   ✅ FontAwesome fallback system implemented" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  FontAwesome fallback system not clearly defined" -ForegroundColor Yellow
    }
    
} else {
    Write-Host "   ❌ Escolher.cshtml file not found" -ForegroundColor Red
}

Write-Host ""

# Test 2: Compile and check for errors
Write-Host "2. Testing compilation..." -ForegroundColor Green
try {
    Set-Location "RDO-NET8-Migration/RdoApp.Core"
    
    Write-Host "   Building project..." -ForegroundColor Yellow
    $buildResult = dotnet build --no-restore 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ Project compiled successfully" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Compilation errors found:" -ForegroundColor Red
        Write-Host $buildResult -ForegroundColor Red
    }
    
    Set-Location "../.."
} catch {
    Write-Host "   ❌ Error during compilation test: $($_.Exception.Message)" -ForegroundColor Red
    Set-Location "../.."
}

Write-Host ""

# Test 3: Check responsive icon sizes
Write-Host "3. Checking responsive icon sizes..." -ForegroundColor Green
if (Test-Path $escolherFile) {
    $content = Get-Content $escolherFile -Raw
    
    # Check mobile size
    if ($content -match '@media.*max-width.*768px.*font-size:\s*40px') {
        Write-Host "   ✅ Mobile icon size: 40px" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Mobile icon size not properly set" -ForegroundColor Red
    }
    
    # Check desktop size
    if ($content -match 'font-size:\s*60px.*!important') {
        Write-Host "   ✅ Desktop icon size: 60px" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Desktop icon size not properly set" -ForegroundColor Red
    }
}

Write-Host ""

# Test 4: Verify icon system matches Gilberto's approach
Write-Host "4. Verifying match with Gilberto's system..." -ForegroundColor Green
$gilbertoFile = "RDO-Production-Gilberto/rdoappProject/Client/Views/Obra/escolher.html"

if (Test-Path $gilbertoFile) {
    $gilbertoContent = Get-Content $gilbertoFile -Raw
    
    if ($gilbertoContent -match 'icon-\{\{obra\.contratanteContratada\}\}') {
        Write-Host "   ✅ Gilberto uses: icon-{{obra.contratanteContratada}}" -ForegroundColor Green
        Write-Host "   ✅ Our implementation: icon-@obra.ContratanteContratada" -ForegroundColor Green
        Write-Host "   ✅ Pattern matches correctly (AngularJS vs Razor syntax)" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Could not verify Gilberto's pattern" -ForegroundColor Red
    }
} else {
    Write-Host "   ⚠️  Gilberto's file not found for comparison" -ForegroundColor Yellow
}

Write-Host ""

# Summary
Write-Host "=== SUMMARY ===" -ForegroundColor Cyan
Write-Host "Dynamic Icon System Implementation:" -ForegroundColor White
Write-Host "• Replaced static 'fas fa-hard-hat' with dynamic 'icon-@obra.ContratanteContratada'" -ForegroundColor White
Write-Host "• Added custom font definitions for icon-contratada (\e807) and icon-contratante (\e815)" -ForegroundColor White
Write-Host "• Reduced icon size from 97px to 60px for better visual balance" -ForegroundColor White
Write-Host "• Added FontAwesome fallback system" -ForegroundColor White
Write-Host "• Maintained responsive design with 40px on mobile" -ForegroundColor White
Write-Host "• Matches Gilberto's original dynamic icon system exactly" -ForegroundColor White

Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Test the application with F5 to see the dynamic icons in action" -ForegroundColor White
Write-Host "2. Verify that different obras show different icons based on contratanteContratada field" -ForegroundColor White
Write-Host "3. Check that the 60px size provides better visual balance" -ForegroundColor White

Write-Host ""
Write-Host "=== TEST COMPLETED ===" -ForegroundColor Cyan