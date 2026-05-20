# FORÇAR REFRESH DO CACHE - SOLUÇÃO SIMPLES
Write-Host "=== FORÇANDO REFRESH DO CACHE ===" -ForegroundColor Yellow

# 1. Parar todos os processos
Write-Host "1. Parando Visual Studio e IIS..." -ForegroundColor Cyan
Get-Process | Where-Object {$_.ProcessName -like "*devenv*" -or $_.ProcessName -like "*iisexpress*"} | Stop-Process -Force -ErrorAction SilentlyContinue

# 2. Adicionar timestamp ao JavaScript
Write-Host "2. Modificando JavaScript para forçar refresh..." -ForegroundColor Cyan
$jsFile = "RDO-Homolog-Test\rdoappProject\Client\Controllers\TarefaController.js"
$content = Get-Content $jsFile -Raw
$timestamp = Get-Date -Format "yyyyMMddHHmmss"

# Substituir o log existente por um com timestamp único
$newLog = "console.log('DEBUG LAUDO - CACHE REFRESH TEST $timestamp - Tarefa salva, iniciando salvamento do laudo');"
$content = $content -replace "console\.log\('DEBUG LAUDO - CACHE REFRESH TEST.*?'\);", $newLog

Set-Content $jsFile $content -Encoding UTF8

Write-Host "3. JavaScript modificado com timestamp: $timestamp" -ForegroundColor Green

Write-Host ""
Write-Host "=== INSTRUÇÕES ===" -ForegroundColor Yellow
Write-Host "1. Abra Visual Studio como ADMINISTRADOR" -ForegroundColor White
Write-Host "2. Pressione F5" -ForegroundColor White  
Write-Host "3. Abra Chrome INCÓGNITO (Ctrl+Shift+N)" -ForegroundColor White
Write-Host "4. Acesse localhost e faça login" -ForegroundColor White
Write-Host "5. Tente salvar um laudo" -ForegroundColor White
Write-Host "6. No F12 Console, deve aparecer:" -ForegroundColor White
Write-Host "   'DEBUG LAUDO - CACHE REFRESH TEST $timestamp'" -ForegroundColor Green
Write-Host ""
Write-Host "Se ainda aparecer o log antigo, o problema é do IIS/ASP.NET" -ForegroundColor Red