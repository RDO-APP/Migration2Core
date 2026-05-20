# Quick Test Environment Verification Script
# Run this to verify everything is ready for testing

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Test Environment Verification        " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$allGood = $true

# Check 1: Required files exist
Write-Host "[1/5] Checking required files..." -ForegroundColor Yellow

$requiredFiles = @(
    "rdoappProject\Web.config",
    "rdoappProject\Api\Models\LaudoModel.cs",
    "rdoappProject\Api\Contents\Reports\Teste.rdlc",
    "rdoappClass\laudo.cs",
    "rdoappClass\rdoappModel.Context.cs",
    "setup-homolog-database.sql",
    "VISUAL-STUDIO-INSTRUCTIONS.md"
)

foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Write-Host "   ✓ $file" -ForegroundColor Green
    } else {
        Write-Host "   ✗ $file MISSING" -ForegroundColor Red
        $allGood = $false
    }
}

# Check 2: Connection string verification
Write-Host "`n[2/5] Verifying connection string..." -ForegroundColor Yellow
$webConfig = Get-Content "rdoappProject\Web.config" -Raw
if ($webConfig -like "*piscinas_rdoapp_homolog*") {
    Write-Host "   ✓ Points to homolog database" -ForegroundColor Green
} else {
    Write-Host "   ✗ Still points to production database!" -ForegroundColor Red
    $allGood = $false
}

# Check 3: Entity Framework fix verification
Write-Host "`n[3/5] Verifying Entity Framework fix..." -ForegroundColor Yellow
$laudoModel = Get-Content "rdoappProject\Api\Models\LaudoModel.cs" -Raw
if ($laudoModel -like "*context.Set<laudo>()*") {
    Write-Host "   ✓ Entity Framework fix applied" -ForegroundColor Green
} else {
    Write-Host "   ✗ Entity Framework fix NOT applied" -ForegroundColor Red
    $allGood = $false
}

# Check 4: RDLC template verification
Write-Host "`n[4/5] Verifying RDLC template..." -ForegroundColor Yellow
$rdlcPath = "rdoappProject\Api\Contents\Reports\Teste.rdlc"
if (Test-Path $rdlcPath) {
    $rdlcSize = (Get-Item $rdlcPath).Length
    if ($rdlcSize -gt 1000) {
        Write-Host "   ✓ Teste.rdlc exists and has content ($rdlcSize bytes)" -ForegroundColor Green
    } else {
        Write-Host "   ⚠ Teste.rdlc exists but seems small ($rdlcSize bytes)" -ForegroundColor Yellow
    }
} else {
    Write-Host "   ✗ Teste.rdlc NOT found" -ForegroundColor Red
    $allGood = $false
}

# Check 5: Solution file verification
Write-Host "`n[5/5] Verifying solution file..." -ForegroundColor Yellow
$solutionFiles = Get-ChildItem -Filter "*.sln"
if ($solutionFiles.Count -gt 0) {
    Write-Host "   ✓ Solution file found: $($solutionFiles[0].Name)" -ForegroundColor Green
} else {
    Write-Host "   ⚠ No .sln file found - you may need to create one" -ForegroundColor Yellow
}

# Summary
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Verification Results                  " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if ($allGood) {
    Write-Host "🎉 ALL CHECKS PASSED!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Your test environment is ready!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "1. Run setup-homolog-database.sql in MySQL" -ForegroundColor White
    Write-Host "2. Open solution in Visual Studio" -ForegroundColor White
    Write-Host "3. Follow VISUAL-STUDIO-INSTRUCTIONS.md" -ForegroundColor White
    Write-Host "4. Test Laudo functionality" -ForegroundColor White
} else {
    Write-Host "❌ SOME CHECKS FAILED!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please fix the issues above before proceeding." -ForegroundColor Yellow
    Write-Host "The test environment is not ready for testing." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Test environment location: $(Get-Location)" -ForegroundColor Gray
Write-Host "Original files location: ..\  (unchanged)" -ForegroundColor Gray
Write-Host ""