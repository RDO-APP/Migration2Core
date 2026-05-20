# LIMPEZA BACKEND SIMPLES - SEM CARACTERES ESPECIAIS

Write-Host "=== LIMPEZA BACKEND ===" -ForegroundColor Yellow
Write-Host "Parando processos e limpando cache..." -ForegroundColor Cyan

# 1. PARAR PROCESSOS
try {
    Get-Process -Name "iisexpress" -ErrorAction SilentlyContinue | Stop-Process -Force
    Get-Process -Name "w3wp" -ErrorAction SilentlyContinue | Stop-Process -Force
    Get-Process -Name "devenv" -ErrorAction SilentlyContinue | Stop-Process -Force
    Write-Host "Processos finalizados" -ForegroundColor Green
} catch {
    Write-Host "Alguns processos nao encontrados" -ForegroundColor Yellow
}

# 2. LIMPAR BIN E OBJ
$projectPath = "rdoappProject"
$binPath = "$projectPath\bin"
$objPath = "$projectPath\obj"

if (Test-Path $binPath) {
    Remove-Item $binPath -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "Pasta bin/ removida" -ForegroundColor Green
}

if (Test-Path $objPath) {
    Remove-Item $objPath -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "Pasta obj/ removida" -ForegroundColor Green
}

# 3. LIMPAR CACHE ASP.NET
$tempAspNet = "$env:WINDOWS\Microsoft.NET\Framework64\v4.0.30319\Temporary ASP.NET Files"
if (Test-Path $tempAspNet) {
    try {
        Get-ChildItem $tempAspNet -Recurse -Force | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
        Write-Host "Cache ASP.NET limpo" -ForegroundColor Green
    } catch {
        Write-Host "Alguns arquivos de cache nao puderam ser removidos" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "=== LIMPEZA CONCLUIDA ===" -ForegroundColor Green
Write-Host ""
Write-Host "PROXIMOS PASSOS:" -ForegroundColor Yellow
Write-Host "1. Abra Visual Studio COMO ADMINISTRADOR" -ForegroundColor White
Write-Host "2. Abra o projeto: rdoappProject\rdoappProject.sln" -ForegroundColor White
Write-Host "3. Compilar > Limpar Solucao" -ForegroundColor White
Write-Host "4. Compilar > Recompilar Solucao" -ForegroundColor White
Write-Host "5. F5 para executar" -ForegroundColor White