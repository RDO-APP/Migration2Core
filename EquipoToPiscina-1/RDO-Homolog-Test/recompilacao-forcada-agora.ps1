# RECOMPILACAO FORCADA - GARANTIR QUE BACKEND SEJA ATUALIZADO

Write-Host "=== RECOMPILACAO FORCADA ===" -ForegroundColor Yellow
Write-Host ""

# 1. PARAR TODOS OS PROCESSOS
Write-Host "1. Parando todos os processos..." -ForegroundColor Cyan
try {
    Get-Process -Name "iisexpress" -ErrorAction SilentlyContinue | Stop-Process -Force
    Get-Process -Name "w3wp" -ErrorAction SilentlyContinue | Stop-Process -Force
    Get-Process -Name "WebDev.WebServer40" -ErrorAction SilentlyContinue | Stop-Process -Force
    Write-Host "   Processos web finalizados" -ForegroundColor Green
    Start-Sleep -Seconds 3
} catch {
    Write-Host "   Alguns processos nao encontrados" -ForegroundColor Yellow
}

# 2. LIMPAR CACHE COMPLETO
Write-Host ""
Write-Host "2. Limpando cache completo..." -ForegroundColor Cyan

$projectPath = "rdoappProject"
$binPath = "$projectPath\bin"
$objPath = "$projectPath\obj"

# Remover bin e obj
if (Test-Path $binPath) {
    Remove-Item $binPath -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "   Pasta bin/ removida" -ForegroundColor Green
}

if (Test-Path $objPath) {
    Remove-Item $objPath -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "   Pasta obj/ removida" -ForegroundColor Green
}

# Limpar cache ASP.NET
$tempAspNet = "$env:WINDOWS\Microsoft.NET\Framework64\v4.0.30319\Temporary ASP.NET Files"
if (Test-Path $tempAspNet) {
    try {
        Get-ChildItem $tempAspNet -Recurse -Force | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
        Write-Host "   Cache ASP.NET limpo" -ForegroundColor Green
    } catch {
        Write-Host "   Alguns arquivos de cache nao puderam ser removidos" -ForegroundColor Yellow
    }
}

# 3. VERIFICAR SE VISUAL STUDIO ESTA ABERTO
Write-Host ""
Write-Host "3. Verificando Visual Studio..." -ForegroundColor Cyan
$vsProcess = Get-Process -Name "devenv" -ErrorAction SilentlyContinue
if ($vsProcess) {
    Write-Host "   Visual Studio esta aberto" -ForegroundColor Green
    Write-Host "   PID: $($vsProcess.Id)" -ForegroundColor White
} else {
    Write-Host "   ERRO: Visual Studio nao esta aberto!" -ForegroundColor Red
    Write-Host "   Abra o Visual Studio COMO ADMINISTRADOR primeiro!" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "=== LIMPEZA CONCLUIDA ===" -ForegroundColor Green
Write-Host ""
Write-Host "AGORA NO VISUAL STUDIO:" -ForegroundColor Yellow
Write-Host "1. Pare a aplicacao (Shift+F5)" -ForegroundColor White
Write-Host "2. Compilar > Limpar Solucao" -ForegroundColor White
Write-Host "3. Compilar > Recompilar Solucao" -ForegroundColor White
Write-Host "4. Aguarde finalizar COMPLETAMENTE" -ForegroundColor Red
Write-Host "5. F5 para executar" -ForegroundColor White
Write-Host "6. Teste salvar laudo novamente" -ForegroundColor White
Write-Host ""
Write-Host "DEVE APARECER NO F12:" -ForegroundColor Green
Write-Host "=== TESTE RECOMPILACAO FUNCIONANDO ===" -ForegroundColor Cyan
Write-Host "BACKEND RECEBEU CHAMADA - IdTarefa: [numero]" -ForegroundColor Cyan

Write-Host ""