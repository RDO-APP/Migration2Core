# ☢️ NUCLEAR MODAL 2026 - ATOMIC FIX TEST SCRIPT

Write-Host "☢️ NUCLEAR MODAL 2026 - ATOMIC FIX TEST" -ForegroundColor Red -BackgroundColor White

# Step 1: Kill all processes to prevent file locks
Write-Host "🔥 Step 1: Killing all RdoApp processes..." -ForegroundColor Yellow
try {
    Get-Process | Where-Object {$_.ProcessName -like "*RdoApp*" -or $_.ProcessName -like "*dotnet*" -or $_.ProcessName -like "*w3wp*"} | Stop-Process -Force -ErrorAction SilentlyContinue
    Write-Host "✅ Processes killed successfully" -ForegroundColor Green
} catch {
    Write-Host "⚠️ Some processes may still be running: $($_.Exception.Message)" -ForegroundColor Yellow
}

Start-Sleep -Seconds 2

# Step 2: Clean build artifacts
Write-Host "🧹 Step 2: Cleaning build artifacts..." -ForegroundColor Yellow
Set-Location "RDO-NET8-Migration/RdoApp.Core"

if (Test-Path "bin") { Remove-Item -Recurse -Force "bin" -ErrorAction SilentlyContinue }
if (Test-Path "obj") { Remove-Item -Recurse -Force "obj" -ErrorAction SilentlyContinue }

Write-Host "✅ Build artifacts cleaned" -ForegroundColor Green

# Step 3: Verify Nuclear 2026 files
Write-Host "🔍 Step 3: Verifying Nuclear 2026 implementation..." -ForegroundColor Yellow

# Check Layout.cshtml for Nuclear indicator
$layoutContent = Get-Content "Views/Shared/_Layout.cshtml" -Raw
if ($layoutContent -match "☢️ NUCLEAR 2026 ACTIVE ☢️") {
    Write-Host "✅ Layout: Nuclear 2026 indicator found" -ForegroundColor Green
} else {
    Write-Host "❌ Layout: Nuclear 2026 indicator NOT found" -ForegroundColor Red
}

# Check Cards.cshtml for Atomic script
$cardsContent = Get-Content "Views/Etapa/Cards.cshtml" -Raw
if ($cardsContent -match "☢️ ATOMIC VERSION 2026 IS ALIVE ☢️") {
    Write-Host "✅ Cards: Atomic 2026 script found" -ForegroundColor Green
} else {
    Write-Host "❌ Cards: Atomic 2026 script NOT found" -ForegroundColor Red
}

# Check TaskCardPartial for nuclearShowModal
$taskCardContent = Get-Content "Views/Etapa/_TaskCardPartial.cshtml" -Raw
if ($taskCardContent -match "nuclearShowModal") {
    Write-Host "✅ TaskCard: Nuclear function call found" -ForegroundColor Green
} else {
    Write-Host "❌ TaskCard: Nuclear function call NOT found" -ForegroundColor Red
}

# Check Modal for new ID
$modalContent = Get-Content "Views/Etapa/_NovaMedicaoModal.cshtml" -Raw
if ($modalContent -match "manual-modal-medicao-2026") {
    Write-Host "✅ Modal: New ID found (manual-modal-medicao-2026)" -ForegroundColor Green
} else {
    Write-Host "❌ Modal: New ID NOT found" -ForegroundColor Red
}

# Step 4: Build project
Write-Host "🔨 Step 4: Building project..." -ForegroundColor Yellow
$buildResult = dotnet build --verbosity quiet 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Build successful" -ForegroundColor Green
} else {
    Write-Host "❌ Build failed:" -ForegroundColor Red
    Write-Host $buildResult -ForegroundColor Red
    exit 1
}

# Step 5: Start application
Write-Host "🚀 Step 5: Starting Nuclear 2026 application..." -ForegroundColor Yellow
Write-Host ""
Write-Host "☢️ NUCLEAR 2026 READY FOR TESTING ☢️" -ForegroundColor Red -BackgroundColor White
Write-Host ""
Write-Host "PROOF OF LIFE INDICATORS TO LOOK FOR:" -ForegroundColor Cyan
Write-Host "1. Top Right: '☢️ NUCLEAR 2026 ACTIVE ☢️' (RED)" -ForegroundColor White
Write-Host "2. Cards Page: '☢️ NUCLEAR CARDS 2026 ☢️' (RED)" -ForegroundColor White
Write-Host "3. F12 Console: '☢️ ATOMIC VERSION 2026 IS ALIVE ☢️' (RED)" -ForegroundColor White
Write-Host ""
Write-Host "TESTING STEPS:" -ForegroundColor Cyan
Write-Host "1. Navigate to Etapas/Tarefas page" -ForegroundColor White
Write-Host "2. Click Plus (+) button on any task card" -ForegroundColor White
Write-Host "3. Verify modal opens with Date=today, Status=task status" -ForegroundColor White
Write-Host "4. Check F12 console for NO Bootstrap errors" -ForegroundColor White
Write-Host ""
Write-Host "Press Ctrl+C to stop when testing is complete" -ForegroundColor Yellow

# Start the application
dotnet run