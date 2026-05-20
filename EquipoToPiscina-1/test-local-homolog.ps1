# Quick Local Homolog Test Script
# Run this after building the solution locally

param(
    [string]$LocalUrl = "http://localhost"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Local Homolog Environment Test       " -ForegroundColor Cyan  
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Test 1: Check if files exist
Write-Host "[1/6] Checking required files..." -ForegroundColor Yellow

$requiredFiles = @(
    "rdoappProject\Api\Contents\Reports\Teste.rdlc",
    "rdoappProject\Api\Models\LaudoModel.cs",
    "rdoappProject\Web.config",
    "rdoappClass\laudo.cs"
)

$allFilesExist = $true
foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Write-Host "   ✓ $file exists" -ForegroundColor Green
    } else {
        Write-Host "   ✗ $file missing" -ForegroundColor Red
        $allFilesExist = $false
    }
}

# Test 2: Check connection string
Write-Host "`n[2/6] Checking connection string..." -ForegroundColor Yellow
$webConfig = Get-Content "rdoappProject\Web.config" -Raw
if ($webConfig -like "*piscinas_rdoapp_homolog*") {
    Write-Host "   ✓ Connection string points to homolog database" -ForegroundColor Green
} else {
    Write-Host "   ✗ Connection string still points to production!" -ForegroundColor Red
    $allFilesExist = $false
}

# Test 3: Check Entity Framework fix
Write-Host "`n[3/6] Checking Entity Framework fix..." -ForegroundColor Yellow
$laudoModel = Get-Content "rdoappProject\Api\Models\LaudoModel.cs" -Raw
if ($laudoModel -like "*context.Set<laudo>()*") {
    Write-Host "   ✓ Entity Framework fix applied" -ForegroundColor Green
} else {
    Write-Host "   ✗ Entity Framework fix not found" -ForegroundColor Red
    $allFilesExist = $false
}

# Test 4: Check build output
Write-Host "`n[4/6] Checking build output..." -ForegroundColor Yellow
$dllPath = "rdoappClass\bin\Debug\rdoappClass.dll"
if (Test-Path $dllPath) {
    $dllInfo = Get-Item $dllPath
    $age = (Get-Date) - $dllInfo.LastWriteTime
    if ($age.TotalMinutes -lt 60) {
        Write-Host "   ✓ DLL is recent (built $([math]::Round($age.TotalMinutes, 1)) minutes ago)" -ForegroundColor Green
    } else {
        Write-Host "   ⚠ DLL is old (built $([math]::Round($age.TotalHours, 1)) hours ago)" -ForegroundColor Yellow
        Write-Host "     Consider rebuilding the solution" -ForegroundColor Gray
    }
} else {
    Write-Host "   ✗ rdoappClass.dll not found - solution needs to be built" -ForegroundColor Red
    $allFilesExist = $false
}

# Test 5: Check RDLC template content
Write-Host "`n[5/6] Checking RDLC template..." -ForegroundColor Yellow
$rdlcPath = "rdoappProject\Api\Contents\Reports\Teste.rdlc"
if (Test-Path $rdlcPath) {
    $rdlcContent = Get-Content $rdlcPath -Raw
    if ($rdlcContent -like "*dtItensLaudo*" -or $rdlcContent -like "*dtCargosAgrupados*") {
        Write-Host "   ✓ RDLC template has expected data sources" -ForegroundColor Green
    } else {
        Write-Host "   ⚠ RDLC template may need customization for Laudo data" -ForegroundColor Yellow
    }
} else {
    Write-Host "   ✗ Teste.rdlc not found" -ForegroundColor Red
    $allFilesExist = $false
}

# Test 6: Provide next steps
Write-Host "`n[6/6] Next steps..." -ForegroundColor Yellow

if ($allFilesExist) {
    Write-Host "   ✅ All files ready for testing!" -ForegroundColor Green
    Write-Host ""
    Write-Host "To test locally:" -ForegroundColor Cyan
    Write-Host "1. Open solution in Visual Studio" -ForegroundColor White
    Write-Host "2. Set rdoappProject as startup project" -ForegroundColor White
    Write-Host "3. Press F5 to run" -ForegroundColor White
    Write-Host "4. Navigate to /laudos/index" -ForegroundColor White
    Write-Host "5. Test Laudo creation and PDF generation" -ForegroundColor White
} else {
    Write-Host "   ❌ Some files are missing or incorrect" -ForegroundColor Red
    Write-Host ""
    Write-Host "Required actions:" -ForegroundColor Yellow
    Write-Host "1. Build the solution in Visual Studio" -ForegroundColor White
    Write-Host "2. Run T4 templates (rdoappModel.Context.tt)" -ForegroundColor White
    Write-Host "3. Verify all files exist" -ForegroundColor White
    Write-Host "4. Re-run this test script" -ForegroundColor White
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Test Complete                         " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Summary
if ($allFilesExist) {
    Write-Host "🎉 Ready for local testing!" -ForegroundColor Green
} else {
    Write-Host "⚠️  Setup incomplete - follow the actions above" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "For detailed testing guide, see: LOCAL-TESTING-GUIDE.md" -ForegroundColor Gray
Write-Host ""