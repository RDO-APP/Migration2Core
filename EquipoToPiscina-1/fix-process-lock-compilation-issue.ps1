# Fix Process Lock Compilation Issue - RdoApp.Core
Write-Host "=== RESOLVENDO PROBLEMA DE PROCESSO BLOQUEADO ===" -ForegroundColor Green

# Navigate to project directory
Set-Location "RDO-NET8-Migration\RdoApp.Core"

Write-Host "1. Parando todos os processos RdoApp.Core..." -ForegroundColor Yellow

# Stop all RdoApp.Core processes
Get-Process -Name "RdoApp.Core" -ErrorAction SilentlyContinue | ForEach-Object {
    Write-Host "   Parando processo RdoApp.Core (PID: $($_.Id))" -ForegroundColor Cyan
    Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
}

# Stop dotnet processes that might be running the app
Get-Process -Name "dotnet" -ErrorAction SilentlyContinue | Where-Object { 
    $_.MainWindowTitle -like "*RdoApp*" -or 
    $_.ProcessName -eq "dotnet" 
} | ForEach-Object {
    Write-Host "   Parando processo dotnet relacionado (PID: $($_.Id))" -ForegroundColor Cyan
    Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
}

# Wait a moment for processes to fully terminate
Start-Sleep -Seconds 2

Write-Host "2. Limpando arquivos de build..." -ForegroundColor Yellow

# Clean bin and obj directories
if (Test-Path "bin") {
    Remove-Item -Path "bin" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "   Pasta bin removida" -ForegroundColor Cyan
}

if (Test-Path "obj") {
    Remove-Item -Path "obj" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "   Pasta obj removida" -ForegroundColor Cyan
}

Write-Host "3. Executando dotnet clean..." -ForegroundColor Yellow
dotnet clean --verbosity quiet

Write-Host "4. Restaurando pacotes NuGet..." -ForegroundColor Yellow
dotnet restore --verbosity quiet

Write-Host "5. Compilando projeto..." -ForegroundColor Yellow
$buildResult = dotnet build --no-restore --verbosity normal

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ COMPILAÇÃO REALIZADA COM SUCESSO!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Agora você pode:" -ForegroundColor Cyan
    Write-Host "1. Pressionar F5 no Visual Studio" -ForegroundColor White
    Write-Host "2. Ou executar: dotnet run" -ForegroundColor White
    Write-Host ""
    Write-Host "=== TESTE DO RBAC ICON FIX ===" -ForegroundColor Yellow
    Write-Host "Login: CPF 12345678901, Senha: 1234" -ForegroundColor White
    Write-Host "Verifique se os ícones aparecem baseados no grupo do usuário" -ForegroundColor White
} else {
    Write-Host "❌ ERRO NA COMPILAÇÃO" -ForegroundColor Red
    Write-Host "Detalhes do erro:" -ForegroundColor Yellow
    Write-Host $buildResult -ForegroundColor White
    
    Write-Host ""
    Write-Host "Tentativas de solução:" -ForegroundColor Cyan
    Write-Host "1. Feche completamente o Visual Studio" -ForegroundColor White
    Write-Host "2. Execute este script novamente" -ForegroundColor White
    Write-Host "3. Reabra o Visual Studio como Administrador" -ForegroundColor White
}

Write-Host ""
Write-Host "=== PROCESSO CONCLUÍDO ===" -ForegroundColor Green