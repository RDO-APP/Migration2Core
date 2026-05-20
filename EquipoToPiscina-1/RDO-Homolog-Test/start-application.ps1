# Script para iniciar a aplicação e verificar problemas
# Execute no PowerShell

Write-Host "=== INICIANDO APLICAÇÃO RDO HOMOLOG ===" -ForegroundColor Green
Write-Host ""

Write-Host "1. VERIFICANDO SE O VISUAL STUDIO ESTÁ ABERTO..." -ForegroundColor Cyan
$vsProcess = Get-Process "devenv" -ErrorAction SilentlyContinue
if ($vsProcess) {
    Write-Host "   ✅ Visual Studio está rodando" -ForegroundColor Green
} else {
    Write-Host "   ❌ Visual Studio não está rodando" -ForegroundColor Red
    Write-Host "   📝 Abra o Visual Studio e carregue o projeto:" -ForegroundColor Yellow
    Write-Host "      RDO-Homolog-Test/rdoappProject/rdoappProject.sln" -ForegroundColor White
}
Write-Host ""

Write-Host "2. VERIFICANDO SE A APLICAÇÃO ESTÁ RODANDO..." -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5051" -TimeoutSec 5 -ErrorAction Stop
    Write-Host "   ✅ Aplicação está rodando na porta 5051" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Aplicação não está rodando" -ForegroundColor Red
    Write-Host "   📝 No Visual Studio, pressione F5 para iniciar" -ForegroundColor Yellow
}
Write-Host ""

Write-Host "3. PASSOS PARA INICIAR A APLICAÇÃO:" -ForegroundColor Cyan
Write-Host "   1. Abra o Visual Studio" -ForegroundColor White
Write-Host "   2. File > Open > Project/Solution" -ForegroundColor White
Write-Host "   3. Navegue até: RDO-Homolog-Test/rdoappProject/rdoappProject.sln" -ForegroundColor White
Write-Host "   4. Pressione F5 ou clique em 'Start'" -ForegroundColor White
Write-Host "   5. Aguarde a compilação" -ForegroundColor White
Write-Host "   6. O navegador deve abrir automaticamente" -ForegroundColor White
Write-Host ""

Write-Host "4. SE HOUVER ERROS DE COMPILAÇÃO:" -ForegroundColor Cyan
Write-Host "   - Verifique a aba 'Error List' no Visual Studio" -ForegroundColor White
Write-Host "   - Procure por erros relacionados ao Entity Framework" -ForegroundColor White
Write-Host "   - Verifique se todos os pacotes NuGet foram restaurados" -ForegroundColor White
Write-Host ""

Write-Host "5. VERIFICAR PORTA DA APLICAÇÃO:" -ForegroundColor Cyan
Write-Host "   - No Visual Studio, clique com botão direito no projeto" -ForegroundColor White
Write-Host "   - Properties > Web" -ForegroundColor White
Write-Host "   - Verifique se a porta está configurada como 5051" -ForegroundColor White
Write-Host ""

Write-Host "6. APÓS INICIAR, TESTE:" -ForegroundColor Cyan
Write-Host "   - http://localhost:5051 (página inicial)" -ForegroundColor White
Write-Host "   - http://localhost:5051/tarefa/cards (página das tarefas)" -ForegroundColor White
Write-Host ""

Write-Host "=== EXECUTE ESTES PASSOS E ME INFORME O RESULTADO ===" -ForegroundColor Yellow