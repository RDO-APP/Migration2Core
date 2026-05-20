# Configurar sistema para usar banco homologa

Write-Host "Configurando sistema para banco homologa..." -ForegroundColor Yellow

$appsettingsPath = "RDO-NET8-Migration\RdoApp.Core\appsettings.json"

if (Test-Path $appsettingsPath) {
    # Fazer backup
    Copy-Item $appsettingsPath "$appsettingsPath.backup" -Force
    
    # Ler e modificar connection string
    $content = Get-Content $appsettingsPath -Raw | ConvertFrom-Json
    $content.ConnectionStrings.DefaultConnection = "Server=localhost;Database=piscinas_rdoapp_homologa;Uid=rdoadmin;Pwd=rdoapp2024;Charset=utf8mb4;"
    
    # Salvar
    $content | ConvertTo-Json -Depth 10 | Set-Content $appsettingsPath -Encoding UTF8
    
    Write-Host "Connection string alterada para banco homologa" -ForegroundColor Green
} else {
    Write-Host "appsettings.json nao encontrado!" -ForegroundColor Red
}

Write-Host ""
Write-Host "AGORA:" -ForegroundColor Yellow
Write-Host "1. Execute este SQL no DBeaver (banco homologa):" -ForegroundColor White
Write-Host "   SHOW TABLES;" -ForegroundColor Gray
Write-Host "2. Verifique se as tabelas existem e tem dados" -ForegroundColor White