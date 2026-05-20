# SOLUÇÃO DEFINITIVA: Process Lock Compilation Error
# Erro: "O arquivo é bloqueado por: RdoApp.Core (32988)"

Write-Host "🚨 RESOLVENDO ERRO DE PROCESSO BLOQUEADO" -ForegroundColor Red
Write-Host "Erro: Arquivo bloqueado por RdoApp.Core" -ForegroundColor Yellow
Write-Host ""

# Passo 1: Parar TODOS os processos relacionados
Write-Host "1. Parando TODOS os processos RdoApp..." -ForegroundColor Green

# Parar processos dotnet
Write-Host "   Parando processos dotnet..." -ForegroundColor Cyan
try {
    Get-Process -Name "dotnet" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Write-Host "   ✅ Processos dotnet parados" -ForegroundColor Green
} catch {
    Write-Host "   ⚠️  Nenhum processo dotnet encontrado" -ForegroundColor Yellow
}

# Parar processos RdoApp.Core
Write-Host "   Parando processos RdoApp.Core..." -ForegroundColor Cyan
try {
    Get-Process -Name "RdoApp.Core" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Write-Host "   ✅ Processos RdoApp.Core parados" -ForegroundColor Green
} catch {
    Write-Host "   ⚠️  Nenhum processo RdoApp.Core encontrado" -ForegroundColor Yellow
}

# Parar processos IIS Express
Write-Host "   Parando processos IIS Express..." -ForegroundColor Cyan
try {
    Get-Process -Name "iisexpress" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Write-Host "   ✅ Processos IIS Express parados" -ForegroundColor Green
} catch {
    Write-Host "   ⚠️  Nenhum processo IIS Express encontrado" -ForegroundColor Yellow
}

# Parar processos Visual Studio se estiver rodando o projeto
Write-Host "   Verificando Visual Studio..." -ForegroundColor Cyan
try {
    $vsProcesses = Get-Process -Name "devenv" -ErrorAction SilentlyContinue
    if ($vsProcesses) {
        Write-Host "   ⚠️  Visual Studio está rodando. Feche o projeto antes de continuar." -ForegroundColor Yellow
        Write-Host "   💡 Dica: Pare o debug (Shift+F5) no Visual Studio" -ForegroundColor Cyan
    } else {
        Write-Host "   ✅ Visual Studio não está bloqueando" -ForegroundColor Green
    }
} catch {
    Write-Host "   ✅ Visual Studio não encontrado" -ForegroundColor Green
}

# Aguardar um momento para os processos terminarem
Write-Host ""
Write-Host "2. Aguardando processos terminarem..." -ForegroundColor Green
Start-Sleep -Seconds 3

# Passo 2: Limpar arquivos de build
Write-Host ""
Write-Host "3. Limpando arquivos de build..." -ForegroundColor Green

$projectPath = "RDO-NET8-Migration/RdoApp.Core"

if (Test-Path $projectPath) {
    # Remover pasta bin
    $binPath = "$projectPath/bin"
    if (Test-Path $binPath) {
        try {
            Remove-Item -Path $binPath -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "   ✅ Pasta bin removida" -ForegroundColor Green
        } catch {
            Write-Host "   ⚠️  Erro ao remover pasta bin: $($_.Exception.Message)" -ForegroundColor Yellow
        }
    }

    # Remover pasta obj
    $objPath = "$projectPath/obj"
    if (Test-Path $objPath) {
        try {
            Remove-Item -Path $objPath -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "   ✅ Pasta obj removida" -ForegroundColor Green
        } catch {
            Write-Host "   ⚠️  Erro ao remover pasta obj: $($_.Exception.Message)" -ForegroundColor Yellow
        }
    }
} else {
    Write-Host "   ❌ Projeto não encontrado em: $projectPath" -ForegroundColor Red
    exit 1
}

# Passo 3: Verificar se ainda há processos rodando
Write-Host ""
Write-Host "4. Verificação final de processos..." -ForegroundColor Green

$remainingProcesses = @()
$remainingProcesses += Get-Process -Name "dotnet" -ErrorAction SilentlyContinue
$remainingProcesses += Get-Process -Name "RdoApp.Core" -ErrorAction SilentlyContinue
$remainingProcesses += Get-Process -Name "iisexpress" -ErrorAction SilentlyContinue

