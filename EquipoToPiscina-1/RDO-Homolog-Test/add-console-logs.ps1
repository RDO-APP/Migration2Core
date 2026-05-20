# ADICIONAR LOGS CONSOLE PARA DEBUG

Write-Host "=== ADICIONANDO LOGS CONSOLE VISIVEIS ===" -ForegroundColor Yellow
Write-Host ""

$tarefaModelPath = "rdoappProject\Api\Models\TarefaModel.cs"

if (Test-Path $tarefaModelPath) {
    $content = Get-Content $tarefaModelPath -Raw
    
    # Adicionar Console.WriteLine junto com Debug.WriteLine
    $newContent = $content -replace 'System\.Diagnostics\.Debug\.WriteLine\("LAUDO START"\);', 'System.Diagnostics.Debug.WriteLine("LAUDO START"); Console.WriteLine("=== CONSOLE: LAUDO START ===");'
    
    $newContent = $newContent -replace 'System\.Diagnostics\.Debug\.WriteLine\(\$"BACKEND: \{laudoView\.IdTarefa\}"\);', 'System.Diagnostics.Debug.WriteLine($"BACKEND: {laudoView.IdTarefa}"); Console.WriteLine($"=== CONSOLE: BACKEND IdTarefa={laudoView.IdTarefa} ===");'
    
    $newContent = $newContent -replace 'System\.Diagnostics\.Debug\.WriteLine\(\$"DEBUG LAUDO - Tarefa encontrada: \{tarefa\.tar_id_tarefa\}, Etapa: \{tarefa\.tar_id_etapa\}"\);', 'System.Diagnostics.Debug.WriteLine($"DEBUG LAUDO - Tarefa encontrada: {tarefa.tar_id_tarefa}, Etapa: {tarefa.tar_id_etapa}"); Console.WriteLine($"=== CONSOLE: Tarefa {tarefa.tar_id_tarefa}, Etapa {tarefa.tar_id_etapa} ===");'
    
    $newContent = $newContent -replace 'System\.Diagnostics\.Debug\.WriteLine\(\$"DEBUG LAUDO - SUCESSO - Salvo na tabela laudo \(ID: \{laudo\.lau_id_laudo\}\)"\);', 'System.Diagnostics.Debug.WriteLine($"DEBUG LAUDO - SUCESSO - Salvo na tabela laudo (ID: {laudo.lau_id_laudo})"); Console.WriteLine($"=== CONSOLE: SUCESSO - Laudo ID={laudo.lau_id_laudo} ===");'
    
    $newContent = $newContent -replace 'System\.Diagnostics\.Debug\.WriteLine\(\$"DEBUG LAUDO - ERRO COMPLETO: \{ex\.Message\}"\);', 'System.Diagnostics.Debug.WriteLine($"DEBUG LAUDO - ERRO COMPLETO: {ex.Message}"); Console.WriteLine($"=== CONSOLE: ERRO - {ex.Message} ===");'
    
    Set-Content $tarefaModelPath $newContent -Encoding UTF8
    Write-Host "   Console.WriteLine adicionado aos logs principais" -ForegroundColor Green
}

Write-Host ""
Write-Host "=== LOGS CONSOLE ADICIONADOS ===" -ForegroundColor Green
Write-Host ""
Write-Host "AGORA:" -ForegroundColor Yellow
Write-Host "1. Pare a aplicacao (Shift+F5)" -ForegroundColor White
Write-Host "2. Recompile (Build > Rebuild Solution)" -ForegroundColor White
Write-Host "3. Execute (F5)" -ForegroundColor White
Write-Host "4. Teste o salvamento do laudo" -ForegroundColor White
Write-Host ""
Write-Host "OS LOGS DEVEM APARECER:" -ForegroundColor Green
Write-Host "- Na janela Saida do Visual Studio" -ForegroundColor White
Write-Host "- Com prefixo '=== CONSOLE:'" -ForegroundColor White
Write-Host "- Incluindo detalhes do erro se houver" -ForegroundColor White