#!/usr/bin/env pwsh

Write-Host "🔍 DEBUG SISTEMÁTICO: Etapa/Tarefa Empty Page" -ForegroundColor Yellow
Write-Host "Seguindo o plano de 4 pontos específicos" -ForegroundColor Yellow
Write-Host "=" * 70

Write-Host "`n📋 MODIFICAÇÕES APLICADAS:" -ForegroundColor Cyan
Write-Host "✅ 1. Debug logs no método EscolherObra (verificar obraId)" -ForegroundColor Green
Write-Host "✅ 2. Debug logs detalhados no EtapaService (filtro ColaboradorId)" -ForegroundColor Green
Write-Host "✅ 3. Include das Tarefas já estava correto" -ForegroundColor Green
Write-Host "✅ 4. Criada view debug simplificada (sem ícones complexos)" -ForegroundColor Green

Write-Host "`n🎯 PLANO DE TESTE SISTEMÁTICO:" -ForegroundColor Cyan

Write-Host "`n1️⃣ VERIFICAR OBRAIDNO MÉTODO ESCOLHER" -ForegroundColor Yellow
Write-Host "   • Execute a aplicação" -ForegroundColor White
Write-Host "   • Faça login e escolha uma obra" -ForegroundColor White
Write-Host "   • Verifique logs: 'ObraId X salvo na sessão'" -ForegroundColor White
Write-Host "   • Verifique logs: 'Redirecionando para Etapas com obraId=X'" -ForegroundColor White

Write-Host "`n2️⃣ VERIFICAR FILTRO POR COLABORADORID" -ForegroundColor Yellow
Write-Host "   • Acesse: /Obra/EtapasDebug" -ForegroundColor White
Write-Host "   • Verifique logs do EtapaService:" -ForegroundColor White
Write-Host "     - 'ColaboradorId recebido: X'" -ForegroundColor Gray
Write-Host "     - 'Etapas encontradas no banco: X'" -ForegroundColor Gray
Write-Host "     - 'Tarefa Y: ColaboradorInsercaoId=Z'" -ForegroundColor Gray
Write-Host "     - 'Tarefas APÓS filtro por colaborador: X'" -ForegroundColor Gray

Write-Host "`n3️⃣ VERIFICAR INCLUDE DAS TAREFAS" -ForegroundColor Yellow
Write-Host "   • Já verificado - está correto no código" -ForegroundColor White
Write-Host "   • .Include(e => e.Tarefas).ThenInclude(t => t.Status)" -ForegroundColor Gray

Write-Host "`n4️⃣ VERIFICAR ÍCONES DE STATUS" -ForegroundColor Yellow
Write-Host "   • Compare /Obra/Etapas (versão normal)" -ForegroundColor White
Write-Host "   • Com /Obra/EtapasDebug (versão simplificada)" -ForegroundColor White
Write-Host "   • Se EtapasDebug funcionar e Etapas não = problema nos ícones" -ForegroundColor White

Write-Host "`n🚀 COMANDOS PARA EXECUTAR:" -ForegroundColor Cyan
Write-Host "cd RDO-NET8-Migration/RdoApp.Core" -ForegroundColor White
Write-Host "dotnet run" -ForegroundColor White

Write-Host "`n🌐 URLS PARA TESTAR:" -ForegroundColor Cyan
Write-Host "• Login: https://localhost:7001/Auth/Login" -ForegroundColor White
Write-Host "• Obras: https://localhost:7001/Obra/Escolher" -ForegroundColor White
Write-Host "• Etapas Normal: https://localhost:7001/Obra/Etapas" -ForegroundColor White
Write-Host "• Etapas Debug: https://localhost:7001/Obra/EtapasDebug" -ForegroundColor White

Write-Host "`n📊 LOGS ESPERADOS (EtapaService):" -ForegroundColor Cyan
Write-Host "=== DEBUG EtapaService.ObterEtapasViewModelAsync ===" -ForegroundColor Gray
Write-Host "ObraId recebido: 1" -ForegroundColor Gray
Write-Host "ColaboradorId recebido: 123" -ForegroundColor Gray
Write-Host "Etapas encontradas no banco: 5" -ForegroundColor Gray
Write-Host "  - Etapa 1: Descrição com 3 tarefas" -ForegroundColor Gray
Write-Host "--- Processando Etapa 1 ---" -ForegroundColor Gray
Write-Host "Total de tarefas na etapa: 3" -ForegroundColor Gray
Write-Host "  Tarefa 1: ColaboradorInsercaoId=123, Status=1" -ForegroundColor Gray
Write-Host "  Tarefa 2: ColaboradorInsercaoId=456, Status=2" -ForegroundColor Gray
Write-Host "Tarefas APÓS filtro por colaborador: 1" -ForegroundColor Gray
Write-Host "=== RESULTADO FINAL: 5 etapas no ViewModel ===" -ForegroundColor Gray

Write-Host "`n🔍 POSSÍVEIS RESULTADOS:" -ForegroundColor Cyan
Write-Host "• Se 'Etapas encontradas no banco: 0' → Não há dados" -ForegroundColor White
Write-Host "• Se 'Tarefas APÓS filtro: 0' → Filtro colaborador eliminando tudo" -ForegroundColor White
Write-Host "• Se EtapasDebug funciona mas Etapas não → Problema nos ícones" -ForegroundColor White
Write-Host "• Se ambos não funcionam → Problema no service/controller" -ForegroundColor White

Write-Host "`n🎯 EXECUTE E REPORTE OS LOGS!" -ForegroundColor Green