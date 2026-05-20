Write-Host "=== TESTE DE COMPILAÇÃO ===" -ForegroundColor Green

Set-Location "rdoappProject"

Write-Host "Limpando..." -ForegroundColor Yellow
Remove-Item "bin" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "obj" -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "Compilando..." -ForegroundColor Yellow
dotnet build --configuration Release

if ($LASTEXITCODE -eq 0) {
    Write-Host "SUCESSO! Projeto compilado!" -ForegroundColor Green
} else {
    Write-Host "Ainda há erros" -ForegroundColor Red
}

Set-Location ".."