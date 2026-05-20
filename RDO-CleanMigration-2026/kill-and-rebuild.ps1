# Kill RdoApp.Core processes and rebuild
Write-Host "=== MATANDO PROCESSOS RdoApp.Core ===" -ForegroundColor Yellow

# Kill by process name
Get-Process -Name "RdoApp.Core" -ErrorAction SilentlyContinue | ForEach-Object {
    Write-Host "Matando processo: $($_.Name) (PID: $($_.Id))" -ForegroundColor Red
    Stop-Process -Id $_.Id -Force
}

# Kill by PID 2120 specifically
try {
    Stop-Process -Id 2120 -Force -ErrorAction SilentlyContinue
    Write-Host "Processo PID 2120 morto" -ForegroundColor Green
} catch {
    Write-Host "PID 2120 já não existe" -ForegroundColor Gray
}

# Wait a bit
Start-Sleep -Seconds 2

# Clean bin and obj folders
Write-Host "`n=== LIMPANDO BIN E OBJ ===" -ForegroundColor Yellow
$projectPath = "C:\Dev\RDO-CleanMigration-2026\RDO-CleanMigration-2026\RdoApp.Core"

if (Test-Path "$projectPath\bin") {
    Remove-Item "$projectPath\bin" -Recurse -Force
    Write-Host "Pasta bin removida" -ForegroundColor Green
}

if (Test-Path "$projectPath\obj") {
    Remove-Item "$projectPath\obj" -Recurse -Force
    Write-Host "Pasta obj removida" -ForegroundColor Green
}

Write-Host "`n=== RECONSTRUINDO PROJETO ===" -ForegroundColor Yellow
Set-Location $projectPath
dotnet build

Write-Host "`n=== PRONTO! ===" -ForegroundColor Green
Write-Host "Agora você pode:" -ForegroundColor Cyan
Write-Host "1. Pressionar F5 no Visual Studio" -ForegroundColor White
Write-Host "2. Ou executar: dotnet run" -ForegroundColor White
