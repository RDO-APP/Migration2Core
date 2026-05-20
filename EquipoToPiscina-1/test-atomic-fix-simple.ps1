# ATOMIC BOOTSTRAP FIX - SIMPLE TEST
Write-Host "ATOMIC BOOTSTRAP FIX - TEST VERIFICATION" -ForegroundColor Green

# Check Plus button has no Bootstrap data attributes
Write-Host "`n1. CHECKING PLUS BUTTON..." -ForegroundColor Yellow
$taskCardContent = Get-Content "RDO-NET8-Migration/RdoApp.Core/Views/Etapa/_TaskCardPartial.cshtml" -Raw

if ($taskCardContent -match "data-bs-toggle|data-bs-target|data-toggle.*modal|data-target.*modal") {
    Write-Host "ERROR: Plus button still has Bootstrap modal data attributes" -ForegroundColor Red
} else {
    Write-Host "SUCCESS: Plus button has NO Bootstrap modal data attributes" -ForegroundColor Green
}

if ($taskCardContent -match "window\.smartOpenModal") {
    Write-Host "SUCCESS: Plus button uses window.smartOpenModal function" -ForegroundColor Green
} else {
    Write-Host "ERROR: Plus button missing window.smartOpenModal call" -ForegroundColor Red
}

# Check Global Stop implementation
Write-Host "`n2. CHECKING GLOBAL STOP..." -ForegroundColor Yellow
$cardsContent = Get-Content "RDO-NET8-Migration/RdoApp.Core/Views/Etapa/Cards.cshtml" -Raw

if ($cardsContent -match "removeAttribute.*data-bs-toggle") {
    Write-Host "SUCCESS: Global Stop implemented" -ForegroundColor Green
} else {
    Write-Host "ERROR: Global Stop missing" -ForegroundColor Red
}

# Check Pure DOM Modal Implementation
Write-Host "`n3. CHECKING PURE DOM MODAL..." -ForegroundColor Yellow

if ($cardsContent -match "modalElement\.style\.display = 'block'") {
    Write-Host "SUCCESS: Uses pure DOM manipulation" -ForegroundColor Green
} else {
    Write-Host "ERROR: Missing pure DOM display manipulation" -ForegroundColor Red
}

if ($cardsContent -match "new bootstrap\.Modal|bootstrap\.Modal\.getOrCreateInstance") {
    Write-Host "ERROR: Still using Bootstrap Modal constructor" -ForegroundColor Red
} else {
    Write-Host "SUCCESS: NO Bootstrap Modal constructor usage" -ForegroundColor Green
}

# Test compilation
Write-Host "`n4. TESTING COMPILATION..." -ForegroundColor Yellow
try {
    $buildResult = dotnet build "RDO-NET8-Migration/RdoApp.Core" --verbosity quiet 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "SUCCESS: Compilation successful" -ForegroundColor Green
    } else {
        Write-Host "ERROR: Compilation failed" -ForegroundColor Red
    }
} catch {
    Write-Host "ERROR: Build error" -ForegroundColor Red
}

Write-Host "`nATOMIC FIX VERIFICATION COMPLETE!" -ForegroundColor Green
Write-Host "Ready to test in browser at: http://localhost:5031" -ForegroundColor Cyan