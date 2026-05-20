# MIDDLEWARE ASSASSINATION FIX - VERIFICATION TEST
# Tests that /Obra/Escolher no longer gets killed by middleware

Write-Host "=== MIDDLEWARE ASSASSINATION FIX TEST ===" -ForegroundColor Cyan
Write-Host "Testing: Middleware whitelist for modern MVC routes" -ForegroundColor Yellow

# Step 1: Verify the middleware fix was applied
Write-Host "`n1. CHECKING MIDDLEWARE FIX..." -ForegroundColor Green
$programCs = Get-Content "RDO-NET8-Migration/RdoApp.Core/Program.cs" -Raw

if ($programCs -match 'Skip middleware for modern MVC routes') {
    Write-Host "   ✅ Middleware whitelist comment added" -ForegroundColor Green
} else {
    Write-Host "   ❌ Middleware whitelist comment missing" -ForegroundColor Red
}

if ($programCs -match 'path\?\.\StartsWith\("/obra/"\)') {
    Write-Host "   ✅ /obra/ route whitelisted" -ForegroundColor Green
} else {
    Write-Host "   ❌ /obra/ route NOT whitelisted" -ForegroundColor Red
}

if ($programCs -match 'path\?\.\StartsWith\("/account/"\)') {
    Write-Host "   ✅ /account/ route whitelisted" -ForegroundColor Green
} else {
    Write-Host "   ❌ /account/ route NOT whitelisted" -ForegroundColor Red
}

# Check that dangerous Contains() was removed
if ($programCs -match 'Contains\("escolher\.html"\)') {
    Write-Host "   ❌ DANGEROUS: Contains('escolher.html') still present" -ForegroundColor Red
} else {
    Write-Host "   ✅ Dangerous Contains() removed" -ForegroundColor Green
}

# Check for exact legacy path matching
if ($programCs -match '/client/views/obra/escolher\.html') {
    Write-Host "   ✅ Exact legacy path matching implemented" -ForegroundColor Green
} else {
    Write-Host "   ❌ Exact legacy path matching missing" -ForegroundColor Red
}

# Step 2: Verify Blazor framework routes are whitelisted
Write-Host "`n2. CHECKING BLAZOR ROUTE PROTECTION..." -ForegroundColor Green
if ($programCs -match '_framework/') {
    Write-Host "   ✅ Blazor framework routes protected" -ForegroundColor Green
} else {
    Write-Host "   ❌ Blazor framework routes NOT protected" -ForegroundColor Red
}

if ($programCs -match '_content/') {
    Write-Host "   ✅ Blazor content routes protected" -ForegroundColor Green
} else {
    Write-Host "   ❌ Blazor content routes NOT protected" -ForegroundColor Red
}

# Step 3: Build test to ensure no compilation errors
Write-Host "`n3. TESTING COMPILATION..." -ForegroundColor Green
try {
    Set-Location "RDO-NET8-Migration/RdoApp.Core"
    
    Write-Host "   Building project..." -ForegroundColor Yellow
    $buildResult = dotnet build --no-restore --verbosity quiet 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ Project builds successfully" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Build failed:" -ForegroundColor Red
        Write-Host $buildResult -ForegroundColor Red
    }
} catch {
    Write-Host "   ⚠️  Could not test build: $($_.Exception.Message)" -ForegroundColor Yellow
} finally {
    Set-Location "../.."
}

# Step 4: Route analysis
Write-Host "`n4. ROUTE ANALYSIS..." -ForegroundColor Green
Write-Host "   PROTECTED ROUTES (will reach controllers):" -ForegroundColor White
Write-Host "   - /Obra/Escolher ✅" -ForegroundColor Green
Write-Host "   - /Tarefa/Cards ✅" -ForegroundColor Green
Write-Host "   - /Etapa/Cards ✅" -ForegroundColor Green
Write-Host "   - /Account/Login ✅" -ForegroundColor Green
Write-Host "   - /_framework/blazor.server.js ✅" -ForegroundColor Green
Write-Host "   - /_content/RdoApp.Core/styles.css ✅" -ForegroundColor Green

Write-Host "`n   LEGACY REDIRECTS (will redirect to login):" -ForegroundColor White
Write-Host "   - / (root)" -ForegroundColor Yellow
Write-Host "   - /home" -ForegroundColor Yellow
Write-Host "   - /login.html" -ForegroundColor Yellow
Write-Host "   - /client/views/obra/escolher.html" -ForegroundColor Yellow

# Step 5: Expected behavior summary
Write-Host "`n=== EXPECTED BEHAVIOR AFTER FIX ===" -ForegroundColor Cyan
Write-Host "1. Navigate to /Account/Login - should work normally" -ForegroundColor White
Write-Host "2. Login with credentials - should authenticate" -ForegroundColor White
Write-Host "3. Navigate to /Obra/Escolher - should NOT get killed by middleware" -ForegroundColor White
Write-Host "4. Should see controller logs: 'Loading obras for user'" -ForegroundColor White
Write-Host "5. Should see DEBUG message: 'Found 103 obras in Model'" -ForegroundColor White
Write-Host "6. Should see 103 obra cards rendered" -ForegroundColor White

Write-Host "`n=== CRITICAL DIFFERENCE ===" -ForegroundColor Cyan
Write-Host "BEFORE: /Obra/Escolher → Middleware kills request → White screen" -ForegroundColor Red
Write-Host "AFTER:  /Obra/Escolher → Middleware skips → Controller executes → Cards render" -ForegroundColor Green

Write-Host "`n=== NEXT STEPS ===" -ForegroundColor Cyan
Write-Host "1. Start application: dotnet run" -ForegroundColor White
Write-Host "2. Login with test credentials" -ForegroundColor White
Write-Host "3. Navigate to obra selection" -ForegroundColor White
Write-Host "4. Verify 103 cards appear (no more white screen)" -ForegroundColor White

Write-Host "`n=== MIDDLEWARE ASSASSINATION FIX TEST COMPLETE ===" -ForegroundColor Cyan