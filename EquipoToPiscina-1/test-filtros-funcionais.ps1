# TESTE FILTROS FUNCIONAIS - CORREÇÃO IMPLEMENTADA
# Data: 28 Dec 2025
# Objetivo: Testar se AMBOS os filtros (Unidade Escolar E Município) estão funcionando

Write-Host "=== TESTE FILTROS FUNCIONAIS - CORREÇÃO ===" -ForegroundColor Green
Write-Host "Testando correção baseada EXATAMENTE no código do Gilberto" -ForegroundColor Yellow

# Compilar o projeto
Write-Host "`n1. Compilando projeto..." -ForegroundColor Cyan
dotnet build --no-restore RDO-NET8-Migration/RdoApp.Core/

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Compilação bem-sucedida" -ForegroundColor Green
    
    Write-Host "`n2. Iniciando aplicação..." -ForegroundColor Cyan
    Write-Host "URL: https://localhost:7201/Obra/Escolher" -ForegroundColor Yellow
    Write-Host "`n📋 TESTE MANUAL DOS FILTROS CORRIGIDOS:" -ForegroundColor Magenta
    Write-Host "1. Faça login com CPF: 567.065.455-20, Senha: RXL8DjdYj6Y=" -ForegroundColor White
    Write-Host "2. Vá para a página de escolher obras" -ForegroundColor White
    Write-Host "3. ✅ TESTE FILTRO UNIDADE: Digite no campo 'Unidade escolar'" -ForegroundColor Green
    Write-Host "4. ✅ TESTE FILTRO MUNICÍPIO: Digite no campo 'Município'" -ForegroundColor Green
    Write-Host "5. Verifique se os cards são filtrados em tempo real" -ForegroundColor White
    Write-Host "6. Teste combinação dos dois filtros juntos" -ForegroundColor White
    Write-Host "`n🔧 CORREÇÕES APLICADAS:" -ForegroundColor Cyan
    Write-Host "- Removidas as duas caixas duplicadas (filter tabs)" -ForegroundColor White
    Write-Host "- Corrigido filtro município para buscar no primeiro <p>" -ForegroundColor White
    Write-Host "- Baseado EXATAMENTE no código do Gilberto" -ForegroundColor White
    Write-Host "`n⚠️  PRESSIONE CTRL+C PARA PARAR O SERVIDOR" -ForegroundColor Red
    
    # Iniciar aplicação
    dotnet run --project RDO-NET8-Migration/RdoApp.Core/ --no-build
} else {
    Write-Host "❌ Erro na compilação" -ForegroundColor Red
    Write-Host "Verifique os erros acima e corrija antes de testar" -ForegroundColor Yellow
}