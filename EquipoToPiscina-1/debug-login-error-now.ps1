# 🔍 DEBUG LOGIN ERROR - DESCOBRIR ERRO ESPECÍFICO

Write-Host "🚨 DEBUG LOGIN ERROR" -ForegroundColor Red
Write-Host "===================" -ForegroundColor Red
Write-Host ""

$projectPath = "RDO-NET8-Migration\RdoApp.Core"

Write-Host "🔍 STEP 1: Adicionando logs detalhados no AuthService..." -ForegroundColor Cyan

$authServicePath = "$projectPath\Services\Implementations\AuthService.cs"

if (Test-Path $authServicePath) {
    Write-Host "✅ AuthService encontrado" -ForegroundColor Green
    
    # Fazer backup
    Copy-Item $authServicePath "$authServicePath.backup" -Force
    
    # Ler conteúdo
    $content = Get-Content $authServicePath -Raw
    
    # Adicionar logs mais detalhados
    $newContent = $content -replace 
        'catch \(Exception ex\)\s*\{\s*_logger\.LogError\(ex, "Erro ao realizar login para CPF: \{Cpf\}", loginDto\.Cpf\);',
        'catch (Exception ex)
            {
                _logger.LogError(ex, "ERRO DETALHADO - Tipo: {ExceptionType}", ex.GetType().Name);
                _logger.LogError(ex, "ERRO DETALHADO - Mensagem: {Message}", ex.Message);
                _logger.LogError(ex, "ERRO DETALHADO - Stack: {StackTrace}", ex.StackTrace);
                if (ex.InnerException != null)
                {
                    _logger.LogError(ex, "ERRO DETALHADO - Inner: {InnerMessage}", ex.InnerException.Message);
                }
                _logger.LogError(ex, "Erro ao realizar login para CPF: {Cpf}", loginDto.Cpf);'
    
    # Salvar
    $newContent | Set-Content $authServicePath -Encoding UTF8
    
    Write-Host "✅ Logs detalhados adicionados" -ForegroundColor Green
} else {
    Write-Host "❌ AuthService não encontrado!" -ForegroundColor Red
}

Write-Host ""
Write-Host "🔍 STEP 2: Criando script SQL para verificar usuário..." -ForegroundColor Cyan

$sqlScript = @"
-- Verificar usuário teste
SELECT 
    Id,
    Nome,
    Cpf,
    Email,
    Ativo,
    Senha,
    PasswordHash
FROM colaboradores 
WHERE Cpf = '56706545520' OR Cpf = '567.065.455-20';

-- Contar total de colaboradores
SELECT COUNT(*) as TotalColaboradores FROM colaboradores;

-- Verificar estrutura da tabela
SHOW COLUMNS FROM colaboradores;
"@

$sqlScript | Set-Content "debug-usuario-login.sql" -Encoding UTF8
Write-Host "✅ Script SQL criado: debug-usuario-login.sql" -ForegroundColor Green

Write-Host ""
Write-Host "🎯 INSTRUÇÕES PARA DESCOBRIR O ERRO:" -ForegroundColor Yellow
Write-Host "===================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. 🔄 RECOMPILE no Visual Studio (Ctrl+Shift+B)" -ForegroundColor White
Write-Host "2. 🚀 Execute com F5" -ForegroundColor White
Write-Host "3. 📊 Abra o Output do Visual Studio:" -ForegroundColor White
Write-Host "   - Menu: View > Output" -ForegroundColor Gray
Write-Host "   - Dropdown: Show output from > Debug" -ForegroundColor Gray
Write-Host "4. 🔐 Tente fazer login:" -ForegroundColor White
Write-Host "   - CPF: 567.065.455-20" -ForegroundColor Gray
Write-Host "   - Senha: 1234" -ForegroundColor Gray
Write-Host "5. 📋 COPIE toda mensagem de erro que aparecer" -ForegroundColor White
Write-Host ""
Write-Host "🗃️ TAMBÉM execute o SQL no DBeaver:" -ForegroundColor White
Write-Host "   - Arquivo: debug-usuario-login.sql" -ForegroundColor Gray
Write-Host ""
Write-Host "📤 ME ENVIE:" -ForegroundColor Red
Write-Host "   - A mensagem COMPLETA de erro do Output" -ForegroundColor White
Write-Host "   - O resultado do SQL" -ForegroundColor White
Write-Host ""