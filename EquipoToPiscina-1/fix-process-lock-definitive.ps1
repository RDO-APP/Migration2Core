# SOLUÇÃO DEFINITIVA: Resolver travamento de processo
# Execute este script SEMPRE antes de compilar no Visual Studio

Write-Host "🔧 RESOLVENDO TRAVAMENTO DE PROCESSO..." -ForegroundColor Yellow
Write-Host ""

# Função para parar processo com verificação
function Stop-ProcessSafely {
    param($ProcessName)
    
    $processes = Get-Process -Name $ProcessName -ErrorAction SilentlyContinue
    if ($processes) {
        Write-Host "   🛑 Parando $ProcessName..." -ForegroundColor Red
        $processes | Stop-Process -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 1
        
        # Verificar se parou
        $stillRunning = Get-Process -Name $ProcessName -ErrorAction SilentlyContinue
        if ($stillRunning) {
            Write-Host "   ⚠️  $ProcessName ainda rodando, forçando..." -ForegroundColor Yellow
            $stillRunning | Stop-Process -Force -ErrorAction SilentlyContinue
        } else {
            Write-Host "   ✅ $ProcessName parado com sucesso" -ForegroundColor Green
        }
    } else {
        Write-Host "   ✅ $ProcessName não estava rodando" -ForegroundColor Green
    }
}

# Parar todos os processos problemáticos
Write-Host "1️⃣  Parando processos .NET..." -ForegroundColor Cyan
Stop-ProcessSafely "dotnet"
Stop-ProcessSafely "RdoApp.Core"
Stop-ProcessSafely "RdoApp"

Write-Host ""
Write-Host "2️⃣  Parando servidores web..." -ForegroundColor Cyan
Stop-ProcessSafely "iisexpress"
Stop-ProcessSafely "w3wp"

Write-Host ""
Write-Host "3️⃣  Parando Visual Studio se necessário..." -ForegroundColor Cyan
Stop-ProcessSafely "devenv"

# Limpar arquivos temporários
Write-Host ""
Write-Host "4️⃣  Limpando arquivos temporários..." -ForegroundColor Cyan

$projectPath = "RDO-NET8-Migration\RdoApp.Core"
if (Test-Path $projectPath) {
    # Limpar bin e obj
    $binPath = "$projectPath\bin"
    $objPath = "$projectPath\obj"
    
    if (Test-Path $binPath) {
        Write-Host "   🗑️  Removendo pasta bin..." -ForegroundColor Yellow
        Remove-Item $binPath -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "   ✅ Pasta bin removida" -ForegroundColor Green
    }
    
    if (Test-Path $objPath) {
        Write-Host "   🗑️  Removendo pasta obj..." -ForegroundColor Yellow
        Remove-Item $objPath -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "   ✅ Pasta obj removida" -ForegroundColor Green
    }
} else {
    Write-Host "   ⚠️  Pasta do projeto não encontrada: $projectPath" -ForegroundColor Yellow
}

# Aguardar para garantir que tudo foi liberado
Write-Host ""
Write-Host "5️⃣  Aguardando liberação completa..." -ForegroundColor Cyan
Start-Sleep -Seconds 3

Write-Host ""
Write-Host "🎉 PROCESSO CONCLUÍDO!" -ForegroundColor Green
Write-Host ""
Write-Host "✅ Todos os processos foram parados" -ForegroundColor White
Write-Host "✅ Arquivos temporários foram limpos" -ForegroundColor White
Write-Host "✅ Sistema pronto para compilação" -ForegroundColor White
Write-Host ""
Write-Host "🚀 PRÓXIMOS PASSOS:" -ForegroundColor Yellow
Write-Host "   1. Abra o Visual Studio" -ForegroundColor White
Write-Host "   2. Abra o projeto RdoApp.Core.csproj" -ForegroundColor White
Write-Host "   3. Pressione Ctrl+Shift+B para compilar" -ForegroundColor White
Write-Host "   4. Ou pressione F5 para executar" -ForegroundColor White
Write-Host ""
Write-Host "💡 DICA: Execute este script sempre que tiver erro de processo travado!" -ForegroundColor Cyan