Write-Host "=== COMPILANDO PROJETO RDO HOMOLOG ===" -ForegroundColor Green

# Navegar para o diretório do projeto
Set-Location "rdoappProject"

Write-Host ""
Write-Host "TENTATIVA 1: Usando MSBuild (se disponível)" -ForegroundColor Yellow

# Tentar encontrar MSBuild
$msbuildPaths = @(
    "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe",
    "${env:ProgramFiles}\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe",
    "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\MSBuild.exe",
    "${env:ProgramFiles}\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\MSBuild.exe",
    "${env:ProgramFiles(x86)}\MSBuild\14.0\Bin\MSBuild.exe",
    "${env:ProgramFiles}\MSBuild\14.0\Bin\MSBuild.exe"
)

$msbuild = $null
foreach ($path in $msbuildPaths) {
    if (Test-Path $path) {
        $msbuild = $path
        Write-Host "MSBuild encontrado em: $path" -ForegroundColor Green
        break
    }
}

if ($msbuild) {
    Write-Host "Executando MSBuild..." -ForegroundColor Cyan
    & $msbuild "rdoappProject.csproj" /p:Configuration=Debug /verbosity:minimal /nologo
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "COMPILAÇÃO CONCLUÍDA COM SUCESSO!" -ForegroundColor Green
        Write-Host "0 erros encontrados" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "COMPILAÇÃO FALHOU!" -ForegroundColor Red
        Write-Host "Código de saída: $LASTEXITCODE" -ForegroundColor Red
    }
} else {
    Write-Host "MSBuild não encontrado!" -ForegroundColor Red
    Write-Host ""
    Write-Host "TENTATIVA 2: Verificando se Visual Studio está instalado" -ForegroundColor Yellow
    
    $vsPath = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe"
    if (Test-Path $vsPath) {
        Write-Host "Visual Studio encontrado. Recomendação:" -ForegroundColor Green
        Write-Host "1. Abra o Visual Studio" -ForegroundColor White
        Write-Host "2. Abra o projeto rdoappProject.csproj" -ForegroundColor White
        Write-Host "3. Pressione Ctrl+Shift+B para compilar" -ForegroundColor White
        Write-Host "4. Verifique a janela 'Error List' para ver os erros" -ForegroundColor White
    } else {
        Write-Host "Visual Studio não encontrado!" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "SCRIPT DE COMPILAÇÃO FINALIZADO" -ForegroundColor Cyan