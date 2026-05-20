# 🔍 DIAGNÓSTICO DETALHADO DO ERRO INTERNO DO SERVIDOR
# Descobrir exatamente qual erro está acontecendo no login

Write-Host "🚨 DIAGNÓSTICO DETALHADO - ERRO INTERNO DO SERVIDOR" -ForegroundColor Red
Write-Host "=================================================" -ForegroundColor Red
Write-Host ""

$startTime = Get-Date
Write-Host "⏰ Início: $($startTime.ToString('HH:mm:ss'))" -ForegroundColor Yellow

# Definir caminhos
$projectPath = "RDO-NET8-Migration\RdoApp.Core"

Write-Host ""
Write-Host "🔍 STEP 1: Verificando logs do Visual Studio..." -ForegroundColor Cyan

# Verificar se há logs de erro no Output do VS
Write-Host "📋 Instruções para capturar o erro:" -ForegroundColor Yellow
Write-Host "1. No Visual Studio, vá em View > Output" -ForegroundColor White
Write-Host "2. Na dropdown 'Show output from:', selecione 'Debug'" -ForegroundColor White
Write-Host "3. Tente fazer login novamente" -ForegroundColor White
Write-Host "4. Copie TODA a mensagem de erro que aparecer" -ForegroundColor White
Write-Host ""

Write-Host "🔍 STEP 2: Adicionando logs detalhados no AuthService..." -ForegroundColor Cyan

# Vamos adicionar logs mais detalhados no AuthService
$authServicePath = "$projectPath\Services\Implementations\AuthService.cs"

if (Test-Path $authServicePath) {
    Write-Host "✅ AuthService encontrado: $authServicePath" -ForegroundColor Green
    
    # Ler o conteúdo atual
    $content = Get-Content $authServicePath -Raw
    
    # Verificar se já tem logs detalhados
    if ($content -match "LogError.*Erro detalhado") {
        Write-Host "✅ Logs detalhados já estão presentes" -ForegroundColor Green
    } else {
        Write-Host "🔧 Adicionando logs detalhados..." -ForegroundColor Yellow
        
        # Fazer backup
        Copy-Item $authServicePath "$authServicePath.backup" -Force
        
        # Adicionar logs mais detalhados no método LoginAsync
        $newContent = $content -replace 
            '(\s+catch \(Exception ex\)\s*\{\s*_logger\.LogError\(ex, "Erro ao realizar login para CPF: \{Cpf\}", loginDto\.Cpf\);)',
            '$1
                _logger.LogError("Erro detalhado: {Message}", ex.Message);
                _logger.LogError("Stack trace: {StackTrace}", ex.StackTrace);
                if (ex.InnerException != null)
                {
                    _logger.LogError("Inner exception: {InnerMessage}", ex.InnerException.Message);
                }'
        
        # Salvar o arquivo modificado
        $newContent | Set-Content $authServicePath -Encoding UTF8
        
        Write-Host "✅ Logs detalhados adicionados ao AuthService" -ForegroundColor Green
    }
} else {
    Write-Host "❌ AuthService não encontrado!" -ForegroundColor Red
}

Write-Host ""
Write-Host "🔍 STEP 3: Verificando configuração do banco de dados..." -ForegroundColor Cyan

# Verificar appsettings.json
$appsettingsPath = "$projectPath\appsettings.json"
if (Test-Path $appsettingsPath) {
    Write-Host "✅ appsettings.json encontrado" -ForegroundColor Green
    
    $appsettings = Get-Content $appsettingsPath -Raw | ConvertFrom-Json
    if ($appsettings.ConnectionStrings -and $appsettings.ConnectionStrings.DefaultConnection) {
        $connString = $appsettings.ConnectionStrings.DefaultConnection
        Write-Host "📊 Connection String: $($connString.Substring(0, [Math]::Min(50, $connString.Length)))..." -ForegroundColor Yellow
        
        # Verificar se tem as informações básicas
        if ($connString -match "Server=" -and $connString -match "Database=") {
            Write-Host "✅ Connection string parece válida" -ForegroundColor Green
        } else {
            Write-Host "⚠️ Connection string pode estar incompleta" -ForegroundColor Yellow
        }
    } else {
        Write-Host "❌ Connection string não encontrada!" -ForegroundColor Red
    }
} else {
    Write-Host "❌ appsettings.json não encontrado!" -ForegroundColor Red
}

Write-Host ""
Write-Host "🔍 STEP 4: Testando conexão com banco de dados..." -ForegroundColor Cyan

# Criar um teste simples de conexão
$testConnectionScript = @"
using Microsoft.EntityFrameworkCore;
using RdoApp.Core.Data.Context;

