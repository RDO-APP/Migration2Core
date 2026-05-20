# DEBUG DETALHADO - ACESSO ÀS OBRAS
# Testa todos os pontos possíveis de falha

Write-Host "=== DEBUG DETALHADO ACESSO OBRAS ===" -ForegroundColor Cyan
Write-Host ""

Write-Host "1. Testando endpoint /Obra/Escolher..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "https://localhost:7201/Obra/Escolher" -UseBasicParsing -TimeoutSec 10
    Write-Host "✅ Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "✅ Endpoint acessível" -ForegroundColor Green
} catch {
    Write-Host "❌ Erro ao acessar endpoint: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

Write-Host "2. Verificando se aplicação está rodando..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "https://localhost:7201" -UseBasicParsing -TimeoutSec 5
    Write-Host "✅ Aplicação rodando na porta 7201" -ForegroundColor Green
} catch {
    Write-Host "❌ Aplicação não está rodando: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

Write-Host "3. Testando endpoint de login..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "https://localhost:7201/Auth/Login" -UseBasicParsing -TimeoutSec 5
    Write-Host "✅ Login endpoint acessível" -ForegroundColor Green
} catch {
    Write-Host "❌ Erro no login endpoint: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

Write-Host "4. Verificando arquivos críticos..." -ForegroundColor Yellow
$arquivos = @(
    "RDO-NET8-Migration/RdoApp.Core/Controllers/ObraController.cs",
    "RDO-NET8-Migration/RdoApp.Core/Views/Obra/Escolher.cshtml",
    "RDO-NET8-Migration/RdoApp.Core/Controllers/AuthController.cs"
)

foreach ($arquivo in $arquivos) {
    if (Test-Path $arquivo) {
        Write-Host "✅ $arquivo" -ForegroundColor Green
    } else {
        Write-Host "❌ $arquivo - NÃO ENCONTRADO" -ForegroundColor Red
    }
}
Write-Host ""

Write-Host "5. INSTRUÇÕES PARA DEBUG NO VISUAL STUDIO:" -ForegroundColor Magenta
Write-Host "   a) Coloque breakpoint no ObraController.Escolher()" -ForegroundColor White
Write-Host "   b) Faça login e tente acessar obras" -ForegroundColor White
Write-Host "   c) Verifique se o breakpoint é atingido" -ForegroundColor White
Write-Host "   d) Verifique o valor de 'userId' na query" -ForegroundColor White
Write-Host "   e) Verifique se a query retorna obras" -ForegroundColor White
Write-Host ""

Write-Host "6. VERIFICAR LOGS NO VISUAL STUDIO:" -ForegroundColor Magenta
Write-Host "   - Janela Output > Show output from: Debug" -ForegroundColor White
Write-Host "   - Procurar por erros ou exceções" -ForegroundColor White
Write-Host "   - Verificar se há erros de SQL/Entity Framework" -ForegroundColor White
Write-Host ""

Write-Host "7. TESTE MANUAL SUGERIDO:" -ForegroundColor Magenta
Write-Host "   1. Faça login com CPF: 567.065.455-20" -ForegroundColor White
Write-Host "   2. Após login, acesse manualmente: https://localhost:7201/Obra/Escolher" -ForegroundColor White
Write-Host "   3. Observe se há erro 500, 404 ou página em branco" -ForegroundColor White
Write-Host "   4. Abra F12 (Developer Tools) e verifique Console" -ForegroundColor White