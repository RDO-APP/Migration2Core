# Testar configuração atual do banco homologa

Write-Host "=== TESTE CONFIGURAÇÃO BANCO HOMOLOGA ===" -ForegroundColor Green
Write-Host ""

# Verificar appsettings.json
$appsettingsPath = "RDO-NET8-Migration\RdoApp.Core\appsettings.json"
if (Test-Path $appsettingsPath) {
    $content = Get-Content $appsettingsPath -Raw | ConvertFrom-Json
    $connectionString = $content.ConnectionStrings.DefaultConnection
    
    Write-Host "Connection String atual:" -ForegroundColor Yellow
    Write-Host $connectionString -ForegroundColor White
    Write-Host ""
    
    if ($connectionString -like "*piscinas_rdoapp_homologa*") {
        Write-Host "Sistema configurado para banco HOMOLOGA" -ForegroundColor Green
    } else {
        Write-Host "Sistema NAO esta configurado para homologa" -ForegroundColor Red
    }
} else {
    Write-Host "appsettings.json nao encontrado!" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== PRÓXIMOS PASSOS ===" -ForegroundColor Yellow
Write-Host "1. Compile o projeto no Visual Studio (Ctrl+Shift+B)" -ForegroundColor White
Write-Host "2. Execute com F5" -ForegroundColor White
Write-Host "3. Teste login com:" -ForegroundColor White
Write-Host "   CPF: 567.065.455-20" -ForegroundColor Gray
Write-Host "   Senha: 1234" -ForegroundColor Gray
Write-Host ""
Write-Host "Se der erro, copie a mensagem EXATA do erro aqui." -ForegroundColor Cyan