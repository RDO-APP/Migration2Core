# FIX MODEL.SHOWREQUESTID ERROR
# Corrige erro 500 na página inicial

Write-Host "=== CORREÇÃO ERRO MODEL.SHOWREQUESTID ===" -ForegroundColor Cyan
Write-Host "Data: $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')" -ForegroundColor Gray
Write-Host ""

Write-Host "ERRO IDENTIFICADO:" -ForegroundColor Yellow
Write-Host "❌ Erro 500 na página inicial (https://localhost:7201/)" -ForegroundColor Red
Write-Host "❌ Model.ShowRequestId causando problema" -ForegroundColor Red
Write-Host "❌ Aplicação não consegue carregar página inicial" -ForegroundColor Red
Write-Host ""

Write-Host "POSSÍVEIS CAUSAS:" -ForegroundColor Yellow
Write-Host "1. Problema na View Error.cshtml" -ForegroundColor White
Write-Host "2. Problema no HomeController" -ForegroundColor White
Write-Host "3. Problema no modelo ErrorViewModel" -ForegroundColor White
Write-Host "4. Problema na configuração de roteamento" -ForegroundColor White
Write-Host ""

Write-Host "VERIFICANDO ARQUIVOS CRÍTICOS..." -ForegroundColor Yellow

# Verificar se arquivos existem
$arquivos = @(
    "RDO-NET8-Migration/RdoApp.Core/Controllers/HomeController.cs",
    "RDO-NET8-Migration/RdoApp.Core/Views/Home/Index.cshtml",
    "RDO-NET8-Migration/RdoApp.Core/Views/Shared/Error.cshtml",
    "RDO-NET8-Migration/RdoApp.Core/Models/ErrorViewModel.cs"
)

foreach ($arquivo in $arquivos) {
    if (Test-Path $arquivo) {
        Write-Host "✅ $arquivo" -ForegroundColor Green
    } else {
        Write-Host "❌ $arquivo - NÃO ENCONTRADO" -ForegroundColor Red
    }
}
Write-Host ""

Write-Host "PRÓXIMOS PASSOS:" -ForegroundColor Magenta
Write-Host "1. Verificar se ErrorViewModel existe" -ForegroundColor White
Write-Host "2. Verificar se Error.cshtml está correto" -ForegroundColor White
Write-Host "3. Verificar se HomeController está funcionando" -ForegroundColor White
Write-Host "4. Corrigir problema na página inicial" -ForegroundColor White
Write-Host ""

Write-Host "EXECUTAR:" -ForegroundColor Magenta
Write-Host ".\create-missing-error-files.ps1" -ForegroundColor Yellow