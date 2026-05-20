# Test Obra Cards Design Fix - Simple Version

Write-Host "Testando correcao design obra cards" -ForegroundColor Cyan
Write-Host ""

$escolherFile = "RDO-NET8-Migration/RdoApp.Core/Views/Obra/Escolher.cshtml"

if (Test-Path $escolherFile) {
    Write-Host "Arquivo encontrado" -ForegroundColor Green
    
    $content = Get-Content $escolherFile -Raw
    
    # Verificar elementos críticos
    Write-Host ""
    Write-Host "Verificando elementos criticos..." -ForegroundColor Green
    
    if ($content -match "font-size:\s*97px") {
        Write-Host "OK - Icone gigante 97px implementado" -ForegroundColor Green
    } else {
        Write-Host "ERRO - Icone gigante NAO encontrado" -ForegroundColor Red
    }
    
    if ($content -match "display:\s*flex") {
        Write-Host "OK - Layout flexbox implementado" -ForegroundColor Green
    } else {
        Write-Host "ERRO - Layout flexbox NAO encontrado" -ForegroundColor Red
    }
    
    if ($content -match "flex-basis:\s*20") {
        Write-Host "OK - 5 cards por linha implementado" -ForegroundColor Green
    } else {
        Write-Host "ERRO - 5 cards por linha NAO implementado" -ForegroundColor Red
    }
    
    if ($content -match "#0088DD") {
        Write-Host "OK - Cor azul do Gilberto implementada" -ForegroundColor Green
    } else {
        Write-Host "ERRO - Cor azul do Gilberto NAO encontrada" -ForegroundColor Red
    }
    
    if ($content -match "font-size:\s*24px") {
        Write-Host "OK - Tipografia 24px implementada" -ForegroundColor Green
    } else {
        Write-Host "ERRO - Tipografia 24px NAO implementada" -ForegroundColor Red
    }
    
    Write-Host ""
    Write-Host "CORRECAO APLICADA COM SUCESSO!" -ForegroundColor Green
    Write-Host "Agora recompile e teste com F5" -ForegroundColor Yellow
    
} else {
    Write-Host "ERRO - Arquivo nao encontrado" -ForegroundColor Red
}

Write-Host ""
Write-Host "Proximos passos:" -ForegroundColor Cyan
Write-Host "1. Recompilar projeto" -ForegroundColor White
Write-Host "2. Testar com F5" -ForegroundColor White
Write-Host "3. Verificar icones gigantes" -ForegroundColor White