# Test Nova Medição Implementation
# Tests the Plus Button workflow for water quality measurements

Write-Host "=== TESTING NOVA MEDIÇÃO IMPLEMENTATION ===" -ForegroundColor Green
Write-Host "Date: $(Get-Date)" -ForegroundColor Yellow

# Test 1: Check if controller action exists
Write-Host "`n1. Checking TarefaController.cs for SalvarMedicao action..." -ForegroundColor Cyan
$controllerFile = "RDO-NET8-Migration/RdoApp.Core/Controllers/TarefaController.cs"
if (Test-Path $controllerFile) {
    $controllerContent = Get-Content $controllerFile -Raw
    if ($controllerContent -match "SalvarMedicao") {
        Write-Host "   ✅ SalvarMedicao action found in TarefaController" -ForegroundColor Green
    } else {
        Write-Host "   ❌ SalvarMedicao action NOT found" -ForegroundColor Red
    }
    
    if ($controllerContent -match "GetWaterQualityOptions") {
        Write-Host "   ✅ GetWaterQualityOptions action found" -ForegroundColor Green
    } else {
        Write-Host "   ❌ GetWaterQualityOptions action NOT found" -ForegroundColor Red
    }
} else {
    Write-Host "   ❌ TarefaController.cs not found" -ForegroundColor Red
}

# Test 2: Check if ViewModel exists
Write-Host "`n2. Checking NovaMedicaoViewModel..." -ForegroundColor Cyan
$viewModelFile = "RDO-NET8-Migration/RdoApp.Core/Models/ViewModels/NovaMedicaoViewModel.cs"
if (Test-Path $viewModelFile) {
    Write-Host "   ✅ NovaMedicaoViewModel.cs exists" -ForegroundColor Green
    $viewModelContent = Get-Content $viewModelFile -Raw
    if ($viewModelContent -match "NivelCloro.*NivelPH.*NivelAlcalinidade") {
        Write-Host "   ✅ Water quality properties found" -ForegroundColor Green
    }
} else {
    Write-Host "   ❌ NovaMedicaoViewModel.cs not found" -ForegroundColor Red
}

# Test 3: Check if modal has correct Gilberto's options
Write-Host "`n3. Checking Nova Medição Modal..." -ForegroundColor Cyan
$modalFile = "RDO-NET8-Migration/RdoApp.Core/Views/Etapa/_NovaMedicaoModal.cshtml"
if (Test-Path $modalFile) {
    Write-Host "   ✅ _NovaMedicaoModal.cshtml exists" -ForegroundColor Green
    $modalContent = Get-Content $modalFile -Raw
    
    # Check for Gilberto's original water quality options
    if ($modalContent -match "0 ppm.*0,5 < 1,0.*> 3,0") {
        Write-Host "   ✅ Gilberto's Cloro options found" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Gilberto's Cloro options NOT found" -ForegroundColor Red
    }
    
    if ($modalContent -match "< 7.0.*7.0 < 7.2.*> 7.8") {
        Write-Host "   ✅ Gilberto's PH options found" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Gilberto's PH options NOT found" -ForegroundColor Red
    }
    
    if ($modalContent -match "< 70.*70 < 80.*> 140") {
        Write-Host "   ✅ Gilberto's Alcalinidade options found" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Gilberto's Alcalinidade options NOT found" -ForegroundColor Red
    }
    
    # Check for JavaScript functions
    if ($modalContent -match "function novaMedicao") {
        Write-Host "   ✅ novaMedicao JavaScript function found" -ForegroundColor Green
    } else {
        Write-Host "   ❌ novaMedicao JavaScript function NOT found" -ForegroundColor Red
    }
    
    if ($modalContent -match "function salvarNovaMedicao") {
        Write-Host "   ✅ salvarNovaMedicao JavaScript function found" -ForegroundColor Green
    } else {
        Write-Host "   ❌ salvarNovaMedicao JavaScript function NOT found" -ForegroundColor Red
    }
} else {
    Write-Host "   ❌ _NovaMedicaoModal.cshtml not found" -ForegroundColor Red
}

# Test 4: Check TaskCard Plus button integration
Write-Host "`n4. Checking TaskCard Plus Button Integration..." -ForegroundColor Cyan
$taskCardFile = "RDO-NET8-Migration/RdoApp.Core/Components/TaskCard.razor"
if (Test-Path $taskCardFile) {
    Write-Host "   ✅ TaskCard.razor exists" -ForegroundColor Green
    $taskCardContent = Get-Content $taskCardFile -Raw
    
    if ($taskCardContent -match "AddMeasurement.*novaMedicao") {
        Write-Host "   ✅ Plus button calls novaMedicao function" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Plus button integration NOT found" -ForegroundColor Red
    }
} else {
    Write-Host "   ❌ TaskCard.razor not found" -ForegroundColor Red
}

# Test 5: Check Service Layer
Write-Host "`n5. Checking TarefaService Water Quality Methods..." -ForegroundColor Cyan
$serviceFile = "RDO-NET8-Migration/RdoApp.Core/Services/Implementations/TarefaService.cs"
if (Test-Path $serviceFile) {
    Write-Host "   ✅ TarefaService.cs exists" -ForegroundColor Green
    $serviceContent = Get-Content $serviceFile -Raw
    
    if ($serviceContent -match "SaveWaterQualityMeasurementAsync") {
        Write-Host "   ✅ SaveWaterQualityMeasurementAsync method found" -ForegroundColor Green
    }
    
    if ($serviceContent -match "GetCloroOptionsAsync.*GetPHOptionsAsync.*GetAlcalinidadeOptionsAsync") {
        Write-Host "   ✅ Water quality dropdown methods found" -ForegroundColor Green
    }
} else {
    Write-Host "   ❌ TarefaService.cs not found" -ForegroundColor Red
}

# Test 6: Check DTOs
Write-Host "`n6. Checking Water Quality DTOs..." -ForegroundColor Cyan
$waterQualityDto = "RDO-NET8-Migration/RdoApp.Core/Models/DTOs/WaterQualityParametersDto.cs"
$dropdownDto = "RDO-NET8-Migration/RdoApp.Core/Models/DTOs/WaterQualityDropdownDto.cs"

if (Test-Path $waterQualityDto) {
    Write-Host "   ✅ WaterQualityParametersDto.cs exists" -ForegroundColor Green
} else {
    Write-Host "   ❌ WaterQualityParametersDto.cs not found" -ForegroundColor Red
}

if (Test-Path $dropdownDto) {
    Write-Host "   ✅ WaterQualityDropdownDto.cs exists" -ForegroundColor Green
} else {
    Write-Host "   ❌ WaterQualityDropdownDto.cs not found" -ForegroundColor Red
}

Write-Host "`n=== NOVA MEDIÇÃO IMPLEMENTATION TEST COMPLETE ===" -ForegroundColor Green
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "1. Compile the project to check for errors" -ForegroundColor White
Write-Host "2. Test the Plus button on TaskCard" -ForegroundColor White
Write-Host "3. Verify modal opens with correct water quality options" -ForegroundColor White
Write-Host "4. Test saving a measurement" -ForegroundColor White
Write-Host "5. Verify task status and water quality data is updated" -ForegroundColor White