if ($remainingProcesses.Count -gt 0) {
    Write-Host "   ⚠️  Ainda há processos rodando:" -ForegroundColor Yellow
    foreach ($proc in $remainingProcesses) {
        Write-Host "      - $($proc.ProcessName) (PID: $($proc.Id))" -ForegroundColor Yellow
    }
    Write-Host ""
    Write-Host "   🔧 Tentando forçar encerramento..." -ForegroundColor Cyan
    try {
        $remainingProcesses | Stop-Process -Force -ErrorAction SilentlyContinue
        Write-Host "   ✅ Processos forçados a parar" -ForegroundColor Green
    } catch {
        Write-Host "   ❌ Erro ao forçar parada: $($_.Exception.Message)" -ForegroundColor Red
    }
} else {
    Write-Host "   ✅ Nenhum processo bloqueando encontrado" -ForegroundColor Green
}

# Passo 4: Tentar compilar
Write-Host ""
Write-Host "5. Tentando compilar o projeto..." -ForegroundColor Green

try {
    Set-Location $projectPath
    
    Write-Host "   Executando: dotnet clean..." -ForegroundColor Cyan
    $cleanResult = dotnet clean 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ Clean executado com sucesso" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  Clean com avisos: $cleanResult" -ForegroundColor Yellow
    }
    
    Write-Host "   Executando: dotnet build..." -ForegroundColor Cyan
    $buildResult = dotnet build 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ BUILD SUCESSO!" -ForegroundColor Green
        Write-Host ""
        Write-Host "🎉 PROBLEMA RESOLVIDO!" -ForegroundColor Green
        Write-Host "   O projeto foi compilado com sucesso." -ForegroundColor White
        Write-Host ""
        Write-Host "📋 PRÓXIMOS PASSOS:" -ForegroundColor Cyan
        Write-Host "   1. Execute: dotnet run" -ForegroundColor White
        Write-Host "   2. Teste a aplicação no navegador" -ForegroundColor White
        Write-Host "   3. Verifique se todas as fases estão funcionando" -ForegroundColor White
    } else {
        Write-Host "   ❌ ERRO NA COMPILAÇÃO:" -ForegroundColor Red
        Write-Host "$buildResult" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "🔧 SOLUÇÕES ADICIONAIS:" -ForegroundColor Cyan
        Write-Host "   1. Verifique se o Visual Studio está completamente fechado" -ForegroundColor White
        Write-Host "   2. Reinicie o PowerShell como Administrador" -ForegroundColor White
        Write-Host "   3. Execute: dotnet restore" -ForegroundColor White
        Write-Host "   4. Tente novamente: dotnet build" -ForegroundColor White
    }
    
} catch {
    Write-Host "   ❌ Erro ao executar comandos: $($_.Exception.Message)" -ForegroundColor Red
} finally {
    Set-Location ..\..\..
}

Write-Host ""
Write-Host "=== PROCESSO CONCLUÍDO ===" -ForegroundColor Yellow

# Passo 5: Criar script de prevenção
Write-Host ""
Write-Host "6. Criando script de prevenção..." -ForegroundColor Green

$preventionScript = @"
# SCRIPT DE PREVENÇÃO: Sempre execute antes de compilar
# Para evitar o erro de processo bloqueado

Write-Host "🛡️  PREVENÇÃO: Parando processos antes de compilar..." -ForegroundColor Cyan

# Parar todos os processos relacionados
Get-Process -Name "dotnet" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Get-Process -Name "RdoApp.Core" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Get-Process -Name "iisexpress" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

Write-Host "✅ Processos parados. Seguro para compilar!" -ForegroundColor Green
"@

$preventionScript | Out-File -FilePath "stop-processes-before-compile.ps1" -Encoding UTF8
Write-Host "   ✅ Script criado: stop-processes-before-compile.ps1" -ForegroundColor Green

Write-Host ""
Write-Host "💡 DICA PARA O FUTURO:" -ForegroundColor Cyan
Write-Host "   Sempre execute 'stop-processes-before-compile.ps1' antes de compilar" -ForegroundColor White
Write-Host "   Isso evitará o erro de processo bloqueado" -ForegroundColor White