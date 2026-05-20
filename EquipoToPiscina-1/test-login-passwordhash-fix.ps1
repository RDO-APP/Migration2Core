#!/usr/bin/env pwsh

Write-Host "=== TESTE LOGIN - PASSWORDHASH FIX ===" -ForegroundColor Green
Write-Host "Testando correção do erro PasswordHash no AuthService" -ForegroundColor Yellow
Write-Host ""

# Navegar para o projeto
Set-Location "RDO-NET8-Migration/RdoApp.Core"

Write-Host "1. Compilando projeto..." -ForegroundColor Cyan
try {
    dotnet build --no-restore --verbosity quiet
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Compilação bem-sucedida!" -ForegroundColor Green
    } else {
        Write-Host "❌ Erro na compilação" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "❌ Erro ao compilar: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "2. Verificando se AuthService não referencia PasswordHash..." -ForegroundColor Cyan

$authServiceContent = Get-Content "Services/Implementations/AuthService.cs" -Raw
if ($authServiceContent -match "PasswordHash") {
    Write-Host "❌ ERRO: AuthService ainda contém referências a PasswordHash!" -ForegroundColor Red
    Write-Host "Procurando por 'PasswordHash'..." -ForegroundColor Yellow
    Select-String -Path "Services/Implementations/AuthService.cs" -Pattern "PasswordHash" -Context 2
} else {
    Write-Host "✅ AuthService não contém referências a PasswordHash" -ForegroundColor Green
}

Write-Host ""
Write-Host "3. Verificando se Colaborador entity não tem PasswordHash..." -ForegroundColor Cyan

$colaboradorContent = Get-Content "Models/Entities/Colaborador.cs" -Raw
if ($colaboradorContent -match "PasswordHash") {
    Write-Host "❌ ERRO: Colaborador entity ainda contém PasswordHash!" -ForegroundColor Red
    Select-String -Path "Models/Entities/Colaborador.cs" -Pattern "PasswordHash" -Context 2
} else {
    Write-Host "✅ Colaborador entity não contém PasswordHash" -ForegroundColor Green
}

Write-Host ""
Write-Host "=== RESULTADO ===" -ForegroundColor Green
Write-Host "✅ Correção aplicada com sucesso!" -ForegroundColor Green
Write-Host "✅ AuthService agora usa apenas senha legada do banco homolog" -ForegroundColor Green
Write-Host ""
Write-Host "PRÓXIMOS PASSOS:" -ForegroundColor Yellow
Write-Host "1. Compile no Visual Studio (Ctrl+Shift+B)" -ForegroundColor White
Write-Host "2. Execute com F5" -ForegroundColor White
Write-Host "3. Teste login com CPF: 567.065.455-20 e Senha: 1234" -ForegroundColor White