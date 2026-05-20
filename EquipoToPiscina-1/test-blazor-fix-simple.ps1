# TEST PURE BLAZOR LAYOUT FIX - SIMPLE VERSION
Write-Host "Testing Pure Blazor Layout Fix..." -ForegroundColor Green

# Step 1: Check Layout assignment is removed
$blazorContent = Get-Content "RDO-NET8-Migration/RdoApp.Core/Components/EtapaCardsPage.razor" -Raw
if ($blazorContent -notmatch 'Layout\s*=') {
    Write-Host "✅ Layout assignment removed from Blazor component" -ForegroundColor Green
} else {
    Write-Host "❌ Layout assignment still present!" -ForegroundColor Red
    exit 1
}

# Step 2: Check controller action exists
$controllerContent = Get-Content "RDO-NET8-Migration/RdoApp.Core/Controllers/EtapaController.cs" -Raw
if ($controllerContent -match 'CardsBlazor') {
    Write-Host "✅ CardsBlazor controller action found" -ForegroundColor Green
} else {
    Write-Host "❌ CardsBlazor controller action missing!" -ForegroundColor Red
    exit 1
}

# Step 3: Check host page exists
if (Test-Path "RDO-NET8-Migration/RdoApp.Core/Views/Etapa/CardsBlazor.cshtml") {
    Write-Host "✅ CardsBlazor.cshtml host page created" -ForegroundColor Green
} else {
    Write-Host "❌ CardsBlazor.cshtml host page missing!" -ForegroundColor Red
    exit 1
}

# Step 4: Try to compile
Write-Host "Compiling project..." -ForegroundColor Yellow
Push-Location "RDO-NET8-Migration/RdoApp.Core"
$buildResult = dotnet build --no-restore 2>&1
Pop-Location

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Project compiled successfully" -ForegroundColor Green
} else {
    Write-Host "❌ Compilation failed:" -ForegroundColor Red
    Write-Host $buildResult -ForegroundColor Red
    exit 1
}

Write-Host "`nSUCCESS! Pure Blazor layout fix complete." -ForegroundColor Green
Write-Host "Test URL: https://localhost:5001/etapa/cards-blazor/233" -ForegroundColor Cyan