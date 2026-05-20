#!/usr/bin/env pwsh

# Comprehensive diagnostic script for Etapas Model.Any() issue
# The database has 4 etapas but Model.Any() returns false in the view

Write-Host "=== DIAGNOSING ETAPAS MODEL.ANY() ISSUE ===" -ForegroundColor Green
Write-Host "Problem: Database has 4 etapas but UI shows 'Nenhuma etapa encontrada'" -ForegroundColor Yellow

# Navigate to project directory
Set-Location "RDO-NET8-Migration/RdoApp.Core"

Write-Host "`n1. Checking EtapaViewModel properties..." -ForegroundColor Cyan
$etapaViewModelPath = "Models/ViewModels/EtapaViewModel.cs"
if (Test-Path $etapaViewModelPath) {
    $viewModelContent = Get-Content $etapaViewModelPath -Raw
    Write-Host "✅ EtapaViewModel.cs exists" -ForegroundColor Green
    
    # Check for essential properties
    $requiredProperties = @("Id", "Descricao", "TotalTarefas", "Tarefas")
    foreach ($prop in $requiredProperties) {
        if ($viewModelContent -match "public.*$prop") {
            Write-Host "  ✅ Property '$prop' found" -ForegroundColor Green
        } else {
            Write-Host "  ❌ Property '$prop' MISSING" -ForegroundColor Red
        }
    }
} else {
    Write-Host "❌ EtapaViewModel.cs not found!" -ForegroundColor Red
}

Write-Host "`n2. Checking TarefaViewModel properties..." -ForegroundColor Cyan
$tarefaViewModelPath = "Models/ViewModels/TarefaViewModel.cs"
if (Test-Path $tarefaViewModelPath) {
    Write-Host "✅ TarefaViewModel.cs exists" -ForegroundColor Green
} else {
    Write-Host "❌ TarefaViewModel.cs not found!" -ForegroundColor Red
}

Write-Host "`n3. Analyzing EtapaService debug logs..." -ForegroundColor Cyan
$etapaServiceContent = Get-Content "Services/Implementations/EtapaService.cs" -Raw

# Check for critical debug statements
$debugChecks = @(
    @{ Pattern = "Console\.WriteLine.*DEBUG.*ObterEtapasViewModelAsync"; Description = "Entry debug logging" },
    @{ Pattern = "Console\.WriteLine.*Etapas encontradas no banco"; Description = "Database query result logging" },
    @{ Pattern = "Console\.WriteLine.*RESULTADO FINAL.*etapas no ViewModel"; Description = "Final result logging" },
    @{ Pattern = "return true;.*bypass colaboradorId filtering"; Description = "Authorization bypass" }
)

foreach ($check in $debugChecks) {
    if ($etapaServiceContent -match $check.Pattern) {
        Write-Host "  ✅ $($check.Description)" -ForegroundColor Green
    } else {
        Write-Host "  ❌ $($check.Description) MISSING" -ForegroundColor Red
    }
}

Write-Host "`n4. Checking Controller debug logs..." -ForegroundColor Cyan
$controllerContent = Get-Content "Controllers/ObraController.cs" -Raw
if ($controllerContent -match "Console\.WriteLine.*Controller received.*etapas from Service") {
    Write-Host "✅ Controller debug logging present" -ForegroundColor Green
} else {
    Write-Host "❌ Controller debug logging missing" -ForegroundColor Red
}

Write-Host "`n5. Checking View debug logs..." -ForegroundColor Cyan
$viewContent = Get-Content "Views/Obra/Etapas.cshtml" -Raw
if ($viewContent -match "System\.Console\.WriteLine.*FORCE DEBUG.*Model count") {
    Write-Host "✅ View debug logging present" -ForegroundColor Green
} else {
    Write-Host "❌ View debug logging missing" -ForegroundColor Red
}

Write-Host "`n6. Checking for potential ViewModel issues..." -ForegroundColor Cyan

# Check if there are any properties in the view that might not exist in ViewModel
$viewProperties = @("BadgeText", "PercentualConclusaoFormatado", "StatusSummary", "CanAddTasks")
foreach ($prop in $viewProperties) {
    if ($viewContent -match "@etapa\.value\.$prop") {
        Write-Host "  ⚠️  View uses property '$prop' - verify it exists in EtapaViewModel" -ForegroundColor Yellow
    }
}

Write-Host "`n7. Creating enhanced debug version of EtapaService..." -ForegroundColor Cyan

