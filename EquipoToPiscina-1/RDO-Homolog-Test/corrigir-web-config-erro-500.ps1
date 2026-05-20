Write-Host "CORRIGINDO ERRO 500.19 NO WEB.CONFIG" -ForegroundColor Yellow

$webConfigPath = "RDO-Homolog-Test\rdoappProject\Web.config"
$backupPath = "RDO-Homolog-Test\rdoappProject\Web.config.BACKUP-ANTES-CACHE"

# Fazer backup do Web.config atual
if (Test-Path $webConfigPath) {
    Copy-Item $webConfigPath $backupPath
    Write-Host "Backup criado: Web.config.BACKUP-ANTES-CACHE" -ForegroundColor Cyan
}

# Usar o Web.config limpo que sabemos que funciona
$cleanConfigPath = "RDO-Homolog-Test\rdoappProject\Web.config.CLEAN"
if (Test-Path $cleanConfigPath) {
    Copy-Item $cleanConfigPath $webConfigPath
    Write-Host "Web.config restaurado da versao limpa" -ForegroundColor Green
} else {
    Write-Host "ERRO: Web.config.CLEAN nao encontrado!" -ForegroundColor Red
    Write-Host "Vamos remover as configuracoes problematicas..." -ForegroundColor Yellow
    
    # Ler o Web.config atual e remover as linhas problematicas
    $content = Get-Content $webConfigPath -Raw
    
    # Remover as configuracoes que adicionamos
    $content = $content -replace '<httpRuntime enableVersionHeader="false" />', ''
    $content = $content -replace '<compilation debug="true" targetFramework="4.8" />', ''
    $content = $content -replace '<caching>\s*<outputCache enableOutputCache="false" />\s*</caching>', ''
    $content = $content -replace '<httpProtocol>.*?</httpProtocol>', '', 'Singleline'
    
    # Limpar linhas vazias extras
    $content = $content -replace '\n\s*\n', "`n"
    
    Set-Content $webConfigPath $content -Encoding UTF8
    Write-Host "Configuracoes problematicas removidas" -ForegroundColor Green
}

Write-Host ""
Write-Host "AGORA TESTE:" -ForegroundColor Cyan
Write-Host "1. Pressione F5 no Visual Studio" -ForegroundColor White
Write-Host "2. O erro 500.19 deve ter sumido" -ForegroundColor White
Write-Host "3. Se funcionar, vamos testar o cache de outra forma" -ForegroundColor White