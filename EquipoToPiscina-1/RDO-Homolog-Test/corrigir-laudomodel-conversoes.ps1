# Script para corrigir todas as conversões incorretas no LaudoModel.cs
Write-Host "=== CORRIGINDO CONVERSÕES NO LAUDOMODEL.CS ===" -ForegroundColor Green

$arquivoLaudo = "rdoappProject\Api\Models\LaudoModel.cs"

if (Test-Path $arquivoLaudo) {
    Write-Host "Lendo arquivo LaudoModel.cs..." -ForegroundColor Yellow
    
    $conteudo = Get-Content $arquivoLaudo -Raw
    
    # Corrigir conversões incorretas
    Write-Host "Corrigindo conversões de tipo..." -ForegroundColor Cyan
    
    # Corrigir campos int que estavam sendo convertidos para bool
    $conteudo = $conteudo -replace 'lau_tp_nivel_cloro = \(bool\)laudo\.lau_tp_nivel_cloro', 'lau_nr_nivel_cloro = (int)(laudo.lau_tp_nivel_cloro ?? 0)'
    $conteudo = $conteudo -replace 'lau_tp_ph = \(bool\)laudo\.lau_tp_ph', 'lau_nr_ph = (int)(laudo.lau_tp_ph ?? 0)'
    
    # Corrigir campo que não existe mais (bacterias -> detritos)
    $conteudo = $conteudo -replace 'lau_tp_nivel_bacterias = \(bool\)laudo\.lau_tp_nivel_bacterias', 'lau_tp_nivel_detritos = (bool)(laudo.lau_tp_nivel_detritos ?? false)'
    
    # Corrigir campos bool que precisam de null check
    $conteudo = $conteudo -replace 'lau_tp_limpidez = \(bool\)laudo\.lau_tp_limpidez', 'lau_nr_limpidez = (bool)(laudo.lau_tp_limpidez ?? false)'
    $conteudo = $conteudo -replace 'lau_tp_superficie = \(bool\)laudo\.lau_tp_superficie', 'lau_tp_superficie = (bool)(laudo.lau_tp_superficie ?? false)'
    $conteudo = $conteudo -replace 'lau_tp_fundo = \(bool\)laudo\.lau_tp_fundo', 'lau_tp_fundo = (bool)(laudo.lau_tp_fundo ?? false)'
    $conteudo = $conteudo -replace 'lau_tp_nivel_cloro_2 = \(bool\)laudo\.lau_tp_nivel_cloro_2', 'lau_tp_nivel_cloro_2 = (bool)(laudo.lau_tp_nivel_cloro_2 ?? false)'
    $conteudo = $conteudo -replace 'lau_tp_nivel_proliferacao = \(bool\)laudo\.lau_tp_nivel_proliferacao', 'lau_tp_nivel_proliferacao = (bool)(laudo.lau_tp_nivel_proliferacao ?? false)'
    
    # Adicionar campo alcalinidade que estava faltando
    $conteudo = $conteudo -replace 'lau_nr_ph = \(int\)\(laudo\.lau_tp_ph \?\? 0\),', 'lau_nr_ph = (int)(laudo.lau_tp_ph ?? 0),
                lau_nr_alcalinidade = (int)(laudo.lau_tp_alcalinidade ?? 0),'
    
    Write-Host "Salvando arquivo corrigido..." -ForegroundColor Cyan
    Set-Content -Path $arquivoLaudo -Value $conteudo -Encoding UTF8
    
    Write-Host "✓ Conversões corrigidas no LaudoModel.cs" -ForegroundColor Green
} else {
    Write-Host "✗ Arquivo LaudoModel.cs não encontrado!" -ForegroundColor Red
}

Write-Host "`nTentando compilar..." -ForegroundColor Yellow
Set-Location "rdoappProject"
dotnet build --configuration Release --verbosity quiet

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Projeto compilado com sucesso!" -ForegroundColor Green
} else {
    Write-Host "✗ Ainda há erros de compilação" -ForegroundColor Red
}

Set-Location ".."
Write-Host "Correção concluída!" -ForegroundColor Green