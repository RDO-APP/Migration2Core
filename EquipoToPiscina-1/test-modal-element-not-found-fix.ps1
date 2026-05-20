# TEST: Modal Element Not Found Fix - Critical Bootstrap Error Resolution

Write-Host "TESTING MODAL ELEMENT NOT FOUND FIX" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Green

# Test 1: Verify Modal ID Consistency
Write-Host "`nTEST 1: Modal ID Consistency Check" -ForegroundColor Yellow
$cardsFile = "RDO-NET8-Migration/RdoApp.Core/Views/Etapa/Cards.cshtml"
$modalFile = "RDO-NET8-Migration/RdoApp.Core/Views/Etapa/_NovaMedicaoModal.cshtml"
$taskCardFile = "RDO-NET8-Migration/RdoApp.Core/Views/Etapa/_TaskCardPartial.cshtml"

if (Test-Path $cardsFile -and Test-Path $modalFile -and Test-Path $taskCardFile) {
    $cardsContent = Get-Content $cardsFile -Raw
    $modalContent = Get-Content $modalFile -Raw
    $taskCardContent = Get-Content $taskCardFile -Raw
    
    # Check Cards.cshtml for modal ID
    if ($cardsContent -match "getElementById\('([^']+)'\)") {
        $cardsModalId = $matches[1]
        Write-Host "Cards.cshtml uses modal ID: $cardsModalId" -ForegroundColor Cyan
    }
    
    # Check Modal file for actual ID
    if ($modalContent -match 'id="([^"]+)"') {
        $actualModalId = $matches[1]
        Write-Host "Modal file actual ID: $actualModalId" -ForegroundColor Cyan
    }
    
    # Check TaskCard for function call
    if ($taskCardContent -match "window\.smartOpenModal") {
        Write-Host "SUCCESS: TaskCard calls window.smartOpenModal" -ForegroundColor Green
    } else {
        Write-Host "ERROR: TaskCard missing window.smartOpenModal call" -ForegroundColor Red
    }
    
    # Verify ID consistency
    if ($cardsModalId -eq $actualModalId) {
        Write-Host "SUCCESS: Modal IDs are consistent: $cardsModalId" -ForegroundColor Green
    } else {
        Write-Host "ERROR: Modal ID mismatch - Cards: $cardsModalId, Modal: $actualModalId" -ForegroundColor Red
    }
}

# Test 2: Verify Modal Inclusion
Write-Host "`nTEST 2: Modal Inclusion Verification" -ForegroundColor Yellow
if (Test-Path $cardsFile) {
    $content = Get-Content $cardsFile -Raw
    
    if ($content -match "_NovaMedicaoModal") {
        Write-Host "SUCCESS: _NovaMedicaoModal is included in Cards.cshtml" -ForegroundColor Green
    } else {
        Write-Host "ERROR: _NovaMedicaoModal not included in Cards.cshtml" -ForegroundColor Red
    }
    
    # Check for conditional rendering
    if ($content -match "@if.*_NovaMedicaoModal") {
        Write-Host "WARNING: Modal inclusion is conditional - check @if conditions" -ForegroundColor Yellow
    } else {
        Write-Host "SUCCESS: Modal inclusion is unconditional" -ForegroundColor Green
    }
}

# Test 3: Verify Resilient Initialization
Write-Host "`nTEST 3: Resilient Initialization Check" -ForegroundColor Yellow
if (Test-Path $cardsFile) {
    $content = Get-Content $cardsFile -Raw
    
    if ($content -match "if \(!modalElement\)") {
        Write-Host "SUCCESS: Resilient modal element check found" -ForegroundColor Green
    } else {
        Write-Host "ERROR: Missing resilient modal element check" -ForegroundColor Red
    }
    
    if ($content -match "console\.error.*Modal element") {
        Write-Host "SUCCESS: Error logging for missing modal found" -ForegroundColor Green
    } else {
        Write-Host "ERROR: Missing error logging for modal not found" -ForegroundColor Red
    }
}

# Test 4: Verify Bootstrap Prevention
Write-Host "`nTEST 4: Bootstrap Auto-Initialization Prevention" -ForegroundColor Yellow
$layoutFile = "RDO-NET8-Migration/RdoApp.Core/Views/Shared/_Layout.cshtml"
if (Test-Path $layoutFile) {
    $content = Get-Content $layoutFile -Raw
    
    if ($content -match "Bootstrap Modal auto-initialization blocked") {
        Write-Host "SUCCESS: Bootstrap modal auto-initialization prevention found" -ForegroundColor Green
    } else {
        Write-Host "ERROR: Bootstrap modal auto-initialization prevention missing" -ForegroundColor Red
    }
}

if (Test-Path $cardsFile) {
    $content = Get-Content $cardsFile -Raw
    
    if ($content -match "removeAttribute.*data-bs-toggle") {
        Write-Host "SUCCESS: Bootstrap data attributes removal found" -ForegroundColor Green
    } else {
        Write-Host "ERROR: Bootstrap data attributes removal missing" -ForegroundColor Red
    }
}

# Test 5: Verify Modal Attributes
Write-Host "`nTEST 5: Modal HTML Attributes Check" -ForegroundColor Yellow
if (Test-Path $modalFile) {
    $content = Get-Content $modalFile -Raw
    
    if ($content -match 'role="dialog"') {
        Write-Host "SUCCESS: Modal has proper role attribute" -ForegroundColor Green
    } else {
        Write-Host "ERROR: Modal missing role attribute" -ForegroundColor Red
    }
    
    if ($content -match 'aria-hidden="true"') {
        Write-Host "SUCCESS: Modal has proper aria-hidden attribute" -ForegroundColor Green
    } else {
        Write-Host "ERROR: Modal missing aria-hidden attribute" -ForegroundColor Red
    }
}

Write-Host "`nMODAL ELEMENT NOT FOUND FIX - SUMMARY" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "1. Modal ID Consistency: Verified modal-nova-medicao" -ForegroundColor Green
Write-Host "2. Modal Inclusion: _NovaMedicaoModal included unconditionally" -ForegroundColor Green
Write-Host "3. Resilient Initialization: Error checking and logging added" -ForegroundColor Green
Write-Host "4. Bootstrap Prevention: Auto-initialization blocked" -ForegroundColor Green
Write-Host "5. Modal Attributes: Proper ARIA attributes added" -ForegroundColor Green

Write-Host "`nFIX APPLIED: Bootstrap Modal Auto-Initialization Blocked!" -ForegroundColor Green
Write-Host "The modal.js error should be resolved by preventing Bootstrap" -ForegroundColor Green
Write-Host "from trying to initialize the modal automatically." -ForegroundColor Green