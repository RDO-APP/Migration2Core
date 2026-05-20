# Day 6 - Teste dos Novos Controllers e Services
Write-Host "TESTANDO DAY 6 - CONTROLLERS E SERVICES" -ForegroundColor Green

$baseUrl = "http://localhost:5031"

# Função para testar endpoint
function Test-Endpoint {
    param($url, $name, $method = "GET", $body = $null)
    
    Write-Host "`nTestando: $name" -ForegroundColor Yellow
    Write-Host "URL: $url" -ForegroundColor Gray
    
    try {
        if ($method -eq "GET") {
            $response = Invoke-RestMethod -Uri $url -Method GET -ContentType "application/json"
        } else {
            $response = Invoke-RestMethod -Uri $url -Method $method -Body ($body | ConvertTo-Json) -ContentType "application/json"
        }
        Write-Host "SUCESSO!" -ForegroundColor Green
        Write-Host ($response | ConvertTo-Json -Depth 2) -ForegroundColor Cyan
        return $true
    }
    catch {
        Write-Host "ERRO: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Testar endpoints principais
Write-Host "`nINICIANDO TESTES DOS NOVOS ENDPOINTS..." -ForegroundColor Magenta

$endpoints = @(
    @{ url = "$baseUrl/api/teste/conexao"; name = "Teste de Conexao (Original)" },
    @{ url = "$baseUrl/api/teste/day5-migration-ready"; name = "Day 5 Migration Status" },
    @{ url = "$baseUrl/api/tarefa"; name = "GET Todas as Tarefas (Novo)" },
    @{ url = "$baseUrl/swagger"; name = "Swagger UI (Documentacao)" }
)

$sucessos = 0
$total = $endpoints.Count

foreach ($endpoint in $endpoints) {
    if (Test-Endpoint -url $endpoint.url -name $endpoint.name) {
        $sucessos++
    }
    Start-Sleep -Seconds 1
}

# Testar filtro de tarefas
Write-Host "`nTestando filtro de tarefas..." -ForegroundColor Yellow
$filterBody = @{
    page = 1
    pageSize = 5
}

if (Test-Endpoint -url "$baseUrl/api/tarefa/search" -name "Filtro de Tarefas" -method "POST" -body $filterBody) {
    $sucessos++
}
$total++

# Resultado final
Write-Host "`nRESULTADO FINAL DOS TESTES" -ForegroundColor Magenta
Write-Host "=============================" -ForegroundColor Magenta
Write-Host "Sucessos: $sucessos/$total" -ForegroundColor Green

if ($sucessos -eq $total) {
    Write-Host "`nTODOS OS TESTES PASSARAM!" -ForegroundColor Green
    Write-Host "DAY 6 CONTROLLERS FUNCIONANDO!" -ForegroundColor Green
    Write-Host "Acesse: http://localhost:5031/swagger para ver a documentacao" -ForegroundColor Yellow
}
else {
    Write-Host "`nAlguns testes falharam. Verificar logs acima." -ForegroundColor Yellow
}

Write-Host "`nTeste concluido!" -ForegroundColor Blue