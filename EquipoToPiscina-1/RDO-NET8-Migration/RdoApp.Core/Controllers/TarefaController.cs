using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using RdoApp.Core.Services.Interfaces;
using RdoApp.Core.Models.ViewModels;
using RdoApp.Core.Models.DTOs;

namespace RdoApp.Core.Controllers
{
    /// <summary>
    /// Tarefa Controller - Handles task card views
    /// Replaces legacy AngularJS task management
    /// </summary>
    [Authorize]
    public class TarefaController : Controller
    {
        private readonly ILogger<TarefaController> _logger;
        private readonly IEtapaService _etapaService;
        private readonly IObraService _obraService;
        private readonly ITarefaService _tarefaService;

        public TarefaController(ILogger<TarefaController> logger, IEtapaService etapaService, IObraService obraService, ITarefaService tarefaService)
        {
            _logger = logger;
            _etapaService = etapaService;
            _obraService = obraService;
            _tarefaService = tarefaService;
        }

        /// <summary>
        /// GET: /Tarefa/Cards
        /// Displays task cards for the selected obra
        /// This is the destination after obra selection
        /// </summary>
        /// <param name="obraId">ID of the selected obra</param>
        /// <returns>Task cards view</returns>
        public async Task<IActionResult> Cards(int? obraId)
        {
            try
            {
                _logger.LogInformation("=== TAREFA CARDS - INÍCIO ===");
                
                // Get user ID from claims
                var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                _logger.LogInformation("UserIdClaim: {UserIdClaim}", userIdClaim ?? "NULL");
                
                if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out int colaboradorId))
                {
                    _logger.LogWarning("Invalid or missing user ID claim for Tarefa Cards access");
                    return RedirectToAction("Login", "Account");
                }
                
                _logger.LogInformation("ColaboradorId: {ColaboradorId}", colaboradorId);

                // Get obra ID from parameter or session
                if (!obraId.HasValue)
                {
                    obraId = HttpContext.Session.GetInt32("ObraId");
                    _logger.LogInformation("ObraId from session: {ObraId}", obraId);
                }
                
                if (!obraId.HasValue)
                {
                    _logger.LogWarning("No obra ID provided, redirecting to obra selection");
                    return RedirectToAction("Escolher", "Obra");
                }
                
                _logger.LogInformation("Loading task cards for obra {ObraId}", obraId.Value);

                // Store obra ID in session for future requests
                HttpContext.Session.SetInt32("ObraId", obraId.Value);

                // Load etapas with tasks using the existing service
                var etapas = await _etapaService.ObterEtapasViewModelAsync(obraId.Value);
                
                _logger.LogInformation("Loaded {Count} etapas with tasks", etapas.Count);
                
                // Set ViewBag data
                ViewBag.ObraId = obraId.Value;
                ViewBag.ObraNome = $"Obra {obraId.Value}";
                ViewBag.UsuarioNome = User.Identity?.Name ?? "Usuário";

                _logger.LogInformation("=== TAREFA CARDS - FIM ===");

