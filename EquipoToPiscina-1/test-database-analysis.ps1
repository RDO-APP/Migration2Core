# Test Database Analysis - Get all tables from piscinas_rdoapp_homologa

Write-Host "Testing DATABASE ANALYSIS" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green

# Test basic connection first
Write-Host "1. Testing basic API connection..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:5031/api/TestConnection/database" -Method GET
    Write-Host "API Connection: $($response.mensagem)" -ForegroundColor Green
    Write-Host "   Total Colaboradores: $($response.totalColaboradores)" -ForegroundColor Cyan
} catch {
    Write-Host "API Connection failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Test database analysis - get all tables
Write-Host "2. Getting all database tables..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:5031/api/DatabaseAnalysis/tables" -Method GET
    Write-Host "Database Analysis successful!" -ForegroundColor Green
    Write-Host "   Total Tables: $($response.totalTables)" -ForegroundColor Cyan
    
    Write-Host "ALL TABLES IN DATABASE:" -ForegroundColor Magenta
    Write-Host "=========================" -ForegroundColor Magenta
    
    foreach ($table in $response.tables) {
        Write-Host "   - $table" -ForegroundColor White
    }
    
} catch {
    Write-Host "Database Analysis failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test colaborador table structure
Write-Host "3. Analyzing COLABORADOR table structure..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:5031/api/DatabaseAnalysis/colaborador-structure" -Method GET
    Write-Host "Colaborador Analysis successful!" -ForegroundColor Green
    Write-Host "   Total Columns: $($response.totalColumns)" -ForegroundColor Cyan
    
    Write-Host "COLABORADOR TABLE STRUCTURE:" -ForegroundColor Magenta
    Write-Host "===============================" -ForegroundColor Magenta
    
    foreach ($column in $response.columns) {
        $nullable = if ($column.permite_null -eq "YES") { "NULL" } else { "NOT NULL" }
        $key = if ($column.tipo_chave -eq "PRI") { " [PK]" } elseif ($column.tipo_chave -eq "MUL") { " [FK]" } else { "" }
        Write-Host "   - $($column.campo): $($column.tipo)($($column.tamanho_max)) $nullable$key" -ForegroundColor White
    }
    
} catch {
    Write-Host "Colaborador Analysis failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test colaborador sample data
Write-Host "4. Getting COLABORADOR sample data..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:5031/api/DatabaseAnalysis/colaborador-sample" -Method GET
    Write-Host "Colaborador Sample successful!" -ForegroundColor Green
    Write-Host "   Sample Records: $($response.totalSample)" -ForegroundColor Cyan
    
    Write-Host "COLABORADOR SAMPLE DATA:" -ForegroundColor Magenta
    Write-Host "========================" -ForegroundColor Magenta
    
    foreach ($colaborador in $response.colaboradores) {
        Write-Host "   ID: $($colaborador.id) | Nome: $($colaborador.nome) | CPF: $($colaborador.cpf) | Ativo: $($colaborador.ativo)" -ForegroundColor White
    }
    
} catch {
    Write-Host "Colaborador Sample failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "DATABASE ANALYSIS COMPLETE!" -ForegroundColor Green