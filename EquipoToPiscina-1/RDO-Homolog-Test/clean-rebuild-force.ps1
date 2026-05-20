# FORÇA RECOMPILAÇÃO COMPLETA - RESOLVE PROBLEMA DE CÓDIGO ANTIGO RODANDO
# Este script força uma recompilação completa quando o Visual Studio não está aplicando as mudanças

Write-Host "=== FORÇA RECOMPILAÇÃO COMPLETA ===" -ForegroundColor Yellow
Write-Host "Problema: Aplicação ainda roda código antigo mesmo após recompilação" -ForegroundColor Red
Write-Host "Solução: Limpeza completa + rebuild forçado" -ForegroundColor Green
Write-Host ""

# 1. PARAR APLICAÇÃO (se estiver rodando)
Write-Host "1. Parando aplicação (se estiver rodando)..." -ForegroundColor Cyan
try {
    # Matar processos do IIS Express
    Get-Process -Name "iisexpress" -ErrorAction SilentlyContinue | Stop-Process -Force
    Get-Process -Name "w3wp" -ErrorAction SilentlyContinue | Stop-Process -Force
    Write-Host "   ✓ Processos IIS Express finalizados" -ForegroundColor Green
} catch {
    Write-Host "   ⚠ Nenhum processo IIS Express encontrado" -ForegroundColor Yellow
}

# 2. LIMPAR PASTAS BIN E OBJ
Write-Host "2. Limpando pastas bin/ e obj/..." -ForegroundColor Cyan
$projectPath = "rdoappProject"

if (Test-Path "$projectPath\bin") {
    Remove-Item "$projectPath\bin" -Recurse -Force
    Write-Host "   ✓ Pasta bin/ removida" -ForegroundColor Green
} else {
    Write-Host "   ⚠ Pasta bin/ não encontrada" -ForegroundColor Yellow
}

if (Test-Path "$projectPath\obj") {
    Remove-Item "$projectPath\obj" -Recurse -Force
    Write-Host "   ✓ Pasta obj/ removida" -ForegroundColor Green
} else {
    Write-Host "   ⚠ Pasta obj/ não encontrada" -ForegroundColor Yellow
}

# 3. LIMPAR CACHE DO NUGET
Write-Host "3. Limpando cache do NuGet..." -ForegroundColor Cyan
try {
    & nuget locals all -clear
    Write-Host "   ✓ Cache NuGet limpo" -ForegroundColor Green
} catch {
    Write-Host "   ⚠ Comando nuget não encontrado, continuando..." -ForegroundColor Yellow
}

# 4. LIMPAR ARQUIVOS TEMPORÁRIOS DO ASP.NET
Write-Host "4. Limpando arquivos temporários do ASP.NET..." -ForegroundColor Cyan
$tempAspNetFiles = "$env:WINDOWS\Microsoft.NET\Framework64\v4.0.30319\Temporary ASP.NET Files"
if (Test-Path $tempAspNetFiles) {
    try {
        Get-ChildItem $tempAspNetFiles -Recurse | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
        Write-Host "   ✓ Arquivos temporários ASP.NET limpos" -ForegroundColor Green
    } catch {
        Write-Host "   ⚠ Alguns arquivos temporários não puderam ser removidos (normal)" -ForegroundColor Yellow
    }
} else {
    Write-Host "   ⚠ Pasta de arquivos temporários não encontrada" -ForegroundColor Yellow
}

# 5. VERIFICAR SE VISUAL STUDIO ESTÁ FECHADO
Write-Host "5. Verificando se Visual Studio está fechado..." -ForegroundColor Cyan
$vsProcesses = Get-Process -Name "devenv" -ErrorAction SilentlyContinue
if ($vsProcesses) {
    Write-Host "   ⚠ ATENÇÃO: Visual Studio ainda está aberto!" -ForegroundColor Red
    Write-Host "   Para garantir rebuild completo, feche o Visual Studio e execute este script novamente" -ForegroundColor Red
    Write-Host "   Ou pressione qualquer tecla para continuar mesmo assim..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
} else {
    Write-Host "   ✓ Visual Studio está fechado" -ForegroundColor Green
}

Write-Host ""
Write-Host "=== LIMPEZA COMPLETA FINALIZADA ===" -ForegroundColor Green
Write-Host ""
Write-Host "PRÓXIMOS PASSOS:" -ForegroundColor Yellow
Write-Host "1. Abra o Visual Studio Community 2022" -ForegroundColor White
Write-Host "2. Abra o projeto: rdoappProject\rdoappProject.sln" -ForegroundColor White
Write-Host "3. No menu: Compilar > Limpar Solução" -ForegroundColor White
Write-Host "4. No menu: Compilar > Recompilar Solução" -ForegroundColor White
Write-Host "5. Pressione F5 para executar" -ForegroundColor White
Write-Host ""
Write-Host "TESTE ESPERADO:" -ForegroundColor Yellow
Write-Host "- Login: 567.065.455-20 / 1234" -ForegroundColor White
Write-Host "- Abrir nova medição e salvar" -ForegroundColor White
Write-Host "- F12 deve mostrar logs detalhados:" -ForegroundColor White
Write-Host "  'DEBUG LAUDO - Tarefa encontrada: [ID], Etapa: [ID_ETAPA]'" -ForegroundColor Cyan
Write-Host "  'DEBUG LAUDO - ID da obra: [ID_OBRA], Data: [DATA]'" -ForegroundColor Cyan
Write-Host "  'DEBUG LAUDO - SUCESSO - Salvo na tabela tarefa e laudo'" -ForegroundColor Cyan
Write-Host ""
Write-Host "Se os logs NÃO aparecerem, o problema persiste e precisamos investigar mais." -ForegroundColor Red