#!/usr/bin/env pwsh

Write-Host "🔧 TESTE: CORREÇÃO DADOS REAIS CARDS OBRA" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "📋 PROBLEMAS IDENTIFICADOS PELO USUÁRIO:" -ForegroundColor Yellow
Write-Host "1. Município já foi corrigido ✅" -ForegroundColor Green
Write-Host "2. Tipo de assinatura (gratuita/básica) estava hardcoded" -ForegroundColor Red
Write-Host "3. Perfil de acesso (Diretor Contratada) não aparecia" -ForegroundColor Red
Write-Host "4. Palavra 'STATUS' vem do HTML do Gilberto" -ForegroundColor Yellow
Write-Host "5. Barras de progresso todas com mesma cor" -ForegroundColor Red
Write-Host ""

Write-Host "✅ CORREÇÕES APLICADAS:" -ForegroundColor Green
Write-Host "1. StatusBasicaGratuita = nome do grupo do usuário (BÁSICA, GRATUITA, etc.)" -ForegroundColor White
Write-Host "2. ContratanteContratada = baseado no grupo.gru_st_contratante" -ForegroundColor White
Write-Host "3. ProgressoPorcentagem = cálculo real baseado nas datas" -ForegroundColor White
Write-Host "4. ClasseStatusCss = cores diferentes (bg-verde, bg-vermelho, bg-cinza)" -ForegroundColor White
Write-Host "5. Adicionada navigation property ObraColaboradores" -ForegroundColor White
Write-Host "6. Query com Include para Grupo e relacionamentos" -ForegroundColor White
Write-Host ""

Write-Host "🎯 MAPEAMENTO EXATO GILBERTO → NOSSA VERSÃO:" -ForegroundColor Magenta
Write-Host "StatusBasicaGratuita: grupo.gru_nm_nome → oc.Grupo.Nome" -ForegroundColor White
Write-Host "ContratanteContratada: grupo.gru_st_contratante → oc.Grupo.StatusContratante" -ForegroundColor White
Write-Host "ProgressoPorcentagem: ProgressoPorcentagem(obra) → CalcularProgressoPorcentagem()" -ForegroundColor White
Write-Host "ClasseStatusCss: ClasseStatusCss(obra) → DeterminarClasseStatusCss()" -ForegroundColor White
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
        Write-Host ""
        
        Write-Host "🔍 VERIFICAR NOS CARDS:" -ForegroundColor Cyan
        Write-Host "✅ Município: Cada obra com município diferente" -ForegroundColor Green
        Write-Host "🔍 Tipo Assinatura: (BÁSICA), (GRATUITA), etc. em vez de hardcoded" -ForegroundColor Yellow
        Write-Host "🔍 Perfil Acesso: Baseado no grupo do usuário logado" -ForegroundColor Yellow
        Write-Host "🔍 Barras Progresso: Cores diferentes (verde/vermelho/cinza)" -ForegroundColor Yellow
        Write-Host "🔍 Percentual: Cálculo real baseado nas datas da obra" -ForegroundColor Yellow
        Write-Host ""
        
        Write-Host "📊 DADOS ESPERADOS:" -ForegroundColor Cyan
        Write-Host "- StatusBasicaGratuita: Nome real do grupo (não 'BÁSICA/GRATUITA')" -ForegroundColor White
        Write-Host "- ContratanteContratada: 'contratante' ou 'contratada'" -ForegroundColor White
        Write-Host "- ProgressoPorcentagem: 0-100% baseado em datas reais" -ForegroundColor White
        Write-Host "- ClasseStatusCss: bg-verde, bg-vermelho ou bg-cinza" -ForegroundColor White
        
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
Write-Host "Após confirmar que os dados estão corretos, implementar botões de navegação!" -ForegroundColor White