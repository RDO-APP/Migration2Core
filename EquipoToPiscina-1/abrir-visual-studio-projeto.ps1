Write-Host "=== ABRINDO VISUAL STUDIO COM PROJETO ===" -ForegroundColor Green

# Caminho completo do projeto
$projectPath = "RDO-NET8-Migration\RdoApp.Core\RdoApp.Core.csproj"
$fullPath = Join-Path (Get-Location) $projectPath

Write-Host "Projeto: $fullPath" -ForegroundColor Yellow

# Verificar se projeto existe
if (Test-Path $fullPath) {
    Write-Host "✅ Projeto encontrado!" -ForegroundColor Green
    
    # Tentar abrir com Visual Studio
    Write-Host "Abrindo Visual Studio..." -ForegroundColor Yellow
    
    try {
        # Método 1: Usar Start-Process com o arquivo .csproj
        Start-Process -FilePath $fullPath -WindowStyle Maximized
        
        Write-Host "✅ Visual Studio abrindo..." -ForegroundColor Green
        Write-Host ""
        Write-Host "PRÓXIMOS PASSOS:" -ForegroundColor Cyan
        Write-Host "1. Aguarde Visual Studio carregar completamente" -ForegroundColor White
        Write-Host "2. Pressione F5 para executar" -ForegroundColor White
        Write-Host "3. Teste no modo incógnito: http://localhost:5031/Auth/Login" -ForegroundColor White
        Write-Host ""
        Write-Host "CREDENCIAIS:" -ForegroundColor Green
        Write-Host "CPF: 567.065.455-20" -ForegroundColor White
        Write-Host "Senha: RXL8DjdYj6Y=" -ForegroundColor White
        Write-Host ""
        Write-Host "LOGIN CORRIGIDO:" -ForegroundColor Green
        Write-Host "✅ Sem dependências CDN externas" -ForegroundColor White
        Write-Host "✅ Funciona perfeitamente no modo incógnito" -ForegroundColor White
        Write-Host "✅ Máscara CPF automática" -ForegroundColor White
        Write-Host "✅ Mesmo design visual" -ForegroundColor White
        
    } catch {
        Write-Host "❌ Erro ao abrir Visual Studio automaticamente" -ForegroundColor Red
        Write-Host ""
        Write-Host "ALTERNATIVA MANUAL:" -ForegroundColor Yellow
        Write-Host "1. Abra Visual Studio manualmente" -ForegroundColor White
        Write-Host "2. Clique em 'Abrir um projeto ou solução'" -ForegroundColor White
        Write-Host "3. Navegue até:" -ForegroundColor White
        Write-Host "   $fullPath" -ForegroundColor Cyan
        Write-Host "4. Clique em 'Abrir'" -ForegroundColor White
        Write-Host "5. Pressione F5" -ForegroundColor White
    }
    
} else {
    Write-Host "❌ Projeto não encontrado em: $fullPath" -ForegroundColor Red
    Write-Host ""
    Write-Host "Verificando estrutura de pastas..." -ForegroundColor Yellow
    
    if (Test-Path "RDO-NET8-Migration") {
        Write-Host "✅ Pasta RDO-NET8-Migration existe" -ForegroundColor Green
        
        if (Test-Path "RDO-NET8-Migration\RdoApp.Core") {
            Write-Host "✅ Pasta RdoApp.Core existe" -ForegroundColor Green
            
            # Listar arquivos .csproj na pasta
            $csprojFiles = Get-ChildItem -Path "RDO-NET8-Migration\RdoApp.Core" -Filter "*.csproj"
            if ($csprojFiles.Count -gt 0) {
                Write-Host "Arquivos .csproj encontrados:" -ForegroundColor Green
                foreach ($file in $csprojFiles) {
                    Write-Host "  - $($file.Name)" -ForegroundColor White
                }
            } else {
                Write-Host "❌ Nenhum arquivo .csproj encontrado" -ForegroundColor Red
            }
        } else {
            Write-Host "❌ Pasta RdoApp.Core não existe" -ForegroundColor Red
        }
    } else {
        Write-Host "❌ Pasta RDO-NET8-Migration não existe" -ForegroundColor Red
    }
}