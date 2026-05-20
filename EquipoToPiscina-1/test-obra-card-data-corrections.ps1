# TEST OBRA CARD DATA CORRECTIONS
# Testa as correções aplicadas nos dados dos cards de obra

Write-Host "=== TESTE CORREÇÕES DADOS CARDS OBRA ===" -ForegroundColor Cyan
Write-Host "Data: $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')" -ForegroundColor Gray
Write-Host ""

# Verificar se as correções foram aplicadas
Write-Host "1. Verificando arquivos modificados..." -ForegroundColor Yellow

$arquivosModificados = @(
    "RDO-NET8-Migration/RdoApp.Core/Controllers/ObraController.cs",
    "RDO-NET8-Migration/RdoApp.Core/Views/Obra/Escolher.cshtml"
)

foreach ($arquivo in $arquivosModificados) {
    if (Test-Path $arquivo) {
        Write-Host "   ✅ $arquivo - ENCONTRADO" -ForegroundColor Green
    } else {
        Write-Host "   ❌ $arquivo - NÃO ENCONTRADO" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "2. Verificando correções específicas..." -ForegroundColor Yellow

# Verificar se ContratanteContratada foi adicionado na view
$viewContent = Get-Content "RDO-NET8-Migration/RdoApp.Core/Views/Obra/Escolher.cshtml" -Raw
if ($viewContent -match "@obra\.ContratanteContratada") {
    Write-Host "   ✅ ContratanteContratada adicionado na view" -ForegroundColor Green
} else {
    Write-Host "   ❌ ContratanteContratada NÃO encontrado na view" -ForegroundColor Red
}

# Verificar se a lógica do perfil foi atualizada
$controllerContent = Get-Content "RDO-NET8-Migration/RdoApp.Core/Controllers/ObraController.cs" -Raw
if ($controllerContent -match "Grupo\.Nome.*Contratante.*Contratada") {
    Write-Host "   ✅ Lógica do perfil completo implementada" -ForegroundColor Green
} else {
    Write-Host "   ❌ Lógica do perfil completo NÃO encontrada" -ForegroundColor Red
}

# Verificar se a lógica de cores foi melhorada
if ($controllerContent -match "bg-vermelho.*bg-verde.*bg-cinza") {
    Write-Host "   ✅ Lógica de cores das barras implementada" -ForegroundColor Green
} else {
    Write-Host "   ❌ Lógica de cores das barras NÃO encontrada" -ForegroundColor Red
}

Write-Host ""
Write-Host "3. Resumo das correções aplicadas:" -ForegroundColor Yellow
Write-Host "   • StatusBasicaGratuita: Nome real do grupo (BÁSICA, GRATUITA, etc.)" -ForegroundColor White
Write-Host "   • ContratanteContratada: Perfil completo (ex: 'Diretor Contratada')" -ForegroundColor White
Write-Host "   • ProgressoPorcentagem: Cálculo baseado em datas reais" -ForegroundColor White
Write-Host "   • ClasseStatusCss: Cores diferentes (verde/vermelho/cinza)" -ForegroundColor White

Write-Host ""
Write-Host "4. PRÓXIMO PASSO:" -ForegroundColor Magenta
Write-Host "   Execute F5 no Visual Studio para testar as correções" -ForegroundColor White
Write-Host "   Acesse: https://localhost:7201/Obra/Escolher" -ForegroundColor White
Write-Host "   Login: CPF 567.065.455-20, Senha: RXL8DjdYj6Y=" -ForegroundColor White

Write-Host ""
Write-Host "5. VERIFICAR NOS CARDS:" -ForegroundColor Magenta
Write-Host "   ✓ Município: Cada obra com município diferente" -ForegroundColor Green
Write-Host "   ✓ Tipo Assinatura: (BÁSICA), (GRATUITA), etc." -ForegroundColor Yellow
Write-Host "   ✓ Perfil Acesso: Diretor Contratada, etc." -ForegroundColor Yellow
Write-Host "   ✓ Barras: Cores diferentes (verde/vermelho/cinza)" -ForegroundColor Yellow
Write-Host "   ✓ Percentual: 0-100% baseado em datas" -ForegroundColor Yellow

Write-Host ""
Write-Host "=== TESTE CONCLUÍDO ===" -ForegroundColor Cyan