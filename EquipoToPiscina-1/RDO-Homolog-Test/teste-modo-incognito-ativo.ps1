#!/usr/bin/env pwsh

Write-Host "=== MODO INCÓGNITO ATIVO - PRÓXIMOS PASSOS ===" -ForegroundColor Green

Write-Host "`n✅ CONFIRMADO: MODO INCÓGNITO FUNCIONANDO" -ForegroundColor Cyan
Write-Host "   - Tela mostra: 'Você entrou no modo de navegação anônima'"
Write-Host "   - Ícone dos óculos escuros visível"
Write-Host "   - Fundo escuro característico"
Write-Host "   - Cache do browser foi limpo"

Write-Host "`n📋 PRÓXIMOS PASSOS CRÍTICOS:" -ForegroundColor Yellow
Write-Host "   1. Na barra de endereço, digitar:"
Write-Host "      http://localhost:58951"
Write-Host "      (ou a porta que aparece no Visual Studio)"
Write-Host ""
Write-Host "   2. Fazer login:"
Write-Host "      Usuário: 567.065.455-20"
Write-Host "      Senha: 1234"
Write-Host ""
Write-Host "   3. Escolher obra → etapa → tarefa"
Write-Host ""
Write-Host "   4. ANTES de preencher laudo:"
Write-Host "      - Pressionar F12 para abrir DevTools"
Write-Host "      - Ir na aba Console"
Write-Host ""
Write-Host "   5. Preencher dados do laudo"
Write-Host ""
Write-Host "   6. Clicar 'Salvar'"

Write-Host "`n🎯 LOGS DECISIVOS NO F12 CONSOLE:" -ForegroundColor Magenta
Write-Host "   SE CACHE ERA O PROBLEMA (logs novos):"
Write-Host "   ✅ === KIRO DEBUG START ==="
Write-Host "   ✅ DEBUG LAUDO - CACHE REFRESH TEST - Tarefa salva..."
Write-Host "   ✅ === RESPONSE COMPLETO === {Success: true, Id: [número]}"
Write-Host "   ✅ === KIRO DEBUG IDTAREFA ==="
Write-Host ""
Write-Host "   SE CACHE NÃO ERA O PROBLEMA (logs antigos):"
Write-Host "   ❌ TarefaController.js:736 DEBUG LAUDO - Tarefa salva..."
Write-Host "   ❌ TarefaController.js:755 DEBUG LAUDO - NivelCloro..."
Write-Host "   ❌ (sem aparecer KIRO DEBUG START)"

Write-Host "`n⚡ TESTE DECISIVO:" -ForegroundColor Red
Write-Host "   Este teste vai determinar se o problema é:"
Write-Host "   - Cache do browser (se logs novos aparecerem)"
Write-Host "   - Problema mais profundo (se logs antigos persistirem)"

Write-Host "`n🔍 TAMBÉM VERIFICAR:" -ForegroundColor Cyan
Write-Host "   Visual Studio Saída deve mostrar:"
Write-Host "   ✅ DEBUG LAUDO - Controller recebeu: IdTarefa=[número real]"
Write-Host "   ❌ Se ainda mostrar IdTarefa=0, problema persiste"

Write-Host "`n=== AGORA DIGITE A URL NO MODO INCÓGNITO ===" -ForegroundColor Yellow