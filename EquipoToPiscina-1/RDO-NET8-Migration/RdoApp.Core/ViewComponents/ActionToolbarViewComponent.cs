using Microsoft.AspNetCore.Mvc;
using RdoApp.Core.Services.Interfaces;

namespace RdoApp.Core.ViewComponents
{
    /// <summary>
    /// ViewComponent for rendering the RDO action toolbar with intelligent button management
    /// Supports both selection mode (2 buttons) and workspace mode (6 buttons)
    /// </summary>
    public class ActionToolbarViewComponent : ViewComponent
    {
        private readonly IActionButtonService _actionButtonService;
        private readonly ILogger<ActionToolbarViewComponent> _logger;

        public ActionToolbarViewComponent(
            IActionButtonService actionButtonService,
            ILogger<ActionToolbarViewComponent> logger)
        {
            _actionButtonService = actionButtonService;
            _logger = logger;
        }

        /// <summary>
        /// Renders action toolbar with context-aware button selection
        /// </summary>
        /// <param name="context">Toolbar context: "selection" for 2 buttons, "workspace" for 6 buttons</param>
        public async Task<IViewComponentResult> InvokeAsync(string context = "workspace")
        {
            try
            {
                _logger.LogDebug("Rendering action toolbar for context: {Context}", context);

                // Get current user role from HTTP context
                var userRole = GetCurrentUserRole();
                
                List<RdoApp.Core.Models.DTOs.ActionButtonDto> actionButtons;
                
                if (context.Equals("selection", StringComparison.OrdinalIgnoreCase))
                {
                    // WORLD A: Selection mode - only 2 buttons
                    actionButtons = await _actionButtonService.GetSelectionButtonsAsync();
                    _logger.LogDebug("Rendering {Count} selection buttons", actionButtons.Count);
                }
                else
                {
                    // WORLD B: Workspace mode - full 6 buttons
                    actionButtons = await _actionButtonService.GetVisibleActionButtonsAsync(userRole);
                    _logger.LogDebug("Rendering {Count} workspace buttons for user role: {UserRole}", 
                        actionButtons.Count, userRole);
                }

                // Pass context to view for conditional rendering
                ViewBag.ToolbarContext = context;
                return View(actionButtons);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error rendering action toolbar for context: {Context}", context);
                
                // Return empty view on error to prevent layout breaking
                return View(new List<RdoApp.Core.Models.DTOs.ActionButtonDto>());
            }
        }

        /// <summary>
        /// Gets the current user role from HTTP context
        /// </summary>
        /// <returns>User role or null if not authenticated</returns>
        private string? GetCurrentUserRole()
        {
            try
            {
                if (HttpContext?.User?.Identity?.IsAuthenticated == true)
                {
                    // Try to get role from claims
                    var roleClaim = HttpContext.User.FindFirst("role") ?? 
                                   HttpContext.User.FindFirst("http://schemas.microsoft.com/ws/2008/06/identity/claims/role");
                    
                    if (roleClaim != null)
                    {
                        return roleClaim.Value;
                    }

                    // Fallback: assume authenticated users have basic user role
                    return "user";
                }

                return null;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting current user role");
                return null;
            }
        }
    }
}