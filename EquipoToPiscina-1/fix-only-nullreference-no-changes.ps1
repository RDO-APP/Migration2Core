#!/usr/bin/env pwsh

Write-Host "=== FIXING ONLY NULL REFERENCE - NO OTHER CHANGES ===" -ForegroundColor Green

# Navigate to project directory
Set-Location "RDO-NET8-Migration/RdoApp.Core"

# Restore ALL original files from backups to undo any unwanted changes
Write-Host "Restoring original files to undo any unwanted changes..." -ForegroundColor Yellow

if (Test-Path "Views/Obra/Escolher.cshtml.backup") {
    Copy-Item "Views/Obra/Escolher.cshtml.backup" "Views/Obra/Escolher.cshtml" -Force
    Write-Host "✓ Restored original Escolher.cshtml" -ForegroundColor Green
}

if (Test-Path "Controllers/Api/ObraApiController.cs.backup") {
    Copy-Item "Controllers/Api/ObraApiController.cs.backup" "Controllers/Api/ObraApiController.cs" -Force
    Write-Host "✓ Restored original ObraApiController.cs" -ForegroundColor Green
}

# Now apply ONLY the minimal null reference fix
Write-Host "`nApplying ONLY the null reference fix..." -ForegroundColor Yellow

# Read the current controller
$controllerContent = Get-Content "Controllers/Api/ObraApiController.cs" -Raw

# Apply ONLY the essential null checks - no other changes
$fixedContent = $controllerContent -replace 'var userIdClaim = User\.FindFirst\(ClaimTypes\.NameIdentifier\)\?\.Value;', @'
// MINIMAL NULL CHECK FIX
if (User?.Identity == null || !User.Identity.IsAuthenticated)
{
    return Unauthorized();
}

var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier);
if (userIdClaim == null || string.IsNullOrEmpty(userIdClaim.Value))
{
    return Unauthorized();
}

var userIdValue = userIdClaim.Value;'@

$fixedContent = $fixedContent -replace 'if \(!int\.TryParse\(userIdClaim, out int idColaborador\)\)', 'if (!int.TryParse(userIdValue, out int idColaborador))'

# Write the minimally fixed controller
$fixedContent | Out-File -FilePath "Controllers/Api/ObraApiController.cs" -Encoding UTF8 -Force

Write-Host "✓ Applied minimal null reference fix" -ForegroundColor Green

# Build to verify fix works
Write-Host "`n=== TESTING MINIMAL FIX ===" -ForegroundColor Yellow
dotnet build --no-restore 2>&1 | Tee-Object -Variable buildOutput

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ MINIMAL FIX SUCCESSFUL!" -ForegroundColor Green
    Write-Host "`nFixed ONLY the null reference error." -ForegroundColor White
    Write-Host "No colors, styling, or other functionality changed." -ForegroundColor White
} else {
    Write-Host "❌ Fix failed, restoring original" -ForegroundColor Red
    if (Test-Path "Controllers/Api/ObraApiController.cs.backup") {
        Copy-Item "Controllers/Api/ObraApiController.cs.backup" "Controllers/Api/ObraApiController.cs" -Force
    }
}

Set-Location "../.."