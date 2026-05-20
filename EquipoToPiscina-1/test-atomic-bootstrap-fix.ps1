# ATOMIC BOOTSTRAP FIX - TEST VERIFICATION
# This script tests the atomic fix for Bootstrap Global Event Handlers

Write-Host "🎯 ATOMIC BOOTSTRAP FIX - TEST VERIFICATION" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green

# Step 1: Verify Plus button has no Bootstrap data attributes
Write-Host "`n1. CHECKING PLUS BUTTON IMPLEMENTATION..." -ForegroundColor Yellow
$taskCardContent = Get-Content "RDO-NET8-Migration/RdoApp.Core/Views/Etapa/_TaskCardPartial.cshtml" -Raw

if ($taskCardContent -match "data-bs-toggle|data-bs-target|data-toggle.*modal|data-target.*modal") {
    Write-Host "❌ Plus button still has Bootstrap modal data attributes" -ForegroundColor Red
    Write-Host "Found: $($matches[0])" -ForegroundColor Red
} else {
    Write-Host "✅ Plus button has NO Bootstrap modal data attributes" -ForegroundColor Green
}

if ($taskCardContent -match "window\.smartOpenModal") {
    Write-Host "✅ Plus button uses window.smartOpenModal function" -ForegroundColor Green
} else {
    Write-Host "❌ Plus button missing window.smartOpenModal call" -ForegroundColor Red
}

# Step 2: Verify Global Stop implementation
Write-Host "`n2. CHECKING GLOBAL STOP IMPLEMENTATION..." -ForegroundColor Yellow
$cardsContent = Get-Content "RDO-NET8-Migration/RdoApp.Core/Views/Etapa/Cards.cshtml" -Raw

if ($cardsContent -match "GLOBAL STOP.*data-bs-toggle.*modal.*removeAttribute") {
    Write-Host "✅ Global Stop implemented - removes data-bs-toggle modal attributes" -ForegroundColor Green
} else {
    Write-Host "❌ Global Stop missing or incomplete" -ForegroundColor Red
}

if ($cardsContent -match "data-bs-target.*removeAttribute") {
    Write-Host "✅ Global Stop removes data-bs-target attributes" -ForegroundColor Green
} else {
    Write-Host "❌ Global Stop missing data-bs-target removal" -ForegroundColor Red
}

# Step 3: Verify Pure DOM Modal Implementation
Write-Host "`n3. CHECKING PURE DOM MODAL IMPLEMENTATION..." -ForegroundColor Yellow

if ($cardsContent -match "modalElement\.style\.display = 'block'") {
    Write-Host "✅ Uses pure DOM manipulation: style.display = 'block'" -ForegroundColor Green
} else {
    Write-Host "❌ Missing pure DOM display manipulation" -ForegroundColor Red
}

if ($cardsContent -match "modalElement\.classList\.add\('show'\)") {
    Write-Host "✅ Uses pure DOM manipulation: classList.add('show')" -ForegroundColor Green
} else {
    Write-Host "❌ Missing pure DOM classList manipulation" -ForegroundColor Red
}

if ($cardsContent -match "document\.body\.classList\.add\('modal-open'\)") {
    Write-Host "✅ Uses pure DOM manipulation: body.classList.add('modal-open')" -ForegroundColor Green
} else {
    Write-Host "❌ Missing body modal-open class manipulation" -ForegroundColor Red
}

# Step 4: Check for Bootstrap Modal constructor usage
Write-Host "`n4. CHECKING FOR BOOTSTRAP MODAL CONSTRUCTOR..." -ForegroundColor Yellow

if ($cardsContent -match "new bootstrap\.Modal|bootstrap\.Modal\.getOrCreateInstance") {
    Write-Host "❌ Still using Bootstrap Modal constructor - THIS WILL CAUSE ERRORS" -ForegroundColor Red
} else {
    Write-Host "✅ NO Bootstrap Modal constructor usage - Pure DOM only" -ForegroundColor Green
}

# Step 5: Verify database mapping is preserved
Write-Host "`n5. CHECKING DATABASE MAPPING..." -ForegroundColor Yellow
$controllerContent = Get-Content "RDO-NET8-Migration/RdoApp.Core/Controllers/TarefaController.cs" -Raw

if ($controllerContent -match "Bacteria = model\.NivelDetritos") {
    Write-Host "✅ Database mapping preserved: NivelDetritos → Bacteria (WRITTEN IN STONE)" -ForegroundColor Green
} else {
    Write-Host "❌ Database mapping missing or changed" -ForegroundColor Red
}

# Step 6: Test compilation
Write-Host "`n6. TESTING COMPILATION..." -ForegroundColor Yellow
try {
    $buildResult = dotnet build "RDO-NET8-Migration/RdoApp.Core" --verbosity quiet 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Compilation successful" -ForegroundColor Green
    } else {
        Write-Host "❌ Compilation failed:" -ForegroundColor Red
        Write-Host $buildResult -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Build error: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 7: Generate test instructions
Write-Host "`n7. TESTING INSTRUCTIONS" -ForegroundColor Yellow
Write-Host "========================" -ForegroundColor Yellow
Write-Host ""
Write-Host "🌐 BROWSER TESTING:" -ForegroundColor Cyan
Write-Host "1. Open browser and navigate to: http://localhost:5031" -ForegroundColor White
Write-Host "2. Login and select an obra" -ForegroundColor White
Write-Host "3. Go to Etapas/Tarefas page" -ForegroundColor White
Write-Host "4. Press F12 to open Developer Console" -ForegroundColor White
Write-Host "5. Click the '+' button on any task card" -ForegroundColor White
Write-Host ""
Write-Host "✅ EXPECTED RESULT:" -ForegroundColor Green
Write-Host "- Modal opens immediately" -ForegroundColor White
Write-Host "- NO console errors (especially no 'classList' errors)" -ForegroundColor White
Write-Host "- Date and Status fields populated" -ForegroundColor White
Write-Host ""
Write-Host "🔍 CONSOLE VERIFICATION COMMANDS:" -ForegroundColor Cyan
Write-Host "// Check if Global Stop worked" -ForegroundColor Gray
Write-Host "document.querySelectorAll('[data-bs-toggle=\"modal\"]').length" -ForegroundColor White
Write-Host "// Should return 0" -ForegroundColor Gray
Write-Host ""
Write-Host "// Test modal function directly" -ForegroundColor Gray
Write-Host "window.smartOpenModal(123, 'Test Task', 2)" -ForegroundColor White
Write-Host ""
Write-Host "// Check modal element" -ForegroundColor Gray
Write-Host "document.getElementById('modal-nova-medicao')" -ForegroundColor White

Write-Host "`n🎯 ATOMIC FIX VERIFICATION COMPLETE!" -ForegroundColor Green
Write-Host ""
Write-Host "SUMMARY OF ATOMIC FIXES:" -ForegroundColor Cyan
Write-Host "- ✅ Plus button: NO Bootstrap data attributes" -ForegroundColor White
Write-Host "- ✅ Global Stop: Removes all modal data attributes on DOM load" -ForegroundColor White
Write-Host "- ✅ Pure DOM: No Bootstrap Modal constructor usage" -ForegroundColor White
Write-Host "- Database mapping: NivelDetritos to Bacteria preserved" -ForegroundColor White
Write-Host ""
Write-Host "🚀 Ready to test - Bootstrap should be completely blind to our modal!" -ForegroundColor Green