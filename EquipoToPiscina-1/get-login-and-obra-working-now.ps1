#!/usr/bin/env pwsh

Write-Host "=== GETTING LOGIN AND OBRA ESCOLHER WORKING NOW ===" -ForegroundColor Green

# Stop any running processes
Get-Process -Name "RdoApp.Core" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Get-Process -Name "dotnet" -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowTitle -like "*RdoApp*" } | Stop-Process -Force -ErrorAction SilentlyContinue

Start-Sleep -Seconds 2

# Navigate to project directory
Set-Location "RDO-NET8-Migration/RdoApp.Core"

Write-Host "Current directory: $(Get-Location)" -ForegroundColor Yellow

# 1. RESTORE ORIGINAL WORKING FILES FROM BACKUPS
Write-Host "`n=== RESTORING ORIGINAL WORKING FILES ===" -ForegroundColor Yellow

if (Test-Path "Views/Obra/Escolher.cshtml.backup") {
    Copy-Item "Views/Obra/Escolher.cshtml.backup" "Views/Obra/Escolher.cshtml" -Force
    Write-Host "✓ Restored original Escolher.cshtml" -ForegroundColor Green
}

if (Test-Path "Controllers/Api/ObraApiController.cs.backup") {
    Copy-Item "Controllers/Api/ObraApiController.cs.backup" "Controllers/Api/ObraApiController.cs" -Force
    Write-Host "✓ Restored original ObraApiController.cs" -ForegroundColor Green
}

# 2. APPLY ONLY ESSENTIAL NULL REFERENCE FIX
Write-Host "`n=== APPLYING MINIMAL NULL REFERENCE FIX ===" -ForegroundColor Yellow

$controllerPath = "Controllers/Api/ObraApiController.cs"
$controllerContent = Get-Content $controllerPath -Raw

# Only add essential null check - no other changes
$nullCheckFix = @"
// Essential null check fix
if (User?.Identity == null || !User.Identity.IsAuthenticated)
{
    return Unauthorized();
}

var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier);
if (userIdClaim == null)
{
    return Unauthorized();
}

var userIdValue = userIdClaim.Value;
"@

$fixedContent = $controllerContent -replace 'var userIdClaim = User\.FindFirst\(ClaimTypes\.NameIdentifier\)\?\.Value;', $nullCheckFix
$fixedContent = $fixedContent -replace 'if \(!int\.TryParse\(userIdClaim, out int idColaborador\)\)', 'if (!int.TryParse(userIdValue, out int idColaborador))'

$fixedContent | Out-File -FilePath $controllerPath -Encoding UTF8 -Force
Write-Host "✓ Applied minimal null reference fix" -ForegroundColor Green

# 3. BUILD PROJECT
Write-Host "`n=== BUILDING PROJECT ===" -ForegroundColor Yellow
dotnet build --no-restore 2>&1 | Tee-Object -Variable buildOutput

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ BUILD SUCCESSFUL!" -ForegroundColor Green
    
    # 4. START APPLICATION
    Write-Host "`n=== STARTING APPLICATION ===" -ForegroundColor Green
    
    # Start in background
    $process = Start-Process -FilePath "dotnet" -ArgumentList "run" -WorkingDirectory (Get-Location) -PassThru -WindowStyle Hidden
    
    Write-Host "Application starting (Process ID: $($process.Id))..." -ForegroundColor Yellow
    Start-Sleep -Seconds 8
    
    Write-Host "`n=== READY FOR USE ===" -ForegroundColor Green
    Write-Host "Login page: https://localhost:7139/Auth/Login" -ForegroundColor Cyan
    Write-Host "Credentials: ricardo / 123456" -ForegroundColor Yellow
    Write-Host "`nAfter login, you'll be redirected to obra selection page" -ForegroundColor White
    Write-Host "From there you can select any obra to access Etapas/Tarefas" -ForegroundColor White
    
    # Open browser
    Start-Sleep -Seconds 2
    Start-Process "https://localhost:7139/Auth/Login"
    
    Write-Host "`n✓ Browser opened to login page" -ForegroundColor Green
    Write-Host "✓ Both login and obra escolher pages should now work" -ForegroundColor Green
    
} else {
    Write-Host "❌ BUILD FAILED!" -ForegroundColor Red
    Write-Host "Build errors:" -ForegroundColor Yellow
    Write-Host $buildOutput -ForegroundColor Red
    
    # Restore original if build failed
    if (Test-Path "Controllers/Api/ObraApiController.cs.backup") {
        Copy-Item "Controllers/Api/ObraApiController.cs.backup" "Controllers/Api/ObraApiController.cs" -Force
        Write-Host "Restored original controller due to build failure" -ForegroundColor Yellow
    }
}

# Return to root directory
Set-Location "../.."
Write-Host "`nReturned to root directory: $(Get-Location)" -ForegroundColor Yellow