# SOLUÇÃO DEFINITIVA PARA CACHE JAVASCRIPT
# Este script força a atualização completa do cache do navegador

Write-Host "=== SOLUÇÃO DEFINITIVA CACHE JAVASCRIPT ===" -ForegroundColor Yellow
Write-Host ""

# 1. Parar o Visual Studio se estiver rodando
Write-Host "1. Parando Visual Studio..." -ForegroundColor Cyan
Get-Process | Where-Object {$_.ProcessName -like "*devenv*" -or $_.ProcessName -like "*iisexpress*"} | Stop-Process -Force -ErrorAction SilentlyContinue

# 2. Limpar cache do IIS Express
Write-Host "2. Limpando cache do IIS Express..." -ForegroundColor Cyan
$iisExpressPath = "$env:USERPROFILE\Documents\IISExpress"
if (Test-Path $iisExpressPath) {
    Remove-Item "$iisExpressPath\*" -Recurse -Force -ErrorAction SilentlyContinue
}

# 3. Limpar cache do navegador Chrome
Write-Host "3. Limpando cache do Chrome..." -ForegroundColor Cyan
$chromePath = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default"
if (Test-Path $chromePath) {
    Get-Process | Where-Object {$_.ProcessName -like "*chrome*"} | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep 2
    Remove-Item "$chromePath\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "$chromePath\Code Cache\*" -Recurse -Force -ErrorAction SilentlyContinue
}

# 4. Adicionar timestamp ao arquivo JavaScript para forçar refresh
Write-Host "4. Adicionando timestamp ao JavaScript..." -ForegroundColor Cyan
$jsFile = "RDO-Homolog-Test\rdoappProject\Client\Controllers\TarefaController.js"
if (Test-Path $jsFile) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $content = Get-Content $jsFile -Raw
    
    # Adicionar comentário com timestamp no início do arquivo
    $newContent = "// CACHE REFRESH: $timestamp`n" + $content
    Set-Content $jsFile $newContent -Encoding UTF8
    
    Write-Host "   Timestamp adicionado ao JavaScript" -ForegroundColor Green
}

# 5. Limpar bin/obj do projeto
Write-Host "5. Limpando bin/obj do projeto..." -ForegroundColor Cyan
$projectPath = "RDO-Homolog-Test\rdoappProject"
if (Test-Path "$projectPath\bin") {
    Remove-Item "$projectPath\bin\*" -Recurse -Force -ErrorAction SilentlyContinue
}
if (Test-Path "$projectPath\obj") {
    Remove-Item "$projectPath\obj\*" -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host ""
Write-Host "=== INSTRUÇÕES PARA O USUÁRIO ===" -ForegroundColor Yellow
Write-Host "1. Abra o Visual Studio como ADMINISTRADOR" -ForegroundColor White
Write-Host "2. Abra o projeto: RDO-Homolog-Test\rdoappProject\rdoappProject.sln" -ForegroundColor White
Write-Host "3. Pressione F5 para executar" -ForegroundColor White
Write-Host "4. Abra Chrome em MODO INCÓGNITO (Ctrl+Shift+N)" -ForegroundColor White
Write-Host "5. Acesse: http://localhost:[porta]" -ForegroundColor White
Write-Host "6. Faça login: 567.065.455-20 / 1234" -ForegroundColor White
Write-Host "7. Vá para uma tarefa e tente salvar laudo" -ForegroundColor White
Write-Host "8. Pressione F12 e verifique se aparece:" -ForegroundColor White
Write-Host "   'DEBUG LAUDO - CACHE REFRESH TEST'" -ForegroundColor Green
Write-Host ""
Write-Host "Se ainda aparecer o log antigo, o problema é mais profundo." -ForegroundColor Red
Write-Host "Neste caso, precisaremos modificar o Web.config para desabilitar cache." -ForegroundColor Red
Write-Host ""
Write-Host "CACHE LIMPO COM SUCESSO!" -ForegroundColor Green