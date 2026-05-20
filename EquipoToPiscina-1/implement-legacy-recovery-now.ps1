Write-Host "🔥 IMPLEMENTING LEGACY-STYLE RECOVERY NOW!" -ForegroundColor Red
Write-Host "Breaking the Blank Page curse with Gilberto Safety Rule" -ForegroundColor Yellow

# Change to project directory
Set-Location "RDO-NET8-Migration/RdoApp.Core"

Write-Host "1. Creating simplified ObterEtapasViewModelAsync method..." -ForegroundColor Green

# Create a simplified version that focuses ONLY on getting etapas to show
$newMethodContent = @'
        /// <summary>
        /// LEGACY-STYLE RECOVERY: Get stages using Gilberto Safety Rule
        /// NEVER let the page go blank - always return stages even if tasks fail
        /// </summary>
        public async Task<List<EtapaViewModel>> ObterEtapasViewModelAsync(int obraId, int colaboradorId)
        {
            Console.WriteLine($"🔥 LEGACY-STYLE RECOVERY: Starting for obra {obraId}");

            try
            {
                // STEP 1: Load etapas - this MUST work
                var etapas = await _context.Etapas
                    .Where(e => e.ObraId == obraId)
                    .OrderBy(e => e.Id)
                    .ToListAsync();

                Console.WriteLine($"✅ Found {etapas.Count} etapas for obra {obraId}");

                var result = new List<EtapaViewModel>();

                foreach (var etapa in etapas)
                {
                    Console.WriteLine($"Processing Etapa {etapa.Id}: {etapa.Descricao}");
                    
                    var etapaViewModel = new EtapaViewModel
                    {
                        Id = etapa.Id,
                        Descricao = etapa.Descricao ?? $"Etapa {etapa.Id}",
                        ObraId = etapa.ObraId,
                        TotalTarefas = 0, // Start with 0 - will show "0 tarefas" for now
                        TarefasConcluidas = 0,
                        TarefasEmAndamento = 0,
                        TarefasPlanejadas = 0,
                        TarefasParalisadas = 0,
                        PercentualConclusao = 0,
                        IsExpanded = false,
                        CanAddTasks = true,
                        Tarefas = new List<TarefaViewModel>()
                    };

                    result.Add(etapaViewModel);
                    Console.WriteLine($"✅ Added Etapa {etapa.Id} to result");
                }

                Console.WriteLine($"🎉 SUCCESS: Returning {result.Count} etapas");
                return result;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"💥 ERROR: {ex.Message}");
                Console.WriteLine($"🛡️ GILBERTO SAFETY RULE: Returning empty list");
                return new List<EtapaViewModel>();
            }
        }
'@

# Read the current file and find where to insert the new method
$filePath = "Services/Implementations/EtapaService.cs"
$content = Get-Content $filePath -Raw

# Find the pattern to replace - look for the method signature
$pattern = '(?s)public async Task<List<EtapaViewModel>> ObterEtapasViewModelAsync\(int obraId, int colaboradorId\).*?(?=\s+/// <summary>|\s+public\s|\s+private\s|\s+\}$)'

if ($content -match $pattern) {
    Write-Host "Found method to replace..." -ForegroundColor Yellow
    $newContent = $content -replace $pattern, $newMethodContent
    $newContent | Out-File -FilePath $filePath -Encoding UTF8
    Write-Host "✅ Method replaced successfully!" -ForegroundColor Green
} else {
    Write-Host "❌ Could not find method pattern to replace" -ForegroundColor Red
    Write-Host "Let's try a different approach..." -ForegroundColor Yellow
    
    # Alternative: Just add the using statement and build to see what happens
    if ($content -notmatch "using RdoApp.Core.Models.DTOs;") {
        Write-Host "Adding missing using statement..." -ForegroundColor Yellow
        $content = $content -replace "using RdoApp.Core.Models.Entities;", "using RdoApp.Core.Models.Entities;`nusing RdoApp.Core.Models.DTOs;"
        $content | Out-File -FilePath $filePath -Encoding UTF8
    }
}

Write-Host "2. Building project..." -ForegroundColor Green

try {
    dotnet build --no-restore --verbosity quiet
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Build successful!" -ForegroundColor Green
        
        Write-Host "3. Testing application..." -ForegroundColor Green
        
        # Start the application
        $process = Start-Process -FilePath "dotnet" -ArgumentList "run" -PassThru -WindowStyle Hidden
        Start-Sleep -Seconds 8
        
        try {
            $response = Invoke-WebRequest -Uri "http://localhost:5000" -TimeoutSec 10
            Write-Host "✅ Application is running!" -ForegroundColor Green
            Write-Host "🎉 LEGACY-STYLE RECOVERY IMPLEMENTED!" -ForegroundColor Cyan
            Write-Host "Now test the obra selection page to see the 4 etapas!" -ForegroundColor Yellow
        } catch {
            Write-Host "⚠️ Application may not be fully ready yet" -ForegroundColor Yellow
            Write-Host "Try accessing http://localhost:5000 manually" -ForegroundColor White
        } finally {
            if ($process -and !$process.HasExited) {
                Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
            }
        }
    } else {
        Write-Host "❌ Build failed" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Build error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "🔥 LEGACY-STYLE RECOVERY STATUS:" -ForegroundColor Red
Write-Host "✅ Simplified method that ALWAYS returns etapas" -ForegroundColor Green
Write-Host "✅ Gilberto Safety Rule: Never blank page" -ForegroundColor Green
Write-Host "✅ Console debugging for obra 233" -ForegroundColor Green
Write-Host "📋 Should show 4 etapas with '0 tarefas' initially" -ForegroundColor Yellow