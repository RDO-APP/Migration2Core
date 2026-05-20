using Microsoft.AspNetCore.Mvc;
using RdoApp.Core.Services.Interfaces;

namespace RdoApp.Core.ViewComponents
{
    /// <summary>
    /// ViewComponent for displaying current obra context in the header
    /// </summary>
    public class CurrentObraViewComponent : ViewComponent
    {
        private readonly ILogger<CurrentObraViewComponent> _logger;
        private readonly IObraService _obraService;

        public CurrentObraViewComponent(ILogger<CurrentObraViewComponent> logger, IObraService obraService)
        {
            _logger = logger;
            _obraService = obraService;
        }

        public async Task<IViewComponentResult> InvokeAsync()
        {
            try
            {
                // Check if we're in obra selection mode
                if (ViewBag.IsObraSelection == true)
                {
                    return Content("Selecionando obra...");
                }

                // Try to get current obra name from session first (faster)
                var obraNome = HttpContext.Session.GetString("ObraNome");
                if (!string.IsNullOrEmpty(obraNome))
                {
                    // Return obra name with truncation for long names
                    if (obraNome.Length > 30)
                    {
                        obraNome = obraNome.Substring(0, 27) + "...";
                    }
                    return Content(obraNome);
                }

                // Fallback: Try to get current obra from session by ID
                var obraId = HttpContext.Session.GetInt32("ObraId");
                if (!obraId.HasValue)
                {
                    _logger.LogDebug("No obra selected in session");
                    return Content("Nenhuma obra selecionada");
                }

                // Get obra details as fallback
                var obra = await _obraService.ObterObraPorIdAsync(obraId.Value);
                if (obra == null)
                {
                    _logger.LogWarning("Obra {ObraId} not found", obraId.Value);
                    return Content($"Obra #{obraId.Value}");
                }

                // Store name in session for future use and return
                var obraName = obra.Descricao;
                HttpContext.Session.SetString("ObraNome", obraName);
                
                if (obraName.Length > 30)
                {
                    obraName = obraName.Substring(0, 27) + "...";
                }

                return Content(obraName);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting current obra context");
                return Content("Erro ao carregar obra");
            }
        }
    }
}