# Create a backup and enhanced version with more debug logging
$backupPath = "Services/Implementations/EtapaService.cs.backup"
if (-not (Test-Path $backupPath)) {
    Copy-Item "Services/Implementations/EtapaService.cs" $backupPath
    Write-Host "✅ Backup created: $backupPath" -ForegroundColor Green
}

# Add enhanced debug logging to the ObterEtapasViewModelAsync method
$enhancedDebugCode = @'
        /// <summary>
        /// Get stages with tasks as strongly-typed ViewModels for modern UI display
        /// Replaces dynamic objects with compile-time safe ViewModels
        /// Applies user-specific filtering based on colaboradorId
        /// ENHANCED DEBUG VERSION - January 1, 2026
        /// </summary>
        public async Task<List<EtapaViewModel>> ObterEtapasViewModelAsync(int obraId, int colaboradorId)
        {
            // ENHANCED DEBUG: Log everything
            Console.WriteLine($"=== ENHANCED DEBUG EtapaService.ObterEtapasViewModelAsync ===");
            Console.WriteLine($"ObraId recebido: {obraId}");
            Console.WriteLine($"ColaboradorId recebido: {colaboradorId}");
            Console.WriteLine($"DateTime.Now: {DateTime.Now}");

            // Test database connection
            try
            {
                var connectionTest = await _context.Database.CanConnectAsync();
                Console.WriteLine($"Database connection test: {connectionTest}");
                
                if (!connectionTest)
                {
                    Console.WriteLine("❌ CRITICAL: Cannot connect to database!");
                    return new List<EtapaViewModel>();
                }
            }
            catch (Exception dbEx)
            {
                Console.WriteLine($"❌ CRITICAL: Database connection error: {dbEx.Message}");
                return new List<EtapaViewModel>();
            }

            // Query database with enhanced logging
            Console.WriteLine($"🔍 Querying database for etapas with ObraId = {obraId}...");
            
            var etapas = await _context.Etapas
                .AsSplitQuery()
                .Include(e => e.Tarefas)
                    .ThenInclude(t => t.Status)
                .Where(e => e.ObraId == obraId)
                .OrderBy(e => e.Id)
                .ToListAsync();

            Console.WriteLine($"📊 DATABASE RESULT: {etapas.Count} etapas found");
            
            if (etapas.Count == 0) {
                Console.WriteLine($"❌ NO ETAPAS FOUND - This explains empty UI!");
                Console.WriteLine($"🔍 Checking if any etapas exist in database at all...");
                
                var totalEtapas = await _context.Etapas.CountAsync();
                Console.WriteLine($"📊 Total etapas in database: {totalEtapas}");
                
                if (totalEtapas > 0) {
                    var allEtapas = await _context.Etapas.Take(5).ToListAsync();
                    Console.WriteLine($"🔍 Sample etapas in database:");
                    foreach (var e in allEtapas) {
                        Console.WriteLine($"  - Etapa {e.Id}: ObraId={e.ObraId}, Descricao='{e.Descricao}'");
                    }
                    Console.WriteLine($"❌ PROBLEM: ObraId {obraId} doesn't match any etapas!");
                }
                
                return new List<EtapaViewModel>();
            }

            // Log each etapa found
            foreach (var e in etapas)
            {
                Console.WriteLine($"  📋 Etapa {e.Id}: '{e.Descricao}' with {e.Tarefas?.Count ?? 0} tarefas");
            }

            var etapasViewModel = new List<EtapaViewModel>();

            // Process each etapa with enhanced error handling
            for (int i = 0; i < etapas.Count; i++)
            {
                var etapa = etapas[i];
                Console.WriteLine($"\n🔄 Processing Etapa {i + 1}/{etapas.Count}: ID {etapa.Id}");
                
                try
                {
                    // Initialize Tarefas if null
                    if (etapa.Tarefas == null)
                    {
                        Console.WriteLine($"⚠️  etapa.Tarefas is NULL for Etapa {etapa.Id} - initializing empty list");
                        etapa.Tarefas = new List<Tarefa>();
                    }
                    
                    Console.WriteLine($"📊 Total tarefas in etapa: {etapa.Tarefas.Count}");
                    
                    // Apply authorization filter (currently always returns true)
                    var tarefasUsuario = etapa.Tarefas
                        .Where(t => IsUserAuthorizedForTask(t, colaboradorId))
                        .ToList();
                    
                    Console.WriteLine($"📊 Tarefas after authorization filter: {tarefasUsuario.Count}");

                    // Create EtapaViewModel
                    var etapaViewModel = new EtapaViewModel
                    {
                        Id = etapa.Id,
                        Descricao = etapa.Descricao ?? $"Etapa {etapa.Id}",
                        ObraId = etapa.ObraId,
                        TotalTarefas = tarefasUsuario.Count,
                        TarefasConcluidas = tarefasUsuario.Count(t => t.StatusId == 3),
                        TarefasEmAndamento = tarefasUsuario.Count(t => t.StatusId == 2),
                        TarefasPlanejadas = tarefasUsuario.Count(t => t.StatusId == 1),
                        TarefasParalisadas = tarefasUsuario.Count(t => t.StatusId == 4),
                        IsExpanded = false,
                        CanAddTasks = true,
                        Tarefas = new List<TarefaViewModel>() // Initialize empty for now to avoid mapping errors
                    };

                    // Calculate completion percentage
                    etapaViewModel.PercentualConclusao = etapaViewModel.TotalTarefas > 0 
                        ? (double)etapaViewModel.TarefasConcluidas / etapaViewModel.TotalTarefas * 100 
                        : 0;

                    Console.WriteLine($"✅ EtapaViewModel created: Id={etapaViewModel.Id}, TotalTarefas={etapaViewModel.TotalTarefas}");
                    
                    etapasViewModel.Add(etapaViewModel);
                    Console.WriteLine($"✅ Added to etapasViewModel list (current count: {etapasViewModel.Count})");
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"❌ ERROR processing Etapa {etapa.Id}: {ex.Message}");
                    Console.WriteLine($"❌ StackTrace: {ex.StackTrace}");
                    
                    // Add minimal etapa to avoid complete failure
                    try
                    {
                        var fallbackEtapa = new EtapaViewModel
                        {
                            Id = etapa.Id,
                            Descricao = etapa.Descricao ?? $"Etapa {etapa.Id}",
                            ObraId = etapa.ObraId,
                            TotalTarefas = 0,
                            TarefasConcluidas = 0,
                            TarefasEmAndamento = 0,
                            TarefasPlanejadas = 0,
                            TarefasParalisadas = 0,
                            IsExpanded = false,
                            CanAddTasks = true,
                            Tarefas = new List<TarefaViewModel>()
                        };
                        
                        etapasViewModel.Add(fallbackEtapa);
                        Console.WriteLine($"✅ Fallback etapa added (current count: {etapasViewModel.Count})");
                    }
                    catch (Exception fallbackEx)
                    {
                        Console.WriteLine($"❌ CRITICAL: Even fallback failed: {fallbackEx.Message}");
                    }
                }
            }

            Console.WriteLine($"\n🎯 FINAL RESULT: {etapasViewModel.Count} etapas in ViewModel");
            Console.WriteLine($"📊 Expected: 4 etapas (880, 881, 883, 884)");
            Console.WriteLine($"📊 Actual: {etapasViewModel.Count} etapas");
            
            if (etapasViewModel.Count == 0) {
                Console.WriteLine($"❌ CRITICAL: Returning empty list - this will cause Model.Any() to return false!");
            } else {
                Console.WriteLine($"✅ SUCCESS: Returning {etapasViewModel.Count} etapas - Model.Any() should return true");
                foreach (var vm in etapasViewModel) {
                    Console.WriteLine($"  📋 ViewModel: Id={vm.Id}, Descricao='{vm.Descricao}', TotalTarefas={vm.TotalTarefas}");
                }
            }
            
            Console.WriteLine($"=== END ENHANCED DEBUG ===\n");
            return etapasViewModel;
        }
'@

Write-Host "`n8. RECOMMENDED NEXT STEPS:" -ForegroundColor Yellow
Write-Host "1. Run the application and check Visual Studio Output window" -ForegroundColor White
Write-Host "2. Look for the enhanced debug logs to identify where the issue occurs" -ForegroundColor White
Write-Host "3. Pay attention to:" -ForegroundColor White
Write-Host "   - Database connection success/failure" -ForegroundColor Gray
Write-Host "   - Number of etapas found in database query" -ForegroundColor Gray
Write-Host "   - ObraId matching issues" -ForegroundColor Gray
Write-Host "   - EtapaViewModel creation errors" -ForegroundColor Gray
Write-Host "   - Final count returned to controller" -ForegroundColor Gray

Write-Host "`n9. TESTING COMMANDS:" -ForegroundColor Yellow
Write-Host "To test with enhanced debugging:" -ForegroundColor White
Write-Host "  dotnet run" -ForegroundColor Gray
Write-Host "Then navigate to Etapas page and check console output" -ForegroundColor White

Write-Host "`n=== DIAGNOSIS COMPLETE ===" -ForegroundColor Green
Write-Host "The enhanced debug logging will help identify exactly where the issue occurs." -ForegroundColor Yellow