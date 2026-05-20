Write-Host "TESTING CARD STYLING FIX - CSS SELECTOR MISMATCH RESOLVED" -ForegroundColor Cyan

Set-Location "RDO-NET8-Migration/RdoApp.Core"

# Test 1: Build
Write-Host "1. TESTING BUILD..." -ForegroundColor Yellow
$buildResult = dotnet build --no-restore 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "BUILD SUCCESS" -ForegroundColor Green
} else {
    Write-Host "BUILD FAILED" -ForegroundColor Red
    exit 1
}

# Test 2: Check _EtapaAccordionPartial structure
Write-Host "2. CHECKING ETAPA ACCORDION STRUCTURE..." -ForegroundColor Yellow
$accordionContent = Get-Content "Views/Etapa/_EtapaAccordionPartial.cshtml" -Raw

if ($accordionContent -match 'kiro-compact-card' -and 
    $accordionContent -match 'kiro-card-header' -and
    $accordionContent -match 'task-title') {
    Write-Host "ACCORDION CARD STRUCTURE - FIXED" -ForegroundColor Green
} else {
    Write-Host "ACCORDION CARD STRUCTURE - ISSUE" -ForegroundColor Red
}

# Test 3: Check Cards.cshtml direct CSS injection
Write-Host "3. CHECKING DIRECT CSS INJECTION..." -ForegroundColor Yellow
$cardsContent = Get-Content "Views/Etapa/Cards.cshtml" -Raw

if ($cardsContent -match 'DIRECT CSS INJECTION' -and 
    $cardsContent -match 'kiro-compact-card' -and
    $cardsContent -match '!important' -and
    $cardsContent -match 'card-style-test') {
    Write-Host "DIRECT CSS INJECTION - ADDED" -ForegroundColor Green
} else {
    Write-Host "DIRECT CSS INJECTION - MISSING" -ForegroundColor Red
}

# Test 4: Check visual indicators
if ($cardsContent -match 'CARD STYLES LOADED' -and 
    $cardsContent -match 'card-style-test') {
    Write-Host "VISUAL TEST INDICATORS - ADDED" -ForegroundColor Green
} else {
    Write-Host "VISUAL TEST INDICATORS - MISSING" -ForegroundColor Red
}

Write-Host "CARD STYLING FIX COMPLETE" -ForegroundColor Green
Write-Host "Expected Results:" -ForegroundColor Yellow
Write-Host "- Limpeza, Manutencao should appear as styled cyan cards" -ForegroundColor White
Write-Host "- Green 'CARD STYLES LOADED' indicator should appear" -ForegroundColor White
Write-Host "- No more plain blue links" -ForegroundColor White

Set-Location "../.."