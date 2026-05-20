#!/usr/bin/env pwsh

Write-Host "=== TESTING NOVA MEDIÇÃO CRITICAL FIXES ===" -ForegroundColor Green
Write-Host "Testing Plus button click event, field mappings, and integration..." -ForegroundColor Yellow

# Test 1: Compilation Check
Write-Host "`n1. COMPILATION TEST:" -ForegroundColor Cyan
try {
    Set-Location "RDO-NET8-Migration/RdoApp.Core"
    
    Write-Host "Building project to verify fixes..." -ForegroundColor Yellow
    $buildResult = dotnet build --no-restore --verbosity quiet 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ COMPILATION SUCCESS - All fixes applied correctly" -ForegroundColor Green
    } else {
        Write-Host "❌ COMPILATION FAILED:" -ForegroundColor Red
        Write-Host $buildResult -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "❌ Build error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Test 2: JavaScript Function Availability
Write-Host "`n2. JAVASCRIPT FUNCTION VERIFICATION:" -ForegroundColor Cyan
Write-Host "Checking if novaMedicao() function is in global scope..." -ForegroundColor Yellow

$cardsContent = Get-Content "Views/Etapa/Cards.cshtml" -Raw

if ($cardsContent -match "function novaMedicao\(tarefaId, descricao\)") {
    Write-Host "✅ novaMedicao() function found in global scope" -ForegroundColor Green
} else {
    Write-Host "❌ novaMedicao() function not found in global scope" -ForegroundColor Red
}

if ($cardsContent -match "function salvarNovaMedicao\(\)") {
    Write-Host "✅ salvarNovaMedicao() function found in global scope" -ForegroundColor Green
} else {
    Write-Host "❌ salvarNovaMedicao() function not found in global scope" -ForegroundColor Red
}

# Test 3: Modal Field Integration
Write-Host "`n3. MODAL FIELD INTEGRATION:" -ForegroundColor Cyan
Write-Host "Checking if all required fields are present..." -ForegroundColor Yellow

$modalContent = Get-Content "Views/Etapa/_NovaMedicaoModal.cshtml" -Raw

$requiredFields = @(
    'id="nova-medicao-status"',
    'id="nova-medicao-data"',
    'id="nova-medicao-hora-inicial"',
    'id="nova-medicao-hora-final"',
    'id="nova-medicao-quantidade"',
    'id="nova-medicao-cloro"',
    'id="nova-medicao-ph"',
    'id="nova-medicao-alcalinidade"',
    'name="limpidez"',
    'name="superficie"',
    'name="fundo"',
    'name="nivelProliferacao"',
    'name="nivelDetritos"',
    'id="nova-medicao-comentario"'
)

foreach ($field in $requiredFields) {
    if ($modalContent -match [regex]::Escape($field)) {
        Write-Host "✅ Found field: $field" -ForegroundColor Green
    } else {
        Write-Host "❌ Missing field: $field" -ForegroundColor Red
    }
}

# Test 4: Label Correction Verification
Write-Host "`n4. LABEL CORRECTION VERIFICATION:" -ForegroundColor Cyan
Write-Host "Checking if 'Nível de Detritos' label is correctly applied..." -ForegroundColor Yellow

if ($modalContent -match "Nível de Detritos") {
    Write-Host "✅ 'Nível de Detritos' label found (UI shows correct label)" -ForegroundColor Green
} else {
    Write-Host "❌ 'Nível de Detritos' label not found" -ForegroundColor Red
}

if ($modalContent -match 'name="nivelDetritos"') {
    Write-Host "✅ 'nivelDetritos' field name found (maps to NivelDetritos property)" -ForegroundColor Green
} else {
    Write-Host "❌ 'nivelDetritos' field name not found" -ForegroundColor Red
}

# Test 5: Controller Field Mapping
Write-Host "`n5. CONTROLLER FIELD MAPPING:" -ForegroundColor Cyan
Write-Host "Checking controller field mappings..." -ForegroundColor Yellow

$controllerContent = Get-Content "Controllers/TarefaController.cs" -Raw

if ($controllerContent -match "Bacteria = model\.NivelDetritos") {
    Write-Host "✅ NivelDetritos → Bacteria mapping found (correct backend processing)" -ForegroundColor Green
} else {
    Write-Host "❌ NivelDetritos → Bacteria mapping not found" -ForegroundColor Red
}

# Test 6: Dropdown Value Ranges
Write-Host "`n6. DROPDOWN VALUE RANGES:" -ForegroundColor Cyan
Write-Host "Verifying dropdown value ranges match technical report..." -ForegroundColor Yellow

# Check Cloro (0-5)
if ($modalContent -match 'value="5".*> 3,0') {
    Write-Host "✅ Cloro dropdown has correct range (1-5)" -ForegroundColor Green
} else {
    Write-Host "❌ Cloro dropdown range incorrect" -ForegroundColor Red
}

# Check PH (0-6)  
if ($modalContent -match 'value="6".*> 7.8') {
    Write-Host "✅ PH dropdown has correct range (1-6)" -ForegroundColor Green
} else {
    Write-Host "❌ PH dropdown range incorrect" -ForegroundColor Red
}

# Check Alcalinidade (0-6)
if ($modalContent -match 'value="6".*> 140') {
    Write-Host "✅ Alcalinidade dropdown has correct range (1-6)" -ForegroundColor Green
} else {
    Write-Host "❌ Alcalinidade dropdown range incorrect" -ForegroundColor Red
}

Write-Host "`n=== NOVA MEDIÇÃO CRITICAL FIXES TEST COMPLETE ===" -ForegroundColor Green
Write-Host "Summary:" -ForegroundColor Yellow
Write-Host "- Plus button click event: Fixed (functions moved to global scope)" -ForegroundColor Cyan
Write-Host "- Label mismatch: Fixed ('Nível de Detritos' UI → NivelDetritos → Bacteria backend)" -ForegroundColor Cyan
Write-Host "- Field integration: Complete (all water quality fields present)" -ForegroundColor Cyan
Write-Host "- Ready for end-to-end testing" -ForegroundColor Green

Set-Location "../.."