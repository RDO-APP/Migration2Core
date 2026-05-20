# FORÇA RECOMPILAÇÃO ESPECÍFICA DO BACKEND C#
# O frontend já funciona, mas o backend C# ainda está com código antigo

Write-Host "=== FORÇA RECOMPILAÇÃO BACKEND C# ===" -ForegroundColor Yellow
Write-Host "Frontend funcionando ✓ - Backend ainda com código antigo ✗" -ForegroundColor Cyan
Write-Host ""

# 1. PARAR APLICAÇÃO COMPLETAMENTE
Write-Host "1. Parando aplicação completamente..." -ForegroundColor Cyan
try {
    Get-Process -Name "iisexpress" -ErrorAction SilentlyContinue | Stop-Process -Force
    Get-Process -Name "w3wp" -ErrorAction SilentlyContinue | Stop-Process -Force
    Get-Process -Name "devenv" -ErrorAction SilentlyContinue | Stop-Process -Force
    Write-Host "   ✓ Todos os processos finalizados" -ForegroundColor Green
} catch {
    Write-Host "   ⚠ Alguns processos não encontrados" -ForegroundColor Yellow
}

# 2. LIMPAR CACHE ESPECÍFICO DO BACKEND
Write-Host "2. Limpando cache específico do backend..." -ForegroundColor Cyan

# Limpar bin e obj mais agressivamente
$projectPath = "rdoappProject"
$binPath = "$projectPath\bin"
$objPath = "$projectPath\obj"

if (Test-Path $binPath) {
    # Forçar desbloqueio de arquivos
    Get-ChildItem $binPath -Recurse | ForEach-Object { 
        try { 
            $_.IsReadOnly = $false
            Remove-Item $_.FullName -Force -ErrorAction SilentlyContinue
        } catch {}
    }
    Remove-Item $binPath -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "   ✓ Pasta bin/ removida agressivamente" -ForegroundColor Green
}

if (Test-Path $objPath) {
    Get-ChildItem $objPath -Recurse | ForEach-Object { 
        try { 
            $_.IsReadOnly = $false
            Remove-Item $_.FullName -Force -ErrorAction SilentlyContinue
        } catch {}
    }
    Remove-Item $objPath -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "   ✓ Pasta obj/ removida agressivamente" -ForegroundColor Green
}

# 3. LIMPAR CACHE DO .NET FRAMEWORK
Write-Host "3. Limpando cache do .NET Framework..." -ForegroundColor Cyan
$tempAspNet = "$env:WINDOWS\Microsoft.NET\Framework64\v4.0.30319\Temporary ASP.NET Files"
if (Test-Path $tempAspNet) {
    try {
        Get-ChildItem $tempAspNet -Recurse -Force | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
        Write-Host "   ✓ Cache .NET Framework limpo" -ForegroundColor Green
    } catch {
        Write-Host "   ⚠ Alguns arquivos não puderam ser removidos" -ForegroundColor Yellow
    }
}

# 4. LIMPAR CACHE DO VISUAL STUDIO
Write-Host "4. Limpando cache do Visual Studio..." -ForegroundColor Cyan
$vsCache = "$env:LOCALAPPDATA\Microsoft\VisualStudio"
if (Test-Path $vsCache) {
    try {
        Get-ChildItem "$vsCache\*\ComponentModelCache" -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
        Write-Host "   ✓ Cache Visual Studio limpo" -ForegroundColor Green
    } catch {
        Write-Host "   ⚠ Cache Visual Studio não encontrado" -ForegroundColor Yellow
    }
}

# 5. VERIFICAR ARQUIVOS C# ESPECÍFICOS
Write-Host "5. Verificando arquivos C# críticos..." -ForegroundColor Cyan
$tarefaModel = "$projectPath\Api\Models\TarefaModel.cs"
$tarefaController = "$projectPath\Api\Controllers\TarefaController.cs"

if (Test-Path $tarefaModel) {
    $content = Get-Content $tarefaModel -Raw
    if ($content -match "DEBUG LAUDO - Iniciando salvamento") {
        Write-Host "   ✓ TarefaModel.cs contém logs debug" -ForegroundColor Green
    } else {
        Write-Host "   ✗ TarefaModel.cs NÃO contém logs debug!" -ForegroundColor Red
    }
}

if (Test-Path $tarefaController) {
    $content = Get-Content $tarefaController -Raw
    if ($content -match "DEBUG LAUDO - Controller recebeu") {
        Write-Host "   ✓ TarefaController.cs contém logs debug" -ForegroundColor Green
    } else {
        Write-Host "   ✗ TarefaController.cs NÃO contém logs debug!" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "=== LIMPEZA BACKEND COMPLETA ===" -ForegroundColor Green
Write-Host ""
Write-Host "PRÓXIMOS PASSOS CRÍTICOS:" -ForegroundColor Yellow
Write-Host "1. Abra Visual Studio Community 2022 COMO ADMINISTRADOR" -ForegroundColor White
Write-Host "2. Abra: rdoappProject\rdoappProject.sln" -ForegroundColor White
Write-Host "3. Compilar > Limpar Solução" -ForegroundColor White
Write-Host "4. Compilar > Recompilar Solução (aguarde completar 100%)" -ForegroundColor White
Write-Host "5. Verifique se não há erros de compilação" -ForegroundColor White
Write-Host "6. F5 para executar" -ForegroundColor White
Write-Host ""
Write-Host "TESTE CRÍTICO:" -ForegroundColor Yellow
Write-Host "- Login: 567.065.455-20 / 1234" -ForegroundColor White
Write-Host "- Nova medição > Salvar" -ForegroundColor White
Write-Host "- F12 DEVE mostrar logs do BACKEND:" -ForegroundColor White
Write-Host "  'DEBUG LAUDO - Controller recebeu: IdTarefa=X'" -ForegroundColor Cyan
Write-Host "  'DEBUG LAUDO - Iniciando salvamento - IdTarefa: X'" -ForegroundColor Cyan
Write-Host "  'DEBUG LAUDO - Tarefa encontrada: X, Etapa: Y'" -ForegroundColor Cyan
Write-Host "  'DEBUG LAUDO - SUCESSO - Salvo na tabela tarefa e laudo'" -ForegroundColor Cyan
Write-Host ""
Write-Host "Se os logs do BACKEND não aparecerem, há problema na recompilação C#!" -ForegroundColor Red