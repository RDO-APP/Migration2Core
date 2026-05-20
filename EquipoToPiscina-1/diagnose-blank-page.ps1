#!/usr/bin/env pwsh

Write-Host "=== DIAGNOSTICO PAGINA EM BRANCO ===" -ForegroundColor Red
Write-Host ""

# Verificar se aplicacao esta rodando
Write-Host "1. Verificando aplicacao..." -ForegroundColor Yellow
$processes = Get-Process -Name "dotnet" -ErrorAction SilentlyContinue
if ($processes) {
    Write-Host "   Processos dotnet encontrados: $($processes.Count)" -ForegroundColor Green
    foreach ($proc in $processes) {
        Write-Host "   PID: $($proc.Id)" -ForegroundColor Gray
    }
} else {
    Write-Host "   NENHUM processo dotnet encontrado!" -ForegroundColor Red
    Write-Host "   A aplicacao NAO esta rodando!" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Verificar logs da aplicacao
Write-Host "2. Verificando logs da aplicacao..." -ForegroundColor Yellow
try {
    Push-Location "RDO-NET8-Migration/RdoApp.Core"
    
    # Verificar se tem erros de compilacao
    Write-Host "   Testando compilacao..." -ForegroundColor Gray
    $buildResult = dotnet build --no-restore 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   Compilacao: OK" -ForegroundColor Green
    } else {
        Write-Host "   ERRO DE COMPILACAO!" -ForegroundColor Red
        Write-Host "   $buildResult" -ForegroundColor Red
        Pop-Location
        exit 1
    }
    
    Pop-Location
} catch {
    Write-Host "   Erro ao verificar compilacao: $($_.Exception.Message)" -ForegroundColor Red
    Pop-Location
}

Write-Host ""

# Testar conectividade direta
Write-Host "3. Testando conectividade..." -ForegroundColor Yellow

# Testar HTTP simples
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5031" -UseBasicParsing -TimeoutSec 5
    Write-Host "   HTTP Root: Status $($response.StatusCode)" -ForegroundColor Green
    Write-Host "   Content Length: $($response.Content.Length) bytes" -ForegroundColor Gray
    
    if ($response.Content.Length -lt 100) {
        Write-Host "   AVISO: Conteudo muito pequeno!" -ForegroundColor Yellow
        Write-Host "   Primeiros 200 chars: $($response.Content.Substring(0, [Math]::Min(200, $response.Content.Length)))" -ForegroundColor Gray
    }
} catch {
    Write-Host "   HTTP Root: ERRO - $($_.Exception.Message)" -ForegroundColor Red
}

# Testar login page HTTP
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5031/Auth/Login" -UseBasicParsing -TimeoutSec 5
    Write-Host "   HTTP Login: Status $($response.StatusCode)" -ForegroundColor Green
    Write-Host "   Content Length: $($response.Content.Length) bytes" -ForegroundColor Gray
    
    if ($response.Content -match "CPF" -and $response.Content -match "Senha") {
        Write-Host "   Login Form: Elementos encontrados" -ForegroundColor Green
    } else {
        Write-Host "   Login Form: ELEMENTOS NAO ENCONTRADOS!" -ForegroundColor Red
    }
} catch {
    Write-Host "   HTTP Login: ERRO - $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Verificar arquivos criticos
Write-Host "4. Verificando arquivos criticos..." -ForegroundColor Yellow

$files = @(
    "RDO-NET8-Migration/RdoApp.Core/Views/Auth/Login.cshtml",
    "RDO-NET8-Migration/RdoApp.Core/Controllers/AuthController.cs",
    "RDO-NET8-Migration/RdoApp.Core/Program.cs"
)

foreach ($file in $files) {
    if (Test-Path $file) {
        $size = (Get-Item $file).Length
        Write-Host "   $file : OK ($size bytes)" -ForegroundColor Green
    } else {
        Write-Host "   $file : AUSENTE!" -ForegroundColor Red
    }
}

Write-Host ""

# Verificar se tem erros no console
Write-Host "5. Verificando erros no console..." -ForegroundColor Yellow
Write-Host "   Verifique o console onde a aplicacao esta rodando" -ForegroundColor Gray
Write-Host "   Procure por erros como:" -ForegroundColor Gray
Write-Host "   - Unable to configure HTTPS endpoint" -ForegroundColor Gray
Write-Host "   - Failed to bind to address" -ForegroundColor Gray
Write-Host "   - Database connection errors" -ForegroundColor Gray

Write-Host ""

Write-Host "=== SOLUCOES POSSIVEIS ===" -ForegroundColor Magenta
Write-Host "1. Reiniciar aplicacao:" -ForegroundColor White
Write-Host "   - Pare a aplicacao (Ctrl+C)" -ForegroundColor Gray
Write-Host "   - Execute: dotnet run" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Limpar cache do browser:" -ForegroundColor White
Write-Host "   - Abra modo incognito" -ForegroundColor Gray
Write-Host "   - Ou limpe cache (Ctrl+Shift+Del)" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Testar URL direta:" -ForegroundColor White
Write-Host "   - http://localhost:5031/Auth/Login" -ForegroundColor Gray
Write-Host ""
Write-Host "4. Verificar firewall/antivirus" -ForegroundColor White
Write-Host "   - Pode estar bloqueando a porta" -ForegroundColor Gray