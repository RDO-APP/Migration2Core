# FORCE REBUILD - Remove Debug Box from Escolher
# This script will force a complete rebuild to clear cached views

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "FORCE REBUILD - ESCOLHER DEBUG BOX FIX" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Stop all running processes
Write-Host "Step 1: Stopping all RdoApp processes..." -ForegroundColor Yellow
Get-Process | Where-Object {$_.ProcessName -like "*RdoApp*" -or $_.ProcessName -like "*dotnet*"} | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
Write-Host "✓ Processes stopped" -ForegroundColor Green
Write-Host ""

# Step 2: Clean bin and obj folders
Write-Host "Step 2: Cleaning bin and obj folders..." -ForegroundColor Yellow
$projectPath = "RDO-NET8-Migration/RdoApp.Core"

if (Test-Path "$projectPath/bin") {
    Remove-Item "$projectPath/bin" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "✓ Removed bin folder" -ForegroundColor Green
}

if (Test-Path "$projectPath/obj") {
    Remove-Item "$projectPath/obj" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "✓ Removed obj folder" -ForegroundColor Green
}
Write-Host ""

# Step 3: Verify the Escolher.cshtml file is correct
Write-Host "Step 3: Verifying Escolher.cshtml file..." -ForegroundColor Yellow
$escolherPath = "$projectPath/Views/Obra/Escolher.cshtml"
$content = Get-Content $escolherPath -Raw

if ($content -match "DEBUG INFO") {
    Write-Host "✗ ERROR: Debug box still in file!" -ForegroundColor Red
    Write-Host "The file was not saved correctly. Please check the file manually." -ForegroundColor Red
    exit 1
} else {
    Write-Host "✓ File is clean (no debug box)" -ForegroundColor Green
}
Write-Host ""

# Step 4: Build the project
Write-Host "Step 4: Building project..." -ForegroundColor Yellow
Set-Location $projectPath
$buildOutput = dotnet build --no-incremental 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Build successful" -ForegroundColor Green
} else {
    Write-Host "✗ Build failed:" -ForegroundColor Red
    Write-Host $buildOutput -ForegroundColor Red
    Set-Location ../..
    exit 1
}
Set-Location ../..
Write-Host ""

# Step 5: Start the application
Write-Host "Step 5: Starting application..." -ForegroundColor Yellow
Write-Host "Running: dotnet run --project $projectPath" -ForegroundColor Gray
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "INSTRUCTIONS:" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "1. Wait for 'Now listening on: https://localhost:7201'" -ForegroundColor White
Write-Host "2. Open browser in INCOGNITO mode (Ctrl+Shift+N)" -ForegroundColor White
Write-Host "3. Navigate to: https://localhost:7201/Obra/Escolher" -ForegroundColor White
Write-Host "4. Press Ctrl+F5 to force refresh" -ForegroundColor White
Write-Host "5. The yellow debug box should be GONE" -ForegroundColor White
Write-Host ""
Write-Host "Press Ctrl+C to stop the server when done testing" -ForegroundColor Yellow
Write-Host ""

Start-Sleep -Seconds 2
Set-Location $projectPath
dotnet run
