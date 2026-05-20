# 🚀 QUICK TEST DAY 8 AUTHENTICATION - NO CONFLICTS
# This script ensures clean testing of the login system

Write-Host "🔄 PREPARING DAY 8 AUTHENTICATION TEST..." -ForegroundColor Cyan
Write-Host ""

# Step 1: Stop any running processes
Write-Host "1️⃣ Stopping any running RdoApp processes..." -ForegroundColor Yellow
& ".\stop-rdoapp-processes.ps1"

# Step 2: Navigate to project directory
Write-Host "2️⃣ Navigating to RdoApp.Core project..." -ForegroundColor Yellow
$projectPath = "RDO-NET8-Migration\RdoApp.Core"
if (Test-Path $projectPath) {
    Set-Location $projectPath
    Write-Host "   ✅ Located project at: $(Get-Location)" -ForegroundColor Green
} else {
    Write-Host "   ❌ Project not found at: $projectPath" -ForegroundColor Red
    exit 1
}

# Step 3: Clean and build
Write-Host "3️⃣ Cleaning and building project..." -ForegroundColor Yellow
dotnet clean --verbosity quiet
dotnet build --verbosity quiet

if ($LASTEXITCODE -eq 0) {
    Write-Host "   ✅ Build successful!" -ForegroundColor Green
} else {
    Write-Host "   ❌ Build failed!" -ForegroundColor Red
    exit 1
}

# Step 4: Start application
Write-Host "4️⃣ Starting application..." -ForegroundColor Yellow
Write-Host ""
Write-Host "🎯 EXPECTED RESULTS:" -ForegroundColor Cyan
Write-Host "   • Browser opens at https://localhost:7201" -ForegroundColor White
Write-Host "   • Redirects to /Auth/Login automatically" -ForegroundColor White
Write-Host "   • Modern login page appears" -ForegroundColor White
Write-Host "   • Use CPF: 567.065.455-20 | Password: 1234" -ForegroundColor White
Write-Host "   • After login: Dashboard with 'Marcel Castro de Santana'" -ForegroundColor White
Write-Host ""
Write-Host "🚀 STARTING APPLICATION NOW..." -ForegroundColor Green
Write-Host "   Press Ctrl+C to stop when done testing" -ForegroundColor Yellow
Write-Host ""

# Start the application
dotnet run