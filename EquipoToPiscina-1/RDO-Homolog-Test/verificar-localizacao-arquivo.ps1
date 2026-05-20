# VERIFICAR LOCALIZACAO E DATA DOS ARQUIVOS

Write-Host "=== VERIFICANDO LOCALIZACAO DOS ARQUIVOS ===" -ForegroundColor Yellow
Write-Host ""

# Caminho atual
$currentPath = Get-Location
Write-Host "Pasta atual: $currentPath" -ForegroundColor Cyan
Write-Host ""

# Verificar se estamos no OneDrive ou HD local
if ($currentPath.Path -like "*OneDrive*") {
    Write-Host "LOCALIZACAO: OneDrive (nuvem)" -ForegroundColor Yellow
    Write-Host "Os arquivos estao sincronizados na nuvem" -ForegroundColor White
} else {
    Write-Host "LOCALIZACAO: HD Local" -ForegroundColor Green
    Write-Host "Os arquivos estao apenas no computador" -ForegroundColor White
}

Write-Host ""
Write-Host "=== ARQUIVOS PRINCIPAIS ===" -ForegroundColor Cyan

# Verificar rdoappProject.sln
$slnFile = "rdoappProject\rdoappProject.sln"
if (Test-Path $slnFile) {
    $fileInfo = Get-Item $slnFile
    Write-Host "✓ rdoappProject.sln" -ForegroundColor Green
    Write-Host "  Caminho: $($fileInfo.FullName)" -ForegroundColor White
    Write-Host "  Data: $($fileInfo.LastWriteTime)" -ForegroundColor White
    Write-Host "  Tamanho: $($fileInfo.Length) bytes" -ForegroundColor White
} else {
    Write-Host "✗ rdoappProject.sln NAO encontrado" -ForegroundColor Red
}

Write-Host ""

# Verificar rdoappProject.csproj
$csprojFile = "rdoappProject\rdoappProject.csproj"
if (Test-Path $csprojFile) {
    $fileInfo = Get-Item $csprojFile
    Write-Host "✓ rdoappProject.csproj" -ForegroundColor Green
    Write-Host "  Caminho: $($fileInfo.FullName)" -ForegroundColor White
    Write-Host "  Data: $($fileInfo.LastWriteTime)" -ForegroundColor White
    Write-Host "  Tamanho: $($fileInfo.Length) bytes" -ForegroundColor White
} else {
    Write-Host "✗ rdoappProject.csproj NAO encontrado" -ForegroundColor Red
}

Write-Host ""

# Verificar TarefaModel.cs (arquivo com nossas modificacoes)
$tarefaFile = "rdoappProject\Api\Models\TarefaModel.cs"
if (Test-Path $tarefaFile) {
    $fileInfo = Get-Item $tarefaFile
    Write-Host "✓ TarefaModel.cs (com nossas modificacoes)" -ForegroundColor Green
    Write-Host "  Caminho: $($fileInfo.FullName)" -ForegroundColor White
    Write-Host "  Data: $($fileInfo.LastWriteTime)" -ForegroundColor White
    Write-Host "  Tamanho: $($fileInfo.Length) bytes" -ForegroundColor White
    
    # Verificar se tem nossos logs debug
    $content = Get-Content $tarefaFile -Raw
    if ($content -match "DEBUG LAUDO") {
        Write-Host "  ✓ Contem logs DEBUG LAUDO (nossas modificacoes)" -ForegroundColor Green
    } else {
        Write-Host "  ✗ NAO contem logs DEBUG LAUDO" -ForegroundColor Red
    }
} else {
    Write-Host "✗ TarefaModel.cs NAO encontrado" -ForegroundColor Red
}

Write-Host ""

# Verificar pasta bin (compilacao)
$binPath = "rdoappProject\bin"
if (Test-Path $binPath) {
    $binInfo = Get-Item $binPath
    Write-Host "✓ Pasta bin\ (arquivos compilados)" -ForegroundColor Green
    Write-Host "  Caminho: $($binInfo.FullName)" -ForegroundColor White
    
    $dllFiles = Get-ChildItem "$binPath\*.dll" -ErrorAction SilentlyContinue
    if ($dllFiles.Count -gt 0) {
        $newestDll = $dllFiles | Sort-Object LastWriteTime -Descending | Select-Object -First 1
        Write-Host "  Arquivos DLL: $($dllFiles.Count)" -ForegroundColor White
        Write-Host "  DLL mais recente: $($newestDll.Name)" -ForegroundColor White
        Write-Host "  Data compilacao: $($newestDll.LastWriteTime)" -ForegroundColor White
    } else {
        Write-Host "  ✗ Nenhum arquivo DLL encontrado" -ForegroundColor Red
    }
} else {
    Write-Host "✗ Pasta bin\ NAO encontrada" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== RESUMO ===" -ForegroundColor Yellow

$now = Get-Date
Write-Host "Data/Hora atual: $now" -ForegroundColor White

if ($currentPath.Path -like "*OneDrive*") {
    Write-Host ""
    Write-Host "IMPORTANTE: Arquivos no OneDrive" -ForegroundColor Yellow
    Write-Host "- Modificacoes sao sincronizadas automaticamente" -ForegroundColor White
    Write-Host "- Visual Studio pode ter problemas com sincronizacao" -ForegroundColor White
    Write-Host "- Recomendado: copiar projeto para pasta local (C:\Temp)" -ForegroundColor White
}