# Script para abrir o projeto RdoApp.Core no Visual Studio
# Corrige o problema de caminho do projeto

Write-Host "🚀 ABRINDO PROJETO RDO-NET8-Migration" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Green

# Caminho correto do projeto
$projectPath = ".\RDO-NET8-Migration\RdoApp.Core\RdoApp.Core.csproj"

# Verificar se o arquivo existe
if (Test-Path $projectPath) {
    Write-Host "✅ Projeto encontrado: $projectPath" -ForegroundColor Green
    
    # Tentar abrir com Visual Studio
    Write-Host "🔧 Abrindo Visual Studio..." -ForegroundColor Yellow
    
    try {
        # Método 1: Tentar com devenv
        $vsPath = "${env:ProgramFiles}\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe"
        if (Test-Path $vsPath) {
            Write-Host "📂 Usando Visual Studio Community 2022" -ForegroundColor Cyan
            Start-Process -FilePath $vsPath -ArgumentList $projectPath
        }
        else {
            # Método 2: Tentar com associação de arquivo
            Write-Host "📂 Usando associação padrão de arquivo" -ForegroundColor Cyan
            Start-Process $projectPath
        }
        
        Write-Host "✅ Visual Studio deve abrir em alguns segundos..." -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Erro ao abrir Visual Studio: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "💡 Tente abrir manualmente:" -ForegroundColor Yellow
        Write-Host "   1. Abra Visual Studio" -ForegroundColor White
        Write-Host "   2. File > Open > Project/Solution" -ForegroundColor White
        Write-Host "   3. Navegue até: $((Get-Location).Path)\$projectPath" -ForegroundColor White
    }
}
else {
    Write-Host "❌ Projeto não encontrado em: $projectPath" -ForegroundColor Red
    Write-Host "📁 Verificando estrutura de pastas..." -ForegroundColor Yellow
    
    if (Test-Path ".\RDO-NET8-Migration") {
        Write-Host "✅ Pasta RDO-NET8-Migration existe" -ForegroundColor Green
        Get-ChildItem ".\RDO-NET8-Migration" -Recurse -Name "*.csproj" | ForEach-Object {
            Write-Host "📄 Projeto encontrado: $_" -ForegroundColor Cyan
        }
    }
    else {
        Write-Host "❌ Pasta RDO-NET8-Migration não encontrada" -ForegroundColor Red
        Write-Host "📁 Conteúdo da pasta atual:" -ForegroundColor Yellow
        Get-ChildItem . -Directory | Select-Object Name | Format-Table -AutoSize
    }
}

Write-Host "`n🏁 Script concluído!" -ForegroundColor Blue