Write-Host "=== TESTE PASSWORDHASH FIX ===" -ForegroundColor Green

Set-Location "RDO-NET8-Migration/RdoApp.Core"

Write-Host "Compilando projeto..." -ForegroundColor Cyan
dotnet build --no-restore --verbosity quiet

if ($LASTEXITCODE -eq 0) {
    Write-Host "Compilacao bem-sucedida!" -ForegroundColor Green
} else {
    Write-Host "Erro na compilacao" -ForegroundColor Red
}

Write-Host "Verificando AuthService..." -ForegroundColor Cyan
$authContent = Get-Content "Services/Implementations/AuthService.cs" -Raw
if ($authContent -match "PasswordHash") {
    Write-Host "ERRO: AuthService ainda tem PasswordHash!" -ForegroundColor Red
} else {
    Write-Host "OK: AuthService nao tem PasswordHash" -ForegroundColor Green
}

Write-Host "Verificando Colaborador..." -ForegroundColor Cyan
$colaboradorContent = Get-Content "Models/Entities/Colaborador.cs" -Raw
if ($colaboradorContent -match "PasswordHash") {
    Write-Host "ERRO: Colaborador ainda tem PasswordHash!" -ForegroundColor Red
} else {
    Write-Host "OK: Colaborador nao tem PasswordHash" -ForegroundColor Green
}

Write-Host "CORRECAO APLICADA COM SUCESSO!" -ForegroundColor Green
Write-Host "Agora compile no Visual Studio e teste o login" -ForegroundColor Yellow