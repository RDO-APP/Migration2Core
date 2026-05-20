# CRITICAL SCHEMA DIAGNOSIS: Test EtapaService database connection and schema mapping
# This will identify the root cause of empty results issue

Write-Host "=== ETAPA SCHEMA DIAGNOSIS ===" -ForegroundColor Yellow
Write-Host "Testing database connection and schema mapping..." -ForegroundColor Green

# Navigate to project directory
Set-Location "RDO-NET8-Migration\RdoApp.Core"

# Create a simple test to verify database connection and schema
$testCode = @"
using Microsoft.EntityFrameworkCore;
using RdoApp.Core.Data.Context;
using RdoApp.Core.Models.Entities;

var connectionString = "Server=equipamentos.cslrikufb7hm.us-east-2.rds.amazonaws.com;Database=piscinas_rdoapp_homologa;Uid=rdoadmin;Pwd=rdoapp2018aws;CharSet=utf8mb4;";

var options = new DbContextOptionsBuilder<RdoContext>()
    .UseMySql(connectionString, ServerVersion.AutoDetect(connectionString))
    .Options;

using var context = new RdoContext(options);

Console.WriteLine("=== DATABASE CONNECTION TEST ===");
try 
{
    var canConnect = await context.Database.CanConnectAsync();
    Console.WriteLine($"Database connection: {canConnect}");
    
    if (!canConnect) 
    {
        Console.WriteLine("❌ CRITICAL: Cannot connect to database!");
        return;
    }
} 
catch (Exception ex) 
{
    Console.WriteLine($"❌ Connection error: {ex.Message}");
    return;
}

Console.WriteLine("\n=== RAW ETAPA COUNT TEST ===");
try 
{
    var totalEtapas = await context.Etapas.CountAsync();
    Console.WriteLine($"Total etapas in database: {totalEtapas}");
    
    var etapasObra1 = await context.Etapas.Where(e => e.ObraId == 1).CountAsync();
    Console.WriteLine($"Etapas for ObraId=1: {etapasObra1}");
    
    if (etapasObra1 == 0) 
    {
        Console.WriteLine("❌ CRITICAL: No etapas found for ObraId=1!");
        
        // Check what obra IDs actually exist
        var obraIds = await context.Etapas
            .GroupBy(e => e.ObraId)
            .Select(g => new { ObraId = g.Key, Count = g.Count() })
            .ToListAsync();
            
        Console.WriteLine("Available ObraIds:");
        foreach (var obra in obraIds) 
        {
            Console.WriteLine($"  - ObraId {obra.ObraId}: {obra.Count} etapas");
        }
    }
} 
catch (Exception ex) 
{
    Console.WriteLine($"❌ Query error: {ex.Message}");
    Console.WriteLine($"❌ Stack trace: {ex.StackTrace}");
}

Console.WriteLine("\n=== ETAPA DETAILS TEST ===");
try 
{
    var etapas = await context.Etapas
        .Where(e => e.ObraId == 1)
        .Take(5)
        .ToListAsync();
        
    Console.WriteLine($"First 5 etapas for ObraId=1:");
    foreach (var etapa in etapas) 
    {
        Console.WriteLine($"  - Etapa {etapa.Id}: '{etapa.Descricao}' (ObraId: {etapa.ObraId})");
    }
} 
catch (Exception ex) 
{
    Console.WriteLine($"❌ Etapa details error: {ex.Message}");
}

Console.WriteLine("\n=== INCLUDE TEST ===");
try 
{
    var etapasWithTarefas = await context.Etapas
        .Include(e => e.Tarefas)
        .Where(e => e.ObraId == 1)
        .Take(2)
        .ToListAsync();
        
    Console.WriteLine($"Etapas with Include(Tarefas):");
    foreach (var etapa in etapasWithTarefas) 
    {
        var tarefaCount = etapa.Tarefas?.Count ?? 0;
        Console.WriteLine($"  - Etapa {etapa.Id}: {tarefaCount} tarefas");
        
        if (etapa.Tarefas == null) 
        {
            Console.WriteLine($"    ❌ WARNING: Tarefas navigation property is NULL!");
        }
    }
} 
catch (Exception ex) 
{
    Console.WriteLine($"❌ Include test error: {ex.Message}");
}

Console.WriteLine("\n=== DIAGNOSIS COMPLETE ===");
"@

# Write test code to temporary file
$testCode | Out-File -FilePath "EtapaDiagnosis.cs" -Encoding UTF8

Write-Host "Created diagnosis test file: EtapaDiagnosis.cs" -ForegroundColor Green
Write-Host "Run this with: dotnet run --project . EtapaDiagnosis.cs" -ForegroundColor Yellow
Write-Host "Or compile and run in Visual Studio for better debugging" -ForegroundColor Yellow

# Return to root directory
Set-Location "..\..\"

Write-Host "=== NEXT STEPS ===" -ForegroundColor Yellow
Write-Host "1. Run the diagnosis test to identify the exact issue" -ForegroundColor White
Write-Host "2. Check Visual Studio Output window for EtapaService debug logs" -ForegroundColor White
Write-Host "3. Compare ObraId values between logs and DBeaver" -ForegroundColor White
Write-Host "4. Verify Entity Framework configuration matches database schema" -ForegroundColor White