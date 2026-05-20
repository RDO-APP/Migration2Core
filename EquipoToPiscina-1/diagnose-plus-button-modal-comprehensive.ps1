# PLUS BUTTON MODAL DIAGNOSTIC - COMPREHENSIVE VERIFICATION
# This script verifies the Plus button modal functionality and checks for console errors

Write-Host "🎯 PLUS BUTTON MODAL DIAGNOSTIC - COMPREHENSIVE VERIFICATION" -ForegroundColor Green
Write-Host "=============================================================" -ForegroundColor Green

# Step 1: Check if application is running
Write-Host "`n1. CHECKING APPLICATION STATUS..." -ForegroundColor Yellow
$processes = Get-Process -Name "dotnet" -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -eq "dotnet" }
if ($processes) {
    Write-Host "✅ Application is running (dotnet processes found: $($processes.Count))" -ForegroundColor Green
} else {
    Write-Host "❌ Application is NOT running" -ForegroundColor Red
    Write-Host "Starting application..." -ForegroundColor Yellow
    
    # Start application
    Start-Process -FilePath "dotnet" -ArgumentList "run", "--project", "RDO-NET8-Migration/RdoApp.Core" -NoNewWindow
    Start-Sleep -Seconds 10
    Write-Host "✅ Application started" -ForegroundColor Green
}

