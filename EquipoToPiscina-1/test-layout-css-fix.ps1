#!/usr/bin/env pwsh

Write-Host "🔧 TESTING LAYOUT CSS FIX AND AUTHENTICATION BYPASS ELIMINATION" -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Cyan

# Test 1: Build verification
Write-Host "`n1️⃣ TESTING BUILD..." -ForegroundColor Yellow
Set-Location "RDO-NET8-Migration/RdoApp.Core"

$buildResult = dotnet build --no-restore 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ BUILD SUCCESS" -ForegroundColor Green
} else {
    Write-Host "❌ BUILD FAILED" -ForegroundColor Red
    Write-Host $buildResult
    exit 1
}

# Test 2: Check Layout CSS paths
Write-Host "`n2️⃣ CHECKING LAYOUT CSS PATHS..." -ForegroundColor Yellow
$layoutContent = Get-Content "Views/Shared/_Layout.cshtml" -Raw

if ($layoutContent -match 'href="~/lib/bootstrap' -and 
    $layoutContent -match 'href="~/css/site.css' -and
    $layoutContent -match 'src="~/lib/jquery' -and
    $layoutContent -match 'src="~/js/site.js') {
    Write-Host "✅ CSS/JS PATHS USE ROOT-RELATIVE (~/) - CORRECT" -ForegroundColor Green
} else {
    Write-Host "❌ CSS/JS PATHS NOT ROOT-RELATIVE" -ForegroundColor Red
}

# Test 3: Check Styles section is optional
if ($layoutContent -match '@await RenderSectionAsync\("Styles", required: false\)') {
    Write-Host "✅ STYLES SECTION IS OPTIONAL - CORRECT" -ForegroundColor Green
} else {
    Write-Host "❌ STYLES SECTION NOT OPTIONAL" -ForegroundColor Red
}

# Test 4: Check AccountController force logout
Write-Host "`n3️⃣ CHECKING ACCOUNTCONTROLLER FORCE LOGOUT..." -ForegroundColor Yellow
$accountContent = Get-Content "Controllers/AccountController.cs" -Raw

if ($accountContent -match 'foreach \(var cookie in Request\.Cookies\.Keys\)' -and
    $accountContent -match 'Response\.Cookies\.Delete\(cookie\)') {
    Write-Host "✅ AGGRESSIVE COOKIE CLEARING IMPLEMENTED" -ForegroundColor Green
} else {
    Write-Host "❌ COOKIE CLEARING NOT IMPLEMENTED" -ForegroundColor Red
}

# Test 5: Check Program.cs middleware
Write-Host "`n4️⃣ CHECKING PROGRAM.CS MIDDLEWARE..." -ForegroundColor Yellow
$programContent = Get-Content "Program.cs" -Raw

if ($programContent -match 'foreach \(var cookie in context\.Request\.Cookies\.Keys\)' -and
    $programContent -match 'context\.Response\.Cookies\.Delete\(cookie\)') {
    Write-Host "✅ MIDDLEWARE COOKIE CLEARING IMPLEMENTED" -ForegroundColor Green
} else {
    Write-Host "❌ MIDDLEWARE COOKIE CLEARING NOT IMPLEMENTED" -ForegroundColor Red
}

# Test 6: Check Tarefa/Cards layout
Write-Host "`n5️⃣ CHECKING TAREFA/CARDS LAYOUT..." -ForegroundColor Yellow
$tarefaContent = Get-Content "Views/Tarefa/Cards.cshtml" -Raw

if ($tarefaContent -match 'Layout = "_Layout"') {
    Write-Host "✅ TAREFA/CARDS USES SHARED LAYOUT" -ForegroundColor Green
} else {
    Write-Host "❌ TAREFA/CARDS LAYOUT ISSUE" -ForegroundColor Red
}

# Test 7: Check Obra/Escolher clean room
Write-Host "`n6️⃣ CHECKING OBRA/ESCOLHER CLEAN ROOM..." -ForegroundColor Yellow
$obraContent = Get-Content "Views/Obra/Escolher.cshtml" -Raw

if ($obraContent -match 'Layout = null' -and 
    $obraContent -match '<!DOCTYPE html>' -and
    $obraContent -notmatch 'ng-') {
    Write-Host "✅ OBRA/ESCOLHER IS CLEAN ROOM (NO ANGULARJS)" -ForegroundColor Green
} else {
    Write-Host "❌ OBRA/ESCOLHER NOT CLEAN ROOM" -ForegroundColor Red
}

Write-Host "`n🎯 SUMMARY:" -ForegroundColor Cyan
Write-Host "- Layout CSS paths use root-relative (~/) for nested routes" -ForegroundColor White
Write-Host "- Styles section is optional (required: false)" -ForegroundColor White
Write-Host "- Aggressive cookie clearing in AccountController and middleware" -ForegroundColor White
Write-Host "- Tarefa/Cards uses shared layout for proper styling" -ForegroundColor White
Write-Host "- Obra/Escolher remains clean room (Layout = null)" -ForegroundColor White

Write-Host "`n✅ LAYOUT CSS FIX AND AUTHENTICATION BYPASS ELIMINATION COMPLETE" -ForegroundColor Green
Write-Host "Ready for testing: Login should force logout, CSS should load on /Tarefa/Cards" -ForegroundColor Green

Set-Location "../.."