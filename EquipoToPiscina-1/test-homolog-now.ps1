# 🧪 QUICK HOMOLOG TEST SCRIPT
# This script helps you test the homolog environment immediately

Write-Host "🧪 TESTING HOMOLOG ENVIRONMENT" -ForegroundColor Cyan
Write-Host "===============================" -ForegroundColor Cyan

# Step 1: Check if we're in the right location
Write-Host "`n[1/5] Checking location..." -ForegroundColor Yellow
$currentPath = Get-Location
Write-Host "   Current path: $currentPath" -ForegroundColor White

if (Test-Path "RDO-Homolog-Test") {
    Write-Host "   ✅ RDO-Homolog-Test folder found" -ForegroundColor Green
} else {
    Write-Host "   ❌ RDO-Homolog-Test folder not found" -ForegroundColor Red
    Write-Host "   Please run this script from the main project folder" -ForegroundColor Yellow
    exit
}

# Step 2: Check solution file
Write-Host "`n[2/5] Checking solution file..." -ForegroundColor Yellow
if (Test-Path "RDO-Homolog-Test\solution\rdoapp.sln") {
    Write-Host "   ✅ Solution file found" -ForegroundColor Green
} else {
    Write-Host "   ❌ Solution file not found" -ForegroundColor Red
    exit
}

# Step 3: Check key files
Write-Host "`n[3/5] Checking key files..." -ForegroundColor Yellow
$keyFiles = @(
    "RDO-Homolog-Test\rdoappProject\Web.config",
    "RDO-Homolog-Test\rdoappProject\Api\Models\LaudoModel.cs",
    "RDO-Homolog-Test\rdoappProject\Client\Views\Laudos\cadastro.html"
)

foreach ($file in $keyFiles) {
    if (Test-Path $file) {
        Write-Host "   ✅ $($file.Split('\')[-1])" -ForegroundColor Green
    } else {
        Write-Host "   ❌ $($file.Split('\')[-1]) MISSING" -ForegroundColor Red
    }
}

# Step 4: Check database connection
Write-Host "`n[4/5] Checking database configuration..." -ForegroundColor Yellow
$webConfig = Get-Content "RDO-Homolog-Test\rdoappProject\Web.config" -Raw
if ($webConfig -like "*piscinas_rdoapp_homologa*") {
    Write-Host "   ✅ Points to homolog database (piscinas_rdoapp_homologa)" -ForegroundColor Green
} else {
    Write-Host "   ⚠️  Database connection needs verification" -ForegroundColor Yellow
}

# Step 5: Check Entity Framework fix
Write-Host "`n[5/5] Checking Entity Framework fix..." -ForegroundColor Yellow
$laudoModel = Get-Content "RDO-Homolog-Test\rdoappProject\Api\Models\LaudoModel.cs" -Raw
if ($laudoModel -like "*context.Set<laudo>()*") {
    Write-Host "   ✅ Entity Framework fix applied" -ForegroundColor Green
} else {
    Write-Host "   ❌ Entity Framework fix NOT applied" -ForegroundColor Red
}

Write-Host "`n" -ForegroundColor White
Write-Host "🚀 READY TO TEST!" -ForegroundColor Green
Write-Host "=================" -ForegroundColor Green
Write-Host ""
Write-Host "NEXT STEPS:" -ForegroundColor Cyan
Write-Host "1. Open Visual Studio" -ForegroundColor White
Write-Host "2. Open: RDO-Homolog-Test\solution\rdoapp.sln" -ForegroundColor White
Write-Host "3. Set rdoappProject as startup project" -ForegroundColor White
Write-Host "4. Press F5 to run" -ForegroundColor White
Write-Host "5. Navigate to /laudos/cadastro to see the form" -ForegroundColor White
Write-Host ""
Write-Host "WHAT TO TEST:" -ForegroundColor Cyan
Write-Host "✅ Check if laudo form loads without errors" -ForegroundColor White
Write-Host "✅ Verify all inspection questions are present:" -ForegroundColor White
Write-Host "   - CLORO levels" -ForegroundColor Gray
Write-Host "   - PH levels" -ForegroundColor Gray
Write-Host "   - LIMPIDEZ DA ÁGUA" -ForegroundColor Gray
Write-Host "   - MATÉRIAS FLUTUANTES" -ForegroundColor Gray
Write-Host "   - DETRITOS" -ForegroundColor Gray
Write-Host "   - BACTÉRIAS" -ForegroundColor Gray
Write-Host "   - ALGAS" -ForegroundColor Gray
Write-Host "✅ Test form submission" -ForegroundColor White
Write-Host "✅ Check for any Entity Framework errors" -ForegroundColor White
Write-Host ""
Write-Host "EXPECTED RESULT:" -ForegroundColor Green
Write-Host "The form should match the production interface you showed me!" -ForegroundColor White
Write-Host ""
Write-Host "If you encounter any issues, check:" -ForegroundColor Yellow
Write-Host "- Visual Studio Output window for errors" -ForegroundColor Gray
Write-Host "- Browser console for JavaScript errors" -ForegroundColor Gray
Write-Host "- Database connection in DBeaver" -ForegroundColor Gray
Write-Host ""
Write-Host "📞 Report back with your test results!" -ForegroundColor Cyan