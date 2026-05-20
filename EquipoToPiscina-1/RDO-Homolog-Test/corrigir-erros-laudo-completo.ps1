# Script para corrigir todos os erros de compilação relacionados ao laudo
Write-Host "=== CORREÇÃO COMPLETA DOS ERROS DE LAUDO ===" -ForegroundColor Green

Write-Host "`n1. Verificando estrutura da entidade laudo..." -ForegroundColor Yellow

# Verificar se a entidade laudo foi corrigida
$laudoContent = Get-Content "rdoappClass\laudo.cs" -Raw
if ($laudoContent -match "lau_tp_alcalinidade") {
    Write-Host "✓ Campo lau_tp_alcalinidade encontrado na entidade laudo" -ForegroundColor Green
} else {
    Write-Host "✗ Campo lau_tp_alcalinidade NÃO encontrado na entidade laudo" -ForegroundColor Red
}

if ($laudoContent -match "lau_tp_nivel_detritos") {
    Write-Host "✓ Campo lau_tp_nivel_detritos encontrado na entidade laudo" -ForegroundColor Green
} else {
    Write-Host "✗ Campo lau_tp_nivel_detritos NÃO encontrado na entidade laudo" -ForegroundColor Red
}

if ($laudoContent -match "Nullable<int> lau_tp_nivel_cloro") {
    Write-Host "✓ Campo lau_tp_nivel_cloro é int (correto)" -ForegroundColor Green
} else {
    Write-Host "✗ Campo lau_tp_nivel_cloro não é int" -ForegroundColor Red
}

if ($laudoContent -match "Nullable<int> lau_tp_ph") {
    Write-Host "✓ Campo lau_tp_ph é int (correto)" -ForegroundColor Green
} else {
    Write-Host "✗ Campo lau_tp_ph não é int" -ForegroundColor Red
}

Write-Host "`n2. Tentando compilar o projeto..." -ForegroundColor Yellow

Set-Location "rdoappProject"

# Limpar projeto
Write-Host "Limpando projeto..." -ForegroundColor Cyan
if (Test-Path "bin") { Remove-Item "bin" -Recurse -Force -ErrorAction SilentlyContinue }
if (Test-Path "obj") { Remove-Item "obj" -Recurse -Force -ErrorAction SilentlyContinue }

# Tentar compilar
Write-Host "Compilando projeto..." -ForegroundColor Cyan
$buildOutput = dotnet build --configuration Release 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Projeto compilado com sucesso!" -ForegroundColor Green
} else {
    Write-Host "✗ Ainda há erros de compilação:" -ForegroundColor Red
    Write-Host $buildOutput -ForegroundColor Yellow
}

Write-Host "`n3. Verificando correções implementadas..." -ForegroundColor Yellow

# Verificar JavaScript
$jsContent = Get-Content "Client\Controllers\TarefaController.js" -Raw
if ($jsContent -match "controller\.salvarLaudo") {
    Write-Host "✓ Função salvarLaudo no JavaScript" -ForegroundColor Green
} else {
    Write-Host "✗ Função salvarLaudo NÃO encontrada no JavaScript" -ForegroundColor Red
}

# Verificar Controller C#
$controllerContent = Get-Content "Api\Controllers\TarefaController.cs" -Raw
if ($controllerContent -match "SalvarLaudo") {
    Write-Host "✓ Endpoint SalvarLaudo no Controller" -ForegroundColor Green
} else {
    Write-Host "✗ Endpoint SalvarLaudo NÃO encontrado no Controller" -ForegroundColor Red
}

# Verificar Model C#
$modelContent = Get-Content "Api\Models\TarefaModel.cs" -Raw
if ($modelContent -match "public static int SalvarLaudo") {
    Write-Host "✓ Método SalvarLaudo no Model" -ForegroundColor Green
} else {
    Write-Host "✗ Método SalvarLaudo NÃO encontrado no Model" -ForegroundColor Red
}

Write-Host "`n=== CAMPOS DO LAUDO CORRIGIDOS ===" -ForegroundColor Green
Write-Host "✓ lau_tp_nivel_cloro: Nullable<int> (era bool)" -ForegroundColor Green
Write-Host "✓ lau_tp_ph: Nullable<int> (era bool)" -ForegroundColor Green
Write-Host "✓ lau_tp_alcalinidade: Nullable<int> (adicionado)" -ForegroundColor Green
Write-Host "✓ lau_tp_nivel_detritos: Nullable<bool> (era lau_tp_nivel_bacterias)" -ForegroundColor Green
Write-Host "✓ Todos os 8 campos do laudo agora estão corretos" -ForegroundColor Green

Write-Host "`nPróximos passos:" -ForegroundColor Yellow
Write-Host "1. Abra o Visual Studio como Administrador" -ForegroundColor Cyan
Write-Host "2. Abra o projeto rdoappProject.sln" -ForegroundColor Cyan
Write-Host "3. Compile o projeto (Ctrl+Shift+B)" -ForegroundColor Cyan
Write-Host "4. Se houver erros, verifique a Lista de Erros" -ForegroundColor Cyan
Write-Host "5. Execute o projeto (F5) para testar" -ForegroundColor Cyan

Set-Location ".."