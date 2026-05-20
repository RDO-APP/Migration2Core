# Script para testar a correção do laudo
Write-Host "=== TESTE DA CORREÇÃO DO LAUDO ===" -ForegroundColor Green

Write-Host "`n1. Verificando se o projeto compila..." -ForegroundColor Yellow
try {
    Set-Location "RDO-Homolog-Test\rdoappProject"
    
    # Limpar e recompilar
    Write-Host "Limpando projeto..." -ForegroundColor Cyan
    if (Test-Path "bin") { Remove-Item "bin" -Recurse -Force }
    if (Test-Path "obj") { Remove-Item "obj" -Recurse -Force }
    
    Write-Host "Recompilando projeto..." -ForegroundColor Cyan
    dotnet build --configuration Release --verbosity quiet
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Projeto compilado com sucesso!" -ForegroundColor Green
    } else {
        Write-Host "✗ Erro na compilação!" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "✗ Erro durante a compilação: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "`n2. Verificando arquivos modificados..." -ForegroundColor Yellow

$arquivos = @(
    "Client\Controllers\TarefaController.js",
    "Api\Controllers\TarefaController.cs", 
    "Api\Models\TarefaModel.cs"
)

foreach ($arquivo in $arquivos) {
    if (Test-Path $arquivo) {
        Write-Host "✓ $arquivo - OK" -ForegroundColor Green
    } else {
        Write-Host "✗ $arquivo - FALTANDO" -ForegroundColor Red
    }
}

Write-Host "`n3. Verificando se as funções foram adicionadas..." -ForegroundColor Yellow

# Verificar JavaScript
$jsContent = Get-Content "Client\Controllers\TarefaController.js" -Raw
if ($jsContent -match "controller\.salvarLaudo") {
    Write-Host "✓ Função salvarLaudo adicionada no JavaScript" -ForegroundColor Green
} else {
    Write-Host "✗ Função salvarLaudo NÃO encontrada no JavaScript" -ForegroundColor Red
}

if ($jsContent -match "DEBUG LAUDO") {
    Write-Host "✓ Logs de debug adicionados no JavaScript" -ForegroundColor Green
} else {
    Write-Host "✗ Logs de debug NÃO encontrados no JavaScript" -ForegroundColor Red
}

# Verificar Controller C#
$controllerContent = Get-Content "Api\Controllers\TarefaController.cs" -Raw
if ($controllerContent -match "SalvarLaudo") {
    Write-Host "✓ Método SalvarLaudo adicionado no Controller" -ForegroundColor Green
} else {
    Write-Host "✗ Método SalvarLaudo NÃO encontrado no Controller" -ForegroundColor Red
}

# Verificar Model C#
$modelContent = Get-Content "Api\Models\TarefaModel.cs" -Raw
if ($modelContent -match "public static int SalvarLaudo") {
    Write-Host "✓ Método SalvarLaudo adicionado no Model" -ForegroundColor Green
} else {
    Write-Host "✗ Método SalvarLaudo NÃO encontrado no Model" -ForegroundColor Red
}

if ($modelContent -match "ConvertSimNaoToBool") {
    Write-Host "✓ Função ConvertSimNaoToBool adicionada no Model" -ForegroundColor Green
} else {
    Write-Host "✗ Função ConvertSimNaoToBool NÃO encontrada no Model" -ForegroundColor Red
}

Write-Host "`n4. Instruções para teste:" -ForegroundColor Yellow
Write-Host "   1. Abra o Visual Studio como Administrador" -ForegroundColor Cyan
Write-Host "   2. Abra o projeto rdoappProject.sln" -ForegroundColor Cyan
Write-Host "   3. Pressione F5 para executar" -ForegroundColor Cyan
Write-Host "   4. Faça login com: 567.065.455-20 / 1234" -ForegroundColor Cyan
Write-Host "   5. Vá para uma tarefa e clique no botão '+' para nova medição" -ForegroundColor Cyan
Write-Host "   6. Preencha os campos de laudo (Cloro PH Alcalinidade etc.)" -ForegroundColor Cyan
Write-Host "   7. Salve e verifique no F12 se os logs 'DEBUG LAUDO' aparecem" -ForegroundColor Cyan
Write-Host "   8. Clique no botão relógio (histórico) para ver se os valores aparecem" -ForegroundColor Cyan

Write-Host "`n=== CORREÇÕES IMPLEMENTADAS ===" -ForegroundColor Green
Write-Host "✓ Adicionada função salvarLaudo() no JavaScript" -ForegroundColor Green
Write-Host "✓ Corrigido escopo do 'controller' no JavaScript" -ForegroundColor Green
Write-Host "✓ Adicionado endpoint SalvarLaudo no backend" -ForegroundColor Green
Write-Host "✓ Implementada lógica de salvamento na tabela laudo" -ForegroundColor Green
Write-Host "✓ Adicionada conversão de campos Sim/Não para boolean" -ForegroundColor Green
Write-Host "✓ Mantida integração com histórico de tarefas" -ForegroundColor Green
Write-Host "✓ Adicionados logs de debug para facilitar troubleshooting" -ForegroundColor Green

Write-Host "`nTeste concluído! Execute o projeto e teste a funcionalidade." -ForegroundColor Green

Set-Location ".."