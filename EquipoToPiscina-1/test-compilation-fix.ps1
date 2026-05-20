# Test compilation after fixing entity conflict
Write-Host "🔧 TESTING COMPILATION AFTER ENTITY CONFLICT FIX" -ForegroundColor Green
Write-Host ""

$projectPath = "RDO-NET8-Migration\RdoApp.Core"

if (Test-Path $projectPath) {
    Write-Host "📂 Project found: $projectPath" -ForegroundColor Cyan
    
    Set-Location $projectPath
    
    Write-Host "🧹 Cleaning project..." -ForegroundColor Yellow
    dotnet clean
    
    Write-Host "🔨 Building project..." -ForegroundColor Yellow
    $buildResult = dotnet build --verbosity minimal
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ COMPILATION SUCCESSFUL!" -ForegroundColor Green
        Write-Host ""
        Write-Host "🎯 FIXES APPLIED:" -ForegroundColor Yellow
        Write-Host "  ✅ Removed duplicate Usuario entity" -ForegroundColor White
        Write-Host "  ✅ Enhanced Colaborador with auth fields" -ForegroundColor White
        Write-Host "  ✅ Fixed RdoContext duplicate DbSet" -ForegroundColor White
        Write-Host "  ✅ Created missing DTOs" -ForegroundColor White
        Write-Host ""
        Write-Host "🚀 Ready to test login!" -ForegroundColor Green
    } else {
        Write-Host "❌ COMPILATION FAILED" -ForegroundColor Red
        Write-Host "Build output:" -ForegroundColor Yellow
        Write-Host $buildResult -ForegroundColor White
    }
    
    Set-Location ..\..\
} else {
    Write-Host "❌ Project not found: $projectPath" -ForegroundColor Red
}