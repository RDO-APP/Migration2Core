# OPEN BROWSER MANUALLY
# Abrir browser manualmente para testar a aplicacao

Write-Host "ABRINDO BROWSER PARA TESTAR APLICACAO..." -ForegroundColor Green
Write-Host ""

# Try common URLs
$urls = @(
    "https://localhost:7201",
    "http://localhost:5000", 
    "https://localhost:5001"
)

Write-Host "Tentando abrir as URLs da aplicacao..." -ForegroundColor Yellow

foreach ($url in $urls) {
    Write-Host "Abrindo: $url" -ForegroundColor Cyan
    try {
        Start-Process $url
        Start-Sleep -Seconds 2
    } catch {
        Write-Host "Erro ao abrir $url" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "INSTRUCOES:" -ForegroundColor Yellow
Write-Host "1. O browser deve ter aberto com as URLs" -ForegroundColor Yellow
Write-Host "2. Se aparecer aviso de certificado SSL, clique 'Avancado' > 'Continuar'" -ForegroundColor Yellow
Write-Host "3. A aplicacao deve mostrar a tela de login" -ForegroundColor Yellow
Write-Host "4. Use CPF: 567.065.455-20 e Senha: 1234" -ForegroundColor Yellow

Write-Host ""
Write-Host "Se nenhuma URL funcionar:" -ForegroundColor Red
Write-Host "- Verifique se a aplicacao ainda esta rodando no Visual Studio" -ForegroundColor Red
Write-Host "- Olhe na saida do VS para ver qual porta esta sendo usada" -ForegroundColor Red
Write-Host "- Tente parar (Shift+F5) e rodar novamente (F5)" -ForegroundColor Red

Write-Host ""
Write-Host "Browser aberto! Teste a aplicacao." -ForegroundColor Green