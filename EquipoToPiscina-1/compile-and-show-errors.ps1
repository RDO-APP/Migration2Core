# COMPILE AND SHOW ERRORS
# Compilar e mostrar erros detalhados

Write-Host "COMPILANDO PROJETO E MOSTRANDO ERROS..." -ForegroundColor Green
Write-Host "Date: $(Get-Date)" -ForegroundColor Yellow
Write-Host ""

# Change to project directory
Set-Location "RDO-NET8-Migration/RdoApp.Core"

Write-Host "Diretorio: $(Get-Location)" -ForegroundColor Cyan
Write-Host ""

# Clean first
Write-Host "STEP 1: LIMPANDO PROJETO" -ForegroundColor Magenta
dotnet clean --verbosity normal

Write-Host ""

# Build with detailed output
Write-Host "STEP 2: COMPILANDO COM DETALHES" -ForegroundColor Magenta
Write-Host "Executando: dotnet build --verbosity detailed" -ForegroundColor Yellow
Write-Host ""

$buildOutput = dotnet build --verbosity detailed 2>&1
$exitCode = $LASTEXITCODE

Write-Host "RESULTADO DA COMPILACAO:" -ForegroundColor Magenta
Write-Host "========================" -ForegroundColor Magenta

if ($exitCode -eq 0) {
    Write-Host "COMPILACAO: SUCESSO" -ForegroundColor Green
} else {
    Write-Host "COMPILACAO: FALHOU" -ForegroundColor Red
}

Write-Host ""
Write-Host "SAIDA COMPLETA:" -ForegroundColor Yellow
Write-Host $buildOutput

Write-Host ""
Write-Host "Exit Code: $exitCode" -ForegroundColor Cyan
Write-Host "Compilacao concluida em: $(Get-Date)" -ForegroundColor Cyan