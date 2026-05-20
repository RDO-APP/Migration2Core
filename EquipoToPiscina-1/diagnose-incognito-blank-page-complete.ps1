#!/usr/bin/env pwsh

Write-Host "=== DIAGNÓSTICO COMPLETO - PÁGINA EM BRANCO MODO INCÓGNITO ===" -ForegroundColor Green

# Parar processos existentes
Write-Host "Parando processos..." -ForegroundColor Yellow
Get-Process -Name "RdoApp.Core", "dotnet" -ErrorAction SilentlyContinue | Stop-Process -Force

# Ir para projeto
Set-Location "RDO-NET8-Migration/RdoApp.Core"

Write-Host "1. Verificando arquivos necessários..." -ForegroundColor Cyan

$files = @(
    "Views/Auth/Login.cshtml",
    "Controllers/AuthController.cs",
    "Models/DTOs/LoginDto.cs",
    "Services/Implementations/AuthService.cs"
)

foreach ($file in $files) {
    if (Test-Path $file) {
        Write-Host "✅ $file" -ForegroundColor Green
    } else {
        Write-Host "❌ $file FALTANDO" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "2. Verificando compilação..." -ForegroundColor Cyan
$buildResult = dotnet build --verbosity quiet
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Compilação OK" -ForegroundColor Green
} else {
    Write-Host "❌ Erro de compilação" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "3. Iniciando aplicação com logs detalhados..." -ForegroundColor Cyan

# Configurar logs detalhados
$env:ASPNETCORE_ENVIRONMENT = "Development"
$env:Logging__LogLevel__Default = "Debug"
$env:Logging__LogLevel__Microsoft__AspNetCore = "Information"

# Iniciar aplicação
$process = Start-Process -FilePath "dotnet" -ArgumentList "run --urls `"http://localhost:5031;https://localhost:7201`"" -PassThru -WindowStyle Normal

Write-Host "Aguardando inicialização..." -ForegroundColor Yellow
Start-Sleep -Seconds 8

Write-Host ""
Write-Host "4. Testando conectividade..." -ForegroundColor Cyan

# Testar se aplicação está respondendo
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5031" -Method GET -TimeoutSec 10 -UseBasicParsing
    Write-Host "✅ Aplicação respondendo: HTTP $($response.StatusCode)" -ForegroundColor Green
} catch {
    Write-Host "❌ Aplicação não responde na porta 5031" -ForegroundColor Red
    Write-Host "Erro: $($_.Exception.Message)" -ForegroundColor Red
}

# Testar rota de login especificamente
try {
    $loginResponse = Invoke-WebRequest -Uri "http://localhost:5031/Auth/Login" -Method GET -TimeoutSec 10 -UseBasicParsing
    Write-Host "✅ Rota /Auth/Login respondendo: HTTP $($loginResponse.StatusCode)" -ForegroundColor Green
    
    # Verificar tamanho da resposta
    $contentLength = $loginResponse.Content.Length
    Write-Host "📄 Tamanho do conteúdo: $contentLength bytes" -ForegroundColor White
    
    if ($contentLength -lt 100) {
        Write-Host "⚠️  Conteúdo muito pequeno - possível página em branco" -ForegroundColor Yellow
        Write-Host "Conteúdo recebido:" -ForegroundColor Yellow
        Write-Host $loginResponse.Content -ForegroundColor White
    } else {
        Write-Host "✅ Conteúdo parece normal" -ForegroundColor Green
        
        # Verificar se contém elementos esperados
        if ($loginResponse.Content -like "*login*" -or $loginResponse.Content -like "*CPF*" -or $loginResponse.Content -like "*form*") {
            Write-Host "✅ Página contém elementos de login" -ForegroundColor Green
        } else {
            Write-Host "⚠️  Página não contém elementos esperados de login" -ForegroundColor Yellow
        }
    }
    
} catch {
    Write-Host "❌ Rota /Auth/Login não responde" -ForegroundColor Red
    Write-Host "Erro: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "5. Testando HTTPS..." -ForegroundColor Cyan
try {
    $httpsResponse = Invoke-WebRequest -Uri "https://localhost:7201/Auth/Login" -Method GET -TimeoutSec 10 -UseBasicParsing -SkipCertificateCheck
    Write-Host "✅ HTTPS funcionando: HTTP $($httpsResponse.StatusCode)" -ForegroundColor Green
} catch {
    Write-Host "❌ HTTPS não funciona" -ForegroundColor Red
    Write-Host "Erro: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "🔍 RESULTADO DO DIAGNÓSTICO:" -ForegroundColor Green
Write-Host ""
Write-Host "PRÓXIMOS PASSOS:" -ForegroundColor Cyan
Write-Host "1. Abra janela INCÓGNITA/ANÔNIMA" -ForegroundColor White
Write-Host "2. Acesse: http://localhost:5031/Auth/Login" -ForegroundColor White
Write-Host "3. Se estiver em branco:" -ForegroundColor White
Write-Host "   - Pressione F12 (Developer Tools)" -ForegroundColor White
Write-Host "   - Vá na aba Console - veja erros JavaScript" -ForegroundColor White
Write-Host "   - Vá na aba Network - veja se há erros 404/500" -ForegroundColor White
Write-Host "   - Vá na aba Elements - veja se HTML está carregando" -ForegroundColor White
Write-Host ""
Write-Host "4. Teste também: https://localhost:7201/Auth/Login" -ForegroundColor White
Write-Host ""
Write-Host "CREDENCIAIS:" -ForegroundColor Cyan
Write-Host "CPF: 567.065.455-20" -ForegroundColor White
Write-Host "Senha: RXL8DjdYj6Y=" -ForegroundColor White
Write-Host ""
Write-Host "Pressione ENTER para parar a aplicação..." -ForegroundColor Yellow
Read-Host

# Parar aplicação
$process.Kill() -ErrorAction SilentlyContinue
Write-Host "Aplicação parada." -ForegroundColor Green