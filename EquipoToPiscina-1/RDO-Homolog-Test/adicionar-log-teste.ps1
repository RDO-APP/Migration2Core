# ADICIONAR LOG DE TESTE NO BACKEND

Write-Host "=== ADICIONANDO LOG DE TESTE ===" -ForegroundColor Yellow

$tarefaModelPath = "rdoappProject\Api\Models\TarefaModel.cs"

# Fazer backup
Copy-Item $tarefaModelPath "$tarefaModelPath.backup" -Force
Write-Host "Backup criado: $tarefaModelPath.backup" -ForegroundColor Green

# Ler conteudo atual
$content = Get-Content $tarefaModelPath -Raw

# Verificar se ja tem o log de teste
if ($content -match "TESTE RECOMPILACAO FUNCIONANDO") {
    Write-Host "Log de teste ja existe no arquivo" -ForegroundColor Yellow
} else {
    # Adicionar log bem no inicio do metodo SalvarLaudo
    $newContent = $content -replace 
        '(public static bool SalvarLaudo\(TarefaLaudoViewModel laudoView\)\s*\{\s*using \(var context = new rdoappEntities\(\)\)\s*\{\s*try\s*\{)',
        '$1
                System.Diagnostics.Debug.WriteLine("=== TESTE RECOMPILACAO FUNCIONANDO ===");
                System.Diagnostics.Debug.WriteLine($"BACKEND RECEBEU CHAMADA - IdTarefa: {laudoView.IdTarefa}");'

    # Salvar arquivo modificado
    Set-Content $tarefaModelPath -Value $newContent -Encoding UTF8
    Write-Host "Log de teste adicionado ao metodo SalvarLaudo" -ForegroundColor Green
}

Write-Host ""
Write-Host "PROXIMOS PASSOS:" -ForegroundColor Yellow
Write-Host "1. Abra Visual Studio COMO ADMINISTRADOR" -ForegroundColor White
Write-Host "2. Recompile a aplicacao" -ForegroundColor White
Write-Host "3. Execute com F5" -ForegroundColor White
Write-Host "4. Teste salvar laudo" -ForegroundColor White
Write-Host "5. Verifique F12 Console" -ForegroundColor White
Write-Host ""
Write-Host "DEVE APARECER:" -ForegroundColor Green
Write-Host "=== TESTE RECOMPILACAO FUNCIONANDO ===" -ForegroundColor Cyan
Write-Host "BACKEND RECEBEU CHAMADA - IdTarefa: [numero]" -ForegroundColor Cyan