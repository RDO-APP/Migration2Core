# Test Login Implementation
# Kills processes, rebuilds, and prepares for testing

Write-Host "=== Testing Login Implementation ===" -ForegroundColor Cyan
Write-Host ""

# Step 1: Kill any running RdoApp processes
Write-Host "Step 1: Killing any running RdoApp processes..." -ForegroundColor Yellow
Get-Process | Where-Object {$_.ProcessName -like "*RdoApp*"} | ForEach-Object {
    Write-Host "  Killing process: $($_.ProcessName) (PID: $($_.Id))" -ForegroundColor Gray
    Stop-Process -Id $_.Id -Force
}
Write-Host "  ✅ Processes killed" -ForegroundColor Green
Write-Host ""

# Step 2: Clean and rebuild
Write-Host "Step 2: Cleaning and rebuilding project..." -ForegroundColor Yellow
Set-Location "RDO-CleanMigration-2026\RdoApp.Core"

Write-Host "  Cleaning..." -ForegroundColor Gray
dotnet clean --nologo --verbosity quiet

Write-Host "  Building..." -ForegroundColor Gray
$buildOutput = dotnet build --nologo --verbosity quiet 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "  ✅ Build successful" -ForegroundColor Green
} else {
    Write-Host "  ❌ Build failed!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Build output:" -ForegroundColor Yellow
    Write-Host $buildOutput
    exit 1
}

Set-Location "..\..\"
Write-Host ""

# Step 3: Verify key files exist
Write-Host "Step 3: Verifying implementation files..." -ForegroundColor Yellow

$filesToCheck = @(
    "RDO-CleanMigration-2026\RdoApp.Core\Utils\Seguranca.cs",
    "RDO-CleanMigration-2026\RdoApp.Core\Models\ViewModels\LoginViewModel.cs",
    "RDO-CleanMigration-2026\RdoApp.Core\Controllers\AccountController.cs",
    "RDO-CleanMigration-2026\RdoApp.Core\Controllers\ObraController.cs",
    "RDO-CleanMigration-2026\RdoApp.Core\Views\Obra\Escolher.cshtml"
)

$allFilesExist = $true
foreach ($file in $filesToCheck) {
    if (Test-Path $file) {
        Write-Host "  ✅ $file" -ForegroundColor Green
    } else {
        Write-Host "  ❌ $file NOT FOUND" -ForegroundColor Red
        $allFilesExist = $false
    }
}

Write-Host ""

if ($allFilesExist) {
    Write-Host "=== ✅ ALL CHECKS PASSED ===" -ForegroundColor Green
    Write-Host ""
    Write-Host "Ready to test! Next steps:" -ForegroundColor Cyan
    Write-Host "1. Open Visual Studio" -ForegroundColor White
    Write-Host "2. Open RDO-CleanMigration-2026\RDO-CleanMigration-2026\RdoApp.sln" -ForegroundColor White
    Write-Host "3. Press F5 to run" -ForegroundColor White
    Write-Host "4. Login with:" -ForegroundColor White
    Write-Host "   CPF: 567.065.455-20" -ForegroundColor Yellow
    Write-Host "   Password: RXL8DjdYj6Y=" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Expected: Login page → Obra selection (103 obras)" -ForegroundColor Cyan
} else {
    Write-Host "=== ❌ SOME FILES MISSING ===" -ForegroundColor Red
    Write-Host "Check the file list above" -ForegroundColor Yellow
    exit 1
}
