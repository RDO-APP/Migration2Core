# DESABILITAR CACHE NO WEB.CONFIG
# Este script modifica o Web.config para desabilitar completamente o cache

Write-Host "=== DESABILITANDO CACHE NO WEB.CONFIG ===" -ForegroundColor Yellow

$webConfigPath = "RDO-Homolog-Test\rdoappProject\Web.config"

if (Test-Path $webConfigPath) {
    Write-Host "Modificando Web.config..." -ForegroundColor Cyan
    
    $content = Get-Content $webConfigPath -Raw
    
    # Adicionar configurações de cache no system.web
    $cacheConfig = @"
    <!-- DESABILITAR CACHE PARA DESENVOLVIMENTO -->
    <httpRuntime enableVersionHeader="false" />
    <compilation debug="true" targetFramework="4.8" />
    <caching>
      <outputCache enableOutputCache="false" />
    </caching>
    <httpCookies httpOnlyCookies="true" requireSSL="false" />
"@

    # Procurar por <system.web> e adicionar as configurações
    if ($content -match '<system\.web>') {
        $content = $content -replace '(<system\.web>)', "`$1`n$cacheConfig"
    }
    
    # Adicionar headers para desabilitar cache no system.webServer
    $headerConfig = @"
      <!-- HEADERS PARA DESABILITAR CACHE -->
      <httpProtocol>
        <customHeaders>
          <add name="Cache-Control" value="no-cache, no-store, must-revalidate" />
          <add name="Pragma" value="no-cache" />
          <add name="Expires" value="0" />
        </customHeaders>
      </httpProtocol>
"@

    # Procurar por <system.webServer> e adicionar os headers
    if ($content -match '<system\.webServer>') {
        $content = $content -replace '(<system\.webServer>)', "`$1`n$headerConfig"
    }
    
    # Salvar o arquivo modificado
    Set-Content $webConfigPath $content -Encoding UTF8
    
    Write-Host "Web.config modificado com sucesso!" -ForegroundColor Green
    Write-Host ""
    Write-Host "CONFIGURAÇÕES ADICIONADAS:" -ForegroundColor Yellow
    Write-Host "- enableOutputCache=false" -ForegroundColor White
    Write-Host "- Cache-Control: no-cache" -ForegroundColor White
    Write-Host "- Pragma: no-cache" -ForegroundColor White
    Write-Host "- Expires: 0" -ForegroundColor White
    Write-Host ""
    Write-Host "AGORA:" -ForegroundColor Cyan
    Write-Host "1. Feche o Visual Studio completamente" -ForegroundColor White
    Write-Host "2. Abra como ADMINISTRADOR" -ForegroundColor White
    Write-Host "3. Pressione F5" -ForegroundColor White
    Write-Host "4. Use Chrome incógnito" -ForegroundColor White
    Write-Host "5. O cache deve estar desabilitado" -ForegroundColor White
} else {
    Write-Host "ERRO: Web.config não encontrado em $webConfigPath" -ForegroundColor Red
}