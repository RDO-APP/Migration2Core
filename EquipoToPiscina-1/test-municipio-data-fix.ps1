#!/usr/bin/env pwsh

Write-Host "🔧 TESTE: CORREÇÃO DADOS MUNICÍPIO - OBRAS" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "📋 PROBLEMA IDENTIFICADO:" -ForegroundColor Yellow
Write-Host "- Todas as obras mostravam o mesmo município (Salvador, BA)" -ForegroundColor Red
Write-Host "- Era um placeholder hardcoded, não dados reais do banco" -ForegroundColor Red
Write-Host ""

Write-Host "✅ CORREÇÕES APLICADAS:" -ForegroundColor Green
Write-Host "1. Adicionada navigation property Municipio na entidade Obra" -ForegroundColor White
Write-Host "2. Configurado relacionamento Obra -> Municipio -> Uf" -ForegroundColor White
Write-Host "3. Query atualizada para incluir dados reais: Municipio.Descricao + '/' + Uf.Sigla" -ForegroundColor White
Write-Host "4. Baseado EXATAMENTE no código do Gilberto" -ForegroundColor White
Write-Host ""

Write-Host "🎯 RESULTADO ESPERADO:" -ForegroundColor Magenta
Write-Host "- Cada obra deve mostrar seu município real do banco de dados" -ForegroundColor White
Write-Host "- Formato: 'NomeMunicipio/SiglaUF' (ex: 'Salvador/BA', 'São Paulo/SP')" -ForegroundColor White
Write-Host "- Filtro de município deve funcionar com dados reais" -ForegroundColor White
Write-Host ""

Write-Host "🚀 EXECUTANDO TESTE..." -ForegroundColor Cyan

try {
    # Navegar para o diretório do projeto
    Set-Location "RDO-NET8-Migration/RdoApp.Core"
    
    Write-Host "📦 Compilando projeto..." -ForegroundColor Yellow
    dotnet build --no-restore --verbosity quiet
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Compilação bem-sucedida!" -ForegroundColor Green
        
        Write-Host ""
        Write-Host "🌐 TESTE MANUAL NECESSÁRIO:" -ForegroundColor Yellow
        Write-Host "1. Execute F5 no Visual Studio" -ForegroundColor White
        Write-Host "2. Faça login: CPF: 567.065.455-20, Senha: RXL8DjdYj6Y=" -ForegroundColor White
        Write-Host "3. Vá para /Obra/Escolher" -ForegroundColor White
        Write-Host "4. Verifique se cada obra mostra município diferente" -ForegroundColor White
        Write-Host "5. Teste o filtro de município com nomes reais" -ForegroundColor White
        Write-Host ""
        
        Write-Host "📊 DADOS ESPERADOS NO BANCO HOMOLOG:" -ForegroundColor Cyan
        Write-Host "- Obras com municípios variados (não todos 'Salvador/BA')" -ForegroundColor White
        Write-Host "- Filtro funcionando com nomes reais de cidades" -ForegroundColor White
        
    } else {
        Write-Host "❌ Erro na compilação!" -ForegroundColor Red
        Write-Host "Verifique os erros acima e corrija antes de testar." -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "❌ Erro durante o teste: $($_.Exception.Message)" -ForegroundColor Red
} finally {
    # Voltar ao diretório raiz
    Set-Location "../.."
}

Write-Host ""
Write-Host "🎯 PRÓXIMO PASSO:" -ForegroundColor Magenta
Write-Host "Após confirmar que os municípios estão corretos, implementar os botões de navegação!" -ForegroundColor White