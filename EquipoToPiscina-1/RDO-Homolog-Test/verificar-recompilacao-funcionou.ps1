# VERIFICAR SE A RECOMPILACAO FUNCIONOU

Write-Host "=== VERIFICANDO SE RECOMPILACAO FUNCIONOU ===" -ForegroundColor Yellow
Write-Host ""

# Verificar se os arquivos de debug existem
$tarefaModel = "rdoappProject\Api\Models\TarefaModel.cs"
$tarefaController = "rdoappProject\Api\Controllers\TarefaController.cs"

Write-Host "1. Verificando arquivos C# com logs de debug..." -ForegroundColor Cyan

if (Test-Path $tarefaModel) {
    $content = Get-Content $tarefaModel -Raw
    if ($content -match "DEBUG LAUDO - Iniciando salvamento") {
        Write-Host "   ✓ TarefaModel.cs tem logs de debug" -ForegroundColor Green
    } else {
        Write-Host "   ✗ TarefaModel.cs NAO tem logs de debug" -ForegroundColor Red
    }
} else {
    Write-Host "   ✗ TarefaModel.cs nao encontrado!" -ForegroundColor Red
}

if (Test-Path $tarefaController) {
    $content = Get-Content $tarefaController -Raw
    if ($content -match "DEBUG LAUDO - Controller recebeu") {
        Write-Host "   ✓ TarefaController.cs tem logs de debug" -ForegroundColor Green
    } else {
        Write-Host "   ✗ TarefaController.cs NAO tem logs de debug" -ForegroundColor Red
    }
} else {
    Write-Host "   ✗ TarefaController.cs nao encontrado!" -ForegroundColor Red
}

# Verificar se bin foi gerado
Write-Host ""
Write-Host "2. Verificando se compilacao gerou arquivos..." -ForegroundColor Cyan

$binPath = "rdoappProject\bin"
if (Test-Path $binPath) {
    $dllFiles = Get-ChildItem "$binPath\*.dll" -ErrorAction SilentlyContinue
    if ($dllFiles.Count -gt 0) {
        Write-Host "   ✓ Pasta bin/ tem $($dllFiles.Count) arquivos DLL" -ForegroundColor Green
        
        # Verificar data de modificacao mais recente
        $newestDll = $dllFiles | Sort-Object LastWriteTime -Descending | Select-Object -First 1
        $timeDiff = (Get-Date) - $newestDll.LastWriteTime
        
        if ($timeDiff.TotalMinutes -lt 10) {
            Write-Host "   ✓ DLL mais recente: $($newestDll.Name) (modificado ha $([math]::Round($timeDiff.TotalMinutes, 1)) minutos)" -ForegroundColor Green
        } else {
            Write-Host "   ⚠ DLL mais recente: $($newestDll.Name) (modificado ha $([math]::Round($timeDiff.TotalMinutes, 1)) minutos)" -ForegroundColor Yellow
            Write-Host "     Pode ser que a recompilacao nao funcionou completamente" -ForegroundColor Yellow
        }
    } else {
        Write-Host "   ✗ Pasta bin/ existe mas nao tem arquivos DLL!" -ForegroundColor Red
    }
} else {
    Write-Host "   ✗ Pasta bin/ nao existe!" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== RESULTADO DA VERIFICACAO ===" -ForegroundColor Yellow

# Verificar se Web.config existe
$webConfig = "rdoappProject\Web.config"
if (Test-Path $webConfig) {
    Write-Host "✓ Web.config existe" -ForegroundColor Green
} else {
    Write-Host "✗ Web.config NAO existe!" -ForegroundColor Red
}

Write-Host ""
Write-Host "AGORA TESTE:" -ForegroundColor Yellow
Write-Host "1. Execute a aplicacao (F5 no Visual Studio)" -ForegroundColor White
Write-Host "2. Login: 567.065.455-20 / 1234" -ForegroundColor White
Write-Host "3. Nova medicao > Preencher campos > Salvar" -ForegroundColor White
Write-Host "4. Pressione F12 e veja o Console" -ForegroundColor White
Write-Host ""
Write-Host "SE A RECOMPILACAO FUNCIONOU, voce deve ver:" -ForegroundColor Green
Write-Host "  'DEBUG LAUDO - Controller recebeu: IdTarefa=X'" -ForegroundColor Cyan
Write-Host "  'DEBUG LAUDO - Iniciando salvamento - IdTarefa: X'" -ForegroundColor Cyan
Write-Host "  'DEBUG LAUDO - Tarefa encontrada: X, Etapa: Y'" -ForegroundColor Cyan
Write-Host "  'DEBUG LAUDO - SUCESSO - Salvo na tabela tarefa e laudo'" -ForegroundColor Cyan
Write-Host ""
Write-Host "SE NAO APARECEREM ESSES LOGS:" -ForegroundColor Red
Write-Host "- A recompilacao nao funcionou" -ForegroundColor White
Write-Host "- O backend ainda esta com codigo antigo" -ForegroundColor White
Write-Host "- Precisa tentar uma abordagem diferente" -ForegroundColor White