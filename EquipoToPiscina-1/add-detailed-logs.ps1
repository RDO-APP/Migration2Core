# Adicionar logs detalhados para descobrir o erro

Write-Host "Adicionando logs detalhados no AuthService..." -ForegroundColor Yellow

$authServicePath = "RDO-NET8-Migration\RdoApp.Core\Services\Implementations\AuthService.cs"

if (Test-Path $authServicePath) {
    # Fazer backup
    Copy-Item $authServicePath "$authServicePath.backup" -Force
    
    # Ler conteúdo
    $content = Get-Content $authServicePath -Raw
    
    # Adicionar logs detalhados no catch
    $newContent = $content -replace 
        '_logger\.LogError\(ex, "Erro ao realizar login para CPF: \{Cpf\}", loginDto\.Cpf\);',
        '_logger.LogError(ex, "ERRO COMPLETO - Tipo: {ExceptionType}, Mensagem: {Message}", ex.GetType().Name, ex.Message);
                _logger.LogError(ex, "STACK TRACE: {StackTrace}", ex.StackTrace);
                if (ex.InnerException != null) _logger.LogError(ex, "INNER EXCEPTION: {InnerMessage}", ex.InnerException.Message);
                _logger.LogError(ex, "Erro ao realizar login para CPF: {Cpf}", loginDto.Cpf);'
    
    # Salvar
    $newContent | Set-Content $authServicePath -Encoding UTF8
    
    Write-Host "Logs detalhados adicionados com sucesso!" -ForegroundColor Green
} else {
    Write-Host "AuthService nao encontrado!" -ForegroundColor Red
}

Write-Host ""
Write-Host "AGORA:" -ForegroundColor Yellow
Write-Host "1. Recompile no Visual Studio (Ctrl+Shift+B)" -ForegroundColor White
Write-Host "2. Execute com F5" -ForegroundColor White
Write-Host "3. Abra View > Output > Debug" -ForegroundColor White
Write-Host "4. Tente login e me envie TODA mensagem de erro" -ForegroundColor White