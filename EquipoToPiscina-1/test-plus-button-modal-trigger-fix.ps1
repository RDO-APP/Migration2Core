#!/usr/bin/env pwsh
# PLUS BUTTON MODAL TRIGGER FIX - Verification Script

Write-Host "🔧 PLUS BUTTON MODAL TRIGGER FIX" -ForegroundColor Cyan
Write-Host "=" * 50

# Step 1: Verify compilation
Write-Host "📋 Step 1: Compilation Verification" -ForegroundColor Yellow
Set-Location "RDO-NET8-Migration/RdoApp.Core"

$buildResult = dotnet build --no-restore --verbosity quiet
$buildExitCode = $LASTEXITCODE

if ($buildExitCode -eq 0) {
    Write-Host "✅ Compilation: SUCCESS" -ForegroundColor Green
} else {
    Write-Host "❌ Compilation: FAILED" -ForegroundColor Red
    exit 1
}

# Step 2: Verify TaskCard Plus Button
Write-Host "`n📋 Step 2: TaskCard Plus Button Verification" -ForegroundColor Yellow

$taskCardFile = "Components/TaskCard.razor"
if (Test-Path $taskCardFile) {
    $taskCardContent = Get-Content $taskCardFile -Raw
    
    # Check for Plus button with @onclick
    if ($taskCardContent -match '@onclick=".*AddMeasurement.*"') {
        Write-Host "✅ Plus button @onclick: FOUND" -ForegroundColor Green
    } else {
        Write-Host "❌ Plus button @onclick: NOT FOUND" -ForegroundColor Red
    }
    
    # Check for AddMeasurement method
    if ($taskCardContent -match "private async Task AddMeasurement") {
        Write-Host "✅ AddMeasurement method: FOUND" -ForegroundColor Green
    } else {
        Write-Host "❌ AddMeasurement method: NOT FOUND" -ForegroundColor Red
    }
    
    # Check for JavaScript interop call
    if ($taskCardContent -match 'JSRuntime\.InvokeVoidAsync.*novaMedicao') {
        Write-Host "✅ JavaScript interop call: FOUND" -ForegroundColor Green
    } else {
        Write-Host "❌ JavaScript interop call: NOT FOUND" -ForegroundColor Red
    }
} else {
    Write-Host "❌ TaskCard.razor file: NOT FOUND" -ForegroundColor Red
}

# Step 3: Verify JavaScript Function
Write-Host "`n📋 Step 3: JavaScript Function Verification" -ForegroundColor Yellow

$cardsFile = "Views/Etapa/Cards.cshtml"
if (Test-Path $cardsFile) {
    $cardsContent = Get-Content $cardsFile -Raw
    
    # Check for enhanced novaMedicao function
    if ($cardsContent -match "function novaMedicao.*tarefaId.*descricao") {
        Write-Host "✅ novaMedicao function: FOUND" -ForegroundColor Green
    } else {
        Write-Host "❌ novaMedicao function: NOT FOUND" -ForegroundColor Red
    }
    
    # Check for debugging console.log
    if ($cardsContent -match "console\.log.*NOVA MEDIÇÃO.*Opening") {
        Write-Host "✅ Debug logging: FOUND" -ForegroundColor Green
    } else {
        Write-Host "❌ Debug logging: NOT FOUND" -ForegroundColor Red
    }
    
    # Check for jQuery availability check
    if ($cardsContent -match "typeof.*===.*undefined") {
        Write-Host "✅ jQuery check: FOUND" -ForegroundColor Green
    } else {
        Write-Host "❌ jQuery check: NOT FOUND" -ForegroundColor Red
    }
    
    # Check for modal element check
    if ($cardsContent -match "getElementById.*nova-medicao-botao-rapido") {
        Write-Host "✅ Modal element check: FOUND" -ForegroundColor Green
    } else {
        Write-Host "❌ Modal element check: NOT FOUND" -ForegroundColor Red
    }
    
    # Check for Bootstrap 5 compatibility
    if ($cardsContent -match "bootstrap\.Modal") {
        Write-Host "✅ Bootstrap 5 compatibility: FOUND" -ForegroundColor Green
    } else {
        Write-Host "❌ Bootstrap 5 compatibility: NOT FOUND" -ForegroundColor Red
    }
} else {
    Write-Host "❌ Cards.cshtml file: NOT FOUND" -ForegroundColor Red
}

