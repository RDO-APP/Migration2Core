# TEST ASSET PATH CRISIS - FINAL FIX VERIFICATION
# Tests the complete fix for 404 errors and header rendering

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "ASSET PATH CRISIS - FINAL FIX TEST" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Verify files exist
Write-Host "STEP 1: Verifying Asset Files Exist..." -ForegroundColor Yellow
Write-Host ""

$assets = @(
    "RDO-NET8-Migration/RdoApp.Core/wwwroot/css/fontello.css",
    "RDO-NET8-Migration/RdoApp.Core/wwwroot/fonts/fontello.woff",
    "RDO-NET8-Migration/RdoApp.Core/wwwroot/fonts/fontello.woff2",
    "RDO-NET8-Migration/RdoApp.Core/wwwroot/Assets/images/user.png",
    "RDO-NET8-Migration/RdoApp.Core/wwwroot/images/logo.png",
    "RDO-NET8-Migration/RdoApp.Core/wwwroot/css/rdo-unified-theme.css",
    "RDO-NET8-Migration/RdoApp.Core/wwwroot/css/escolher-legacy.css"
)

$allExist = $true
foreach ($asset in $assets) {
    if (Test-Path $asset) {
        Write-Host "  ✅ $asset" -ForegroundColor Green
    } else {
        Write-Host "  ❌ $asset - MISSING!" -ForegroundColor Red
        $allExist = $false
    }
}

Write-Host ""

if (-not $allExist) {
    Write-Host "❌ CRITICAL: Some assets are missing!" -ForegroundColor Red
    exit 1
}

# Step 2: Verify Escolher.cshtml has header
Write-Host "STEP 2: Verifying Escolher.cshtml Has Header..." -ForegroundColor Yellow
Write-Host ""

$escolherContent = Get-Content "RDO-NET8-Migration/RdoApp.Core/Views/Obra/Escolher.cshtml" -Raw

$checks = @{
    "UnifiedRdoHeader component" = $escolherContent -match "UnifiedRdoHeader"
    "fontello.css with asp-append-version" = $escolherContent -match "fontello\.css.*asp-append-version"
    "rdo-unified-theme.css" = $escolherContent -match "rdo-unified-theme\.css"
    "AntiForgeryToken" = $escolherContent -match "@Html\.AntiForgeryToken\(\)"
}

$allChecks = $true
foreach ($check in $checks.GetEnumerator()) {
    if ($check.Value) {
        Write-Host "  ✅ $($check.Key)" -ForegroundColor Green
    } else {
        Write-Host "  ❌ $($check.Key) - MISSING!" -ForegroundColor Red
        $allChecks = $false
    }
}

Write-Host ""

if (-not $allChecks) {
    Write-Host "❌ CRITICAL: Escolher.cshtml is missing required elements!" -ForegroundColor Red
    exit 1
}

# Step 3: Verify Program.cs has static file middleware
Write-Host "STEP 3: Verifying Static File Middleware..." -ForegroundColor Yellow
Write-Host ""

$programContent = Get-Content "RDO-NET8-Migration/RdoApp.Core/Program.cs" -Raw

if ($programContent -match "UseStaticFiles") {
    Write-Host "  ✅ UseStaticFiles middleware configured" -ForegroundColor Green
} else {
    Write-Host "  ❌ UseStaticFiles middleware MISSING!" -ForegroundColor Red
    exit 1
}

if ($programContent -match "FileExtensionContentTypeProvider") {
    Write-Host "  ✅ MIME type provider configured" -ForegroundColor Green
} else {
    Write-Host "  ⚠️  MIME type provider not found (may be optional)" -ForegroundColor Yellow
}

Write-Host ""

# Step 4: Build the project
Write-Host "STEP 4: Building Project..." -ForegroundColor Yellow
Write-Host ""

Push-Location "RDO-NET8-Migration/RdoApp.Core"

$buildOutput = dotnet build --no-restore 2>&1
$buildSuccess = $LASTEXITCODE -eq 0

Pop-Location

if ($buildSuccess) {
    Write-Host "  ✅ Build successful" -ForegroundColor Green
} else {
    Write-Host "  ❌ Build failed!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Build Output:" -ForegroundColor Yellow
    Write-Host $buildOutput
    exit 1
}

Write-Host ""

# Step 5: Instructions for manual testing
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "MANUAL TESTING REQUIRED" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "✅ All automated checks passed!" -ForegroundColor Green
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Start the application:" -ForegroundColor White
Write-Host "   cd RDO-NET8-Migration/RdoApp.Core" -ForegroundColor Gray
Write-Host "   dotnet run" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Open browser and navigate to:" -ForegroundColor White
Write-Host "   https://localhost:5001/Account/Login" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Login with test credentials:" -ForegroundColor White
Write-Host "   CPF: 12345678900" -ForegroundColor Gray
Write-Host "   Password: senha123" -ForegroundColor Gray
Write-Host ""
Write-Host "4. Verify the following:" -ForegroundColor White
Write-Host "   - Header appears horizontally with dark blue background" -ForegroundColor Gray
Write-Host "   - Logo icon displays correctly" -ForegroundColor Gray
Write-Host "   - Action toolbar icons visible (Chart, Plus, etc.)" -ForegroundColor Gray
Write-Host "   - User avatar displays (no 404 for user.png)" -ForegroundColor Gray
Write-Host "   - 103 obra cards render in grid layout" -ForegroundColor Gray
Write-Host "   - Card icons display correctly" -ForegroundColor Gray
Write-Host "   - Progress bars show correct colors" -ForegroundColor Gray
Write-Host "   - No 404 errors in F12 console" -ForegroundColor Gray
Write-Host ""
Write-Host "5. Open F12 Developer Tools:" -ForegroundColor White
Write-Host "   - Check Console tab for errors" -ForegroundColor Gray
Write-Host "   - Check Network tab for 404 responses" -ForegroundColor Gray
Write-Host "   - Verify fontello.css loads (Status 200)" -ForegroundColor Gray
Write-Host "   - Verify user.png loads (Status 200)" -ForegroundColor Gray
Write-Host ""
Write-Host "6. If you see 404 errors:" -ForegroundColor White
Write-Host "   - Clear browser cache (Ctrl+Shift+Delete)" -ForegroundColor Gray
Write-Host "   - Hard refresh (Ctrl+F5)" -ForegroundColor Gray
Write-Host "   - Close and reopen browser" -ForegroundColor Gray
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "TEST COMPLETE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
