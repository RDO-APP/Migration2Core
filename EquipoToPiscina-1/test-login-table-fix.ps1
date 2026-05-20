#!/usr/bin/env pwsh

# 🧪 TESTE LOGIN - CORREÇÃO TABELA COLABORADOR
# Testa se o login funciona após corrigir o nome da tabela

Write-Host "🔧 TESTANDO LOGIN APÓS CORREÇÃO DA TABELA..." -ForegroundColor Yellow
Write-Host ""

# 1. Verificar se aplicação está rodando
Write-Host "1. Verificando se aplicação está rodando..." -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5031" -Method GET -TimeoutSec 10
    Write-Host "   ✅ Aplicação está rodando (Status: $($response.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Aplicação não está rodando!" -ForegroundColor Red
    Write-Host "   Execute: dotnet run no diretório RDO-NET8-Migration/RdoApp.Core" -ForegroundColor Yellow
    exit 1
}

Write-Host ""

# 2. Testar página de login
Write-Host "2. Testando página de login..." -ForegroundColor Cyan
try {
    $loginPage = Invoke-WebRequest -Uri "http://localhost:5031/Auth/Login" -Method GET -TimeoutSec 10
    Write-Host "   ✅ Página de login carregou (Status: $($loginPage.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Erro ao carregar página de login: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ""

# 3. Testar API de login
Write-Host "3. Testando API de login com credenciais de teste..." -ForegroundColor Cyan
$loginData = @{
    cpf = "567.065.455-20"
    senha = "1234"
    lembrarMe = $false
} | ConvertTo-Json

$headers = @{
    "Content-Type" = "application/json"
}

try {
    $apiResponse = Invoke-WebRequest -Uri "http://localhost:5031/api/auth/login" -Method POST -Body $loginData -Headers $headers -TimeoutSec 15
    $responseContent = $apiResponse.Content | ConvertFrom-Json
    
    if ($responseContent.sucesso) {
        Write-Host "   ✅ LOGIN FUNCIONOU!" -ForegroundColor Green
        Write-Host "   👤 Usuário: $($responseContent.usuario.nome)" -ForegroundColor Cyan
        Write-Host "   📧 Email: $($responseContent.usuario.email)" -ForegroundColor Cyan
        Write-Host "   📱 Telefone: $($responseContent.usuario.telefone)" -ForegroundColor Cyan
    } else {
        Write-Host "   ❌ Login falhou: $($responseContent.mensagem)" -ForegroundColor Red
    }
} catch {
    Write-Host "   ❌ Erro na API de login: $($_.Exception.Message)" -ForegroundColor Red
    
    # Tentar extrair detalhes do erro
    if ($_.Exception.Response) {
        $errorStream = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorStream)
        $errorContent = $reader.ReadToEnd()
        Write-Host "   📋 Detalhes do erro: $errorContent" -ForegroundColor Yellow
    }
}

Write-Host ""

# 4. Abrir navegador para teste manual
Write-Host "4. Abrindo navegador para teste manual..." -ForegroundColor Cyan
Start-Process "http://localhost:5031/Auth/Login"

Write-Host ""
Write-Host "🎯 TESTE CONCLUÍDO!" -ForegroundColor Green
Write-Host "   Use as credenciais:" -ForegroundColor Cyan
Write-Host "   CPF: 567.065.455-20" -ForegroundColor White
Write-Host "   Senha: 1234" -ForegroundColor White
Write-Host ""