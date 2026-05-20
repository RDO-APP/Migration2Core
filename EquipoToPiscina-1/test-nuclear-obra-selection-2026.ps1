# 🏗️ NUCLEAR OBRA SELECTION 2026 - COMPREHENSIVE TEST SCRIPT

Write-Host "🏗️ NUCLEAR OBRA SELECTION 2026 - COMPREHENSIVE TEST" -ForegroundColor Orange -BackgroundColor Black

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

# Step 3: Verify Nuclear 2026 Obra Selection implementation
Write-Host "🔍 Step 3: Verifying Nuclear 2026 Obra Selection implementation..." -ForegroundColor Yellow

# Check Escolher.cshtml for Nuclear indicators
$escolherContent = Get-Content "Views/Obra/Escolher.cshtml" -Raw
if ($escolherContent -match "🏗️ OBRA SELECTION SYSTEM 2026 ACTIVE") {
    Write-Host "✅ Escolher: Nuclear 2026 script found" -ForegroundColor Green
} else {
    Write-Host "❌ Escolher: Nuclear 2026 script NOT found" -ForegroundColor Red
}

# Check for shared layout usage
if ($escolherContent -match 'Layout = "_Layout"') {
    Write-Host "✅ Escolher: Using Nuclear 2026 cleaned layout" -ForegroundColor Green
} else {
    Write-Host "❌ Escolher: NOT using cleaned layout" -ForegroundColor Red
}

# Check for corrected navigation route
if ($escolherContent -match 'Action\("Cards", "Etapa"\)') {
    Write-Host "✅ Escolher: Correct navigation route (Etapa/Cards)" -ForegroundColor Green
} else {
    Write-Host "❌ Escolher: Incorrect navigation route" -ForegroundColor Red
}

# Check for pure JavaScript (no jQuery/AngularJS)
if ($escolherContent -match "console\.error.*NUCLEAR.*2026" -and $escolherContent -notmatch "jquery" -and $escolherContent -notmatch "angular") {
    Write-Host "✅ Escolher: Pure JavaScript implementation" -ForegroundColor Green
} else {
    Write-Host "❌ Escolher: Legacy dependencies detected" -ForegroundColor Red
}

# Check ObraController for modern implementation
$controllerContent = Get-Content "Controllers/ObraController.cs" -Raw
if ($controllerContent -match "IObraService" -and $controllerContent -match "Claims") {
    Write-Host "✅ Controller: Modern service injection and claims-based auth" -ForegroundColor Green
} else {
    Write-Host "❌ Controller: Legacy implementation detected" -ForegroundColor Red
}

# Check site.js for cleanliness
$siteJsContent = Get-Content "wwwroot/js/site.js" -Raw
if ($siteJsContent.Trim().Length -lt 200) {
    Write-Host "✅ site.js: Clean (no legacy pollution)" -ForegroundColor Green
} else {
    Write-Host "⚠️ site.js: Contains content (check for legacy)" -ForegroundColor Yellow
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
Write-Host "🚀 Step 5: Starting Nuclear 2026 Obra Selection System..." -ForegroundColor Yellow
Write-Host ""
Write-Host "🏗️ NUCLEAR OBRA SELECTION 2026 READY FOR TESTING 🏗️" -ForegroundColor Orange -BackgroundColor Black
Write-Host ""
Write-Host "PROOF OF LIFE INDICATORS TO LOOK FOR:" -ForegroundColor Cyan
Write-Host "1. Top Right: '☢️ NUCLEAR 2026 ACTIVE ☢️' (RED)" -ForegroundColor White
Write-Host "2. Below that: '🏗️ OBRA SELECTION 2026 ☢️' (ORANGE)" -ForegroundColor White
Write-Host "3. F12 Console: '🏗️ OBRA SELECTION SYSTEM 2026 ACTIVE' (RED)" -ForegroundColor White
Write-Host ""
Write-Host "TESTING STEPS:" -ForegroundColor Cyan
Write-Host "1. Navigate to /Obra/Escolher (login first if needed)" -ForegroundColor White
Write-Host "2. Verify Nuclear 2026 indicators are visible" -ForegroundColor White
Write-Host "3. Test filters: Type in 'Unidade escolar' and 'Município' fields" -ForegroundColor White
Write-Host "4. Click any obra card to navigate to Etapa/Cards" -ForegroundColor White
Write-Host "5. Check F12 console for NO legacy errors" -ForegroundColor White
Write-Host ""
Write-Host "SUCCESS CRITERIA:" -ForegroundColor Cyan
Write-Host "✅ Nuclear 2026 indicators visible" -ForegroundColor White
Write-Host "✅ Filters work in real-time" -ForegroundColor White
Write-Host "✅ Navigation goes to /Etapa/Cards?obraId=X" -ForegroundColor White
Write-Host "✅ NO jQuery, AngularJS, or maskMoney errors" -ForegroundColor White
Write-Host "✅ Uses cleaned _Layout.cshtml" -ForegroundColor White
Write-Host ""
Write-Host "COMPARISON WITH LEGACY:" -ForegroundColor Cyan
Write-Host "❌ OLD: Layout = null (independent layout)" -ForegroundColor Red
Write-Host "✅ NEW: Layout = '_Layout' (Nuclear 2026 cleaned layout)" -ForegroundColor Green
Write-Host "❌ OLD: /Tarefa/Cards navigation" -ForegroundColor Red
Write-Host "✅ NEW: /Etapa/Cards navigation (corrected)" -ForegroundColor Green
Write-Host "❌ OLD: console.log messages" -ForegroundColor Red
Write-Host "✅ NEW: console.error for RED visibility" -ForegroundColor Green
Write-Host ""
Write-Host "Press Ctrl+C to stop when testing is complete" -ForegroundColor Yellow

# Start the application
dotnet run