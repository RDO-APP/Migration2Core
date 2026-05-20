using Microsoft.AspNetCore.Mvc;
using RdoApp.Core.Models.ViewModels;
using RdoApp.Core.Services.Interfaces;

namespace RdoApp.Core.Controllers.Api
{
    /// <summary>
    /// API Controller for lazy loading tasks within stages (Etapas)
    /// Implements Gilberto's "Source of Truth" pattern for accordion expansion
    /// </summary>
    [ApiController]
    [Route("api/[controller]")]
    public class EtapaTasksController : ControllerBase
    {
        private readonly IEtapaService _etapaService;

        public EtapaTasksController(IEtapaService etapaService)
        {
            _etapaService = etapaService;
        }

        /// <summary>
        /// Load tasks for a specific stage (lazy loading pattern from Gilberto's implementation)
        /// This mimics the original loadCards() function behavior
        /// </summary>
        /// <param name="etapaId">Stage ID</param>
        /// <param name="colaboradorId">User ID for permissions</param>
        /// <returns>List of tasks for the stage</returns>
        [HttpGet("LoadTasks/{etapaId}")]
        public async Task<ActionResult<List<TarefaViewModel>>> LoadTasksForEtapa(int etapaId, int colaboradorId = 1)
        {
            try
            {
                Console.WriteLine($"🔥 LAZY LOADING: Loading tasks for Etapa {etapaId}");

                // Use the existing method that already has the task loading logic
                var etapaViewModel = await _etapaService.ObterEtapaPorIdAsync(etapaId, colaboradorId);
                
                if (etapaViewModel == null)
                {
                    Console.WriteLine($"❌ LAZY LOADING: Etapa {etapaId} not found");
                    return NotFound($"Etapa {etapaId} não encontrada");
                }

                Console.WriteLine($"✅ LAZY LOADING: Returning {etapaViewModel.Tarefas.Count} tasks for Etapa {etapaId}");
                return Ok(etapaViewModel.Tarefas);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"💥 LAZY LOADING ERROR: {ex.Message}");
                // Return empty list instead of error to prevent blank page
                return Ok(new List<TarefaViewModel>());
            }
        }

        /// <summary>
        /// Get task counts for badge display (without loading full task details)
        /// This provides the badge numbers without the overhead of full task loading
        /// </summary>
        /// <param name="etapaId">Stage ID</param>
        /// <returns>Task count summary</returns>
        [HttpGet("TaskCounts/{etapaId}")]
        public async Task<ActionResult<object>> GetTaskCounts(int etapaId)
        {
            try
            {
                Console.WriteLine($"📊 TASK COUNTS: Getting counts for Etapa {etapaId}");

                // Use raw SQL to get just the counts (faster than loading full objects)
                var etapaViewModel = await _etapaService.ObterEtapaPorIdAsync(etapaId, 1);
                
                if (etapaViewModel == null)
                {
                    return Ok(new { total = 0, concluidas = 0, emAndamento = 0, planejadas = 0, paralisadas = 0 });
                }

                var result = new
                {
                    total = etapaViewModel.TotalTarefas,
                    concluidas = etapaViewModel.TarefasConcluidas,
                    emAndamento = etapaViewModel.TarefasEmAndamento,
                    planejadas = etapaViewModel.TarefasPlanejadas,
                    paralisadas = etapaViewModel.TarefasParalisadas,
                    percentual = etapaViewModel.PercentualConclusao
                };

                Console.WriteLine($"✅ TASK COUNTS: Etapa {etapaId} has {result.total} total tasks");
                return Ok(result);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"💥 TASK COUNTS ERROR: {ex.Message}");
                return Ok(new { total = 0, concluidas = 0, emAndamento = 0, planejadas = 0, paralisadas = 0 });
            }
        }
    }
}