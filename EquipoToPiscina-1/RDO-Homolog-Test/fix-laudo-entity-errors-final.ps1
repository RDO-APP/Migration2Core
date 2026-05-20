#!/usr/bin/env pwsh

Write-Host "=== CORRIGINDO ERROS DE ENTIDADE LAUDO ===" -ForegroundColor Green

# Arquivo principal a ser corrigido
$laudoModelFile = "RDO-Homolog-Test/rdoappProject/Api/Models/LaudoModel.cs"

Write-Host "1. Corrigindo mapeamentos no método DashboardGrafico..." -ForegroundColor Yellow

# Ler o conteúdo do arquivo
$content = Get-Content $laudoModelFile -Raw

# Corrigir o primeiro bloco no método DashboardGrafico
$oldPattern1 = @"
                lau_tp_nivel_cloro = \(bool\)laudo\.lau_tp_nivel_cloro,
                lau_tp_ph = \(bool\)laudo\.lau_tp_ph,
                lau_tp_limpidez = \(bool\)laudo\.lau_tp_limpidez,
                lau_tp_superficie = \(bool\)laudo\.lau_tp_superficie,
                lau_tp_fundo = \(bool\)laudo\.lau_tp_fundo,
                lau_tp_nivel_cloro_2 = \(bool\)laudo\.lau_tp_nivel_cloro_2,
                lau_tp_nivel_bacterias = \(bool\)laudo\.lau_tp_nivel_bacterias,
                lau_tp_nivel_proliferacao = \(bool\)laudo\.lau_tp_nivel_proliferacao,
"@

$newPattern1 = @"
                lau_tp_nivel_cloro = (bool)laudo.lau_tp_nivel_cloro,
                lau_tp_ph = (bool)laudo.lau_tp_ph,
                lau_tp_alcalinidade = laudo.lau_tp_alcalinidade ?? 0,
                lau_tp_limpidez = (bool)laudo.lau_tp_limpidez,
                lau_tp_superficie = (bool)laudo.lau_tp_superficie,
                lau_tp_fundo = (bool)laudo.lau_tp_fundo,
                lau_tp_nivel_cloro_2 = (bool)laudo.lau_tp_nivel_cloro_2,
                lau_tp_nivel_bacterias = (bool)laudo.lau_tp_nivel_bacterias,
                lau_tp_nivel_proliferacao = (bool)laudo.lau_tp_nivel_proliferacao,
"@

# Aplicar a correção usando regex
$content = $content -replace $oldPattern1, $newPattern1

Write-Host "2. Salvando arquivo corrigido..." -ForegroundColor Yellow

# Salvar o arquivo corrigido
Set-Content -Path $laudoModelFile -Value $content -Encoding UTF8

Write-Host "=== CORREÇÕES APLICADAS COM SUCESSO ===" -ForegroundColor Green
Write-Host ""
Write-Host "Resumo das correções aplicadas:" -ForegroundColor Cyan
Write-Host "✓ Adicionado campo lau_tp_alcalinidade nos mapeamentos" -ForegroundColor Green
Write-Host "✓ Mantido campo lau_tp_nivel_bacterias (nome original)" -ForegroundColor Green
Write-Host "✓ LaudoViewModel já estava corrigido anteriormente" -ForegroundColor Green
Write-Host ""
Write-Host "Próximos passos:" -ForegroundColor Yellow
Write-Host "1. Abrir Visual Studio como Administrador" -ForegroundColor White
Write-Host "2. Fazer Clean Solution" -ForegroundColor White
Write-Host "3. Rebuild Solution" -ForegroundColor White
Write-Host "4. Testar a aplicacao" -ForegroundColor White