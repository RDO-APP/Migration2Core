# Script para corrigir problemas de pacotes NuGet

Write-Host "=== CORRIGINDO PACOTES NUGET ===" -ForegroundColor Green

$projectPath = "RDO-Homolog-Test\rdoappProject"

if (!(Test-Path $projectPath)) {
    Write-Host "ERRO: Projeto não encontrado" -ForegroundColor Red
    exit 1
}

Write-Host "1. Navegando para o diretório do projeto..." -ForegroundColor Yellow
Set-Location $projectPath

Write-Host "2. Limpando cache do NuGet..." -ForegroundColor Yellow
try {
    nuget locals all -clear
    Write-Host "Cache limpo com sucesso" -ForegroundColor Green
} catch {
    Write-Host "Aviso: Não foi possível limpar o cache (normal se nuget.exe não estiver no PATH)" -ForegroundColor Yellow
}

Write-Host "3. Restaurando pacotes..." -ForegroundColor Yellow
try {
    nuget restore
    Write-Host "Pacotes restaurados com sucesso" -ForegroundColor Green
} catch {
    Write-Host "Tentando com dotnet restore..." -ForegroundColor Yellow
    try {
        dotnet restore
        Write-Host "Pacotes restaurados com dotnet" -ForegroundColor Green
    } catch {
        Write-Host "Erro ao restaurar pacotes. Tente manualmente no Visual Studio:" -ForegroundColor Red
        Write-Host "1. Clique com botão direito na solução" -ForegroundColor White
        Write-Host "2. Selecione 'Restore NuGet Packages'" -ForegroundColor White
        Write-Host "3. Ou use Package Manager Console: Update-Package -reinstall" -ForegroundColor White
    }
}

Write-Host "4. Verificando packages.config..." -ForegroundColor Yellow
if (Test-Path "packages.config") {
    $packages = Get-Content "packages.config"
    Write-Host "Packages.config encontrado:" -ForegroundColor Green
    $packages | Select-String "package id" | ForEach-Object { 
        Write-Host "  - $($_.Line.Trim())" -ForegroundColor Cyan 
    }
} else {
    Write-Host "packages.config não encontrado" -ForegroundColor Yellow
}

Write-Host "`n=== PRÓXIMOS PASSOS ===" -ForegroundColor Green
Write-Host "1. Abra o Visual Studio" -ForegroundColor White
Write-Host "2. Se ainda houver erros de pacotes:" -ForegroundColor White
Write-Host "   - Tools > NuGet Package Manager > Package Manager Console" -ForegroundColor Cyan
Write-Host "   - Execute: Update-Package -reinstall" -ForegroundColor Cyan
Write-Host "3. Compile o projeto (Ctrl+Shift+B)" -ForegroundColor White

Set-Location ..\..