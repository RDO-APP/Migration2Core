# Test Anti-Forgery Token Fix
# Verifies that LoginPage.razor properly generates and includes anti-forgery token

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "ANTI-FORGERY TOKEN FIX VERIFICATION" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$testsPassed = 0
$testsFailed = 0

# Test 1: Check IAntiforgery injection
Write-Host "TEST 1: Verify IAntiforgery service injection..." -ForegroundColor Yellow
$loginPagePath = "RDO-NET8-Migration/RdoApp.Core/Components/LoginPage.razor"
$content = Get-Content $loginPagePath -Raw
if ($content -match '@inject Microsoft\.AspNetCore\.Antiforgery\.IAntiforgery') {
    Write-Host "  ✅ PASS: IAntiforgery service injected" -ForegroundColor Green
    $testsPassed++
} else {
    Write-Host "  ❌ FAIL: IAntiforgery service NOT injected" -ForegroundColor Red
    $testsFailed++
}

# Test 2: Check IHttpContextAccessor injection
Write-Host "TEST 2: Verify IHttpContextAccessor injection..." -ForegroundColor Yellow
if ($content -match '@inject IHttpContextAccessor') {
    Write-Host "  ✅ PASS: IHttpContextAccessor injected" -ForegroundColor Green
    $testsPassed++
} else {
    Write-Host "  ❌ FAIL: IHttpContextAccessor NOT injected" -ForegroundColor Red
    $testsFailed++
}

# Test 3: Check antiForgeryToken field
Write-Host "TEST 3: Verify antiForgeryToken field exists..." -ForegroundColor Yellow
if ($content -match 'private string antiForgeryToken') {
    Write-Host "  ✅ PASS: antiForgeryToken field declared" -ForegroundColor Green
    $testsPassed++
} else {
    Write-Host "  ❌ FAIL: antiForgeryToken field NOT declared" -ForegroundColor Red
    $testsFailed++
}

# Test 4: Check OnInitialized method
Write-Host "TEST 4: Verify OnInitialized method exists..." -ForegroundColor Yellow
if ($content -match 'protected override void OnInitialized\(\)') {
    Write-Host "  ✅ PASS: OnInitialized method exists" -ForegroundColor Green
    $testsPassed++
} else {
    Write-Host "  ❌ FAIL: OnInitialized method NOT found" -ForegroundColor Red
    $testsFailed++
}

# Test 5: Check token generation logic
Write-Host "TEST 5: Verify token generation logic..." -ForegroundColor Yellow
if ($content -match 'Antiforgery\.GetAndStoreTokens') {
    Write-Host "  ✅ PASS: Token generation logic present" -ForegroundColor Green
    $testsPassed++
} else {
    Write-Host "  ❌ FAIL: Token generation logic NOT found" -ForegroundColor Red
    $testsFailed++
}

# Test 6: Check hidden input field
Write-Host "TEST 6: Verify hidden input field in form..." -ForegroundColor Yellow
if ($content -match '<input type="hidden" name="__RequestVerificationToken"') {
    Write-Host "  ✅ PASS: Hidden input field exists" -ForegroundColor Green
    $testsPassed++
} else {
    Write-Host "  ❌ FAIL: Hidden input field NOT found" -ForegroundColor Red
    $testsFailed++
}

# Test 7: Check token value binding
Write-Host "TEST 7: Verify token value binding..." -ForegroundColor Yellow
if ($content -match 'value="@antiForgeryToken"') {
    Write-Host "  ✅ PASS: Token value properly bound" -ForegroundColor Green
    $testsPassed++
} else {
    Write-Host "  ❌ FAIL: Token value NOT bound" -ForegroundColor Red
    $testsFailed++
}

# Test 8: Check form method and action
Write-Host "TEST 8: Verify form method and action..." -ForegroundColor Yellow
if ($content -match '<form method="post" action="/Account/Login">') {
    Write-Host "  ✅ PASS: Form method and action correct" -ForegroundColor Green
    $testsPassed++
} else {
    Write-Host "  ❌ FAIL: Form method or action incorrect" -ForegroundColor Red
    $testsFailed++
}

# Test 9: Check AccountController has ValidateAntiForgeryToken
Write-Host "TEST 9: Verify AccountController has ValidateAntiForgeryToken..." -ForegroundColor Yellow
$controllerPath = "RDO-NET8-Migration/RdoApp.Core/Controllers/AccountController.cs"
$controllerContent = Get-Content $controllerPath -Raw
if ($controllerContent -match '\[ValidateAntiForgeryToken\]') {
    Write-Host "  ✅ PASS: ValidateAntiForgeryToken attribute present" -ForegroundColor Green
    $testsPassed++
} else {
    Write-Host "  ❌ FAIL: ValidateAntiForgeryToken attribute NOT found" -ForegroundColor Red
    $testsFailed++
}

