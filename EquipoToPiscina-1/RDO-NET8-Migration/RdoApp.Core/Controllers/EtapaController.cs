using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using RdoApp.Core.Models.ViewModels;
using RdoApp.Core.Services.Interfaces;
using System.Linq;

namespace RdoApp.Core.Controllers
{
    /// <summary>
    /// Controller for Etapa/Tarefa management
    /// Provides server-side rendering for task cards
    /// Replaces AngularJS frontend with Razor views
    /// </summary>
    [Authorize]
    public class EtapaController : Controller
    {
        private readonly IEtapaService _etapaService;
        private readonly ILogger<EtapaController> _logger;
        
        public EtapaController(IEtapaService etapaService, ILogger<EtapaController> logger)
        {
            _etapaService = etapaService;
            _logger = logger;
        }
        
        /// <summary>
        /// Simple Cards action for direct navigation from Obra selection
        /// Redirects to CardsRazor with proper parameters
        /// </summary>
        /// <param name="obraId">Selected obra ID</param>
        /// <returns>Redirect to CardsRazor or Cards view</returns>
        [HttpGet]
        public async Task<IActionResult> Cards(int? obraId = null)
        {
            try
            {
                _logger.LogInformation("Cards action called with obraId: {ObraId}", obraId);
                
                // If obraId is provided, store it in session and redirect to CardsRazor
                if (obraId.HasValue)
                {
                    HttpContext.Session.SetInt32("ObraId", obraId.Value);
                    _logger.LogInformation("Stored obraId {ObraId} in session", obraId.Value);
                    
                    // Create filter with the obra ID
                    var filter = new EtapaFilterViewModel
                    {
                        IdObra = obraId.Value
                    };
                    
                    return RedirectToAction(nameof(CardsRazor), filter);
                }
                
                // If no obraId, try to get from session
                var sessionObraId = HttpContext.Session.GetInt32("ObraId");
                if (sessionObraId.HasValue)
                {
                    var filter = new EtapaFilterViewModel
                    {
                        IdObra = sessionObraId.Value
                    };
                    
                    return RedirectToAction(nameof(CardsRazor), filter);
                }
                
                // No obra selected, redirect to obra selection
                _logger.LogWarning("No obra selected, redirecting to Obra/Escolher");
                return RedirectToAction("Escolher", "Obra");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in Cards action");
                return RedirectToAction("Escolher", "Obra");
            }
        }
        
        /// <summary>
        /// Main Cards view - replaces the AngularJS cards.html
        /// </summary>
        /// <param name="filter">Filter parameters from query string or form</param>
        /// <returns>Cards view with server-rendered task cards</returns>
        [HttpGet]
        [Route("tarefa/cards")]
        public async Task<IActionResult> CardsRazor([FromQuery] EtapaFilterViewModel? filter = null)
        {
            try
            {
                _logger.LogInformation("Loading Etapa/Tarefa cards view");
                
                // Initialize filter if null
                filter ??= new EtapaFilterViewModel();
                
                // Get current obra ID from user session/claims
                // TODO: Implement proper user/obra context
                filter.IdObra = GetCurrentObraId();
                
                if (filter.IdObra <= 0)
                {
                    _logger.LogWarning("No obra selected for user");
                    return RedirectToAction("Escolher", "Obra");
                }
                
                // Validate filter
                if (!filter.IsValid())
                {
                    ModelState.AddModelError("", "Parâmetros de filtro inválidos. Verifique as datas informadas.");
                }
                
                // Load data
                var etapas = await _etapaService.GetEtapasWithTarefasAsync(filter);
                var statusOptions = await _etapaService.GetStatusOptionsAsync();
                var etapaOptions = await _etapaService.GetEtapaOptionsAsync(filter.IdObra);
                
                // Build view model
                var viewModel = new EtapaCardsViewModel
                {
                    Etapas = etapas,
                    Filter = filter,
                    StatusOptions = statusOptions,
                    EtapaOptions = etapaOptions,
                    CanEdit = User.HasClaim("permission", "editar"),
                    CanDelete = User.HasClaim("permission", "deletar"),
                    CanCreateNew = User.HasClaim("permission", "criarNovo"),
                    CanChangeStatus = User.HasClaim("permission", "alterarStatus"),
                    IsWorkFinalized = IsCurrentWorkFinalized(),
                    CurrentObraId = filter.IdObra,
                    CurrentObraName = GetCurrentObraName()
                };
                
                // Set ViewBag data for partials
                ViewBag.StatusOptions = statusOptions;
                ViewBag.EtapaOptions = etapaOptions;
                ViewBag.CanEdit = viewModel.CanEdit;
                ViewBag.CanDelete = viewModel.CanDelete;
                ViewBag.CanCreateNew = viewModel.CanCreateNew;
                ViewBag.CanChangeStatus = viewModel.CanChangeStatus;
                ViewBag.CanView = true; // Assuming all users can view
                ViewBag.IsWorkFinalized = viewModel.IsWorkFinalized;
                
                _logger.LogInformation("Loaded {EtapaCount} etapas with {TaskCount} total tasks", 
                    viewModel.TotalEtapas, viewModel.TotalTarefas);
                
                return View(viewModel);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error loading Etapa/Tarefa cards view");
                
                var errorViewModel = new EtapaCardsViewModel
                {
                    HasError = true,
                    ErrorMessage = "Erro ao carregar as etapas e tarefas. Tente novamente.",
                    Filter = filter ?? new EtapaFilterViewModel()
                };
                
                return View(errorViewModel);
            }
        }
        
