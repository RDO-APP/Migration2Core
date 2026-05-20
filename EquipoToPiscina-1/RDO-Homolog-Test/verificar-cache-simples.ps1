# VERIFICAÇÃO SIMPLES DO CACHE
Write-Host "=== VERIFICANDO PROBLEMA DE CACHE ===" -ForegroundColor Yellow

$jsFile = "RDO-Homolog-Test\rdoappProject\Client\Controllers\TarefaController.js"

if (Test-Path $jsFile) {
    $content = Get-Content $jsFile -Raw
    
    Write-Host "Verificando conteúdo do JavaScript..." -ForegroundColor Cyan
    
    if ($content -match "CACHE REFRESH TEST") {
        Write-Host "✓ JavaScript TEM as mudanças novas" -ForegroundColor Green
    } else {
        Write-Host "✗ JavaScript ainda tem código ANTIGO" -ForegroundColor Red
    }
    
    # Mostrar as primeiras linhas do arquivo
    Write-Host ""
    Write-Host "Primeiras 5 linhas do arquivo:" -ForegroundColor Cyan
    $lines = Get-Content $jsFile | Select-Object -First 5
    $lines | ForEach-Object { Write-Host "  $_" -ForegroundColor White }
    
} else {
    Write-Host "✗ Arquivo não encontrado!" -ForegroundColor Red
}

Write-Host ""
Write-Host "PRÓXIMO PASSO:" -ForegroundColor Yellow
Write-Host "Execute: .\RDO-Homolog-Test\solucao-definitiva-cache-js-agora.ps1" -ForegroundColor Green