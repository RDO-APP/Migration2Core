#!/usr/bin/env pwsh

# Teste simples para debugar o EtapaService
Write-Host "🔍 Teste Debug: EtapaService" -ForegroundColor Yellow
Write-Host "=" * 50

# Primeiro, vamos executar o SQL para verificar dados
Write-Host "`n📋 Execute este SQL no DBeaver para verificar dados:" -ForegroundColor Cyan
Write-Host "investigate-empty-etapas-page.sql" -ForegroundColor Green

# Vamos criar um teste simples do controller
Write-Host "`n📋 Criando versão debug do método Etapas..." -ForegroundColor Cyan

$debugMethod = @"
public async Task<IActionResult> Etapas(int? obraId)
{
    try
    {
        // DEBUG: Log início
        Console.WriteLine("=== INÍCIO DEBUG ETAPAS ===");
        
        // IMPROVEMENT 3: Claims-based authentication
        var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        Console.WriteLine($"UserIdClaim: {userIdClaim ?? "NULL"}");
        
        if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out int colaboradorId))
        {
            Console.WriteLine("ERRO: Invalid or missing user ID claim for Etapas access");
            return RedirectToAction("Login", "Auth");
        }
        
        Console.WriteLine($"ColaboradorId extraído: {colaboradorId}");

        if (!obraId.HasValue)
        {
            obraId = HttpContext.Session.GetInt32("ObraId") ?? 1;
        }
        
        Console.WriteLine($"ObraId: {obraId.Value}");

        // DEBUG: Testar conexão direta com banco usando DbContext
        using (var scope = HttpContext.RequestServices.CreateScope())
        {
            var context = scope.ServiceProvider.GetRequiredService<RdoContext>();
            
            var totalEtapas = await context.Etapas.CountAsync();
            Console.WriteLine($"Total de etapas no banco: {totalEtapas}");
            
            var etapasObra = await context.Etapas.Where(e => e.ObraId == obraId.Value).CountAsync();
            Console.WriteLine($"Etapas para obra {obraId.Value}: {etapasObra}");
            
            // Listar algumas etapas
            var etapasLista = await context.Etapas
                .Where(e => e.ObraId == obraId.Value)
                .Take(5)
                .ToListAsync();
                
            Console.WriteLine($"Primeiras etapas encontradas:");
            foreach (var e in etapasLista)
            {
                Console.WriteLine($"  - Etapa {e.Id}: {e.Descricao}");
            }
        }

        // IMPROVEMENT 2: Use dedicated EtapaService with strongly-typed ViewModels
        Console.WriteLine("Chamando ObterEtapasViewModelAsync...");
        var etapas = await _etapaService.ObterEtapasViewModelAsync(obraId.Value, colaboradorId);
        
        Console.WriteLine($"Resultado: {etapas.Count} etapas retornadas");
        
        foreach (var etapa in etapas)
        {
            Console.WriteLine($"Etapa {etapa.Id}: {etapa.Descricao} - {etapa.TotalTarefas} tarefas");
        }

        ViewBag.ObraId = obraId.Value;
        ViewBag.ObraNome = $"Obra {obraId.Value}";
        ViewBag.UsuarioNome = User.Identity?.Name ?? "Usuário";

        Console.WriteLine("=== FIM DEBUG ETAPAS ===");

        // IMPROVEMENT 1: Return strongly-typed ViewModels
        return View(etapas);
    }
    catch (Exception ex)
    {
        Console.WriteLine($"ERRO COMPLETO: {ex.Message}");
        Console.WriteLine($"Stack Trace: {ex.StackTrace}");
        ViewBag.ErrorMessage = "Erro ao carregar etapas. Tente novamente.";
        return View(new List<EtapaViewModel>());
    }
}
"@

Write-Output $debugMethod | Out-File -FilePath "debug-etapas-method.cs" -Encoding UTF8
Write-Host "✅ Método debug criado: debug-etapas-method.cs" -ForegroundColor Green

Write-Host "`n🎯 PRÓXIMOS PASSOS:" -ForegroundColor Green
Write-Host "1. Execute investigate-empty-etapas-page.sql no DBeaver" -ForegroundColor Yellow
Write-Host "2. Substitua temporariamente o método Etapas() pelo debug version" -ForegroundColor Yellow
Write-Host "3. Execute a aplicação e verifique os logs no console" -ForegroundColor Yellow
Write-Host "4. Verifique se há dados no banco para a obra selecionada" -ForegroundColor Yellow

Write-Host "`n📊 POSSÍVEIS CAUSAS:" -ForegroundColor Cyan
Write-Host "• Não há etapas no banco para a obra selecionada" -ForegroundColor White
Write-Host "• Problema na autenticação - colaboradorId inválido" -ForegroundColor White
Write-Host "• Erro na query do Entity Framework" -ForegroundColor White
Write-Host "• Problema no mapeamento Entity -> ViewModel" -ForegroundColor White
Write-Host "• Exceção silenciosa no controller" -ForegroundColor White