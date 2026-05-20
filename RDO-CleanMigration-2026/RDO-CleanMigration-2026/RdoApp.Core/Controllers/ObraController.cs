using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using RdoApp.Core.Data;
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
        private readonly ILogger<ObraController> _logger;

        public ObraController(RdoDbContext context, ILogger<ObraController> logger)
        {
            _context = context;
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
            var loginDataJson = HttpContext.Session.GetString("LoginData");
            if (string.IsNullOrEmpty(loginDataJson))
            {
                _logger.LogWarning("LoginData missing from session, redirecting to login");
                return RedirectToAction("Login", "Account");
            }

            var colaboradorIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            
            if (string.IsNullOrEmpty(colaboradorIdClaim) || !int.TryParse(colaboradorIdClaim, out int colaboradorId))
            {
                _logger.LogWarning("Invalid colaboradorId in claims, redirecting to login");
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
        public async Task<IActionResult> Selecionar(int idObra)
        {
            var colaboradorIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            
            if (string.IsNullOrEmpty(colaboradorIdClaim) || !int.TryParse(colaboradorIdClaim, out int colaboradorId))
            {
                _logger.LogWarning("Invalid colaboradorId in claims, redirecting to login");
                return RedirectToAction("Login", "Account");
            }

            _logger.LogInformation("Colaborador {ColaboradorId} selecting obra {IdObra}", colaboradorId, idObra);

            // Store selected obra in session
            HttpContext.Session.SetInt32("ObraId", idObra);

            // TODO: Implement full LoginObra logic:
            // - Query obra_colaborador
            // - Build full context with permissions
            // - Verify license
            // - Log to historico_login with obra info

            _logger.LogInformation("Obra {IdObra} selected successfully, redirecting to home", idObra);

            return RedirectToAction("Index", "Home");
        }
    }
}
