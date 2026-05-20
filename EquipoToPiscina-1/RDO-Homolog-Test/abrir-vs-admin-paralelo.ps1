# ABRIR VISUAL STUDIO COMO ADMINISTRADOR EM PARALELO
# Isso nao vai fechar a aplicacao que esta rodando

Write-Host "=== ABRINDO VS COMMUNITY COMO ADMINISTRADOR ===" -ForegroundColor Yellow
Write-Host "Isso vai abrir uma SEGUNDA instancia do Visual Studio" -ForegroundColor Cyan
Write-Host "Sua aplicacao atual continuara rodando normalmente" -ForegroundColor Green
Write-Host ""

# Tentar caminho padrao primeiro
$vsPath = "${env:ProgramFiles}\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe"

if (-not (Test-Path $vsPath)) {
    $vsPath = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe"
}

if (Test-Path $vsPath) {
    Write-Host "Visual Studio encontrado: $vsPath" -ForegroundColor Green
    Write-Host ""
    Write-Host "Abrindo como Administrador..." -ForegroundColor Cyan
    
    try {
        # Abrir como administrador com o projeto
        $projectPath = "rdoappProject\rdoappProject.sln"
        if (Test-Path $projectPath) {
            $fullProjectPath = (Resolve-Path $projectPath).Path
            Start-Process -FilePath $vsPath -ArgumentList "`"$fullProjectPath`"" -Verb RunAs
            Write-Host "✓ Visual Studio Community aberto como Administrador!" -ForegroundColor Green
            Write-Host "✓ Projeto carregado: $projectPath" -ForegroundColor Green
        } else {
            Start-Process -FilePath $vsPath -Verb RunAs
            Write-Host "✓ Visual Studio Community aberto como Administrador!" -ForegroundColor Green
            Write-Host "⚠ Projeto nao encontrado, abra manualmente" -ForegroundColor Yellow
        }
        
        Write-Host ""
        Write-Host "AGORA VOCE TEM DUAS INSTANCIAS:" -ForegroundColor Yellow
        Write-Host "1. VS atual (sem admin) - aplicacao rodando" -ForegroundColor White
        Write-Host "2. VS novo (COM admin) - para recompilar" -ForegroundColor White
        Write-Host ""
        Write-Host "NO VS NOVO (COM ADMIN):" -ForegroundColor Cyan
        Write-Host "1. Verifique se tem '(Administrador)' no titulo" -ForegroundColor White
        Write-Host "2. Compilar > Recompilar Solucao" -ForegroundColor White
        Write-Host "3. F5 para executar" -ForegroundColor White
        Write-Host "4. Teste o laudo e verifique F12" -ForegroundColor White
        
    } catch {
        Write-Host "✗ Erro ao abrir: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host ""
        Write-Host "ALTERNATIVA MANUAL:" -ForegroundColor Yellow
        Write-Host "1. Pressione Windows + R" -ForegroundColor White
        Write-Host "2. Cole: `"$vsPath`"" -ForegroundColor White
        Write-Host "3. Pressione Ctrl+Shift+Enter" -ForegroundColor White
    }
    
} else {
    Write-Host "✗ Visual Studio Community nao encontrado!" -ForegroundColor Red
    Write-Host ""
    Write-Host "CAMINHOS VERIFICADOS:" -ForegroundColor Yellow
    Write-Host "- ${env:ProgramFiles}\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe" -ForegroundColor White
    Write-Host "- ${env:ProgramFiles(x86)}\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe" -ForegroundColor White
}

Write-Host ""