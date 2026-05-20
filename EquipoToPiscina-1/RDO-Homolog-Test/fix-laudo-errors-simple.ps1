Write-Host "=== CORRIGINDO ERROS DE ENTIDADE LAUDO ===" -ForegroundColor Green

$laudoModelFile = "rdoappProject/Api/Models/LaudoModel.cs"

Write-Host "Corrigindo mapeamentos..." -ForegroundColor Yellow

$content = Get-Content $laudoModelFile -Raw

$oldPattern = "lau_tp_limpidez = \(bool\)laudo\.lau_tp_limpidez,"
$newPattern = "lau_tp_alcalinidade = laudo.lau_tp_alcalinidade ?? 0,`n                lau_tp_limpidez = (bool)laudo.lau_tp_limpidez,"

$content = $content -replace $oldPattern, $newPattern

Set-Content -Path $laudoModelFile -Value $content -Encoding UTF8

Write-Host "Correcoes aplicadas com sucesso!" -ForegroundColor Green