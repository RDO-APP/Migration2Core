Write-Host "=== TESTE LOGIN COM DEBUG DETALHADO ===" -ForegroundColor Green
Write-Host ""

Set-Location "RDO-NET8-Migration/RdoApp.Core"

Write-Host "1. Compilando com logs detalhados..." -ForegroundColor Cyan
dotnet build --no-restore --verbosity quiet

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Compilacao bem-sucedida!" -ForegroundColor Green
} else {
    Write-Host "❌ Erro na compilacao" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "=== INSTRUCOES PARA TESTE ===" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. EXECUTE NO VISUAL STUDIO:" -ForegroundColor White
Write-Host "   - Pressione F5 para executar" -ForegroundColor Gray
Write-Host "   - Aguarde o browser abrir" -ForegroundColor Gray
Write-Host ""
Write-Host "2. TESTE LOGIN COM:" -ForegroundColor White
Write-Host "   CPF: 567.065.455-20" -ForegroundColor Yellow
Write-Host "   Senha: RXL8DjdVj6Y=" -ForegroundColor Yellow
Write-Host ""
Write-Host "3. VERIFIQUE OS LOGS:" -ForegroundColor White
Write-Host "   - No Visual Studio: View -> Output" -ForegroundColor Gray
Write-Host "   - Selecione 'Debug' no dropdown" -ForegroundColor Gray
Write-Host "   - Procure por '=== INICIO LOGIN DEBUG ==='" -ForegroundColor Gray
Write-Host ""
Write-Host "4. EXECUTE TAMBEM NO DBEAVER:" -ForegroundColor White
Write-Host "   - Abra o arquivo: verificar-dados-banco-real.sql" -ForegroundColor Gray
Write-Host "   - Execute todas as queries" -ForegroundColor Gray
Write-Host "   - Verifique se existem dados na tabela colaborador" -ForegroundColor Gray
Write-Host ""
Write-Host "=== O QUE OS LOGS VAO MOSTRAR ===" -ForegroundColor Cyan
Write-Host "- CPF recebido e formatado" -ForegroundColor White
Write-Host "- Total de colaboradores no banco" -ForegroundColor White
Write-Host "- Primeiros 5 colaboradores" -ForegroundColor White
Write-Host "- Se o usuario foi encontrado" -ForegroundColor White
Write-Host "- Comparacao detalhada das senhas" -ForegroundColor White
Write-Host ""
Write-Host "AGORA TESTE E ME DIGA O QUE APARECEU NOS LOGS!" -ForegroundColor Green