Write-Host "=== VERIFICAÇÃO DAS CORREÇÕES DO LAUDO ===" -ForegroundColor Green

Write-Host "`nVerificando entidade laudo..." -ForegroundColor Yellow
$laudoContent = Get-Content "rdoappClass\laudo.cs" -Raw

if ($laudoContent -match "lau_tp_alcalinidade") {
    Write-Host "✓ Campo lau_tp_alcalinidade encontrado" -ForegroundColor Green
} else {
    Write-Host "✗ Campo lau_tp_alcalinidade NÃO encontrado" -ForegroundColor Red
}

if ($laudoContent -match "Nullable<int> lau_tp_nivel_cloro") {
    Write-Host "✓ lau_tp_nivel_cloro é int (correto)" -ForegroundColor Green
} else {
    Write-Host "✗ lau_tp_nivel_cloro não é int" -ForegroundColor Red
}

if ($laudoContent -match "Nullable<int> lau_tp_ph") {
    Write-Host "✓ lau_tp_ph é int (correto)" -ForegroundColor Green
} else {
    Write-Host "✗ lau_tp_ph não é int" -ForegroundColor Red
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
Write-Host "`nVerificação concluída!" -ForegroundColor Green