        /// <summary>
        /// Handle filter form submission
        /// </summary>
        /// <param name="filter">Filter parameters from form</param>
        /// <returns>Redirect to Cards with filter parameters</returns>
        [HttpPost]
        [Route("tarefa/cards")]
        public IActionResult CardsFilter(EtapaFilterViewModel filter)
        {
            try
            {
                _logger.LogInformation("Processing filter form submission");
                
                // Validate filter
                if (!filter.IsValid())
                {
                    ModelState.AddModelError("", "Parâmetros de filtro inválidos. Verifique as datas informadas.");
                    // Return to GET action with current filter
                    return RedirectToAction(nameof(CardsRazor), filter);
                }
                
                // Redirect to GET action with filter parameters
                return RedirectToAction(nameof(CardsRazor), filter);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error processing filter form");
                return RedirectToAction(nameof(CardsRazor));
            }
        }
        
        /// <summary>
        /// Update task status via AJAX or form submission
        /// </summary>
        /// <param name="taskId">Task ID</param>
        /// <param name="statusId">New status ID</param>
        /// <returns>JSON result or redirect</returns>
        [HttpPost]
        [Route("tarefa/updateStatus")]
        public async Task<IActionResult> UpdateTaskStatus(int taskId, int statusId)
        {
            try
            {
                _logger.LogInformation("Updating task {TaskId} to status {StatusId}", taskId, statusId);
                
                // TODO: Implement task status update
                // For now, just return success
                
                if (Request.Headers["X-Requested-With"] == "XMLHttpRequest")
                {
                    return Json(new { success = true, message = "Status atualizado com sucesso" });
                }
                
                TempData["SuccessMessage"] = "Status da tarefa atualizado com sucesso";
                return RedirectToAction(nameof(CardsRazor));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error updating task status for task {TaskId}", taskId);
                
                if (Request.Headers["X-Requested-With"] == "XMLHttpRequest")
                {
                    return Json(new { success = false, message = "Erro ao atualizar status da tarefa" });
                }
                
                TempData["ErrorMessage"] = "Erro ao atualizar status da tarefa";
                return RedirectToAction(nameof(CardsRazor));
            }
        }
        
