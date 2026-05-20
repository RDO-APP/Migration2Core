Write-Host "Procurando Visual Studio Community..." -ForegroundColor Green

# Tentar diferentes caminhos do VS Community
$vsPaths = @(
    "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\Common7\IDE\devenv.exe",
    "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\Common7\IDE\devenv.exe",
    "C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe",
    "C:\Program Files (x86)\Microsoft Visual Studio\Installer\vs_installer.exe"
)

$solutionPath = "rdoappProject\rdoappProject.sln"

foreach ($vsPath in $vsPaths) {
    if (Test-Path $vsPath) {
        Write-Host "Encontrado: $vsPath" -ForegroundColor Green
        if ($vsPath -like "*installer*") {
            Write-Host "Abrindo VS Installer..." -ForegroundColor Yellow
            Start-Process $vsPath
        } else {
            Write-Host "Abrindo projeto no Visual Studio..." -ForegroundColor Yellow
            Start-Process $vsPath -ArgumentList $solutionPath
        }
        exit
    }
}

Write-Host "Visual Studio Community não encontrado!" -ForegroundColor Red
Write-Host "Tentando abrir o arquivo .sln diretamente..." -ForegroundColor Yellow
Start-Process $solutionPath