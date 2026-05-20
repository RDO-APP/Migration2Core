# DIAGNÓSTICO COMPLETO DO PROBLEMA DE CACHE
# Este script verifica todos os aspectos do problema

Write-Host "=== DIAGNÓSTICO COMPLETO CACHE JAVASCRIPT ===" -ForegroundColor Yellow
Write-Host ""

# 1. Verificar se o arquivo JavaScript tem as mudanças corretas
Write-Host "1. VERIFICANDO CONTEÚDO DO JAVASCRIPT..." -ForegroundColor Cyan
$jsFile = "RDO-Homolog-Test\rdoappProject\Client\Controllers\TarefaController.js"

if (Test-Path $jsFile) {
    $content = Get-Content $jsFile -Raw
    
    if ($content -match "CACHE REFRESH TEST") {
        Write-Host "   ✓ JavaScript contém as mudanças NOVAS" -ForegroundColor Green
    } else {
        Write-Host "   ✗ JavaScript ainda tem código ANTIGO" -ForegroundColor Red
        Write-Host "   PROBLEMA: O arquivo não foi atualizado corretamente" -ForegroundColor Red
    }
    
    if ($content -match "=== KIRO DEBUG START ===") {
        Write-Host "   ✓ Debug logs novos estão presentes" -ForegroundColor Green
    } else {
        Write-Host "   ✗ Debug logs novos não encontrados" -ForegroundColor Red
    }
} else {
    Write-Host "   ✗ Arquivo JavaScript não encontrado!" -ForegroundColor Red
}

Write-Host ""

# 2. Verificar processos do Visual Studio
Write-Host "2. VERIFICANDO PROCESSOS..." -ForegroundColor Cyan
$vsProcesses = Get-Process | Where-Object {$_.ProcessName -like "*devenv*" -or $_.ProcessName -like "*iisexpress*"}
if ($vsProcesses) {
    Write-Host "   ⚠ Visual Studio/IIS Express ainda rodando:" -ForegroundColor Yellow
    $vsProcesses | ForEach-Object { Write-Host "     - $($_.ProcessName)" -ForegroundColor White }
} else {
    Write-Host "   ✓ Nenhum processo VS/IIS rodando" -ForegroundColor Green
}

Write-Host ""

# 3. Verificar cache do Chrome
Write-Host "3. VERIFICANDO CACHE DO CHROME..." -ForegroundColor Cyan
$chromePath = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache"
if (Test-Path $chromePath) {
    $cacheFiles = Get-ChildItem $chromePath -ErrorAction SilentlyContinue | Measure-Object
    Write-Host "   ⚠ Cache do Chrome contém $($cacheFiles.Count) arquivos" -ForegroundColor Yellow
} else {
    Write-Host "   ✓ Cache do Chrome limpo ou não encontrado" -ForegroundColor Green
}

Write-Host ""

# 4. Verificar Web.config
Write-Host "4. VERIFICANDO WEB.CONFIG..." -ForegroundColor Cyan
$webConfigPath = "RDO-Homolog-Test\rdoappProject\Web.config"
if (Test-Path $webConfigPath) {
    $webContent = Get-Content $webConfigPath -Raw
    
    if ($webContent -match "no-cache") {
        Write-Host "   ✓ Web.config tem configurações anti-cache" -ForegroundColor Green
    } else {
        Write-Host "   ⚠ Web.config não tem configurações anti-cache" -ForegroundColor Yellow
    }
} else {
    Write-Host "   ✗ Web.config não encontrado" -ForegroundColor Red
}

Write-Host ""

# 5. Verificar timestamp do arquivo
Write-Host "5. VERIFICANDO TIMESTAMP DO ARQUIVO..." -ForegroundColor Cyan
if (Test-Path $jsFile) {
    $lastWrite = (Get-Item $jsFile).LastWriteTime
    $now = Get-Date
    $diff = $now - $lastWrite
    
    Write-Host "   Última modificação: $lastWrite" -ForegroundColor White
    Write-Host "   Diferença: $($diff.TotalMinutes.ToString('F1')) minutos atrás" -ForegroundColor White
    
    if ($diff.TotalMinutes -lt 5) {
        Write-Host "   ✓ Arquivo foi modificado recentemente" -ForegroundColor Green
    } else {
        Write-Host "   ⚠ Arquivo não foi modificado recentemente" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "=== DIAGNÓSTICO CONCLUÍDO ===" -ForegroundColor Yellow
Write-Host ""
Write-Host "PRÓXIMOS PASSOS BASEADOS NO DIAGNÓSTICO:" -ForegroundColor Cyan
Write-Host "1. Se JavaScript tem código ANTIGO → Execute solucao-definitiva-cache-js-agora.ps1" -ForegroundColor White
Write-Host "2. Se VS/IIS ainda rodando → Feche tudo e reabra como admin" -ForegroundColor White
Write-Host "3. Se cache Chrome cheio → Limpe manualmente ou use incógnito" -ForegroundColor White
Write-Host "4. Se Web.config sem anti-cache → Execute desabilitar-cache-web-config.ps1" -ForegroundColor White
Write-Host ""
Write-Host "TESTE FINAL:" -ForegroundColor Green
Write-Host "No F12 Console, deve aparecer: 'DEBUG LAUDO - CACHE REFRESH TEST'" -ForegroundColor Green