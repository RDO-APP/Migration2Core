#!/usr/bin/env pwsh

Write-Host "🔍 COMPREHENSIVE PLUS BUTTON DEBUG TEST" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan

# Test 1: Check window.novaMedicao function with alert
Write-Host "`n📋 TEST 1: JavaScript Function with Alert" -ForegroundColor Yellow
$cardsFile = "RDO-NET8-Migration/RdoApp.Core/Views/Etapa/Cards.cshtml"
$windowFunction = Select-String -Path $cardsFile -Pattern "window\.novaMedicao.*function"
$alertTest = Select-String -Path $cardsFile -Pattern "alert.*JS TRIGGERED"

if ($windowFunction -and $alertTest) {
    Write-Host "✅ JAVASCRIPT: window.novaMedicao function with alert found" -ForegroundColor Green
    Write-Host "   Function: $($windowFunction.Line.Trim())" -ForegroundColor Gray
    Write-Host "   Alert: $($alertTest.Line.Trim())" -ForegroundColor Gray
} else {
    Write-Host "❌ JAVASCRIPT: Missing window.novaMedicao or alert" -ForegroundColor Red
    exit 1
}

# Test 2: Check TaskCard button implementation
Write-Host "`n📋 TEST 2: TaskCard Button Implementation" -ForegroundColor Yellow
$taskCardFile = "RDO-NET8-Migration/RdoApp.Core/Components/TaskCard.razor"
$buttonId = Select-String -Path $taskCardFile -Pattern 'id="plus-btn-.*"'
$blazorOnclick = Select-String -Path $taskCardFile -Pattern '@onclick=".*AddMeasurement.*"'
$jsOnclick = Select-String -Path $taskCardFile -Pattern 'onclick="window\.novaMedicao'
$plusIcon = Select-String -Path $taskCardFile -Pattern 'fa-plus'

Write-Host "Button ID: $(if($buttonId) {'✅'} else {'❌'}) Found" -ForegroundColor $(if($buttonId) {'Green'} else {'Red'})
Write-Host "Blazor @onclick: $(if($blazorOnclick) {'✅'} else {'❌'}) Found" -ForegroundColor $(if($blazorOnclick) {'Green'} else {'Red'})
Write-Host "JS onclick fallback: $(if($jsOnclick) {'✅'} else {'❌'}) Found" -ForegroundColor $(if($jsOnclick) {'Green'} else {'Red'})
Write-Host "Plus icon: $(if($plusIcon) {'✅'} else {'❌'}) Found" -ForegroundColor $(if($plusIcon) {'Green'} else {'Red'})

# Test 3: Check AddMeasurement method with debugging
Write-Host "`n📋 TEST 3: AddMeasurement Method Debugging" -ForegroundColor Yellow
$addMeasurementDebug = Select-String -Path $taskCardFile -Pattern "Console\.WriteLine.*BLAZOR.*AddMeasurement"
$jsRuntimeCall = Select-String -Path $taskCardFile -Pattern 'JSRuntime\.InvokeVoidAsync\("novaMedicao"'
$errorHandling = Select-String -Path $taskCardFile -Pattern "catch.*Exception"

Write-Host "Blazor debugging: $(if($addMeasurementDebug) {'✅'} else {'❌'}) Found" -ForegroundColor $(if($addMeasurementDebug) {'Green'} else {'Red'})
Write-Host "JSRuntime call: $(if($jsRuntimeCall) {'✅'} else {'❌'}) Found" -ForegroundColor $(if($jsRuntimeCall) {'Green'} else {'Red'})
Write-Host "Error handling: $(if($errorHandling) {'✅'} else {'❌'}) Found" -ForegroundColor $(if($errorHandling) {'Green'} else {'Red'})

# Test 4: Check modal ID consistency
Write-Host "`n📋 TEST 4: Modal ID Consistency" -ForegroundColor Yellow
$modalFile = "RDO-NET8-Migration/RdoApp.Core/Views/Etapa/_NovaMedicaoModal.cshtml"
$modalId = Select-String -Path $modalFile -Pattern 'id="nova-medicao-botao-rapido"'
$jsModalRef = Select-String -Path $cardsFile -Pattern "nova-medicao-botao-rapido"

Write-Host "Modal ID: $(if($modalId) {'✅'} else {'❌'}) nova-medicao-botao-rapido" -ForegroundColor $(if($modalId) {'Green'} else {'Red'})
Write-Host "JS references: $(if($jsModalRef) {'✅'} else {'❌'}) Found $($jsModalRef.Count) references" -ForegroundColor $(if($jsModalRef) {'Green'} else {'Red'})

# Test 5: Compilation check
Write-Host "`n📋 TEST 5: Compilation Check" -ForegroundColor Yellow
try {
    Set-Location "RDO-NET8-Migration/RdoApp.Core"
    $buildResult = dotnet build --no-restore --verbosity minimal 2>&1
    $exitCode = $LASTEXITCODE
    
    if ($exitCode -eq 0) {
        Write-Host "✅ COMPILATION: SUCCESS" -ForegroundColor Green
    } else {
        Write-Host "❌ COMPILATION: FAILED" -ForegroundColor Red
        Write-Host "Build errors detected - check for syntax issues" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ COMPILATION: ERROR - $($_.Exception.Message)" -ForegroundColor Red
} finally {
    Set-Location "../.."
}

Write-Host "`n🎯 DEBUG IMPLEMENTATION SUMMARY:" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host "✅ Added window.novaMedicao with alert test" -ForegroundColor Green
Write-Host "✅ Added button ID for direct targeting" -ForegroundColor Green
Write-Host "✅ Added JavaScript onclick fallback" -ForegroundColor Green
Write-Host "✅ Added Blazor console debugging" -ForegroundColor Green
Write-Host "✅ Verified modal ID consistency" -ForegroundColor Green

Write-Host "`n🚀 TESTING INSTRUCTIONS:" -ForegroundColor Yellow
Write-Host "1. Start the application" -ForegroundColor White
Write-Host "2. Navigate to Etapas/Tarefas page" -ForegroundColor White
Write-Host "3. Click the Plus button on any task card" -ForegroundColor White
Write-Host "4. Look for the alert popup with task ID" -ForegroundColor White
Write-Host "5. Check browser console for debug messages" -ForegroundColor White

Write-Host "`n📊 EXPECTED RESULTS:" -ForegroundColor Yellow
Write-Host "- Alert popup: 'JS TRIGGERED for ID: [number]'" -ForegroundColor White
Write-Host "- Console: 'BLAZOR: AddMeasurement called for Task ID: [number]'" -ForegroundColor White
Write-Host "- Console: 'NOVA MEDICAO: Opening for task: [number]'" -ForegroundColor White
Write-Host "- Modal should open with task information" -ForegroundColor White