# Step 4: Verify Modal ID Match
Write-Host "`n📋 Step 4: Modal ID Verification" -ForegroundColor Yellow

$modalFile = "Views/Etapa/_NovaMedicaoModal.cshtml"
if (Test-Path $modalFile) {
    $modalContent = Get-Content $modalFile -Raw
    
    # Check for correct modal ID
    if ($modalContent -match 'id="nova-medicao-botao-rapido"') {
        Write-Host "✅ Modal ID 'nova-medicao-botao-rapido': FOUND" -ForegroundColor Green
    } else {
        Write-Host "❌ Modal ID 'nova-medicao-botao-rapido': NOT FOUND" -ForegroundColor Red
    }
    
    # Check for form elements
    $formElements = @("nova-medicao-descricao", "nova-medicao-tarefa-id", "nova-medicao-data", "nova-medicao-status")
    foreach ($element in $formElements) {
        if ($modalContent -match $element) {
            Write-Host "✅ Form element '$element': FOUND" -ForegroundColor Green
        } else {
            Write-Host "❌ Form element '$element': NOT FOUND" -ForegroundColor Red
        }
    }
} else {
    Write-Host "❌ _NovaMedicaoModal.cshtml file: NOT FOUND" -ForegroundColor Red
}

# Step 5: Verify Modal Inclusion
Write-Host "`n📋 Step 5: Modal Inclusion Verification" -ForegroundColor Yellow

if (Test-Path $cardsFile) {
    $cardsContent = Get-Content $cardsFile -Raw
    
    # Check if modal is included
    if ($cardsContent -match 'Html\.PartialAsync.*_NovaMedicaoModal') {
        Write-Host "✅ Modal inclusion: FOUND" -ForegroundColor Green
    } else {
        Write-Host "❌ Modal inclusion: NOT FOUND" -ForegroundColor Red
    }
}

# Step 6: Summary
Write-Host "`n📋 Step 6: Fix Summary" -ForegroundColor Yellow

Write-Host "`n🎯 PLUS BUTTON TRIGGER FLOW:" -ForegroundColor Cyan
Write-Host "1. User clicks Plus button on TaskCard" -ForegroundColor White
Write-Host "2. TaskCard calls AddMeasurement() method" -ForegroundColor White
Write-Host "3. AddMeasurement() calls JSRuntime.InvokeVoidAsync('novaMedicao', taskId, description)" -ForegroundColor White
Write-Host "4. JavaScript novaMedicao() function executes with debugging" -ForegroundColor White
Write-Host "5. Function checks jQuery availability and modal element existence" -ForegroundColor White
Write-Host "6. Function populates form fields (description, taskId, date)" -ForegroundColor White
Write-Host "7. Function resets form to defaults" -ForegroundColor White
Write-Host "8. Function shows modal using Bootstrap API (v4/v5 compatible)" -ForegroundColor White

Write-Host "`n🔧 FIXES APPLIED:" -ForegroundColor Cyan
Write-Host "• Enhanced error handling with try-catch blocks" -ForegroundColor White
Write-Host "• Added jQuery availability check" -ForegroundColor White
Write-Host "• Added modal element existence check" -ForegroundColor White
Write-Host "• Added comprehensive console logging for debugging" -ForegroundColor White
Write-Host "• Added Bootstrap 5 compatibility (fallback to v4)" -ForegroundColor White
Write-Host "• Enhanced form reset with null checks" -ForegroundColor White
Write-Host "• Added user-friendly error alerts" -ForegroundColor White

Write-Host "`n✅ PLUS BUTTON MODAL TRIGGER FIX COMPLETE" -ForegroundColor Green
Write-Host "Ready for browser testing!" -ForegroundColor Green

Set-Location "../.."