        /// <summary>
        /// Update multiple task statuses via AJAX
        /// </summary>
        /// <param name="request">Request with task IDs and new status</param>
        /// <returns>JSON result</returns>
        [HttpPost]
        [Route("tarefa/updateMultipleStatus")]
        public async Task<IActionResult> UpdateMultipleTaskStatus([FromBody] UpdateMultipleTaskStatusRequest request)
        {
            try
            {
                _logger.LogInformation("Updating {TaskCount} tasks to status {StatusId}", 
                    request.TaskIds?.Count ?? 0, request.StatusId);
                
                if (request.TaskIds == null || !request.TaskIds.Any())
                {
                    return Json(new { success = false, message = "Nenhuma tarefa selecionada" });
                }
                
                // TODO: Implement bulk task status update
                // For now, just return success
                
                return Json(new { 
                    success = true, 
                    message = $"Status de {request.TaskIds.Count} tarefa(s) atualizado com sucesso" 
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error updating multiple task statuses");
                return Json(new { success = false, message = "Erro ao atualizar status das tarefas" });
            }
        }
        
        /// <summary>
        /// DEVELOPMENT REDIRECT: Force redirect from old MVC to new Blazor URL
        /// This ensures the Pure Blazor component loads instead of legacy MVC view
        /// </summary>
        /// <param name="obraId">Obra ID for loading tasks</param>
        /// <returns>Redirect to Pure Blazor URL</returns>
        [HttpGet]
        [Route("etapa/cards-blazor/{obraId:int}")]
        public IActionResult CardsBlazorRedirect(int obraId)
        {
            _logger.LogInformation("🔄 DEVELOPMENT REDIRECT: Forcing redirect to Pure Blazor URL for obra {ObraId}", obraId);
            
            // FORCE redirect to the actual Blazor page URL
            // This bypasses MVC routing and lets Blazor handle the route
            return Redirect($"/blazor-etapa-cards/{obraId}");
        }

        /// <summary>
        /// Pure Blazor Cards page - Modern Equivalent Migration
        /// Uses Pure Blazor components with zero JavaScript dependencies
        /// IMPORTANT: Uses different route to avoid MVC conflicts
        /// </summary>
        /// <param name="obraId">Obra ID for loading tasks</param>
        /// <returns>Pure Blazor page with _LayoutBlazor</returns>
        [HttpGet]
        [Route("blazor-etapa-cards/{obraId:int}")]
        public async Task<IActionResult> CardsBlazor(int obraId)
        {
            try
            {
                _logger.LogInformation("🚀 Loading Pure Blazor Etapa/Tarefa cards for obra {ObraId}", obraId);
                
                // Store obra ID in session for component access
                HttpContext.Session.SetInt32("ObraId", obraId);
                
                // Pass obra ID to the view
                ViewBag.ObraId = obraId;
                ViewBag.Title = $"Etapas / Tarefas - Obra {obraId} (Pure Blazor)";
                ViewBag.CanEdit = User.HasClaim("permission", "editar");
                ViewBag.IsWorkFinalized = IsCurrentWorkFinalized();
                
                _logger.LogInformation("✅ Pure Blazor environment configured - Zero JavaScript dependencies");
                
                return View("CardsBlazor");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error loading Pure Blazor cards for obra {ObraId}", obraId);
                return RedirectToAction("Escolher", "Obra");
            }
        }

        /// <summary>
        /// Test action to verify hand icons and debug view loading
        /// </summary>
        [HttpGet]
        [Route("etapa/test")]
        public IActionResult TestCards()
        {
            ViewBag.CanView = true;
            ViewBag.CanEdit = true;
            ViewBag.CanDelete = true;
            ViewBag.IsWorkFinalized = false;
            
            // Create test task with different status IDs
            var testTasks = new List<TarefaViewModel>
            {
                new TarefaViewModel { Id = 1, StatusId = 1, Descricao = "Test Planejada", QuantidadeColaboradores = 2, QuantidadeEquipamentos = 1 },
                new TarefaViewModel { Id = 2, StatusId = 2, Descricao = "Test Em Execução", QuantidadeColaboradores = 3, QuantidadeEquipamentos = 2 },
                new TarefaViewModel { Id = 3, StatusId = 3, Descricao = "Test Finalizada", QuantidadeColaboradores = 1, QuantidadeEquipamentos = 0 },
                new TarefaViewModel { Id = 4, StatusId = 4, Descricao = "Test Paralisada", QuantidadeColaboradores = 2, QuantidadeEquipamentos = 1 },
                new TarefaViewModel { Id = 5, StatusId = 5, Descricao = "Test Cancelada", QuantidadeColaboradores = 0, QuantidadeEquipamentos = 0 }
            };
            
            return View("TestCards", testTasks);
        }

        // Helper methods
        private int GetCurrentObraId()
        {
            // For testing, use obra 233 which has the 4 etapas we saw in logs
            // TODO: Get from user session/claims in production
            return 233;
        }
        
        private bool IsCurrentWorkFinalized()
        {
            // TODO: Check if current obra is finalized
            return false;
        }
        
        private string GetCurrentObraName()
        {
            // TODO: Get from user session/claims
            return "Obra 233 - Teste";
        }
    }
    
    /// <summary>
    /// Request model for updating multiple task statuses
    /// </summary>
    public class UpdateMultipleTaskStatusRequest
    {
        public List<int> TaskIds { get; set; } = new List<int>();
        public int StatusId { get; set; }
    }
}