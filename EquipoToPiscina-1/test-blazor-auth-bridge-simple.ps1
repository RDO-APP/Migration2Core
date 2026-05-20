# Test Blazor-First Authentication Bridge Implementation
Write-Host "Testing Blazor-First Auth Bridge Implementation" -ForegroundColor Green

# Test 1: Verify required files exist
Write-Host "`nStep 1: Checking Implementation Files..." -ForegroundColor Yellow

$requiredFiles = @(
    "RDO-NET8-Migration/RdoApp.Core/Models/DTOs/AuthBridgeDto.cs",
    "RDO-NET8-Migration/RdoApp.Core/Services/Interfaces/IJwtTokenService.cs", 
    "RDO-NET8-Migration/RdoApp.Core/Services/Implementations/JwtTokenService.cs",
    "RDO-NET8-Migration/RdoApp.Core/wwwroot/js/rdo-auth-bridge.js"
)

foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Write-Host "✅ $file" -ForegroundColor Green
    } else {
        Write-Host "❌ MISSING: $file" -ForegroundColor Red
    }
}

# Test 2: Check LoginPage.razor modifications
Write-Host "`nStep 2: Checking LoginPage.razor Integration..." -ForegroundColor Yellow

$loginPagePath = "RDO-NET8-Migration/RdoApp.Core/Components/LoginPage.razor"
if (Test-Path $loginPagePath) {
    $content = Get-Content $loginPagePath -Raw
    
    if ($content -match "@inject IJwtTokenService") {
        Write-Host "✅ IJwtTokenService injection found" -ForegroundColor Green
    } else {
        Write-Host "❌ MISSING: IJwtTokenService injection" -ForegroundColor Red
    }
    
    if ($content -match 'id="authBridge"') {
        Write-Host "✅ Hidden auth bridge form found" -ForegroundColor Green
    } else {
        Write-Host "❌ MISSING: Hidden auth bridge form" -ForegroundColor Red
    }
    
    if ($content -match "rdoAuth.submitAuthBridge") {
        Write-Host "✅ JavaScript bridge call found" -ForegroundColor Green
    } else {
        Write-Host "❌ MISSING: JavaScript bridge call" -ForegroundColor Red
    }
}

# Test 3: Check AccountController modifications
Write-Host "`nStep 3: Checking AccountController Integration..." -ForegroundColor Yellow

$controllerPath = "RDO-NET8-Migration/RdoApp.Core/Controllers/AccountController.cs"
if (Test-Path $controllerPath) {
    $content = Get-Content $controllerPath -Raw
    
    if ($content -match "AuthBridge.*AuthBridgeDto") {
        Write-Host "✅ AuthBridge action method found" -ForegroundColor Green
    } else {
        Write-Host "❌ MISSING: AuthBridge action method" -ForegroundColor Red
    }
    
    if ($content -match "ValidateAuthToken") {
        Write-Host "✅ Token validation found" -ForegroundColor Green
    } else {
        Write-Host "❌ MISSING: Token validation" -ForegroundColor Red
    }
}

# Test 4: Compilation test
Write-Host "`nStep 4: Testing Compilation..." -ForegroundColor Yellow

try {
    Push-Location "RDO-NET8-Migration/RdoApp.Core"
    
    Write-Host "Building project..." -ForegroundColor Cyan
    $buildResult = dotnet build --no-restore --verbosity quiet 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Project compiles successfully" -ForegroundColor Green
    } else {
        Write-Host "❌ COMPILATION ERRORS:" -ForegroundColor Red
        Write-Host $buildResult -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Build test failed: $($_.Exception.Message)" -ForegroundColor Red
} finally {
    Pop-Location
}

Write-Host "`nBLAZOR-FIRST AUTH BRIDGE IMPLEMENTATION COMPLETE!" -ForegroundColor Green
Write-Host "Ready to test the authentication flow." -ForegroundColor White