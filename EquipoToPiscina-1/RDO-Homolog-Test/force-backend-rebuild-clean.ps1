# FORÇA RECOMPILACAO ESPECIFICA DO BACKEND C#
# O frontend ja funciona, mas o backend C# ainda esta com codigo antigo

Write-Host "=== FORÇA RECOMPILACAO BACKEND C# ===" -ForegroundColor Yellow
Write-Host "Frontend funcionando - Backend ainda com codigo antigo" -ForegroundColor Cyan
Write-Host ""

# 1. PARAR APLICACAO COMPLETAMENTE
Write-Host "1. Parando aplicacao completamente..." -ForegroundColor Cyan
try {
    Get-Process -Name "iisexpress" -ErrorAction SilentlyContinue | Stop-Process -Force
    Get-Process -Name "w3wp" -ErrorAction SilentlyContinue | Stop-Process -Force
    Get-Process -Name "devenv" -ErrorAction SilentlyContinue | Stop-Process -Force
    Write-Host "   Todos os processos finalizados" -ForegroundColor Green
} catch {
    Write-Host "   Alguns processos nao encontrados" -ForegroundColor Yellow
}

# 2. LIMPAR CACHE ESPECIFICO DO BACKEND
Write-Host "2. Limpando cache especifico do backend..." -ForegroundColor Cyan

# Limpar bin e obj mais agressivamente
$projectPath = "rdoappProject"
$binPath = "$projectPath\bin"
$objPath = "$projectPath\obj"

if (Test-Path $binPath) {
    # Forcar desbloqueio de arquivos
    Get-ChildItem $binPath -Recurse | ForEach-Object { 
        try { 
            $_.IsReadOnly = $false
            Remove-Item $_.FullName -Force -ErrorAction SilentlyContinue
        } catch {}
    }
    Remove-Item $binPath -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "   Pasta bin/ removida agressivamente" -ForegroundColor Green
}

if (Test-Path $objPath) {
    Get-ChildItem $objPath -Recurse | ForEach-Object { 
        try { 
            $_.IsReadOnly = $false
            Remove-Item $_.FullName -Force -ErrorAction SilentlyContinue
        } catch {}
    }
    Remove-Item $objPath -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "   Pasta obj/ removida agressivamente" -ForegroundColor Green
}

# 3. LIMPAR CACHE DO .NET FRAMEWORK
Write-Host "3. Limpando cache do .NET Framework..." -ForegroundColor Cyan
$tempAspNet = "$env:WINDOWS\Microsoft.NET\Framework64\v4.0.30319\Temporary ASP.NET Files"
if (Test-Path $tempAspNet) {
    try {
        Get-ChildItem $tempAspNet -Recurse -Force | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
        Write-Host "   Cache .NET Framework limpo" -ForegroundColor Green
    } catch {
        Write-Host "   Alguns arquivos nao puderam ser removidos" -ForegroundColor Yellow
    }
}

# 4. VERIFICAR ARQUIVOS C# ESPECIFICOS
Write-Host "4. Verificando arquivos C# criticos..." -ForegroundColor Cyan
$tarefaModel = "$projectPath\Api\Models\TarefaModel.cs"
$tarefaController = "$projectPath\Api\Controllers\TarefaController.cs"

if (Test-Path $tarefaModel) {
    $content = Get-Content $tarefaModel -Raw
    if ($content -match "DEBUG LAUDO - Iniciando salvamento") {
        Write-Host "   TarefaModel.cs contem logs debug" -ForegroundColor Green
    } else {
        Write-Host "   TarefaModel.cs NAO contem logs debug!" -ForegroundColor Red
    }
}

if (Test-Path $tarefaController) {
    $content = Get-Content $tarefaController -Raw
    if ($content -match "DEBUG LAUDO - Controller recebeu") {
        Write-Host "   TarefaController.cs contem logs debug" -ForegroundColor Green
    } else {
        Write-Host "   TarefaController.cs NAO contem logs debug!" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "=== LIMPEZA BACKEND COMPLETA ===" -ForegroundColor Green
Write-Host ""
Write-Host "PROXIMOS PASSOS CRITICOS:" -ForegroundColor Yellow
Write-Host "1. Abra Visual Studio Community 2022 COMO ADMINISTRADOR" -ForegroundColor White
Write-Host "2. Abra: rdoappProject\rdoappProject.sln" -ForegroundColor White
Write-Host "3. Compilar > Limpar Solucao" -ForegroundColor White
Write-Host "4. Compilar > Recompilar Solucao (aguarde completar 100%)" -ForegroundColor White
Write-Host "5. Verifique se nao ha erros de compilacao" -ForegroundColor White
Write-Host "6. F5 para executar" -ForegroundColor White
Write-Host ""
Write-Host "TESTE CRITICO:" -ForegroundColor Yellow
Write-Host "- Login: 567.065.455-20 / 1234" -ForegroundColor White
Write-Host "- Nova medicao > Salvar" -ForegroundColor White
Write-Host "- F12 DEVE mostrar logs do BACKEND:" -ForegroundColor White
Write-Host "  'DEBUG LAUDO - Controller recebeu: IdTarefa=X'" -ForegroundColor Cyan
Write-Host "  'DEBUG LAUDO - Iniciando salvamento - IdTarefa: X'" -ForegroundColor Cyan
Write-Host "  'DEBUG LAUDO - Tarefa encontrada: X, Etapa: Y'" -ForegroundColor Cyan
Write-Host "  'DEBUG LAUDO - SUCESSO - Salvo na tabela tarefa e laudo'" -ForegroundColor Cyan
Write-Host ""
Write-Host "Se os logs do BACKEND nao aparecerem, ha problema na recompilacao C#!" -ForegroundColor Red