# Step 2: Test compilation
Write-Host "`n2. TESTING COMPILATION..." -ForegroundColor Yellow
try {
    $buildResult = dotnet build "RDO-NET8-Migration/RdoApp.Core" --no-restore 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Compilation successful" -ForegroundColor Green
    } else {
        Write-Host "❌ Compilation errors found:" -ForegroundColor Red
        Write-Host $buildResult -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Build error: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 3: Check key files exist
Write-Host "`n3. VERIFYING KEY FILES..." -ForegroundColor Yellow
$keyFiles = @(
    "RDO-NET8-Migration/RdoApp.Core/Views/Etapa/Cards.cshtml",
    "RDO-NET8-Migration/RdoApp.Core/Views/Etapa/_TaskCardPartial.cshtml",
    "RDO-NET8-Migration/RdoApp.Core/Views/Etapa/_NovaMedicaoModal.cshtml",
    "RDO-NET8-Migration/RdoApp.Core/Views/Shared/_Layout.cshtml",
    "RDO-NET8-Migration/RdoApp.Core/Controllers/TarefaController.cs"
)

foreach ($file in $keyFiles) {
    if (Test-Path $file) {
        Write-Host "✅ $file exists" -ForegroundColor Green
    } else {
        Write-Host "❌ $file MISSING" -ForegroundColor Red
    }
}

# Step 4: Check for Plus button implementation
Write-Host "`n4. CHECKING PLUS BUTTON IMPLEMENTATION..." -ForegroundColor Yellow
$taskCardContent = Get-Content "RDO-NET8-Migration/RdoApp.Core/Views/Etapa/_TaskCardPartial.cshtml" -Raw
if ($taskCardContent -match "window\.smartOpenModal") {
    Write-Host "✅ Plus button uses window.smartOpenModal function" -ForegroundColor Green
} else {
    Write-Host "❌ Plus button does NOT use window.smartOpenModal function" -ForegroundColor Red
}

if ($taskCardContent -match "btn-add-medicao") {
    Write-Host "✅ Plus button has btn-add-medicao class" -ForegroundColor Green
} else {
    Write-Host "❌ Plus button missing btn-add-medicao class" -ForegroundColor Red
}

# Step 5: Check for Nuclear Modal System
Write-Host "`n5. CHECKING NUCLEAR MODAL SYSTEM..." -ForegroundColor Yellow
$cardsContent = Get-Content "RDO-NET8-Migration/RdoApp.Core/Views/Etapa/Cards.cshtml" -Raw
if ($cardsContent -match "ULTIMATE NUCLEAR CLEAN MODAL SYSTEM") {
    Write-Host "✅ Nuclear Modal System is implemented" -ForegroundColor Green
} else {
    Write-Host "❌ Nuclear Modal System NOT found" -ForegroundColor Red
}

if ($cardsContent -match "window\.smartOpenModal = function") {
    Write-Host "✅ smartOpenModal function is defined" -ForegroundColor Green
} else {
    Write-Host "❌ smartOpenModal function NOT defined" -ForegroundColor Red
}

if ($cardsContent -match "window\.salvarNovaMedicao = function") {
    Write-Host "✅ salvarNovaMedicao function is defined" -ForegroundColor Green
} else {
    Write-Host "❌ salvarNovaMedicao function NOT defined" -ForegroundColor Red
}

# Step 6: Check for Bootstrap isolation
Write-Host "`n6. CHECKING BOOTSTRAP ISOLATION..." -ForegroundColor Yellow
$layoutContent = Get-Content "RDO-NET8-Migration/RdoApp.Core/Views/Shared/_Layout.cshtml" -Raw
if ($layoutContent -match "ULTIMATE BOOTSTRAP ISOLATION") {
    Write-Host "✅ Bootstrap isolation is implemented" -ForegroundColor Green
} else {
    Write-Host "❌ Bootstrap isolation NOT found" -ForegroundColor Red
}

if ($layoutContent -match "bootstrap\.Modal = function") {
    Write-Host "✅ Bootstrap Modal constructor override is active" -ForegroundColor Green
} else {
    Write-Host "❌ Bootstrap Modal constructor override NOT found" -ForegroundColor Red
}

# Step 7: Check modal HTML structure
Write-Host "`n7. CHECKING MODAL HTML STRUCTURE..." -ForegroundColor Yellow
$modalContent = Get-Content "RDO-NET8-Migration/RdoApp.Core/Views/Etapa/_NovaMedicaoModal.cshtml" -Raw
if ($modalContent -match 'id="modal-nova-medicao"') {
    Write-Host "✅ Modal has correct ID: modal-nova-medicao" -ForegroundColor Green
} else {
    Write-Host "❌ Modal missing correct ID" -ForegroundColor Red
}

if ($modalContent -match 'id="nova-medicao-status"') {
    Write-Host "✅ Status field has correct ID" -ForegroundColor Green
} else {
    Write-Host "❌ Status field missing correct ID" -ForegroundColor Red
}

if ($modalContent -match 'id="nova-medicao-data"') {
    Write-Host "✅ Date field has correct ID" -ForegroundColor Green
} else {
    Write-Host "❌ Date field missing correct ID" -ForegroundColor Red
}

if ($modalContent -match 'name="nivelDetritos"') {
    Write-Host "✅ Nível de Detritos field found (maps to tar_nr_nivel_bacteria)" -ForegroundColor Green
} else {
    Write-Host "❌ Nível de Detritos field missing" -ForegroundColor Red
}

# Step 8: Check TarefaController SalvarMedicao method
Write-Host "`n8. CHECKING TAREFA CONTROLLER..." -ForegroundColor Yellow
$controllerContent = Get-Content "RDO-NET8-Migration/RdoApp.Core/Controllers/TarefaController.cs" -Raw
if ($controllerContent -match "SalvarMedicao") {
    Write-Host "✅ SalvarMedicao method exists in TarefaController" -ForegroundColor Green
} else {
    Write-Host "❌ SalvarMedicao method NOT found in TarefaController" -ForegroundColor Red
}

if ($controllerContent -match "NivelDetritos.*Bacteria") {
    Write-Host "✅ NivelDetritos to Bacteria mapping found" -ForegroundColor Green
} else {
    Write-Host "❌ NivelDetritos to Bacteria mapping NOT found" -ForegroundColor Red
}

# Step 9: Generate browser diagnostic commands
Write-Host "`n9. BROWSER DIAGNOSTIC COMMANDS..." -ForegroundColor Yellow
Write-Host "Copy and paste these commands in your browser's F12 console:" -ForegroundColor Cyan
Write-Host ""
Write-Host "// 1. Check if modal element exists" -ForegroundColor Gray
Write-Host "console.log('Modal element:', document.getElementById('modal-nova-medicao'));" -ForegroundColor White
Write-Host ""
Write-Host "// 2. Check if smartOpenModal function exists" -ForegroundColor Gray
Write-Host "console.log('smartOpenModal function:', typeof window.smartOpenModal);" -ForegroundColor White
Write-Host ""
Write-Host "// 3. Test Plus button click (replace 123 with actual task ID)" -ForegroundColor Gray
Write-Host "window.smartOpenModal(123, 'Test Task', 2);" -ForegroundColor White
Write-Host ""
Write-Host "// 4. Check for console errors" -ForegroundColor Gray
Write-Host "console.log('Check console for any errors above this line');" -ForegroundColor White
Write-Host ""
Write-Host "// 5. Verify modal fields are populated" -ForegroundColor Gray
Write-Host "console.log('Status field:', document.getElementById('nova-medicao-status').value);" -ForegroundColor White
Write-Host "console.log('Date field:', document.getElementById('nova-medicao-data').value);" -ForegroundColor White
Write-Host "console.log('Task ID field:', document.getElementById('nova-medicao-tarefa-id').value);" -ForegroundColor White

# Step 10: Test URL accessibility
Write-Host "`n10. TESTING URL ACCESSIBILITY..." -ForegroundColor Yellow
$testUrls = @(
    "https://localhost:7001",
    "https://localhost:7001/Auth/Login",
    "https://localhost:7001/Obra/Escolher",
    "https://localhost:7001/Etapa/Cards"
)

foreach ($url in $testUrls) {
    try {
        $response = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
        Write-Host "✅ $url - Status: $($response.StatusCode)" -ForegroundColor Green
    } catch {
        Write-Host "❌ $url - Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Step 11: Summary and next steps
Write-Host "`n11. DIAGNOSTIC SUMMARY" -ForegroundColor Yellow
Write-Host "=====================" -ForegroundColor Yellow
Write-Host ""
Write-Host "NEXT STEPS:" -ForegroundColor Cyan
Write-Host "1. Open browser and navigate to: https://localhost:7001" -ForegroundColor White
Write-Host "2. Login with test credentials" -ForegroundColor White
Write-Host "3. Select an obra (work)" -ForegroundColor White
Write-Host "4. Navigate to Etapas/Tarefas page" -ForegroundColor White
Write-Host "5. Press F12 to open developer console" -ForegroundColor White
Write-Host "6. Click the '+' button on any task card" -ForegroundColor White
Write-Host "7. Check console for errors" -ForegroundColor White
Write-Host "8. Verify modal opens with correct data" -ForegroundColor White
Write-Host ""
Write-Host "IF MODAL DOESN'T OPEN:" -ForegroundColor Red
Write-Host "- Check F12 console for JavaScript errors" -ForegroundColor White
Write-Host "- Verify modal-nova-medicao element exists in DOM" -ForegroundColor White
Write-Host "- Confirm smartOpenModal function is defined" -ForegroundColor White
Write-Host "- Test manual modal trigger with browser console commands above" -ForegroundColor White

Write-Host "`n🎯 DIAGNOSTIC COMPLETE!" -ForegroundColor Green