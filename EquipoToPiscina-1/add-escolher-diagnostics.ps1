# Add Enhanced Diagnostics to Escolher Page
# This will help identify the exact point of failure

Write-Host "Adding enhanced diagnostics to Escolher.cshtml..." -ForegroundColor Cyan

$escolherPath = "RDO-NET8-Migration/RdoApp.Core/Views/Obra/Escolher.cshtml"
$content = Get-Content $escolherPath -Raw

# Check if diagnostics already exist
if ($content -match "ENHANCED-DIAGNOSTICS") {
    Write-Host "Diagnostics already present. Skipping..." -ForegroundColor Yellow
    exit 0
}

# Add enhanced diagnostics after the model check
$newContent = $content -replace '(@if \(Model != null && Model\.Any\(\)\)\s*\{)', @'
<!-- ENHANCED DIAGNOSTICS - Step-by-step render tracking -->
<div id="diagnostic-step-1" style="background: #e3f2fd; color: #1976d2; padding: 10px; margin: 10px; border: 2px solid #2196f3; border-radius: 4px;">
    <strong>🔍 STEP 1:</strong> Escolher.cshtml is rendering
    <br>📊 Model Count: @Model.Count()
    <br>🔧 Layout: @(Layout ?? "NULL")
    <br>⚡ Blazor Required: @(ViewData["BlazorRequired"]?.ToString() ?? "false")
</div>

<script>
    console.log('🔍 DIAGNOSTIC: Escolher.cshtml HTML rendered');
    console.log('📊 Model Count:', @Model.Count());
    console.log('⚡ About to render Blazor component...');
</script>

$1
'@

# Write updated content
Set-Content -Path $escolherPath -Value $newContent -Encoding UTF8

Write-Host "✅ Enhanced diagnostics added to Escolher.cshtml" -ForegroundColor Green
Write-Host ""
Write-Host "WHAT WAS ADDED:" -ForegroundColor Yellow
Write-Host "1. Visual diagnostic div showing render progress" -ForegroundColor White
Write-Host "2. Console logging for step-by-step tracking" -ForegroundColor White
Write-Host "3. Model count display" -ForegroundColor White
Write-Host ""
Write-Host "HOW TO USE:" -ForegroundColor Yellow
Write-Host "1. Start application: dotnet run" -ForegroundColor White
Write-Host "2. Open browser F12 Console" -ForegroundColor White
Write-Host "3. Login as Ricardo" -ForegroundColor White
Write-Host "4. Watch console for diagnostic messages" -ForegroundColor White
Write-Host "5. Check if blue diagnostic div appears" -ForegroundColor White
Write-Host ""
Write-Host "IF YOU SEE:" -ForegroundColor Yellow
Write-Host "- Blue diagnostic div: HTML is rendering ✅" -ForegroundColor Green
Write-Host "- Console messages: JavaScript is working ✅" -ForegroundColor Green
Write-Host "- White screen after: Blazor component failed ❌" -ForegroundColor Red
Write-Host ""
