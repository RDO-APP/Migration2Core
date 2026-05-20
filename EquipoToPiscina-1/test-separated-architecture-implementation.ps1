# TEST SEPARATED ARCHITECTURE IMPLEMENTATION
# Tests the modern Blazor components with legacy rules extracted

Write-Host "=== TESTING SEPARATED ARCHITECTURE IMPLEMENTATION ===" -ForegroundColor Cyan
Write-Host "Testing Project A (RdoHeader) + Project B (RdoObraCards) integration" -ForegroundColor Yellow

# Stop any running processes
Write-Host "1. Stopping any running processes..." -ForegroundColor Green
Get-Process -Name "dotnet" -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -eq "dotnet" } | Stop-Process -Force -ErrorAction SilentlyContinue
Get-Process -Name "RdoApp.Core" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

# Navigate to project directory
Set-Location "RDO-NET8-Migration/RdoApp.Core"

# Clean and restore
Write-Host "2. Cleaning and restoring project..." -ForegroundColor Green
dotnet clean --verbosity quiet
dotnet restore --verbosity quiet

# Build the project
Write-Host "3. Building project with new components..." -ForegroundColor Green
$buildResult = dotnet build --verbosity quiet --no-restore 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "BUILD FAILED:" -ForegroundColor Red
    Write-Host $buildResult -ForegroundColor Red
    exit 1
}

Write-Host "✅ Build successful!" -ForegroundColor Green

# Check component files exist
Write-Host "4. Verifying component files..." -ForegroundColor Green

$componentFiles = @(
    "Components/RdoHeader.razor",
    "Components/RdoHeader.razor.css",
    "Components/RdoObraCards.razor", 
    "Components/RdoObraCards.razor.css"
)

foreach ($file in $componentFiles) {
    if (Test-Path $file) {
        Write-Host "✅ $file exists" -ForegroundColor Green
    } else {
        Write-Host "❌ $file missing" -ForegroundColor Red
    }
}

# Check layout files
Write-Host "5. Verifying layout files..." -ForegroundColor Green

$layoutFiles = @(
    "Views/Shared/_LayoutSelection.cshtml",
    "Views/Obra/Escolher.cshtml"
)

foreach ($file in $layoutFiles) {
    if (Test-Path $file) {
        Write-Host "✅ $file updated" -ForegroundColor Green
    } else {
        Write-Host "❌ $file missing" -ForegroundColor Red
    }
}

# Start the application
Write-Host "6. Starting application..." -ForegroundColor Green
Write-Host "Navigate to: https://localhost:7001/Obra/Escolher" -ForegroundColor Yellow
Write-Host "Expected: Modern header + obra cards with legacy styling" -ForegroundColor Yellow

# Start in background
$process = Start-Process -FilePath "dotnet" -ArgumentList "run", "--urls", "https://localhost:7001" -PassThru -WindowStyle Hidden

# Wait a moment for startup
Start-Sleep -Seconds 5

# Check if process is running
if ($process -and !$process.HasExited) {
    Write-Host "✅ Application started successfully!" -ForegroundColor Green
    Write-Host "Process ID: $($process.Id)" -ForegroundColor Cyan
    
    # Try to open browser
    try {
        Start-Process "https://localhost:7001/Obra/Escolher"
        Write-Host "✅ Browser opened to Escolher page" -ForegroundColor Green
    } catch {
        Write-Host "⚠️ Could not open browser automatically" -ForegroundColor Yellow
        Write-Host "Please manually navigate to: https://localhost:7001/Obra/Escolher" -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host "=== TESTING CHECKLIST ===" -ForegroundColor Cyan
    Write-Host "□ Header displays with RDO branding" -ForegroundColor White
    Write-Host "□ Header shows 'PISCINAS' title (no obra selected)" -ForegroundColor White
    Write-Host "□ Circular navigation buttons visible" -ForegroundColor White
    Write-Host "□ User dropdown works" -ForegroundColor White
    Write-Host "□ Mobile menu toggle works" -ForegroundColor White
    Write-Host "□ Obra cards display in grid (5 columns desktop)" -ForegroundColor White
    Write-Host "□ Cards show 97px icons (contratante/contratada)" -ForegroundColor White
    Write-Host "□ Progress bars use legacy colors (green/red/gray)" -ForegroundColor White
    Write-Host "□ Hover effects work (blue background #0088DD)" -ForegroundColor White
    Write-Host "□ Filters work for unidade/município" -ForegroundColor White
    Write-Host "□ Legend displays with correct colors" -ForegroundColor White
    Write-Host "□ Cards navigate to /Etapa/Cards when clicked" -ForegroundColor White
    Write-Host ""
    Write-Host "Press Ctrl+C to stop the server when testing is complete" -ForegroundColor Yellow
    
} else {
    Write-Host "❌ Failed to start application" -ForegroundColor Red
    exit 1
}

# Keep script running
try {
    while ($true) {
        Start-Sleep -Seconds 1
        if ($process.HasExited) {
            Write-Host "Application has stopped" -ForegroundColor Yellow
            break
        }
    }
} catch {
    Write-Host "Stopping application..." -ForegroundColor Yellow
    if ($process -and !$process.HasExited) {
        $process.Kill()
    }
}

Write-Host "=== TEST COMPLETE ===" -ForegroundColor Cyan