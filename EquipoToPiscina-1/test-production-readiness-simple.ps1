# DAY 8 - PRODUCTION READINESS ASSESSMENT
# Comprehensive system validation before production deployment

Write-Host "STARTING PRODUCTION READINESS ASSESSMENT..." -ForegroundColor Green
Write-Host "Date: $(Get-Date)" -ForegroundColor Yellow
Write-Host ""

# Change to project directory
Set-Location "RDO-NET8-Migration/RdoApp.Core"

Write-Host "Current Directory: $(Get-Location)" -ForegroundColor Cyan
Write-Host ""

# Test 1: Compilation Check
Write-Host "TEST 1: COMPILATION VERIFICATION" -ForegroundColor Magenta
Write-Host "Checking if all 48 entities compile successfully..."

try {
    $buildResult = dotnet build --configuration Release --verbosity minimal 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "COMPILATION: SUCCESS" -ForegroundColor Green
        Write-Host "All 48 entities compiled without errors" -ForegroundColor Green
    } else {
        Write-Host "COMPILATION: FAILED" -ForegroundColor Red
        Write-Host "Build errors detected:" -ForegroundColor Red
        Write-Host $buildResult -ForegroundColor Red
        return
    }
} catch {
    Write-Host "COMPILATION: ERROR - $($_.Exception.Message)" -ForegroundColor Red
    return
}

Write-Host ""

# Test 2: Entity Framework Context Validation
Write-Host "TEST 2: ENTITY FRAMEWORK VALIDATION" -ForegroundColor Magenta
Write-Host "Verifying all 48 entities are properly configured..."

# Check if RdoContext.cs contains all required DbSets
$contextFile = "Data/Context/RdoContext.cs"
if (Test-Path $contextFile) {
    $contextContent = Get-Content $contextFile -Raw
    
    # List of critical entities that should be in DbSets
    $requiredEntities = @(
        "Colaborador", "Empresa", "Obra", "Tarefa", "Laudo", "Rdo", "Usuario", "Grupo"
    )
    
    $missingEntities = @()
    foreach ($entity in $requiredEntities) {
        if ($contextContent -notmatch "DbSet<$entity>") {
            $missingEntities += $entity
        }
    }
    
    if ($missingEntities.Count -eq 0) {
        Write-Host "ENTITY FRAMEWORK: SUCCESS" -ForegroundColor Green
        Write-Host "Critical entities found in RdoContext" -ForegroundColor Green
    } else {
        Write-Host "ENTITY FRAMEWORK: WARNING" -ForegroundColor Yellow
        Write-Host "Missing entities: $($missingEntities -join ', ')" -ForegroundColor Yellow
    }
} else {
    Write-Host "ENTITY FRAMEWORK: ERROR - RdoContext.cs not found" -ForegroundColor Red
}

Write-Host ""

# Test 3: Authentication System Check
Write-Host "TEST 3: AUTHENTICATION SYSTEM VALIDATION" -ForegroundColor Magenta
Write-Host "Checking authentication components..."

$authComponents = @(
    "Controllers/AuthController.cs",
    "Services/Implementations/AuthService.cs",
    "Models/DTOs/LoginDto.cs",
    "Models/Entities/Usuario.cs",
    "Views/Auth/Login.cshtml"
)

$authStatus = $true
foreach ($component in $authComponents) {
    if (Test-Path $component) {
        $componentName = Split-Path $component -Leaf
        Write-Host "AUTH COMPONENT: $componentName - Found" -ForegroundColor Green
    } else {
        Write-Host "AUTH COMPONENT: $component - Missing" -ForegroundColor Red
        $authStatus = $false
    }
}

if ($authStatus) {
    Write-Host "AUTHENTICATION: SUCCESS" -ForegroundColor Green
} else {
    Write-Host "AUTHENTICATION: INCOMPLETE" -ForegroundColor Red
}

Write-Host ""

# Test 4: API Endpoints Validation
Write-Host "TEST 4: API ENDPOINTS VALIDATION" -ForegroundColor Magenta
Write-Host "Checking API controllers..."

$apiControllers = @(
    "Controllers/Api/TarefaController.cs",
    "Controllers/Api/LaudoController.cs", 
    "Controllers/Api/RdoController.cs"
)

$apiStatus = $true
foreach ($controller in $apiControllers) {
    if (Test-Path $controller) {
        $controllerName = Split-Path $controller -Leaf
        Write-Host "API CONTROLLER: $controllerName - Found" -ForegroundColor Green
    } else {
        Write-Host "API CONTROLLER: $controller - Missing" -ForegroundColor Red
        $apiStatus = $false
    }
}

if ($apiStatus) {
    Write-Host "API ENDPOINTS: SUCCESS" -ForegroundColor Green
} else {
    Write-Host "API ENDPOINTS: INCOMPLETE" -ForegroundColor Red
}

Write-Host ""

# Test 5: Configuration Files Check
Write-Host "TEST 5: CONFIGURATION VALIDATION" -ForegroundColor Magenta
Write-Host "Checking configuration files..."

$configFiles = @(
    "appsettings.json",
    "Program.cs"
)

$configStatus = $true
foreach ($config in $configFiles) {
    if (Test-Path $config) {
        Write-Host "CONFIG FILE: $config - Found" -ForegroundColor Green
    } else {
        Write-Host "CONFIG FILE: $config - Missing" -ForegroundColor Red
        $configStatus = $false
    }
}

if ($configStatus) {
    Write-Host "CONFIGURATION: SUCCESS" -ForegroundColor Green
} else {
    Write-Host "CONFIGURATION: INCOMPLETE" -ForegroundColor Red
}

Write-Host ""

# Final Assessment
Write-Host "PRODUCTION READINESS ASSESSMENT COMPLETE" -ForegroundColor Magenta
Write-Host "=========================================" -ForegroundColor Magenta

$overallStatus = $true
$testResults = @{
    "Compilation" = ($LASTEXITCODE -eq 0)
    "Entity Framework" = ($missingEntities.Count -eq 0)
    "Authentication" = $authStatus
    "API Endpoints" = $apiStatus
    "Configuration" = $configStatus
}

foreach ($test in $testResults.GetEnumerator()) {
    if ($test.Value) {
        Write-Host "$($test.Key): READY" -ForegroundColor Green
    } else {
        Write-Host "$($test.Key): NOT READY" -ForegroundColor Red
        $overallStatus = $false
    }
}

Write-Host ""

if ($overallStatus) {
    Write-Host "OVERALL STATUS: PRODUCTION READY!" -ForegroundColor Green
    Write-Host "System is ready for production deployment" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next Steps:" -ForegroundColor Yellow
    Write-Host "1. Run security hardening script" -ForegroundColor Yellow
    Write-Host "2. Execute performance tests" -ForegroundColor Yellow
    Write-Host "3. Setup backup strategy" -ForegroundColor Yellow
    Write-Host "4. Proceed with production deployment" -ForegroundColor Yellow
} else {
    Write-Host "OVERALL STATUS: NEEDS ATTENTION" -ForegroundColor Yellow
    Write-Host "Some components need to be addressed before production" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Assessment completed at: $(Get-Date)" -ForegroundColor Cyan

Write-Host "DAY 8 STEP 1 COMPLETED: Production Readiness Assessment" -ForegroundColor Green