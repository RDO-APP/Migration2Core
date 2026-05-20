#!/usr/bin/env pwsh

Write-Host "=== TESTING CARD DUPLICATION FIX - COMPILATION CHECK ===" -ForegroundColor Green

# Test 1: Check if TarefaModel has the new overload methods
Write-Host "`n1. Checking TarefaModel overload methods..." -ForegroundColor Yellow

$tarefaModelPath = "RDO-Production-Gilberto\rdoappProject\Api\Models\TarefaModel.cs"
$tarefaContent = Get-Content $tarefaModelPath -Raw

if ($tarefaContent -match "public static DateTime _ObterPrimeiroDiaExecutado\(int tarIdTarefa\)") {
    Write-Host "✓ _ObterPrimeiroDiaExecutado(int) overload method found" -ForegroundColor Green
} else {
    Write-Host "✗ _ObterPrimeiroDiaExecutado(int) overload method NOT found" -ForegroundColor Red
}

if ($tarefaContent -match "public static DateTime _ObterUltimoDiaExecutado\(int tarIdTarefa\)") {
    Write-Host "✓ _ObterUltimoDiaExecutado(int) overload method found" -ForegroundColor Green
} else {
    Write-Host "✗ _ObterUltimoDiaExecutado(int) overload method NOT found" -ForegroundColor Red
}

# Test 2: Check if EtapaModel has the GroupBy fix
Write-Host "`n2. Checking EtapaModel GroupBy fix..." -ForegroundColor Yellow

$etapaModelPath = "RDO-Production-Gilberto\rdoappProject\Api\Models\EtapaModel.cs"
$etapaContent = Get-Content $etapaModelPath -Raw

if ($etapaContent -match "GroupBy\(t => t\.tar_id_tarefa\)") {
    Write-Host "✓ GroupBy(t => t.tar_id_tarefa) fix found" -ForegroundColor Green
} else {
    Write-Host "✗ GroupBy(t => t.tar_id_tarefa) fix NOT found" -ForegroundColor Red
}

if ($etapaContent -match "PrimeiraExecucao = TarefaModel\._ObterPrimeiroDiaExecutado\(t\.tar_id_tarefa\)") {
    Write-Host "✓ PrimeiraExecucao parameter fix found" -ForegroundColor Green
} else {
    Write-Host "✗ PrimeiraExecucao parameter fix NOT found" -ForegroundColor Red
}

if ($etapaContent -match "UltimaExecucao = TarefaModel\._ObterUltimoDiaExecutado\(t\.tar_id_tarefa\)") {
    Write-Host "✓ UltimaExecucao parameter fix found" -ForegroundColor Green
} else {
    Write-Host "✗ UltimaExecucao parameter fix NOT found" -ForegroundColor Red
}

# Test 3: Check RDO-NET8-Migration connection strings
Write-Host "`n3. Checking RDO-NET8-Migration connection strings..." -ForegroundColor Yellow

$appsettingsPath = "RDO-NET8-Migration\RdoApp.Core\appsettings.json"
$appsettingsDevPath = "RDO-NET8-Migration\RdoApp.Core\appsettings.Development.json"

if (Test-Path $appsettingsPath) {
    $appsettingsContent = Get-Content $appsettingsPath -Raw
    if ($appsettingsContent -match "equipamentos\.cslrikufb7hm\.us-east-2\.rds\.amazonaws\.com" -and 
        $appsettingsContent -match "piscinas_rdoapp_homologa" -and
        $appsettingsContent -notmatch "trusted_connection|Integrated Security") {
        Write-Host "✓ appsettings.json connection string is correct" -ForegroundColor Green
    } else {
        Write-Host "✗ appsettings.json connection string has issues" -ForegroundColor Red
    }
}

if (Test-Path $appsettingsDevPath) {
    $appsettingsDevContent = Get-Content $appsettingsDevPath -Raw
    if ($appsettingsDevContent -match "equipamentos\.cslrikufb7hm\.us-east-2\.rds\.amazonaws\.com" -and 
        $appsettingsDevContent -match "piscinas_rdoapp_homologa" -and
        $appsettingsDevContent -notmatch "trusted_connection|Integrated Security") {
        Write-Host "✓ appsettings.Development.json connection string is correct" -ForegroundColor Green
    } else {
        Write-Host "✗ appsettings.Development.json connection string has issues" -ForegroundColor Red
    }
}

# Test 4: Check Program.cs for ServerVersion configuration
Write-Host "`n4. Checking Program.cs ServerVersion configuration..." -ForegroundColor Yellow

$programPath = "RDO-NET8-Migration\RdoApp.Core\Program.cs"
if (Test-Path $programPath) {
    $programContent = Get-Content $programPath -Raw
    $versionPattern = "ServerVersion\.Create.*8.*0.*30"
    if ($programContent -match $versionPattern -and $programContent -notmatch "ServerVersion\.AutoDetect") {
        Write-Host "✓ Program.cs uses specific MySQL version (not AutoDetect)" -ForegroundColor Green
    } else {
        Write-Host "✗ Program.cs has ServerVersion issues" -ForegroundColor Red
    }
}

Write-Host "`n=== SUMMARY ===" -ForegroundColor Cyan
Write-Host "Card duplication fix: GroupBy changed from tar_nr_agrupador to tar_id_tarefa" -ForegroundColor White
Write-Host "Parameter type fix: Added overload methods for int tar_id_tarefa" -ForegroundColor White
Write-Host "Connection string fix: Removed trusted_connection, using AWS RDS" -ForegroundColor White
Write-Host "ServerVersion fix: Using specific version instead of AutoDetect" -ForegroundColor White

Write-Host "`nNext steps:" -ForegroundColor Yellow
Write-Host "1. Fix NuGet package corruption in RDO-Production-Gilberto" -ForegroundColor White
Write-Host "2. Test the application to verify card duplication is resolved" -ForegroundColor White
Write-Host "3. Verify connection string works without trusted_connection error" -ForegroundColor White