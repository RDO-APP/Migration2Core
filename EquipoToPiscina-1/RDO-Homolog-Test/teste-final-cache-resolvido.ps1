Write-Host "TESTE FINAL - CACHE DESABILITADO" -ForegroundColor Green
Write-Host ""

# Verificar se as configuracoes estao no Web.config
$webConfigPath = "RDO-Homolog-Test\rdoappProject\Web.config"
if (Test-Path $webConfigPath) {
    $content = Get-Content $webConfigPath -Raw
    if ($content -match "no-cache") {
        Write-Host "✓ Web.config tem configuracoes anti-cache" -ForegroundColor Green
    } else {
        Write-Host "✗ Web.config NAO tem configuracoes anti-cache" -ForegroundColor Red
    }
}

# Verificar se o JavaScript tem o timestamp
$jsFile = "RDO-Homolog-Test\rdoappProject\Client\Controllers\TarefaController.js"
if (Test-Path $jsFile) {
    $jsContent = Get-Content $jsFile -Raw
    if ($jsContent -match "20251226113641") {
        Write-Host "✓ JavaScript tem timestamp unico" -ForegroundColor Green
    } else {
        Write-Host "✗ JavaScript NAO tem timestamp" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "AGORA TESTE ASSIM:" -ForegroundColor Yellow
Write-Host "1. Feche COMPLETAMENTE o Visual Studio" -ForegroundColor White
Write-Host "2. Abra Visual Studio como ADMINISTRADOR" -ForegroundColor White
Write-Host "3. Abra o projeto: RDO-Homolog-Test\rdoappProject\rdoappProject.sln" -ForegroundColor White
Write-Host "4. Pressione F5" -ForegroundColor White
Write-Host "5. Quando abrir o navegador, va direto testar" -ForegroundColor White
Write-Host "6. Login: 567.065.455-20 / 1234" -ForegroundColor White
Write-Host "7. Escolha obra > etapa > tarefa" -ForegroundColor White
Write-Host "8. Preencha laudo e clique Salvar" -ForegroundColor White
Write-Host "9. Pressione F12 e procure por:" -ForegroundColor White
Write-Host "   DEBUG LAUDO - CACHE REFRESH TEST 20251226113641" -ForegroundColor Green
Write-Host ""
Write-Host "SE APARECER O TIMESTAMP 20251226113641:" -ForegroundColor Green
Write-Host "- O cache foi resolvido!" -ForegroundColor Green
Write-Host "- Agora o laudo deve salvar corretamente" -ForegroundColor Green
Write-Host ""
Write-Host "SE AINDA APARECER O LOG ANTIGO:" -ForegroundColor Red
Write-Host "- Copie a URL e abra em aba incognito" -ForegroundColor Red
Write-Host "- Ou tente outro navegador (Edge, Firefox)" -ForegroundColor Red