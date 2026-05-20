# SCRIPT PARA DESFAZER TODA A BAGUNÇA QUE O KIRO CRIOU
# Este script vai restaurar o projeto ao estado funcional original

Write-Host "=== DESFAZENDO BAGUNÇA DO KIRO ===" -ForegroundColor Red
Write-Host "Restaurando projeto ao estado funcional original..." -ForegroundColor Yellow

# 1. RESTAURAR WEB.CONFIG LIMPO
Write-Host "1. Restaurando Web.config limpo..." -ForegroundColor Green
if (Test-Path "rdoappProject\Web.config.CLEAN") {
    Copy-Item "rdoappProject\Web.config.CLEAN" "rdoappProject\Web.config" -Force
    Write-Host "   ✓ Web.config restaurado" -ForegroundColor Green
} else {
    Write-Host "   ⚠ Backup limpo não encontrado" -ForegroundColor Yellow
}

# 2. REMOVER ARQUIVOS DE "CORREÇÃO" DESNECESSÁRIOS
Write-Host "2. Removendo arquivos de correção desnecessários..." -ForegroundColor Green

$arquivos_lixo = @(
    "*fix-*",
    "*FIXED*",
    "*CORRIGIDO*",
    "*COMPLETE*",
    "*DEFINITIVO*",
    "*ERROR*",
    "*COMPILATION*",
    "test-*",
    "debug-*",
    "verificar-*",
    "corrigir-*",
    "recompile-*",
    "force-*",
    "clean-*"
)

foreach ($pattern in $arquivos_lixo) {
    $files = Get-ChildItem -Path "." -Name $pattern -Recurse -ErrorAction SilentlyContinue
    foreach ($file in $files) {
        if ($file -notlike "*DESFAZER*") {
            Remove-Item $file -Force -ErrorAction SilentlyContinue
            Write-Host "   ✓ Removido: $file" -ForegroundColor Gray
        }
    }
}

# 3. LIMPAR BIN E OBJ
Write-Host "3. Limpando pastas bin e obj..." -ForegroundColor Green
if (Test-Path "rdoappProject\bin") {
    Remove-Item "rdoappProject\bin" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "   ✓ Pasta bin limpa" -ForegroundColor Green
}
if (Test-Path "rdoappProject\obj") {
    Remove-Item "rdoappProject\obj" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "   ✓ Pasta obj limpa" -ForegroundColor Green
}

# 4. RESTAURAR ARQUIVOS ORIGINAIS (se existirem backups)
Write-Host "4. Procurando backups originais..." -ForegroundColor Green
$backups = Get-ChildItem -Path "." -Name "*.ORIGINAL" -Recurse
foreach ($backup in $backups) {
    $original = $backup -replace "\.ORIGINAL$", ""
    if (Test-Path $backup) {
        Copy-Item $backup $original -Force
        Write-Host "   ✓ Restaurado: $original" -ForegroundColor Green
    }
}

# 5. VERIFICAR ESTADO ATUAL
Write-Host "5. Verificando estado atual..." -ForegroundColor Green
if (Test-Path "rdoappProject\rdoappProject.sln") {
    Write-Host "   ✓ Projeto encontrado" -ForegroundColor Green
} else {
    Write-Host "   ⚠ Projeto não encontrado" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=== LIMPEZA CONCLUÍDA ===" -ForegroundColor Green
Write-Host "Agora você pode:" -ForegroundColor White
Write-Host "1. Abrir o Visual Studio" -ForegroundColor White
Write-Host "2. Compilar o projeto" -ForegroundColor White
Write-Host "3. Testar se funciona como antes" -ForegroundColor White
Write-Host ""
Write-Host "DESCULPE PELA BAGUNÇA!" -ForegroundColor Red