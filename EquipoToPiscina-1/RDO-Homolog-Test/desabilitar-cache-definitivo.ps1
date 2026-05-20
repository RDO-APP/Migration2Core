Write-Host "DESABILITANDO CACHE NO WEB.CONFIG - SOLUCAO DEFINITIVA" -ForegroundColor Yellow

$webConfigPath = "RDO-Homolog-Test\rdoappProject\Web.config"

if (Test-Path $webConfigPath) {
    Write-Host "Modificando Web.config para desabilitar cache..." -ForegroundColor Cyan
    
    $content = Get-Content $webConfigPath -Raw
    
    # Verificar se ja tem as configuracoes
    if ($content -match "no-cache") {
        Write-Host "Web.config ja tem configuracoes anti-cache" -ForegroundColor Green
    } else {
        Write-Host "Adicionando configuracoes anti-cache..." -ForegroundColor Cyan
        
        # Adicionar no system.web
        $webConfig = @"
    <httpRuntime enableVersionHeader="false" />
    <compilation debug="true" targetFramework="4.8" />
    <caching>
      <outputCache enableOutputCache="false" />
    </caching>
"@
        
        # Adicionar no system.webServer  
        $serverConfig = @"
      <httpProtocol>
        <customHeaders>
          <add name="Cache-Control" value="no-cache, no-store, must-revalidate" />
          <add name="Pragma" value="no-cache" />
          <add name="Expires" value="0" />
        </customHeaders>
      </httpProtocol>
"@
        
        # Inserir as configuracoes
        if ($content -match '<system\.web>') {
            $content = $content -replace '(<system\.web>\s*)', "`$1`n$webConfig`n"
        }
        
        if ($content -match '<system\.webServer>') {
            $content = $content -replace '(<system\.webServer>\s*)', "`$1`n$serverConfig`n"
        }
        
        # Salvar
        Set-Content $webConfigPath $content -Encoding UTF8
        Write-Host "Web.config modificado com sucesso!" -ForegroundColor Green
    }
    
    Write-Host ""
    Write-Host "CONFIGURACOES APLICADAS:" -ForegroundColor Yellow
    Write-Host "- enableOutputCache=false" -ForegroundColor White
    Write-Host "- Cache-Control: no-cache" -ForegroundColor White
    Write-Host "- Pragma: no-cache" -ForegroundColor White
    Write-Host "- Expires: 0" -ForegroundColor White
    
} else {
    Write-Host "ERRO: Web.config nao encontrado!" -ForegroundColor Red
}

Write-Host ""
Write-Host "PROXIMOS PASSOS:" -ForegroundColor Cyan
Write-Host "1. Feche o Visual Studio completamente" -ForegroundColor White
Write-Host "2. Abra como ADMINISTRADOR" -ForegroundColor White
Write-Host "3. Pressione F5" -ForegroundColor White
Write-Host "4. O cache estara desabilitado" -ForegroundColor Green
Write-Host "5. Procure por: DEBUG LAUDO - CACHE REFRESH TEST 20251226113641" -ForegroundColor Green