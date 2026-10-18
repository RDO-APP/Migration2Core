using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using RdoApp.Core.Data;
using RdoApp.Core.Infrastructure;
using RdoApp.Core.Models.ViewModels;
using RdoApp.Core.Services;
using System.Security.Claims;
namespace RdoApp.Core.Controllers
{
    /// <summary>
    /// Obra Controller - Clean Migration 2026
    /// Handles obra selection (Step 2 of authentication)
    /// </summary>
    [Authorize]
    public class ObraController : Controller
    {
        private readonly RdoDbContext _context;
        private readonly LoginObraService _loginObraService;
        private readonly ILogger<ObraController> _logger;

        public ObraController(RdoDbContext context, LoginObraService loginObraService, ILogger<ObraController> logger)
        {
            _context = context;
            _loginObraService = loginObraService;
            _logger = logger;
        }

        /// <summary>
        /// GET: /Obra/Escolher
        /// EXACT COPY: Displays obra selection page (Step 2 of authentication)
        /// </summary>
        [HttpGet]
        public async Task<IActionResult> Escolher()
        {
            // Validate session has LoginData (routes and permissions)
            var loginDataJson = HttpContext.Session.GetString(SessionKeys.LoginData);
            if (string.IsNullOrEmpty(loginDataJson))
            {
                _logger.LogWarning("LoginData missing from session, signing out and redirecting to login");
                await HttpContext.SignOutAsync("Cookies");
                HttpContext.Session.Clear();
                return RedirectToAction("Login", "Account");
            }

            var colaboradorIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            
            if (string.IsNullOrEmpty(colaboradorIdClaim) || !int.TryParse(colaboradorIdClaim, out int colaboradorId))
            {
                _logger.LogWarning("Invalid colaboradorId in claims, signing out and redirecting to login");
                await HttpContext.SignOutAsync("Cookies");
                HttpContext.Session.Clear();
                return RedirectToAction("Login", "Account");
            }

            _logger.LogInformation("Loading obras for colaborador {ColaboradorId}", colaboradorId);

            // EXACT COPY: Get all obras for this colaborador
            var obras = await (from oc in _context.ObraColaboradores
                              join o in _context.Obras on oc.OcoIdObra equals o.ObrIdObra
                              where oc.OcoIdColaborador == colaboradorId
                              select new
                              {
                                  IdObra = oc.OcoIdObra,
                                  NomeObra = o.ObrDsObra,
                                  IdObraColaborador = oc.OcoIdObraColaborador
                              }).ToListAsync();

            _logger.LogInformation("Found {Count} obras for colaborador {ColaboradorId}", obras.Count, colaboradorId);

            ViewData["Title"] = "Escolher Obra - RDO App Piscinas";
            ViewData["ColaboradorId"] = colaboradorId;
            ViewData["NomeColaborador"] = User.Identity?.Name ?? "Usuário";
            
            return View(obras);
        }

        /// <summary>
        /// POST: /Obra/Selecionar
        /// EXACT COPY: Selects an obra (completes Step 2 of authentication)
        /// TODO: Implement full LoginObra logic from legacy
        /// </summary>
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Selecionar(int idObra, CancellationToken cancellationToken)
        {
            try
            {
                var colaboradorIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

                if (string.IsNullOrEmpty(colaboradorIdClaim) || !int.TryParse(colaboradorIdClaim, out int colaboradorId))
                {
                    _logger.LogWarning("Invalid colaboradorId in claims, redirecting to login");
                    return RedirectToAction("Login", "Account");
                }

                if (idObra <= 0)
                {
                    TempData["ObraError"] = "Obra inválida.";
                    return RedirectToAction(nameof(Escolher));
                }

                var loginDataJson = HttpContext.Session.GetString(SessionKeys.LoginData);
                var existingLogin = LoginSessionJson.TryDeserialize(loginDataJson);

                _logger.LogInformation("Colaborador {ColaboradorId} selecting obra {IdObra}", colaboradorId, idObra);

                var result = await _loginObraService.SelectObraAsync(colaboradorId, idObra, existingLogin, cancellationToken);
                if (!result.Success || result.LoginData == null)
                {
                    TempData["ObraError"] = result.ErrorMessage ?? "Não foi possível selecionar a obra.";
                    return RedirectToAction(nameof(Escolher));
                }

                HttpContext.Session.SetString(SessionKeys.LoginData, LoginSessionJson.Serialize(result.LoginData));
                HttpContext.Session.SetInt32(SessionKeys.ObraId, result.ObraId);
                HttpContext.Session.SetString(SessionKeys.ObraNome, result.ObraNome ?? string.Empty);
                HttpContext.Session.SetInt32(SessionKeys.ObraColaboradorId, result.ObraColaboradorId);

                _logger.LogInformation("Obra {IdObra} selected, redirecting to task cards", idObra);

                return RedirectToAction("Cards", "Tarefa");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Unhandled error in Obra/Selecionar for obra {IdObra}", idObra);
                TempData["ObraError"] = "Erro ao selecionar a obra. Tente novamente ou contate o suporte.";
                return RedirectToAction(nameof(Escolher));
            }
        }
    }
}