# Test 10: Build verification
Write-Host "TEST 10: Verify project builds successfully..." -ForegroundColor Yellow
Push-Location "RDO-NET8-Migration/RdoApp.Core"
$buildOutput = dotnet build --no-restore 2>&1 | Out-String
Pop-Location
if ($buildOutput -match "Build succeeded") {
    Write-Host "  ✅ PASS: Project builds successfully" -ForegroundColor Green
    $testsPassed++
} else {
    Write-Host "  ❌ FAIL: Build errors detected" -ForegroundColor Red
    $testsFailed++
}

# Test 11: Check no EditForm remnants
Write-Host "TEST 11: Verify no EditForm remnants..." -ForegroundColor Yellow
if ($content -notmatch '<EditForm') {
    Write-Host "  ✅ PASS: No EditForm elements found" -ForegroundColor Green
    $testsPassed++
} else {
    Write-Host "  ❌ FAIL: EditForm elements still present" -ForegroundColor Red
    $testsFailed++
}

# Test 12: Check no Blazor data binding on form inputs
Write-Host "TEST 12: Verify no Blazor data binding on inputs..." -ForegroundColor Yellow
if ($content -notmatch '@bind-Value') {
    Write-Host "  ✅ PASS: No Blazor data binding found" -ForegroundColor Green
    $testsPassed++
} else {
    Write-Host "  ❌ FAIL: Blazor data binding still present" -ForegroundColor Red
    $testsFailed++
}

# Test 13: Check input names match LoginDto
Write-Host "TEST 13: Verify input names match LoginDto properties..." -ForegroundColor Yellow
$hasCpf = $content -match 'name="Cpf"'
$hasSenha = $content -match 'name="Senha"'
$hasLembrarMe = $content -match 'name="LembrarMe"'
if ($hasCpf -and $hasSenha -and $hasLembrarMe) {
    Write-Host "  ✅ PASS: All input names match LoginDto" -ForegroundColor Green
    $testsPassed++
} else {
    Write-Host "  ❌ FAIL: Input names don't match LoginDto" -ForegroundColor Red
    $testsFailed++
}

# Test 14: Check submit button type
Write-Host "TEST 14: Verify submit button type..." -ForegroundColor Yellow
if ($content -match '<button type="submit"') {
    Write-Host "  ✅ PASS: Submit button has correct type" -ForegroundColor Green
    $testsPassed++
} else {
    Write-Host "  ❌ FAIL: Submit button type incorrect" -ForegroundColor Red
    $testsFailed++
}

# Test 15: Check no JavaScript form submission
Write-Host "TEST 15: Verify no JavaScript form submission..." -ForegroundColor Yellow
if ($content -notmatch 'form\.submit\(\)' -and $content -notmatch 'submitAuthBridge') {
    Write-Host "  ✅ PASS: No JavaScript form submission found" -ForegroundColor Green
    $testsPassed++
} else {
    Write-Host "  ❌ FAIL: JavaScript form submission still present" -ForegroundColor Red
    $testsFailed++
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "TEST SUMMARY" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Tests Passed: $testsPassed" -ForegroundColor Green
Write-Host "Tests Failed: $testsFailed" -ForegroundColor $(if ($testsFailed -eq 0) { "Green" } else { "Red" })
Write-Host "Total Tests: $($testsPassed + $testsFailed)" -ForegroundColor Cyan
Write-Host ""

if ($testsFailed -eq 0) {
    Write-Host "✅ ALL TESTS PASSED - Anti-forgery token fix is complete!" -ForegroundColor Green
    Write-Host ""
    Write-Host "NEXT STEPS:" -ForegroundColor Yellow
    Write-Host "1. Start the application (F5 in Visual Studio or 'dotnet run')" -ForegroundColor White
    Write-Host "2. Navigate to https://localhost:7201/" -ForegroundColor White
    Write-Host "3. Enter CPF: 123.456.789-00" -ForegroundColor White
    Write-Host "4. Enter Password: senha123" -ForegroundColor White
    Write-Host "5. Click 'ACESSAR' button" -ForegroundColor White
    Write-Host "6. Verify successful login and redirect to /Obra/Escolher" -ForegroundColor White
    Write-Host ""
    Write-Host "EXPECTED BEHAVIOR:" -ForegroundColor Yellow
    Write-Host "- Form submits without 400 Bad Request error" -ForegroundColor White
    Write-Host "- User is authenticated" -ForegroundColor White
    Write-Host "- Browser redirects to work selection page" -ForegroundColor White
    Write-Host "- No blank page or console errors" -ForegroundColor White
} else {
    Write-Host "❌ SOME TESTS FAILED - Review the failures above" -ForegroundColor Red
}

Write-Host ""
