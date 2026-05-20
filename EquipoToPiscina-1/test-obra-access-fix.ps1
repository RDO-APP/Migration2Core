# TESTE CORREÇÃO ACESSO ÀS OBRAS
# Testa se a correção do claim NameIdentifier funcionou

Write-Host "=== TESTE CORREÇÃO ACESSO OBRAS ===" -ForegroundColor Cyan
Write-Host "Data: $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')" -ForegroundColor Gray
Write-Host ""

Write-Host "PROBLEMA IDENTIFICADO E CORRIGIDO:" -ForegroundColor Yellow
Write-Host "❌ ANTES: User.FindFirst('id') - claim inexistente" -ForegroundColor Red
Write-Host "✅ DEPOIS: User.FindFirst(ClaimTypes.NameIdentifier) - claim correto" -ForegroundColor Green
Write-Host ""

Write-Host "CORREÇÕES APLICADAS:" -ForegroundColor Yellow
Write-Host "1. ✅ Adicionado using System.Security.Claims" -ForegroundColor Green
Write-Host "2. ✅ Corrigido claim de 'id' para ClaimTypes.NameIdentifier" -ForegroundColor Green
Write-Host "3. ✅ Alinhado com AuthController que usa ClaimTypes.NameIdentifier" -ForegroundColor Green
Write-Host ""

Write-Host "VERIFICANDO ARQUIVOS MODIFICADOS..." -ForegroundColor Yellow
$controllerPath = "RDO-NET8-Migration/RdoApp.Core/Controllers/ObraController.cs"
if (Test-Path $controllerPath) {
    $content = Get-Content $controllerPath -Raw
    
    if ($content -match "using System\.Security\.Claims") {
        Write-Host "✅ Using System.Security.Claims adicionado" -ForegroundColor Green
    } else {
        Write-Host "❌ Using System.Security.Claims NÃO encontrado" -ForegroundColor Red
    }
    
    if ($content -match "ClaimTypes\.NameIdentifier") {
        Write-Host "✅ ClaimTypes.NameIdentifier implementado" -ForegroundColor Green
    } else {
        Write-Host "❌ ClaimTypes.NameIdentifier NÃO encontrado" -ForegroundColor Red
    }
    
    if ($content -match 'FindFirst\("id"\)') {
        Write-Host "⚠️  Ainda há referência ao claim 'id' antigo" -ForegroundColor Yellow
    } else {
        Write-Host "✅ Claim 'id' antigo removido" -ForegroundColor Green
    }
} else {
    Write-Host "❌ Arquivo ObraController.cs não encontrado" -ForegroundColor Red
}
Write-Host ""

Write-Host "PRÓXIMO PASSO:" -ForegroundColor Magenta
Write-Host "1. Execute F5 no Visual Studio para recompilar" -ForegroundColor White
Write-Host "2. Faça login com CPF: 567.065.455-20" -ForegroundColor White
Write-Host "3. Após login, deve redirecionar automaticamente para obras" -ForegroundColor White
Write-Host "4. Ou acesse manualmente: https://localhost:7201/Obra/Escolher" -ForegroundColor White
Write-Host ""

Write-Host "SE AINDA NÃO FUNCIONAR:" -ForegroundColor Magenta
Write-Host "1. Execute: .\verify-user-obras-database.sql no DBeaver" -ForegroundColor White
Write-Host "2. Verifique se usuário tem obras associadas" -ForegroundColor White
Write-Host "3. Coloque breakpoint no ObraController.Escolher()" -ForegroundColor White
Write-Host "4. Verifique se userId está sendo obtido corretamente" -ForegroundColor White
Write-Host ""

Write-Host "EXPECTATIVA:" -ForegroundColor Green
Write-Host "✅ Login funciona" -ForegroundColor Green
Write-Host "✅ Redirecionamento para obras funciona" -ForegroundColor Green
Write-Host "✅ Lista de obras é exibida com dados reais" -ForegroundColor Green
Write-Host "✅ Cards mostram StatusBasicaGratuita e ContratanteContratada" -ForegroundColor Green