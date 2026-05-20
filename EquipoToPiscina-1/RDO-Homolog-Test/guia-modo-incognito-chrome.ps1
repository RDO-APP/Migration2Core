#!/usr/bin/env pwsh

Write-Host "=== GUIA: MODO INCÓGNITO NO CHROME ===" -ForegroundColor Green

Write-Host "`n🌐 VOCÊ ESTÁ USANDO: Google Chrome" -ForegroundColor Cyan

Write-Host "`n📋 COMO ABRIR MODO INCÓGNITO:" -ForegroundColor Yellow
Write-Host "   MÉTODO 1 - ATALHO DE TECLADO (Mais Rápido):"
Write-Host "   1. Pressionar: Ctrl + Shift + N"
Write-Host "   2. Uma nova janela escura vai abrir"
Write-Host "   3. No topo vai aparecer: 'Você está navegando em modo incógnito'"
Write-Host ""
Write-Host "   MÉTODO 2 - PELO MENU:"
Write-Host "   1. Clicar nos 3 pontinhos (⋮) no canto superior direito"
Write-Host "   2. Clicar em 'Nova janela anônima'"
Write-Host "   3. Ou clicar em 'New incognito window' (se estiver em inglês)"

Write-Host "`n🔍 COMO IDENTIFICAR O MODO INCÓGNITO:" -ForegroundColor Cyan
Write-Host "   ✅ Janela com fundo ESCURO/PRETO"
Write-Host "   ✅ Ícone de 'óculos escuros' na barra de endereço"
Write-Host "   ✅ Texto: 'Você está navegando em modo incógnito'"
Write-Host "   ✅ Não salva histórico nem cache"

Write-Host "`n🎯 PASSOS APÓS ABRIR MODO INCÓGNITO:" -ForegroundColor Magenta
Write-Host "   1. Na janela incógnita, digitar na barra de endereço:"
Write-Host "      http://localhost:58951"
Write-Host "      (ou a porta que aparece no Visual Studio)"
Write-Host ""
Write-Host "   2. Fazer login: 567.065.455-20 / 1234"
Write-Host ""
Write-Host "   3. Escolher obra → etapa → tarefa"
Write-Host ""
Write-Host "   4. Preencher dados do laudo"
Write-Host ""
Write-Host "   5. Pressionar F12 para abrir DevTools"
Write-Host ""
Write-Host "   6. Clicar em 'Salvar'"

Write-Host "`n✅ LOGS ESPERADOS NO F12 (MODO INCÓGNITO):" -ForegroundColor Green
Write-Host "   Se o cache foi o problema, você deve ver:"
Write-Host "   ✅ === KIRO DEBUG START ==="
Write-Host "   ✅ DEBUG LAUDO - CACHE REFRESH TEST - Tarefa salva..."
Write-Host "   ✅ === RESPONSE COMPLETO === {Success: true, Id: [número]}"
Write-Host "   ✅ === KIRO DEBUG IDTAREFA ==="
Write-Host "   ✅ DEBUG IDTAREFA - response.Id: [número real]"

Write-Host "`n❌ SE AINDA MOSTRAR LOGS ANTIGOS:" -ForegroundColor Red
Write-Host "   - TarefaController.js:736 (sem KIRO DEBUG START)"
Write-Host "   - TarefaController.js:755 (logs antigos)"
Write-Host "   - Então o problema NÃO é cache do browser"

Write-Host "`n=== PRÓXIMO PASSO: Ctrl + Shift + N NO CHROME ===" -ForegroundColor Yellow