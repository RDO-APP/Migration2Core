# Test Authentication Flow
Write-Host "=== TESTE DO FLUXO DE AUTENTICAÇÃO ===" -ForegroundColor Yellow
Write-Host ""

Write-Host "1. Compilando o projeto..." -ForegroundColor Cyan
Set-Location "RDO-NET8-Migration/RdoApp.Core"

try {
    $buildResult = dotnet build --verbosity quiet 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ Compilação bem-sucedida" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Erro na compilação:" -ForegroundColor Red
        Write-Host $buildResult -ForegroundColor Red
        Set-Location "../.."
        return
    }
} catch {
    Write-Host "   ❌ Erro ao compilar: $($_.Exception.Message)" -ForegroundColor Red
    Set-Location "../.."
    return
}

Write-Host ""
Write-Host "2. Iniciando aplicação..." -ForegroundColor Cyan
Write-Host "   Pressione Ctrl+C para parar quando terminar o teste" -ForegroundColor Gray

# Start the application in background
$process = Start-Process -FilePath "dotnet" -ArgumentList "run" -PassThru -WindowStyle Hidden

# Wait a moment for startup
Start-Sleep -Seconds 5

Write-Host ""
Write-Host "3. Testando URLs..." -ForegroundColor Cyan

# Test different URLs
$urls = @(
    "https://localhost:7000",
    "https://localhost:7001", 
    "https://localhost:5000",
    "https://localhost:5001",
    "http://localhost:5000",
    "http://localhost:5001"
)

$workingUrl = $null

foreach ($url in $urls) {
    try {
        Write-Host "   Testando: $url" -ForegroundColor Gray
        $response = Invoke-WebRequest -Uri $url -TimeoutSec 5 -SkipCertificateCheck -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200 -or $response.StatusCode -eq 302) {
            Write-Host "   ✅ Resposta recebida de: $url" -ForegroundColor Green
            $workingUrl = $url
            break
        }
    } catch {
        Write-Host "   ❌ Não respondeu: $url" -ForegroundColor Red
    }
}

if ($workingUrl) {
    Write-Host ""
    Write-Host "4. Testando redirecionamento de autenticação..." -ForegroundColor Cyan
    
    try {
        # Test if home redirects to login
        $homeResponse = Invoke-WebRequest -Uri "$workingUrl/" -MaximumRedirection 0 -ErrorAction SilentlyContinue
        if ($homeResponse.StatusCode -eq 302) {
            $location = $homeResponse.Headers.Location
            Write-Host "   ✅ Redirecionamento detectado para: $location" -ForegroundColor Green
            
            if ($location -like "*Auth/Login*") {
                Write-Host "   ✅ Redirecionamento correto para login!" -ForegroundColor Green
            } else {
                Write-Host "   ⚠️  Redirecionamento para local inesperado: $location" -ForegroundColor Yellow
            }
        } else {
            Write-Host "   ❌ Sem redirecionamento - Status: $($homeResponse.StatusCode)" -ForegroundColor Red
        }
    } catch {
        Write-Host "   ❌ Erro ao testar redirecionamento: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host ""
    Write-Host "5. Testando página de login diretamente..." -ForegroundColor Cyan
    
    try {
        $loginResponse = Invoke-WebRequest -Uri "$workingUrl/Auth/Login" -TimeoutSec 10 -SkipCertificateCheck
        if ($loginResponse.StatusCode -eq 200) {
            Write-Host "   ✅ Página de login acessível!" -ForegroundColor Green
            Write-Host "   📝 Conteúdo contém 'login': $($loginResponse.Content -like '*login*')" -ForegroundColor Gray
        }
    } catch {
        Write-Host "   ❌ Erro ao acessar login: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host ""
    Write-Host "=== RESULTADO ===" -ForegroundColor Magenta
    Write-Host "URL da aplicação: $workingUrl" -ForegroundColor White
    Write-Host "Teste manual:" -ForegroundColor White
    Write-Host "1. Abra o navegador" -ForegroundColor White
    Write-Host "2. Acesse: $workingUrl/Auth/Login" -ForegroundColor White
    Write-Host "3. Deve aparecer a tela de login" -ForegroundColor White
    
} else {
    Write-Host ""
    Write-Host "❌ Aplicação não está respondendo em nenhuma porta" -ForegroundColor Red
    Write-Host "Verifique se o projeto está rodando corretamente" -ForegroundColor Yellow
}

# Stop the process
if ($process -and !$process.HasExited) {
    $process.Kill()
    Write-Host ""
    Write-Host "Processo da aplicação finalizado." -ForegroundColor Gray
}

Set-Location "../.."
Write-Host ""
Write-Host "Teste concluído!" -ForegroundColor Green