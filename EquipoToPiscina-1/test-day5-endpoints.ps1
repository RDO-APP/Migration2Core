# Day 5 - Teste dos Endpoints da Migração .NET 8
# Data: 27 de dezembro de 2025

Write-Host "🚀 TESTANDO DAY 5 - ENDPOINTS DE VALIDAÇÃO" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green

$baseUrl = "http://localhost:5031/api/teste"

# Função para testar endpoint
function Test-Endpoint {
    param($url, $name)
    
    Write-Host "`n📡 Testando: $name" -ForegroundColor Yellow
    Write-Host "URL: $url" -ForegroundColor Gray
    
    try {
        $response = Invoke-RestMethod -Uri $url -Method GET -ContentType "application/json"
        Write-Host "✅ SUCESSO!" -ForegroundColor Green
        Write-Host ($response | ConvertTo-Json -Depth 3) -ForegroundColor Cyan
        return $true
    }
    catch {
        Write-Host "❌ ERRO: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Testar todos os endpoints
Write-Host "`n🔍 INICIANDO TESTES DOS ENDPOINTS..." -ForegroundColor Magenta

$endpoints = @(
    @{ url = "$baseUrl/conexao"; name = "Teste de Conexão" },
    @{ url = "$baseUrl/tabelas"; name = "Listar Tabelas" },
    @{ url = "$baseUrl/estrutura"; name = "Verificar Estrutura" },
    @{ url = "$baseUrl/relacionamentos-complexos"; name = "Relacionamentos Complexos (Day 4)" },
    @{ url = "$baseUrl/day5-migration-ready"; name = "Day 5 - Migration Ready" },
    @{ url = "$baseUrl/validate-all-entities"; name = "Day 5 - Validação Completa" }
)

$sucessos = 0
$total = $endpoints.Count

foreach ($endpoint in $endpoints) {
    if (Test-Endpoint -url $endpoint.url -name $endpoint.name) {
        $sucessos++
    }
    Start-Sleep -Seconds 1
}

# Resultado final
Write-Host "`n" -NoNewline
Write-Host "📊 RESULTADO FINAL DOS TESTES" -ForegroundColor Magenta
Write-Host "=============================" -ForegroundColor Magenta
Write-Host "✅ Sucessos: $sucessos/$total" -ForegroundColor Green

if ($sucessos -eq $total) {
    Write-Host "`n🎉 TODOS OS TESTES PASSARAM!" -ForegroundColor Green
    Write-Host "🎯 DAY 5 VALIDAÇÃO COMPLETA!" -ForegroundColor Green
    Write-Host "📋 Próximos passos:" -ForegroundColor Yellow
    Write-Host "   1. Aplicar migration: dotnet ef database update" -ForegroundColor White
    Write-Host "   2. Testar com banco real" -ForegroundColor White
    Write-Host "   3. Documentar Semana 1 completa" -ForegroundColor White
}
else {
    Write-Host "`n⚠️  Alguns testes falharam. Verificar logs acima." -ForegroundColor Yellow
}

Write-Host "`n🏁 Teste concluído!" -ForegroundColor Blue