try 
{
    var optionsBuilder = new DbContextOptionsBuilder<RdoContext>();
    // Usar connection string do appsettings.json
    
    using var context = new RdoContext(optionsBuilder.Options);
    
    Console.WriteLine("Testando conexão com banco...");
    var canConnect = await context.Database.CanConnectAsync();
    
    if (canConnect) 
    {
        Console.WriteLine("✅ Conexão com banco OK");
        
        // Testar se a tabela Colaboradores existe
        var colaboradorCount = await context.Colaboradores.CountAsync();
        Console.WriteLine($"✅ Tabela Colaboradores: {colaboradorCount} registros");
    } 
    else 
    {
        Console.WriteLine("❌ Não foi possível conectar ao banco");
    }
}
catch (Exception ex)
{
    Console.WriteLine($"❌ Erro na conexão: {ex.Message}");
    if (ex.InnerException != null)
    {
        Console.WriteLine($"❌ Inner Exception: {ex.InnerException.Message}");
    }
}
"@

Write-Host "📝 Script de teste de conexão criado" -ForegroundColor Green

Write-Host ""
Write-Host "🔍 STEP 5: Verificando se o usuário teste existe..." -ForegroundColor Cyan

# Criar script SQL para verificar usuário
$sqlScript = @"
-- Verificar se o usuário teste existe
SELECT 
    Id,
    Nome,
    Cpf,
    Email,
    Ativo,
    CASE 
        WHEN PasswordHash IS NOT NULL THEN 'TEM HASH'
        ELSE 'SEM HASH'
    END as PasswordStatus,
    CASE 
        WHEN Senha IS NOT NULL THEN 'TEM SENHA LEGADA'
        ELSE 'SEM SENHA LEGADA'
    END as SenhaLegadaStatus
FROM colaboradores 
WHERE Cpf = '56706545520'
   OR Cpf = '567.065.455-20';

-- Verificar estrutura da tabela
DESCRIBE colaboradores;
"@

$sqlFile = "verificar-usuario-login-detalhado.sql"
$sqlScript | Set-Content $sqlFile -Encoding UTF8

Write-Host "✅ Script SQL criado: $sqlFile" -ForegroundColor Green

Write-Host ""
Write-Host "🎯 PRÓXIMOS PASSOS PARA DESCOBRIR O ERRO:" -ForegroundColor Green
Write-Host "=======================================" -ForegroundColor Green
Write-Host ""
Write-Host "1. 🔄 RECOMPILAR o projeto no Visual Studio (Ctrl+Shift+B)" -ForegroundColor Yellow
Write-Host "2. 🚀 EXECUTAR com F5" -ForegroundColor Yellow
Write-Host "3. 📊 ABRIR Output do Visual Studio:" -ForegroundColor Yellow
Write-Host "   - View > Output" -ForegroundColor White
Write-Host "   - Show output from: Debug" -ForegroundColor White
Write-Host "4. 🔐 TENTAR LOGIN com:" -ForegroundColor Yellow
Write-Host "   - CPF: 567.065.455-20" -ForegroundColor White
Write-Host "   - Senha: 1234" -ForegroundColor White
Write-Host "5. 📋 COPIAR toda mensagem de erro do Output" -ForegroundColor Yellow
Write-Host "6. 🗃️ EXECUTAR o SQL para verificar usuário:" -ForegroundColor Yellow
Write-Host "   - Abrir DBeaver ou MySQL Workbench" -ForegroundColor White
Write-Host "   - Executar: $sqlFile" -ForegroundColor White
Write-Host ""

Write-Host "🚨 POSSÍVEIS CAUSAS DO ERRO:" -ForegroundColor Red
Write-Host "=============================" -ForegroundColor Red
Write-Host "❌ Conexão com banco de dados falhou" -ForegroundColor Red
Write-Host "❌ Tabela 'colaboradores' não existe ou nome diferente" -ForegroundColor Red
Write-Host "❌ Campo 'Cpf' tem nome diferente no banco" -ForegroundColor Red
Write-Host "❌ Usuário teste não existe no banco" -ForegroundColor Red
Write-Host "❌ Problema com Entity Framework configuration" -ForegroundColor Red
Write-Host "❌ Problema com BCrypt package" -ForegroundColor Red
Write-Host ""

$endTime = Get-Date
$duration = $endTime - $startTime

Write-Host "⏰ Tempo de execução: $($duration.TotalSeconds.ToString('F1')) segundos" -ForegroundColor Yellow
Write-Host ""
Write-Host "🔍 AGUARDANDO INFORMAÇÕES DETALHADAS DO ERRO..." -ForegroundColor Cyan
Write-Host "Por favor, execute os passos acima e me informe:" -ForegroundColor White
Write-Host "1. A mensagem COMPLETA de erro do Output do Visual Studio" -ForegroundColor White
Write-Host "2. O resultado do SQL de verificação do usuário" -ForegroundColor White
Write-Host ""