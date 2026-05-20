# 🔍 DIAGNOSE LOGIN ERROR - Day 8
# Diagnostica o erro interno do servidor no login

Write-Host "🔍 DIAGNOSTICANDO ERRO DE LOGIN..." -ForegroundColor Cyan
Write-Host ""

# 1. Parar processos
Write-Host "1️⃣ Parando processos..." -ForegroundColor Yellow
& ".\stop-rdoapp-processes.ps1"

# 2. Navegar para projeto
$projectPath = "RDO-NET8-Migration\RdoApp.Core"
if (Test-Path $projectPath) {
    Set-Location $projectPath
    Write-Host "   ✅ Projeto localizado" -ForegroundColor Green
} else {
    Write-Host "   ❌ Projeto não encontrado" -ForegroundColor Red
    exit 1
}

# 3. Iniciar aplicação em background
Write-Host "2️⃣ Iniciando aplicação para diagnóstico..." -ForegroundColor Yellow
Start-Process -FilePath "dotnet" -ArgumentList "run" -WindowStyle Hidden

# Aguardar aplicação iniciar
Start-Sleep -Seconds 10

Write-Host ""
Write-Host "🔍 TESTES DE DIAGNÓSTICO:" -ForegroundColor Cyan
Write-Host ""

# 4. Testar conexão com banco
Write-Host "3️⃣ Testando conexão com banco..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "https://localhost:7201/api/testconnection/database" -Method GET -SkipCertificateCheck
    if ($response.sucesso) {
        Write-Host "   ✅ Conexão com banco: OK" -ForegroundColor Green
        Write-Host "   📊 Total colaboradores: $($response.totalColaboradores)" -ForegroundColor White
    } else {
        Write-Host "   ❌ Erro na conexão: $($response.mensagem)" -ForegroundColor Red
    }
} catch {
    Write-Host "   ❌ Erro ao testar conexão: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# 5. Testar usuário específico
Write-Host "4️⃣ Testando usuário de teste..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "https://localhost:7201/api/testconnection/usuario/567.065.455-20" -Method GET -SkipCertificateCheck
    if ($response.sucesso) {
        Write-Host "   ✅ Usuário encontrado: $($response.usuario.nome)" -ForegroundColor Green
        Write-Host "   📋 CPF: $($response.usuario.cpf)" -ForegroundColor White
        Write-Host "   🟢 Ativo: $($response.usuario.ativo)" -ForegroundColor White
    } else {
        Write-Host "   ❌ Usuário não encontrado: $($response.mensagem)" -ForegroundColor Red
    }
} catch {
    Write-Host "   ❌ Erro ao buscar usuário: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "📋 PRÓXIMOS PASSOS:" -ForegroundColor Green
Write-Host "   1. Se usuário não existe, execute verificar-usuario-teste.sql no DBeaver" -ForegroundColor White
Write-Host "   2. Se conexão falhou, verifique configuração do banco" -ForegroundColor White
Write-Host "   3. Verifique logs detalhados no Visual Studio" -ForegroundColor White
Write-Host ""

Write-Host "🌐 ACESSE PARA TESTAR:" -ForegroundColor Cyan
Write-Host "   Login: https://localhost:7201/Auth/Login" -ForegroundColor White
Write-Host "   Teste DB: https://localhost:7201/api/testconnection/database" -ForegroundColor White
Write-Host "   Teste User: https://localhost:7201/api/testconnection/usuario/567.065.455-20" -ForegroundColor White
Write-Host ""