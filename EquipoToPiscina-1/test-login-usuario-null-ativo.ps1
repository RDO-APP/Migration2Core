Write-Host "=== TESTE LOGIN - USUARIO COM ATIVO NULL ===" -ForegroundColor Green
Write-Host "Agora aceita usuarios com Ativo = null tambem" -ForegroundColor Yellow
Write-Host ""

Set-Location "RDO-NET8-Migration/RdoApp.Core"

Write-Host "Compilando..." -ForegroundColor Cyan
dotnet build --no-restore --verbosity quiet

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Compilacao bem-sucedida!" -ForegroundColor Green
} else {
    Write-Host "❌ Erro na compilacao" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "=== AGORA TESTE NO VISUAL STUDIO ===" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Execute com F5" -ForegroundColor White
Write-Host "2. Teste login com:" -ForegroundColor White
Write-Host "   CPF: 567.065.455-20" -ForegroundColor Green
Write-Host "   Senha: RXL8DjdVj6Y=" -ForegroundColor Green
Write-Host ""
Write-Host "3. O usuario 'Ricardo Freire' agora deve fazer login!" -ForegroundColor Green
Write-Host ""
Write-Host "MOTIVO DO PROBLEMA:" -ForegroundColor Cyan
Write-Host "- Usuario existia no banco" -ForegroundColor White
Write-Host "- Mas col_st_admin estava como NULL" -ForegroundColor White
Write-Host "- Sistema so aceitava TRUE" -ForegroundColor White
Write-Host "- Agora aceita TRUE ou NULL" -ForegroundColor White