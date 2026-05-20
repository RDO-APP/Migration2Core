# VERIFICAR RECOMPILACAO SIMPLES

Write-Host "=== VERIFICANDO RECOMPILACAO ===" -ForegroundColor Yellow

# Verificar bin
$binPath = "rdoappProject\bin"
if (Test-Path $binPath) {
    $dllFiles = Get-ChildItem "$binPath\*.dll" -ErrorAction SilentlyContinue
    Write-Host "Arquivos DLL encontrados: $($dllFiles.Count)" -ForegroundColor Green
    
    if ($dllFiles.Count -gt 0) {
        $newest = $dllFiles | Sort-Object LastWriteTime -Descending | Select-Object -First 1
        $minutes = [math]::Round(((Get-Date) - $newest.LastWriteTime).TotalMinutes, 1)
        Write-Host "DLL mais recente: $($newest.Name) (ha $minutes minutos)" -ForegroundColor Cyan
    }
} else {
    Write-Host "Pasta bin/ nao existe!" -ForegroundColor Red
}

# Verificar logs debug
$tarefaModel = "rdoappProject\Api\Models\TarefaModel.cs"
if (Test-Path $tarefaModel) {
    $content = Get-Content $tarefaModel -Raw
    if ($content -match "DEBUG LAUDO") {
        Write-Host "TarefaModel.cs tem logs debug" -ForegroundColor Green
    } else {
        Write-Host "TarefaModel.cs NAO tem logs debug" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "AGORA TESTE A APLICACAO:" -ForegroundColor Yellow
Write-Host "1. F5 no Visual Studio" -ForegroundColor White
Write-Host "2. Login: 567.065.455-20 / 1234" -ForegroundColor White
Write-Host "3. Nova medicao > Salvar" -ForegroundColor White
Write-Host "4. F12 Console - deve mostrar logs DEBUG LAUDO" -ForegroundColor White