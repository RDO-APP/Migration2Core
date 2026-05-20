# Diagnose Login Redirect Issue
Write-Host "=== DIAGNÓSTICO: Por que a página de login não aparece ===" -ForegroundColor Yellow
Write-Host ""

# 1. Verificar se há cookies de autenticação armazenados
Write-Host "1. VERIFICANDO COOKIES DE AUTENTICAÇÃO..." -ForegroundColor Cyan
Write-Host "   - Abra o navegador e pressione F12"
Write-Host "   - Vá para a aba 'Application' ou 'Aplicação'"
Write-Host "   - Procure por 'Cookies' no lado esquerdo"
Write-Host "   - Veja se há cookies com nomes como '.AspNetCore.Cookies' ou similar"
Write-Host "   - Se houver, DELETE todos os cookies do localhost"
Write-Host ""

# 2. Verificar se o projeto está compilando corretamente
Write-Host "2. VERIFICANDO COMPILAÇÃO..." -ForegroundColor Cyan
Set-Location "RDO-NET8-Migration/RdoApp.Core"

try {
    Write-Host "   Executando dotnet build..." -ForegroundColor Gray
    $buildResult = dotnet build --verbosity quiet 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ Compilação bem-sucedida" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Erro na compilação:" -ForegroundColor Red
        Write-Host $buildResult -ForegroundColor Red
        return
    }
} catch {
    Write-Host "   ❌ Erro ao compilar: $($_.Exception.Message)" -ForegroundColor Red
    return
}

Write-Host ""

# 3. Verificar configuração de autenticação
Write-Host "3. VERIFICANDO CONFIGURAÇÃO DE AUTENTICAÇÃO..." -ForegroundColor Cyan
Write-Host "   - LoginPath configurado para: /Auth/Login" -ForegroundColor Gray
Write-Host "   - HomeController tem [Authorize] attribute" -ForegroundColor Gray
Write-Host "   - AuthController tem [AllowAnonymous] no Login" -ForegroundColor Gray
Write-Host ""

# 4. Testar URLs específicas
Write-Host "4. INSTRUÇÕES PARA TESTE MANUAL..." -ForegroundColor Cyan
Write-Host "   Após pressionar F5 no Visual Studio:" -ForegroundColor Gray
Write-Host "   a) Se abrir o Dashboard diretamente, teste estas URLs:" -ForegroundColor Gray
Write-Host "      - https://localhost:XXXX/Auth/Login" -ForegroundColor White
Write-Host "      - https://localhost:XXXX/Auth/Logout (para limpar sessão)" -ForegroundColor White
Write-Host ""
Write-Host "   b) Se aparecer erro 404, verifique se o projeto está rodando na porta correta" -ForegroundColor Gray
Write-Host ""

# 5. Verificar se há sessão ativa
Write-Host "5. POSSÍVEIS CAUSAS DO PROBLEMA..." -ForegroundColor Cyan
Write-Host "   ❓ Você já está logado (sessão ativa)" -ForegroundColor Yellow
Write-Host "   ❓ Cookies de autenticação não foram limpos" -ForegroundColor Yellow
Write-Host "   ❓ Browser cache está interferindo" -ForegroundColor Yellow
Write-Host "   ❓ Redirecionamento automático para Home" -ForegroundColor Yellow
Write-Host ""

# 6. Soluções recomendadas
Write-Host "6. SOLUÇÕES RECOMENDADAS..." -ForegroundColor Cyan
Write-Host "   1️⃣ Limpe todos os cookies do localhost no navegador" -ForegroundColor Green
Write-Host "   2️⃣ Use modo incógnito/privado no navegador" -ForegroundColor Green
Write-Host "   3️⃣ Acesse diretamente: /Auth/Logout e depois /Auth/Login" -ForegroundColor Green
Write-Host "   4️⃣ Feche completamente o navegador e abra novamente" -ForegroundColor Green
Write-Host ""

Write-Host "=== TESTE RÁPIDO ===" -ForegroundColor Magenta
Write-Host "Execute estes passos:" -ForegroundColor White
Write-Host "1. Pressione F5 no Visual Studio" -ForegroundColor White
Write-Host "2. Quando abrir o navegador, adicione '/Auth/Logout' na URL" -ForegroundColor White
Write-Host "3. Pressione Enter - isso vai limpar a sessão" -ForegroundColor White
Write-Host "4. Depois acesse '/Auth/Login' - deve aparecer a tela de login" -ForegroundColor White
Write-Host ""

Set-Location "../.."
Write-Host "Diagnóstico concluído!" -ForegroundColor Green