                // Return the task cards view (use existing Etapa/Cards view)
                return View("~/Views/Etapa/Cards.cshtml", etapas);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error loading task cards for obra {ObraId}", obraId);
                ViewBag.ErrorMessage = "Erro ao carregar tarefas. Tente novamente.";
                return View("Cards", new List<EtapaViewModel>());
            }
        }

        /// <summary>
        /// POST: /Tarefa/SalvarMedicao
        /// Saves a new measurement (Nova Medição) for a task
        /// Replicates Gilberto's original Nova Medição functionality
        /// </summary>
        [HttpPost]
        public async Task<IActionResult> SalvarMedicao(NovaMedicaoViewModel model)
        {
            try
            {
                _logger.LogInformation("=== NOVA MEDIÇÃO - INÍCIO ===");
                _logger.LogInformation("TarefaId: {TarefaId}", model.TarefaId);

                // Get user ID from claims
                var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out int userId))
                {
                    _logger.LogWarning("Invalid user ID for Nova Medição");
                    return Json(new { success = false, message = "Usuário inválido" });
                }

                // Validate required fields
                if (model.TarefaId <= 0)
                {
                    return Json(new { success = false, message = "Tarefa inválida" });
                }

                if (model.Status <= 0)
                {
                    return Json(new { success = false, message = "Status é obrigatório" });
                }

                if (model.DataMedicao == default(DateTime))
                {
                    return Json(new { success = false, message = "Data é obrigatória" });
                }

                // Create water quality parameters DTO
                var waterQualityParams = new WaterQualityParametersDto
                {
                    NivelCloro = model.NivelCloro ?? 0,
                    NivelPH = model.Ph ?? 0,
                    NivelAlcalinidade = model.Alcalinidade ?? 0,
                    Limpidez = model.Limpidez,
                    Superficie = model.Superficie,
                    Fundo = model.Fundo,
                    Bacteria = model.NivelDetritos, // Map NivelDetritos to Bacteria field
                    Proliferacao = model.NivelProliferacao
                };

                // Save water quality measurement
                var waterQualitySaved = await _tarefaService.SaveWaterQualityMeasurementAsync(
                    model.TarefaId, 
                    waterQualityParams, 
                    userId
                );

                if (!waterQualitySaved)
                {
                    return Json(new { success = false, message = "Erro ao salvar parâmetros de qualidade da água" });
                }

                // Update task with measurement data
                var tarefa = await _tarefaService.GetByIdAsync(model.TarefaId);
                if (tarefa == null)
                {
                    return Json(new { success = false, message = "Tarefa não encontrada" });
                }

                var updateDto = new UpdateTarefaDto
                {
                    Descricao = tarefa.Descricao,
                    DataInicio = tarefa.DataInicio,
                    DataPrevisaoFim = tarefa.DataPrevisaoFim,
                    DataFim = model.Status == 3 ? model.DataMedicao : tarefa.DataFim, // Set DataFim if status is Finalizada
                    StatusId = model.Status,
                    EtapaId = tarefa.EtapaId,
                    UnidadeId = tarefa.UnidadeId,
                    QuantidadeConstruida = model.QtdConstruida ?? tarefa.QuantidadeConstruida,
                    QuantidadePrevisao = tarefa.QuantidadePrevisao,
                    Comentario = !string.IsNullOrEmpty(model.Comentario) ? model.Comentario : tarefa.Comentario,
                    Foto = tarefa.Foto,
                    HorasTrabalhadas = tarefa.HorasTrabalhadas,
                    HoraMedicaoInicial = model.HoraInicial,
                    HoraMedicaoFinal = model.HoraFinal,
                    ValorUnitario = tarefa.ValorUnitario,
                    HorimetroInicial = tarefa.HorimetroInicial,
                    HorimetroFinal = tarefa.HorimetroFinal,
                    CodigoParalizacao = tarefa.CodigoParalizacao
                };

                var updatedTarefa = await _tarefaService.UpdateAsync(model.TarefaId, updateDto);

                _logger.LogInformation("Nova medição salva com sucesso para tarefa {TarefaId}", model.TarefaId);

                return Json(new { success = true, message = "Medição salva com sucesso" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Erro ao salvar nova medição para tarefa {TarefaId}", model.TarefaId);
                return Json(new { success = false, message = "Erro interno do servidor" });
            }
        }

        /// <summary>
        /// GET: /Tarefa/GetWaterQualityOptions
        /// Returns water quality dropdown options matching Gilberto's original data
        /// </summary>
        [HttpGet]
        public async Task<IActionResult> GetWaterQualityOptions()
        {
            try
            {
                var options = new
                {
                    cloro = await _tarefaService.GetCloroOptionsAsync(),
                    ph = await _tarefaService.GetPHOptionsAsync(),
                    alcalinidade = await _tarefaService.GetAlcalinidadeOptionsAsync()
                };

                return Json(options);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Erro ao carregar opções de qualidade da água");
                return Json(new { success = false, message = "Erro ao carregar opções" });
            }
        }
    }
}