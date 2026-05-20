# Create Local Test Environment Script
# This creates a copy for testing without modifying original files

param(
    [string]$TestDir = "RDO-Homolog-Test"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Creating Local Test Environment      " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Create test directory
Write-Host "[1/5] Creating test directory..." -ForegroundColor Yellow
if (Test-Path $TestDir) {
    $overwrite = Read-Host "Test directory exists. Overwrite? (y/N)"
    if ($overwrite -eq 'y' -or $overwrite -eq 'Y') {
        Remove-Item $TestDir -Recurse -Force
    } else {
        Write-Host "Aborted by user" -ForegroundColor Gray
        exit 0
    }
}

New-Item -ItemType Directory -Path $TestDir -Force | Out-Null
Write-Host "   ✓ Created directory: $TestDir" -ForegroundColor Green

# Step 2: Copy project files
Write-Host "`n[2/5] Copying project files..." -ForegroundColor Yellow

$projectDirs = @("rdoappClass", "rdoappProject", "solution")
foreach ($dir in $projectDirs) {
    if (Test-Path $dir) {
        Copy-Item -Path $dir -Destination "$TestDir\$dir" -Recurse -Force
        Write-Host "   ✓ Copied $dir" -ForegroundColor Green
    } else {
        Write-Host "   ⚠ $dir not found - skipping" -ForegroundColor Yellow
    }
}

# Copy solution files
Get-ChildItem -Filter "*.sln" | ForEach-Object {
    Copy-Item $_.FullName "$TestDir\$($_.Name)" -Force
    Write-Host "   ✓ Copied $($_.Name)" -ForegroundColor Green
}

# Step 3: Update connection string in test copy
Write-Host "`n[3/5] Updating connection string for test..." -ForegroundColor Yellow
$testWebConfig = "$TestDir\rdoappProject\Web.config"
if (Test-Path $testWebConfig) {
    $webConfig = Get-Content $testWebConfig -Raw
    $webConfig = $webConfig -replace 'database=piscinas_rdoapp"', 'database=piscinas_rdoapp_homolog"'
    Set-Content $testWebConfig $webConfig
    Write-Host "   ✓ Updated Web.config for homolog database" -ForegroundColor Green
} else {
    Write-Host "   ⚠ Web.config not found in test copy" -ForegroundColor Yellow
}

$testAppConfig = "$TestDir\rdoappClass\App.Config"
if (Test-Path $testAppConfig) {
    $appConfig = Get-Content $testAppConfig -Raw
    $appConfig = $appConfig -replace 'database=piscinas_rdoapp"', 'database=piscinas_rdoapp_homolog"'
    Set-Content $testAppConfig $appConfig
    Write-Host "   ✓ Updated App.Config for homolog database" -ForegroundColor Green
}

# Step 4: Apply Entity Framework fix to test copy
Write-Host "`n[4/5] Applying Entity Framework fix to test copy..." -ForegroundColor Yellow
$testLaudoModel = "$TestDir\rdoappProject\Api\Models\LaudoModel.cs"
if (Test-Path $testLaudoModel) {
    $laudoModel = Get-Content $testLaudoModel -Raw
    $originalPattern = 'context\.laudo\.'
    $replacementPattern = 'context.Set<laudo>().'
    
    if ($laudoModel -match $originalPattern) {
        $laudoModel = $laudoModel -replace $originalPattern, $replacementPattern
        Set-Content $testLaudoModel $laudoModel
        Write-Host "   ✓ Applied Entity Framework fix" -ForegroundColor Green
        Write-Host "     Changed: context.laudo. → context.Set<laudo>()." -ForegroundColor Gray
    } else {
        Write-Host "   ⚠ No context.laudo references found to fix" -ForegroundColor Yellow
    }
} else {
    Write-Host "   ⚠ LaudoModel.cs not found in test copy" -ForegroundColor Yellow
}

# Step 5: Create missing RDLC template in test copy
Write-Host "`n[5/5] Creating missing RDLC template in test copy..." -ForegroundColor Yellow
$testReportsDir = "$TestDir\rdoappProject\Api\Contents\Reports"
$sourceRdlc = "$testReportsDir\Rdo_def.rdlc"
$targetRdlc = "$testReportsDir\Teste.rdlc"

if (Test-Path $sourceRdlc) {
    Copy-Item $sourceRdlc $targetRdlc -Force
    Write-Host "   ✓ Created Teste.rdlc from Rdo_def.rdlc" -ForegroundColor Green
} elseif (Test-Path "$testReportsDir\Rdo.rdlc") {
    Copy-Item "$testReportsDir\Rdo.rdlc" $targetRdlc -Force
    Write-Host "   ✓ Created Teste.rdlc from Rdo.rdlc" -ForegroundColor Green
} else {
    Write-Host "   ⚠ No suitable RDLC template found to copy" -ForegroundColor Yellow
    Write-Host "     You may need to create Teste.rdlc manually" -ForegroundColor Gray
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Test Environment Created!            " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Test environment location: $TestDir" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Create homolog database (see LOCAL-HOMOLOG-SETUP.md)" -ForegroundColor White
Write-Host "2. Open solution in Visual Studio:" -ForegroundColor White
Write-Host "   - Navigate to $TestDir" -ForegroundColor Gray
Write-Host "   - Open the .sln file" -ForegroundColor Gray
Write-Host "3. Build and run the test solution" -ForegroundColor White
Write-Host "4. Test Laudo functionality" -ForegroundColor White
Write-Host ""

Write-Host "Files modified in test copy only:" -ForegroundColor Yellow
Write-Host "- Connection strings → homolog database" -ForegroundColor Gray
Write-Host "- LaudoModel.cs → Entity Framework fix" -ForegroundColor Gray
Write-Host "- Teste.rdlc → Created from existing template" -ForegroundColor Gray
Write-Host ""

Write-Host "Original files remain unchanged! ✓" -ForegroundColor Green
Write-Host ""

# Create a quick verification script for the test environment
$verifyScript = @"
# Quick verification script for test environment
Write-Host "Verifying test environment..." -ForegroundColor Yellow

`$testFiles = @(
    "$TestDir\rdoappProject\Web.config",
    "$TestDir\rdoappProject\Api\Models\LaudoModel.cs", 
    "$TestDir\rdoappProject\Api\Contents\Reports\Teste.rdlc"
)

foreach (`$file in `$testFiles) {
    if (Test-Path `$file) {
        Write-Host "✓ `$file exists" -ForegroundColor Green
    } else {
        Write-Host "✗ `$file missing" -ForegroundColor Red
    }
}

Write-Host "`nTest environment ready for Visual Studio!" -ForegroundColor Cyan
"@

Set-Content "$TestDir\verify-test-env.ps1" $verifyScript
Write-Host "Created verification script: $TestDir\verify-test-env.ps1" -ForegroundColor Gray
Write-Host ""