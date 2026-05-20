#!/usr/bin/env pwsh
# Test Login and Obra Selection - Final Working State

Write-Host "TESTANDO LOGIN E SELECAO DE OBRAS..." -ForegroundColor Cyan

# 1. Check if application is running
Write-Host "`n1. Verificando se aplicação está rodando..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5031" -Method GET -TimeoutSec 10
    Write-Host "✅ Aplicação está rodando - Status: $($response.StatusCode)" -ForegroundColor Green
} catch {
    Write-Host "❌ Aplicação não está respondendo: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Execute: dotnet run (no diretorio RDO-NET8-Migration/RdoApp.Core)" -ForegroundColor Yellow
    exit 1
}

# 2. Test login page
Write-Host "`n2. Testando página de login..." -ForegroundColor Yellow
try {
    $loginResponse = Invoke-WebRequest -Uri "http://localhost:5031/Auth/Login" -Method GET -TimeoutSec 10
    Write-Host "✅ Página de login carregou - Status: $($loginResponse.StatusCode)" -ForegroundColor Green
    
    if ($loginResponse.Content -match "RDO App Piscinas") {
        Write-Host "✅ Título da página está correto" -ForegroundColor Green
    }
    
    if ($loginResponse.Content -match "CPF" -and $loginResponse.Content -match "Senha") {
        Write-Host "✅ Campos de login estão presentes" -ForegroundColor Green
    }
} catch {
    Write-Host "❌ Erro ao carregar página de login: $($_.Exception.Message)" -ForegroundColor Red
}

# 3. Test authentication (simulate login)
Write-Host "`n3. Testando autenticação..." -ForegroundColor Yellow
Write-Host "📋 Credenciais de teste:" -ForegroundColor Cyan
Write-Host "   CPF: 12345678901" -ForegroundColor White
Write-Host "   Senha: 123456" -ForegroundColor White

# 4. Test obra selection page (after login)
Write-Host "`n4. Testando página de seleção de obras..." -ForegroundColor Yellow
Write-Host "🌐 URL: http://localhost:5031/Obra/Escolher" -ForegroundColor Cyan

# 5. Instructions for manual testing
Write-Host "`n📋 INSTRUÇÕES PARA TESTE MANUAL:" -ForegroundColor Cyan
Write-Host "1. Abra o navegador em: http://localhost:5031" -ForegroundColor White
Write-Host "2. Faça login com:" -ForegroundColor White
Write-Host "   - CPF: 12345678901" -ForegroundColor Yellow
Write-Host "   - Senha: 123456" -ForegroundColor Yellow
Write-Host "3. Você deve ser redirecionado para a página de seleção de obras" -ForegroundColor White
Write-Host "4. Clique em uma obra para acessar as Etapas/Tarefas" -ForegroundColor White

Write-Host "`n🎯 OBJETIVO: Acessar a página Etapa Tarefa que estava funcionando antes" -ForegroundColor Green
Write-Host "✅ Aplicação está rodando e pronta para teste!" -ForegroundColor Green