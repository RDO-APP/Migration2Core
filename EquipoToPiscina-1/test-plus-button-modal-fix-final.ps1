#!/usr/bin/env pwsh

Write-Host "🎯 TESTING: Plus Button Modal Fix - Final Test" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

# Test 1: Compilation
Write-Host "`n📋 TEST 1: Compilation Check" -ForegroundColor Yellow
try {
    Set-Location "RDO-NET8-Migration/RdoApp.Core"
    $buildResult = dotnet build --no-restore --verbosity quiet 2>&1
    $exitCode = $LASTEXITCODE
    
    if ($exitCode -eq 0) {
        Write-Host "✅ COMPILATION: SUCCESS" -ForegroundColor Green
    } else {
        Write-Host "❌ COMPILATION: FAILED" -ForegroundColor Red
        Write-Host "Build Output: $buildResult" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "❌ COMPILATION: ERROR - $($_.Exception.Message)" -ForegroundColor Red
    exit 1
} finally {
    Set-Location "../.."
}

# Test 2: Check for duplicate novaMedicao functions
Write-Host "`n📋 TEST 2: JavaScript Function Conflict Check" -ForegroundColor Yellow
$cardsFile = "RDO-NET8-Migration/RdoApp.Core/Views/Etapa/Cards.cshtml"
$novaMedicaoCount = (Select-String -Path $cardsFile -Pattern "function novaMedicao" | Measure-Object).Count

if ($novaMedicaoCount -eq 1) {
    Write-Host "✅ JAVASCRIPT: Only 1 novaMedicao function found (conflict resolved)" -ForegroundColor Green
} else {
    Write-Host "❌ JAVASCRIPT: Found $novaMedicaoCount novaMedicao functions (conflict still exists)" -ForegroundColor Red
    exit 1
}

# Test 3: Check modal ID consistency
Write-Host "`n📋 TEST 3: Modal ID Consistency Check" -ForegroundColor Yellow
$modalIdInModal = Select-String -Path "RDO-NET8-Migration/RdoApp.Core/Views/Etapa/_NovaMedicaoModal.cshtml" -Pattern 'id="nova-medicao-botao-rapido"'
$modalIdInJS = Select-String -Path $cardsFile -Pattern "nova-medicao-botao-rapido"

if ($modalIdInModal -and $modalIdInJS) {
    Write-Host "✅ MODAL ID: Consistent across modal and JavaScript" -ForegroundColor Green
} else {
    Write-Host "❌ MODAL ID: Inconsistent between modal and JavaScript" -ForegroundColor Red
    exit 1
}

# Test 4: Check TaskCard Blazor component
Write-Host "`n📋 TEST 4: TaskCard Blazor Component Check" -ForegroundColor Yellow
$taskCardFile = "RDO-NET8-Migration/RdoApp.Core/Components/TaskCard.razor"
$addMeasurementMethod = Select-String -Path $taskCardFile -Pattern "AddMeasurement\(\)"
$jsInterop = Select-String -Path $taskCardFile -Pattern 'JSRuntime\.InvokeVoidAsync\("novaMedicao"'

if ($addMeasurementMethod -and $jsInterop) {
    Write-Host "✅ TASKCARD: AddMeasurement method and JS interop found" -ForegroundColor Green
} else {
    Write-Host "❌ TASKCARD: Missing AddMeasurement method or JS interop" -ForegroundColor Red
    exit 1
}

# Test 5: Check Plus button in TaskCard
Write-Host "`n📋 TEST 5: Plus Button Implementation Check" -ForegroundColor Yellow
$plusButton = Select-String -Path $taskCardFile -Pattern '@onclick=".*AddMeasurement.*"'
$plusIcon = Select-String -Path $taskCardFile -Pattern 'fa-plus'

if ($plusButton -and $plusIcon) {
    Write-Host "✅ PLUS BUTTON: Correctly implemented with AddMeasurement onclick" -ForegroundColor Green
} else {
    Write-Host "❌ PLUS BUTTON: Missing onclick or plus icon" -ForegroundColor Red
    exit 1
}

Write-Host "`n🎉 ALL TESTS PASSED: Plus Button Modal Fix Complete!" -ForegroundColor Green
Write-Host "✅ Compilation successful" -ForegroundColor Green
Write-Host "✅ JavaScript function conflict resolved" -ForegroundColor Green
Write-Host "✅ Modal ID consistency verified" -ForegroundColor Green
Write-Host "✅ TaskCard Blazor component correct" -ForegroundColor Green
Write-Host "✅ Plus button implementation verified" -ForegroundColor Green

Write-Host "`n🚀 READY FOR TESTING: The Plus button should now open the Nova Medicao modal!" -ForegroundColor Cyan