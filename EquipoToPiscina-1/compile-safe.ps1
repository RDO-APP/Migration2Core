# COMPILAÇÃO SEGURA - Resolve automaticamente o problema de processo bloqueado
Write-Host "🔧 COMPILAÇÃO SEGURA DO RDO APP" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green
Write-Host ""

# Passo 1: Parar processos
Write-Host "1️⃣  Parando processos que podem bloquear..." -ForegroundColor Cyan
Get-Process -Name "dotnet" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Get-Process -Name "RdoApp.Core" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Get-Process -Name "iisexpress" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
Write-Host "   ✅ Processos parados" -ForegroundColor Green

# Passo 2: Navegar para o projeto
Write-Host ""
Write-Host "2️⃣  Navegando para o projeto..." -ForegroundColor Cyan
$projectPath = "RDO-NET8-Migration/RdoApp.Core"
if (Test-Path $projectPath) {
    Set-Location $projectPath
    Write-Host "   ✅ Localizado: $projectPath" -ForegroundColor Green
} else {
    Write-Host "   ❌ Projeto não encontrado: $projectPath" -ForegroundColor Red
    exit 1
}

# Passo 3: Limpar build anterior
Write-Host ""
Write-Host "3️⃣  Limpando build anterior..." -ForegroundColor Cyan
try {
    $cleanOutput = dotnet clean 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ Clean executado com sucesso" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  Clean com avisos (normal)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ⚠️  Erro no clean: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Passo 4: Remover pastas bin/obj se ainda existirem
Write-Host ""
Write-Host "4️⃣  Removendo pastas bin/obj..." -ForegroundColor Cyan
if (Test-Path "bin") {
    Remove-Item -Path "bin" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "   ✅ Pasta bin removida" -ForegroundColor Green
}
if (Test-Path "obj") {
    Remove-Item -Path "obj" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "   ✅ Pasta obj removida" -ForegroundColor Green
}

# Passo 5: Restaurar pacotes
Write-Host ""
Write-Host "5️⃣  Restaurando pacotes NuGet..." -ForegroundColor Cyan
try {
    $restoreOutput = dotnet restore 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ Pacotes restaurados com sucesso" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  Restore com avisos:" -ForegroundColor Yellow
        Write-Host "   $restoreOutput" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ❌ Erro no restore: $($_.Exception.Message)" -ForegroundColor Red
}

# Passo 6: Compilar
Write-Host ""
Write-Host "6️⃣  Compilando projeto..." -ForegroundColor Cyan
try {
    $buildOutput = dotnet build 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   🎉 COMPILAÇÃO SUCESSO!" -ForegroundColor Green
        
        # Verificar se o executável foi criado
        if (Test-Path "bin/Debug/net8.0/RdoApp.Core.exe") {
            Write-Host "   ✅ Executável criado com sucesso" -ForegroundColor Green
        }
        
        Write-Host ""
        Write-Host "🚀 PROJETO PRONTO PARA EXECUTAR!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Para testar, execute:" -ForegroundColor Cyan
        Write-Host "   dotnet run" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Ou abra no navegador:" -ForegroundColor Cyan
        Write-Host "   http://localhost:5031" -ForegroundColor Yellow
        
    } else {
        Write-Host "   ❌ ERRO NA COMPILAÇÃO:" -ForegroundColor Red
        Write-Host "$buildOutput" -ForegroundColor Yellow
        
        Write-Host ""
        Write-Host "🔧 POSSÍVEIS SOLUÇÕES:" -ForegroundColor Cyan
        Write-Host "   1. Verifique se o Visual Studio está fechado" -ForegroundColor White
        Write-Host "   2. Execute como Administrador" -ForegroundColor White
        Write-Host "   3. Reinicie o computador se necessário" -ForegroundColor White
    }
} catch {
    Write-Host "   ❌ Erro ao compilar: $($_.Exception.Message)" -ForegroundColor Red
}

# Voltar ao diretório original
Set-Location ..\..\..

Write-Host ""
Write-Host "================================" -ForegroundColor Green
Write-Host "🏁 PROCESSO CONCLUÍDO" -ForegroundColor Green