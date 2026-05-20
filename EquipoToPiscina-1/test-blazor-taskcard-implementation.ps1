# Test Blazor TaskCard Implementation
# This script verifies the Blazor component setup and compilation

Write-Host "🚀 Testing Blazor TaskCard Implementation" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green

# Change to project directory
Set-Location "RDO-NET8-Migration\RdoApp.Core"

Write-Host "📁 Current Directory: $(Get-Location)" -ForegroundColor Yellow

# Check if Blazor files exist
Write-Host "`n🔍 Checking Blazor Component Files:" -ForegroundColor Cyan

$blazorFiles = @(
    "Components\TaskCard.razor",
    "Components\TaskCard.razor.css", 
    "Components\_Imports.razor"
)

foreach ($file in $blazorFiles) {
    if (Test-Path $file) {
        Write-Host "✅ $file exists" -ForegroundColor Green
    } else {
        Write-Host "❌ $file missing" -ForegroundColor Red
    }
}

# Check Program.cs for Blazor services
Write-Host "`n🔍 Checking Program.cs for Blazor Configuration:" -ForegroundColor Cyan

$programContent = Get-Content "Program.cs" -Raw
if ($programContent -match "AddServerSideBlazor") {
    Write-Host "✅ AddServerSideBlazor() found in Program.cs" -ForegroundColor Green
} else {
    Write-Host "❌ AddServerSideBlazor() missing in Program.cs" -ForegroundColor Red
}

if ($programContent -match "MapBlazorHub") {
    Write-Host "✅ MapBlazorHub() found in Program.cs" -ForegroundColor Green
} else {
    Write-Host "❌ MapBlazorHub() missing in Program.cs" -ForegroundColor Red
}

# Check Layout for Blazor script
Write-Host "`n🔍 Checking _Layout.cshtml for Blazor Script:" -ForegroundColor Cyan

$layoutContent = Get-Content "Views\Shared\_Layout.cshtml" -Raw
if ($layoutContent -match "blazor\.server\.js") {
    Write-Host "✅ Blazor server script found in _Layout.cshtml" -ForegroundColor Green
} else {
    Write-Host "❌ Blazor server script missing in _Layout.cshtml" -ForegroundColor Red
}

# Check EtapaAccordionPartial for component usage
Write-Host "`n🔍 Checking _EtapaAccordionPartial.cshtml for Component Usage:" -ForegroundColor Cyan

$accordionContent = Get-Content "Views\Etapa\_EtapaAccordionPartial.cshtml" -Raw
if ($accordionContent -match "component type.*TaskCard") {
    Write-Host "✅ TaskCard component usage found in _EtapaAccordionPartial.cshtml" -ForegroundColor Green
} else {
    Write-Host "❌ TaskCard component usage missing in _EtapaAccordionPartial.cshtml" -ForegroundColor Red
}

# Attempt compilation
Write-Host "`n🔨 Attempting Project Compilation:" -ForegroundColor Cyan

try {
    $buildResult = dotnet build --no-restore --verbosity quiet 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Project compiled successfully!" -ForegroundColor Green
        Write-Host "🎯 Blazor TaskCard component is ready for testing" -ForegroundColor Green
    } else {
        Write-Host "❌ Compilation failed:" -ForegroundColor Red
        Write-Host $buildResult -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Build error: $($_.Exception.Message)" -ForegroundColor Red
}

# Summary
Write-Host "`n📋 Implementation Summary:" -ForegroundColor Yellow
Write-Host "• TaskCard.razor: Blazor component with fixed 200x110px dimensions" -ForegroundColor White
Write-Host "• TaskCard.razor.css: CSS isolation prevents width stretching" -ForegroundColor White  
Write-Host "• Program.cs: Blazor Server services added" -ForegroundColor White
Write-Host "• _Layout.cshtml: Blazor script reference added" -ForegroundColor White
Write-Host "• _EtapaAccordionPartial.cshtml: Updated to use Blazor component" -ForegroundColor White

Write-Host "`n🎯 Next Steps:" -ForegroundColor Yellow
Write-Host "1. Run the application (F5 in Visual Studio)" -ForegroundColor White
Write-Host "2. Navigate to Etapa/Cards page" -ForegroundColor White
Write-Host "3. Verify task cards maintain 200px width" -ForegroundColor White
Write-Host "4. Verify FontAwesome icons display correctly" -ForegroundColor White
Write-Host "5. Test all button interactions work" -ForegroundColor White

Write-Host "`n✨ Blazor TaskCard Implementation Complete!" -ForegroundColor Green