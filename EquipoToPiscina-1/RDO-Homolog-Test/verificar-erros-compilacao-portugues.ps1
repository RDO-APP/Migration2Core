#!/usr/bin/env pwsh

Write-Host "=== VERIFICAR ERROS DE COMPILAÇÃO - VISUAL STUDIO PORTUGUÊS ===" -ForegroundColor Red

Write-Host "`n1. PROBLEMA IDENTIFICADO:" -ForegroundColor Yellow
Write-Host "   ❌ Backend ainda mostra 'IdTarefa=0' na Saída do Visual Studio"
Write-Host "   ❌ Isso significa que as mudanças no backend NÃO foram compiladas"
Write-Host "   ❌ Visual Studio está usando a versão antiga do código"

Write-Host "`n2. VERIFICAÇÕES IMEDIATAS NO VISUAL STUDIO:" -ForegroundColor Cyan
Write-Host "   1. Abrir janela 'Lista de Erros':"
Write-Host "      - Menu: Exibir → Lista de Erros"
Write-Host "      - Ou: View → Error List (se estiver em inglês)"
Write-Host "      - Ou: Ctrl+W, E"
Write-Host ""
Write-Host "   2. Procurar por ERROS EM VERMELHO (não avisos amarelos)"
Write-Host "   3. Especialmente erros relacionados a:"
Write-Host "      - 'SalvarComId'"
Write-Host "      - TarefaController.cs"
Write-Host "      - TarefaModel.cs"

Write-Host "`n3. AÇÕES PARA CORRIGIR:" -ForegroundColor Magenta
Write-Host "   A. SE HOUVER ERROS NA LISTA:"
Write-Host "      - Corrigir cada erro mostrado"
Write-Host "      - Menu: Compilar → Recompilar Solução"
Write-Host "      - Ou: Build → Rebuild Solution"
Write-Host "      - Executar novamente (F5)"
Write-Host ""
Write-Host "   B. SE NÃO HOUVER ERROS VISÍVEIS:"
Write-Host "      - Menu: Compilar → Limpar Solução"
Write-Host "      - Menu: Compilar → Recompilar Solução"
Write-Host "      - Executar novamente (F5)"

Write-Host "`n4. MENUS EM PORTUGUÊS:" -ForegroundColor Green
Write-Host "   - Exibir → Lista de Erros (para ver erros)"
Write-Host "   - Compilar → Limpar Solução (Clean Solution)"
Write-Host "   - Compilar → Recompilar Solução (Rebuild Solution)"
Write-Host "   - Depurar → Iniciar Depuração (F5)"

Write-Host "`n5. TESTE APÓS CORREÇÃO:" -ForegroundColor Green
Write-Host "   Na janela 'Saída' do Visual Studio deve aparecer:"
Write-Host "   ✅ DEBUG LAUDO - Controller recebeu: IdTarefa=[número real], NivelCloro=..."
Write-Host "   ✅ DEBUG LAUDO - Tarefa encontrada: [número], Etapa: ..."
Write-Host "   ✅ DEBUG LAUDO - Resultado do salvamento: True"
Write-Host ""
Write-Host "   ❌ Se ainda mostrar 'IdTarefa=0', o backend não foi atualizado"

Write-Host "`n6. ERROS COMUNS A PROCURAR:" -ForegroundColor Yellow
Write-Host "   - 'SalvarComId' não existe"
Write-Host "   - Erro de sintaxe em C#"
Write-Host "   - Tipo de retorno incorreto"
Write-Host "   - Parênteses ou chaves não fechadas"

Write-Host "`n=== PRÓXIMO PASSO: EXIBIR → LISTA DE ERROS NO VISUAL STUDIO ===" -ForegroundColor Yellow