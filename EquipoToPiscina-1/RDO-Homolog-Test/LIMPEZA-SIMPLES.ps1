Write-Host "=== LIMPANDO BAGUNCA DO KIRO ===" -ForegroundColor Red

# 1. Restaurar Web.config limpo
Write-Host "1. Restaurando Web.config..." -ForegroundColor Green
if (Test-Path "rdoappProject\Web.config.CLEAN") {
    Copy-Item "rdoappProject\Web.config.CLEAN" "rdoappProject\Web.config" -Force
    Write-Host "   Web.config restaurado" -ForegroundColor Green
}

# 2. Limpar bin e obj
Write-Host "2. Limpando bin e obj..." -ForegroundColor Green
if (Test-Path "rdoappProject\bin") {
    Remove-Item "rdoappProject\bin" -Recurse -Force -ErrorAction SilentlyContinue
}
if (Test-Path "rdoappProject\obj") {
    Remove-Item "rdoappProject\obj" -Recurse -Force -ErrorAction SilentlyContinue
}

# 3. Remover arquivos desnecessários
Write-Host "3. Removendo arquivos desnecessários..." -ForegroundColor Green
Get-ChildItem -Path "." -Name "*fix-*" -Recurse | ForEach-Object { Remove-Item $_ -Force -ErrorAction SilentlyContinue }
Get-ChildItem -Path "." -Name "*FIXED*" -Recurse | ForEach-Object { Remove-Item $_ -Force -ErrorAction SilentlyContinue }
Get-ChildItem -Path "." -Name "*COMPLETE*" -Recurse | ForEach-Object { Remove-Item $_ -Force -ErrorAction SilentlyContinue }
Get-ChildItem -Path "." -Name "*ERROR*" -Recurse | ForEach-Object { Remove-Item $_ -Force -ErrorAction SilentlyContinue }
Get-ChildItem -Path "." -Name "test-*" -Recurse | ForEach-Object { Remove-Item $_ -Force -ErrorAction SilentlyContinue }
Get-ChildItem -Path "." -Name "debug-*" -Recurse | ForEach-Object { Remove-Item $_ -Force -ErrorAction SilentlyContinue }

Write-Host "LIMPEZA CONCLUIDA!" -ForegroundColor Green