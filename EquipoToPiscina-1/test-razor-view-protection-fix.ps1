# Test Razor View Protection Middleware Fix
# This tests the surgical fix for Blazor hot-reload middleware blocking Razor views

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "RAZOR VIEW PROTECTION FIX - TEST SCRIPT" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "WHAT WAS FIXED:" -ForegroundColor Yellow
Write-Host "- Blazor hot-reload middleware was intercepting Razor views" -ForegroundColor White
Write-Host "- Views with Layout = null returned blank pages" -ForegroundColor White
Write-Host "- Controller executed successfully but view never rendered" -ForegroundColor White
Write-Host ""

Write-Host "THE SOLUTION:" -ForegroundColor Yellow
Write-Host "- Created RazorViewProtectionMiddleware.cs" -ForegroundColor White
Write-Host "- Registered BEFORE UseStaticFiles in Program.cs" -ForegroundColor White
Write-Host "- Wraps response stream to prevent hot-reload buffering" -ForegroundColor White
Write-Host "- Marks Razor views to skip hot-reload injection" -ForegroundColor White
Write-Host ""

Write-Host "CHANGES APPLIED:" -ForegroundColor Yellow
Write-Host "1. Created: RazorViewProtectionMiddleware.cs" -ForegroundColor Green
Write-Host "2. Registered middleware in Program.cs" -ForegroundColor Green
Write-Host "3. Restored December 2025 backup to Escolher.cshtml" -ForegroundColor Green
Write-Host "4. Fixed model type: IEnumerable<ObraViewModel>" -ForegroundColor Green
Write-Host "5. Reverted controller from ContentResult to View()" -ForegroundColor Green
Write-Host "6. Removed temporary middleware bypass code" -ForegroundColor Green
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "STARTING TEST" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Navigate to project directory
$projectPath = "RDO-NET8-Migration\RdoApp.Core"
if (-not (Test-Path $projectPath)) {
    Write-Host "ERROR: Project path not found: $projectPath" -ForegroundColor Red
    exit 1
}

Set-Location $projectPath
Write-Host "Project directory: $projectPath" -ForegroundColor Green
Write-Host ""

# Kill any existing processes
Write-Host "Stopping any existing RdoApp processes..." -ForegroundColor Yellow
Get-Process | Where-Object { $_.ProcessName -like "*RdoApp*" -or $_.ProcessName -like "*dotnet*" } | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
Write-Host "Processes stopped." -ForegroundColor Green
Write-Host ""

# Build the project
Write-Host "Building project..." -ForegroundColor Yellow
$buildOutput = dotnet build --no-incremental 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "BUILD FAILED!" -ForegroundColor Red
    Write-Host $buildOutput -ForegroundColor Red
    exit 1
}
Write-Host "Build successful." -ForegroundColor Green
Write-Host ""

# Start the server
Write-Host "Starting server with dotnet run..." -ForegroundColor Yellow
Write-Host "URL: https://localhost:7201/Obra/Escolher" -ForegroundColor Cyan
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "EXPECTED RESULTS:" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "✅ Page loads with full December 2025 UI" -ForegroundColor Green
Write-Host "✅ 103 obra cards displayed in grid layout" -ForegroundColor Green
Write-Host "✅ Icons visible (icon-contratante, icon-contratada)" -ForegroundColor Green
Write-Host "✅ Status colors (green/red/gray progress bars)" -ForegroundColor Green
Write-Host "✅ Progress percentages displayed" -ForegroundColor Green
Write-Host "✅ Legend section at bottom" -ForegroundColor Green
Write-Host "✅ No blank page" -ForegroundColor Green
Write-Host "✅ No JavaScript errors in F12 console" -ForegroundColor Green
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "SERVER LOGS TO WATCH:" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Look for these log messages:" -ForegroundColor Yellow
Write-Host "- 'Protecting Razor view from hot-reload: /obra/escolher'" -ForegroundColor White
Write-Host "- 'Razor view protected and rendered: /obra/escolher'" -ForegroundColor White
Write-Host "- 'Loading obras for user: Ricardo Freire'" -ForegroundColor White
Write-Host "- 'Filtered to 103 obras'" -ForegroundColor White
Write-Host ""

Write-Host "Press Ctrl+C to stop the server when done testing." -ForegroundColor Yellow
Write-Host ""

# Run the server
dotnet run
