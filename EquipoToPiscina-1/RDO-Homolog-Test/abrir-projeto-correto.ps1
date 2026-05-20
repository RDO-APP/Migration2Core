# ABRIR O PROJETO CORRETO - HOMOLOG TEST

Write-Host "=== ABRINDO PROJETO CORRETO ===" -ForegroundColor Yellow
Write-Host ""

$correctSolution = (Get-Location).Path + "\rdoappProject\rdoappProject.sln"
$correctProject = (Get-Location).Path + "\rdoappProject\rdoappProject.csproj"

Write-Host "ATENCAO: Voce deve abrir o projeto HOMOLOG, nao o de producao!" -ForegroundColor Red
Write-Host ""
Write-Host "PROJETO CORRETO:" -ForegroundColor Green
Write-Host "Caminho: $correctSolution" -ForegroundColor White
Write-Host ""

# Verificar se existe
if (Test-Path $correctSolution) {
    Write-Host "✓ Arquivo rdoappProject.sln encontrado" -ForegroundColor Green
} else {
    Write-Host "✗ Arquivo rdoappProject.sln NAO encontrado!" -ForegroundColor Red
}

if (Test-Path $correctProject) {
    Write-Host "✓ Arquivo rdoappProject.csproj encontrado" -ForegroundColor Green
} else {
    Write-Host "✗ Arquivo rdoappProject.csproj NAO encontrado!" -ForegroundColor Red
}

Write-Host ""
Write-Host "INSTRUCOES PARA ABRIR O PROJETO CORRETO:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Abra Visual Studio pelo Installer (Iniciar)" -ForegroundColor White
Write-Host "2. Se abrir projeto antigo, FECHE-O (File > Close Solution)" -ForegroundColor White
Write-Host "3. File > Open > Project/Solution" -ForegroundColor White
Write-Host "4. Navegue ate:" -ForegroundColor White
Write-Host "   RDO-Homolog-Test\rdoappProject\" -ForegroundColor Cyan
Write-Host "5. Selecione: rdoappProject.sln" -ForegroundColor Cyan
Write-Host "6. Clique Open" -ForegroundColor White
Write-Host ""
Write-Host "VERIFICACAO:" -ForegroundColor Yellow
Write-Host "- Na barra de titulo deve aparecer: 'rdoappProject'" -ForegroundColor White
Write-Host "- No Solution Explorer deve mostrar: 'rdoappProject'" -ForegroundColor White
Write-Host "- NAO deve mostrar 'rdoapp' (sem Project)" -ForegroundColor White
Write-Host ""
Write-Host "DEPOIS DE ABRIR O PROJETO CORRETO:" -ForegroundColor Yellow
Write-Host "1. Build > Clean Solution" -ForegroundColor White
Write-Host "2. Build > Rebuild Solution" -ForegroundColor White
Write-Host "3. Aguarde 100% completar" -ForegroundColor White
Write-Host "4. F5 para executar" -ForegroundColor White
Write-Host ""
Write-Host "CAMINHO COMPLETO PARA COPIAR:" -ForegroundColor Yellow
Write-Host "$correctSolution" -ForegroundColor Cyan