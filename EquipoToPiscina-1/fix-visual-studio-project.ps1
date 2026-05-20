# Fix Visual Studio Project - Limpar cache e reabrir
Write-Host "CORRIGINDO PROBLEMA DO VISUAL STUDIO" -ForegroundColor Green

# 1. Fechar Visual Studio se estiver aberto
Write-Host "1. Fechando Visual Studio..." -ForegroundColor Yellow
Get-Process | Where-Object {$_.ProcessName -like "*devenv*"} | Stop-Process -Force -ErrorAction SilentlyContinue

# 2. Limpar cache do Visual Studio
Write-Host "2. Limpando cache..." -ForegroundColor Yellow
$vsPath = "$env:LOCALAPPDATA\Microsoft\VisualStudio"
if (Test-Path $vsPath) {
    Get-ChildItem $vsPath -Recurse -Name "ComponentModelCache" | ForEach-Object {
        $cachePath = Join-Path $vsPath $_
        Remove-Item $cachePath -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "   Cache removido: $cachePath" -ForegroundColor Cyan
    }
}

# 3. Limpar bin e obj do projeto
Write-Host "3. Limpando bin e obj..." -ForegroundColor Yellow
$projectDir = ".\RDO-NET8-Migration\RdoApp.Core"
if (Test-Path "$projectDir\bin") {
    Remove-Item "$projectDir\bin" -Recurse -Force
    Write-Host "   Removido: bin" -ForegroundColor Cyan
}
if (Test-Path "$projectDir\obj") {
    Remove-Item "$projectDir\obj" -Recurse -Force  
    Write-Host "   Removido: obj" -ForegroundColor Cyan
}

# 4. Recompilar
Write-Host "4. Recompilando projeto..." -ForegroundColor Yellow
Set-Location $projectDir
dotnet clean
dotnet restore
dotnet build
Set-Location ..\..

# 5. Abrir Visual Studio
Write-Host "5. Abrindo Visual Studio..." -ForegroundColor Yellow
$projectPath = ".\RDO-NET8-Migration\RdoApp.Core\RdoApp.Core.csproj"
Start-Process $projectPath

Write-Host "CORRECAO CONCLUIDA!" -ForegroundColor Green