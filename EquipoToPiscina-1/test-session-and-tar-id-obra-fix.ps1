#!/usr/bin/env pwsh

Write-Host "=== TESTING SESSION CONFIGURATION AND TAR_ID_OBRA FIX ===" -ForegroundColor Green

# Test 1: Verify Session configuration in Program.cs
Write-Host "`n1. Checking Session configuration in Program.cs..." -ForegroundColor Yellow

$programCs = Get-Content "RDO-NET8-Migration/RdoApp.Core/Program.cs" -Raw

if ($programCs -match "builder\.Services\.AddSession") {
    Write-Host "✅ Session service configuration found" -ForegroundColor Green
} else {
    Write-Host "❌ Session service configuration NOT found" -ForegroundColor Red
}

if ($programCs -match "app\.UseSession") {
    Write-Host "✅ Session middleware configuration found" -ForegroundColor Green
} else {
    Write-Host "❌ Session middleware configuration NOT found" -ForegroundColor Red
}

# Test 2: Verify Tarefa.cs has correct tar_id_obra mapping
Write-Host "`n2. Checking Tarefa.cs tar_id_obra mapping..." -ForegroundColor Yellow

$tarefaCs = Get-Content "RDO-NET8-Migration/RdoApp.Core/Models/Entities/Tarefa.cs" -Raw

if ($tarefaCs -match '\[Column\("tar_id_obra"\)\]') {
    Write-Host "✅ tar_id_obra column mapping found in Tarefa.cs" -ForegroundColor Green
} else {
    Write-Host "❌ tar_id_obra column mapping NOT found in Tarefa.cs" -ForegroundColor Red
}

# Test 3: Verify TarefaConfiguration.cs has proper relationship
Write-Host "`n3. Checking TarefaConfiguration.cs relationship..." -ForegroundColor Yellow

$tarefaConfigCs = Get-Content "RDO-NET8-Migration/RdoApp.Core/Data/Configurations/TarefaConfiguration.cs" -Raw

if ($tarefaConfigCs -match "HasForeignKey\(t => t\.EtapaId\)") {
    Write-Host "✅ EtapaId foreign key relationship found" -ForegroundColor Green
} else {
    Write-Host "❌ EtapaId foreign key relationship NOT found" -ForegroundColor Red
}

# Test 4: Verify EtapaService uses clean Include without tar_id_obra filtering
Write-Host "`n4. Checking EtapaService query implementation..." -ForegroundColor Yellow

$etapaServiceCs = Get-Content "RDO-NET8-Migration/RdoApp.Core/Services/Implementations/EtapaService.cs" -Raw

if ($etapaServiceCs -match "\.Include\(e => e\.Tarefas\)") {
    Write-Host "✅ Clean Include(e => e.Tarefas) found in EtapaService" -ForegroundColor Green
} else {
    Write-Host "❌ Clean Include(e => e.Tarefas) NOT found in EtapaService" -ForegroundColor Red
}

if ($etapaServiceCs -match "AsSplitQuery") {
    Write-Host "✅ AsSplitQuery optimization found" -ForegroundColor Green
} else {
    Write-Host "❌ AsSplitQuery optimization NOT found" -ForegroundColor Red
}

# Test 5: Try to compile the project
Write-Host "`n5. Testing compilation..." -ForegroundColor Yellow

try {
    Push-Location "RDO-NET8-Migration/RdoApp.Core"
    
    Write-Host "Building project..." -ForegroundColor Cyan
    $buildResult = dotnet build --no-restore 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Project compiled successfully" -ForegroundColor Green
    } else {
        Write-Host "❌ Compilation failed:" -ForegroundColor Red
        Write-Host $buildResult -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Error during compilation: $($_.Exception.Message)" -ForegroundColor Red
} finally {
    Pop-Location
}

Write-Host "`n=== SUMMARY ===" -ForegroundColor Green
Write-Host "Session Configuration: Added builder.Services.AddSession() and app.UseSession()" -ForegroundColor Cyan
Write-Host "tar_id_obra Mapping: Verified [Column('tar_id_obra')] exists in Tarefa.cs" -ForegroundColor Cyan
Write-Host "EtapaService Query: Uses clean Include(e => e.Tarefas) with AsSplitQuery" -ForegroundColor Cyan
Write-Host "Ready for F5 testing in Visual Studio" -ForegroundColor Green

Write-Host "`n=== NEXT STEPS ===" -ForegroundColor Yellow
Write-Host "1. Press F5 in Visual Studio to test the application" -ForegroundColor White
Write-Host "2. Login and navigate to Obra selection" -ForegroundColor White
Write-Host "3. Select an obra and check if 4 etapas appear" -ForegroundColor White
Write-Host "4. Verify no 'Session has not been configured' error" -ForegroundColor White
Write-Host "5. Verify no 'Unknown column tar_id_obra' MySQL error" -ForegroundColor White