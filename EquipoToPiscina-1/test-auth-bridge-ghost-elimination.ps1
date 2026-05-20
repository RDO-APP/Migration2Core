# Test Script: Auth Bridge Ghost Elimination
# Tests that the auth bridge script is loaded and legacy diagnostic code is removed

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "AUTH BRIDGE GHOST ELIMINATION TEST" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Test 1: Verify _LayoutSelection.cshtml has auth bridge script
Write-Host "[TEST 1] Checking if auth bridge script is in _LayoutSelection.cshtml..." -ForegroundColor Yellow
$layoutPath = "RDO-NET8-Migration/RdoApp.Core/Views/Shared/_LayoutSelection.cshtml"

if (Test-Path $layoutPath) {
    $layoutContent = Get-Content $layoutPath -Raw
    
    if ($layoutContent -match 'rdo-auth-bridge\.js') {
        Write-Host "✅ PASS: Auth bridge script found in layout" -ForegroundColor Green
    } else {
        Write-Host "❌ FAIL: Auth bridge script NOT found in layout" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "❌ FAIL: Layout file not found" -ForegroundColor Red
    exit 1
}

# Test 2: Verify legacy diagnostic banner is removed
Write-Host "[TEST 2] Checking if legacy diagnostic banner is removed..." -ForegroundColor Yellow

if ($layoutContent -match 'session-survival-diagnostic') {
    Write-Host "❌ FAIL: Legacy diagnostic banner still present" -ForegroundColor Red
    exit 1
} else {
    Write-Host "✅ PASS: Legacy diagnostic banner removed" -ForegroundColor Green
}

# Test 3: Verify blazorHeartbeat script is removed
Write-Host "[TEST 3] Checking if blazorHeartbeat script is removed..." -ForegroundColor Yellow

if ($layoutContent -match 'blazorHeartbeat') {
    Write-Host "❌ FAIL: blazorHeartbeat script still present" -ForegroundColor Red
    exit 1
} else {
    Write-Host "✅ PASS: blazorHeartbeat script removed" -ForegroundColor Green
}

# Test 4: Verify "PHASE 2" comments are removed
Write-Host "[TEST 4] Checking if 'PHASE 2' comments are removed..." -ForegroundColor Yellow

if ($layoutContent -match 'PHASE 2') {
    Write-Host "❌ FAIL: 'PHASE 2' comments still present" -ForegroundColor Red
    exit 1
} else {
    Write-Host "✅ PASS: 'PHASE 2' comments removed" -ForegroundColor Green
}

# Test 5: Verify script load order is correct
Write-Host "[TEST 5] Checking script load order..." -ForegroundColor Yellow

$blazorIndex = $layoutContent.IndexOf('blazor.server.js')
$authBridgeIndex = $layoutContent.IndexOf('rdo-auth-bridge.js')
$loginIndex = $layoutContent.IndexOf('rdo-login.js')

if ($blazorIndex -lt $authBridgeIndex -and $authBridgeIndex -lt $loginIndex) {
    Write-Host "✅ PASS: Script load order is correct (Blazor → Auth Bridge → Login)" -ForegroundColor Green
} else {
    Write-Host "❌ FAIL: Script load order is incorrect" -ForegroundColor Red
    Write-Host "  Blazor index: $blazorIndex" -ForegroundColor Red
    Write-Host "  Auth Bridge index: $authBridgeIndex" -ForegroundColor Red
    Write-Host "  Login index: $loginIndex" -ForegroundColor Red
    exit 1
}

# Test 6: Verify antiforgery token is still present
Write-Host "[TEST 6] Checking if antiforgery token is still present..." -ForegroundColor Yellow

if ($layoutContent -match '@Html\.AntiForgeryToken\(\)') {
    Write-Host "✅ PASS: Antiforgery token still present" -ForegroundColor Green
} else {
    Write-Host "❌ FAIL: Antiforgery token missing" -ForegroundColor Red
    exit 1
}

# Test 7: Verify UnifiedRdoHeader component is still present
Write-Host "[TEST 7] Checking if UnifiedRdoHeader component is still present..." -ForegroundColor Yellow

if ($layoutContent -match 'UnifiedRdoHeader') {
    Write-Host "✅ PASS: UnifiedRdoHeader component still present" -ForegroundColor Green
} else {
    Write-Host "❌ FAIL: UnifiedRdoHeader component missing" -ForegroundColor Red
    exit 1
}

# Test 8: Verify rdoObraCards helper is still present
Write-Host "[TEST 8] Checking if rdoObraCards helper is still present..." -ForegroundColor Yellow

if ($layoutContent -match 'rdoObraCards') {
    Write-Host "✅ PASS: rdoObraCards helper still present" -ForegroundColor Green
} else {
    Write-Host "❌ FAIL: rdoObraCards helper missing" -ForegroundColor Red
    exit 1
}

# Test 9: Verify auth bridge script file exists
Write-Host "[TEST 9] Checking if auth bridge script file exists..." -ForegroundColor Yellow
$authBridgePath = "RDO-NET8-Migration/RdoApp.Core/wwwroot/js/rdo-auth-bridge.js"

if (Test-Path $authBridgePath) {
    Write-Host "✅ PASS: Auth bridge script file exists" -ForegroundColor Green
} else {
    Write-Host "❌ FAIL: Auth bridge script file not found" -ForegroundColor Red
    exit 1
}

# Test 10: Verify auth bridge script has required functions
Write-Host "[TEST 10] Checking if auth bridge script has required functions..." -ForegroundColor Yellow
$authBridgeContent = Get-Content $authBridgePath -Raw

if ($authBridgeContent -match 'submitAuthBridge' -and $authBridgeContent -match 'validateAuthData') {
    Write-Host "✅ PASS: Auth bridge script has required functions" -ForegroundColor Green
} else {
    Write-Host "❌ FAIL: Auth bridge script missing required functions" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "ALL TESTS PASSED! ✅" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "1. Start the application (F5 in Visual Studio or 'dotnet run')" -ForegroundColor White
Write-Host "2. Navigate to /Account/Login" -ForegroundColor White
Write-Host "3. Open F12 Developer Tools → Console" -ForegroundColor White
Write-Host "4. Verify no 'rdoAuth.submitAuthBridge is undefined' errors" -ForegroundColor White
Write-Host "5. Verify no legacy diagnostic banners visible" -ForegroundColor White
Write-Host "6. Test login flow: Enter credentials → Click LOGIN → Verify redirect to /Obra/Escolher" -ForegroundColor White
Write-Host ""
Write-Host "Browser Console Tests:" -ForegroundColor Yellow
Write-Host "  typeof window.rdoAuth              // Should be 'object'" -ForegroundColor White
Write-Host "  typeof window.rdoAuth.submitAuthBridge  // Should be 'function'" -ForegroundColor White
Write-Host "  typeof window.blazorHeartbeat      // Should be 'undefined'" -ForegroundColor White
Write-Host "  typeof window.Blazor               // Should be 'object'" -ForegroundColor White
Write-Host ""
