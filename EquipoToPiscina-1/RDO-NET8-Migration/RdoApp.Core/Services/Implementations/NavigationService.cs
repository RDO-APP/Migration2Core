using Microsoft.AspNetCore.Mvc;
using RdoApp.Core.Models.DTOs;
using RdoApp.Core.Services.Interfaces;

namespace RdoApp.Core.Services.Implementations
{
    /// <summary>
    /// Service implementation for handling navigation in the RDO application
    /// </summary>
    public class NavigationService : INavigationService
    {
        private readonly ILogger<NavigationService> _logger;
        private readonly IActionButtonService _actionButtonService;
        private readonly IHttpContextAccessor _httpContextAccessor;
        private readonly Dictionary<ActionButtonType, Func<Task>> _customHandlers;

        public NavigationService(
            ILogger<NavigationService> logger,
            IActionButtonService actionButtonService,
            IHttpContextAccessor httpContextAccessor)
        {
            _logger = logger;
            _actionButtonService = actionButtonService;
            _httpContextAccessor = httpContextAccessor;
            _customHandlers = new Dictionary<ActionButtonType, Func<Task>>();
        }

        public async Task<NavigationResult> NavigateToAsync(ActionButtonType buttonType)
        {
            try
            {
                _logger.LogDebug("Attempting navigation to button type: {ButtonType}", buttonType);

                // Get current user role from HTTP context
                var userRole = GetCurrentUserRole();
                
                // Check if navigation is allowed
                var canNavigate = await CanNavigateToAsync(buttonType, userRole);
                if (!canNavigate)
                {
                    var displayName = GetButtonDisplayName(buttonType);
                    _logger.LogWarning("Navigation denied for button type: {ButtonType}, user role: {UserRole}", buttonType, userRole);
                    return NavigationResult.Unauthorized(displayName);
                }

                // Check for custom handler
                if (_customHandlers.ContainsKey(buttonType))
                {
                    _logger.LogDebug("Executing custom handler for button type: {ButtonType}", buttonType);
                    await _customHandlers[buttonType]();
                    return NavigationResult.Successful("Custom handler executed");
                }

                // Get navigation URL
                var url = await GetNavigationUrlAsync(buttonType);
                if (string.IsNullOrEmpty(url))
                {
                    _logger.LogError("No navigation URL found for button type: {ButtonType}", buttonType);
                    return NavigationResult.Failed($"URL de navegação não encontrada para {GetButtonDisplayName(buttonType)}");
                }

                // Validate route exists
                var routeValid = await ValidateRouteAsync(url);
                if (!routeValid)
                {
                    _logger.LogWarning("Invalid route for button type: {ButtonType}, URL: {Url}", buttonType, url);
                    return NavigationResult.Failed($"Rota inválida: {url}");
                }

                _logger.LogDebug("Navigation successful for button type: {ButtonType} to URL: {Url}", buttonType, url);
                return NavigationResult.Successful(url);
            }
            catch (NavigationException ex)
            {
                _logger.LogError(ex, "Navigation failed for button type: {ButtonType}", buttonType);
                return NavigationResult.Failed($"Erro de navegação: {ex.Message}");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Unexpected error during navigation for button type: {ButtonType}", buttonType);
                return NavigationResult.Failed("Erro inesperado durante a navegação");
            }
        }

        public async Task<bool> CanNavigateToAsync(ActionButtonType buttonType, string? userRole)
        {
            try
            {
                _logger.LogDebug("Checking navigation permission for button type: {ButtonType}, user role: {UserRole}", buttonType, userRole);
                
                // Use ActionButtonService to check visibility (which includes permission checks)
                var canNavigate = await _actionButtonService.IsActionButtonVisibleAsync(buttonType, userRole);
                
                _logger.LogDebug("Navigation permission result for {ButtonType}: {CanNavigate}", buttonType, canNavigate);
                return canNavigate;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error checking navigation permission for button type: {ButtonType}", buttonType);
                return false;
            }
        }

        public async Task<string> GetNavigationUrlAsync(ActionButtonType buttonType)
        {
            try
            {
                return await _actionButtonService.GetNavigationUrlAsync(buttonType);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting navigation URL for button type: {ButtonType}", buttonType);
                return "/";
            }
        }

        public void RegisterNavigationHandler(ActionButtonType buttonType, Func<Task> handler)
        {
            try
            {
                _logger.LogDebug("Registering custom navigation handler for button type: {ButtonType}", buttonType);
                _customHandlers[buttonType] = handler;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error registering navigation handler for button type: {ButtonType}", buttonType);
            }
        }

        public async Task<bool> ValidateRouteAsync(string route)
        {
            try
            {
                if (string.IsNullOrEmpty(route))
                {
                    return false;
                }

                // Basic route validation - check if it starts with /
                if (!route.StartsWith("/"))
                {
                    _logger.LogWarning("Invalid route format: {Route}", route);
                    return false;
                }

                // For now, we'll do basic validation
                // In a more sophisticated implementation, we could check against actual route table
                var validRoutes = new[]
                {
                    "/Laudo", "/Dashboard/Index", "/Relatorio", "/Tarefa/Cards", 
                    "/Chart", "/Obra/Cadastro", "/", "/Home", "/Account/Login"
                };

                var isValid = validRoutes.Any(validRoute => 
                    route.Equals(validRoute, StringComparison.OrdinalIgnoreCase) ||
                    route.StartsWith(validRoute + "/", StringComparison.OrdinalIgnoreCase));

                if (!isValid)
                {
                    _logger.LogDebug("Route validation failed for: {Route}", route);
                }

                return isValid;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error validating route: {Route}", route);
                return false;
            }
        }

        public string GetButtonDisplayName(ActionButtonType buttonType)
        {
            return buttonType switch
            {
                ActionButtonType.Laudos => "Laudos",
                ActionButtonType.DashboardUnidade => "Dashboard da Unidade Escolar",
                ActionButtonType.RelatoriosDiarios => "Relatórios Diários",
                ActionButtonType.Tarefas => "Tarefas",
                ActionButtonType.DashboardGeral => "Dashboard Geral",
                ActionButtonType.NovaUnidade => "Nova Unidade Escolar",
                _ => "Funcionalidade"
            };
        }

        /// <summary>
        /// Gets the current user role from HTTP context
        /// </summary>
        /// <returns>User role or null if not authenticated</returns>
        private string? GetCurrentUserRole()
        {
            try
            {
                var httpContext = _httpContextAccessor.HttpContext;
                if (httpContext?.User?.Identity?.IsAuthenticated == true)
                {
                    // Try to get role from claims
                    var roleClaim = httpContext.User.FindFirst("role") ?? 
                                   httpContext.User.FindFirst("http://schemas.microsoft.com/ws/2008/06/identity/claims/role");
                    
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

    /// <summary>
    /// Custom exception for navigation-related errors
    /// </summary>
    public class NavigationException : Exception
    {
        public NavigationException(string message) : base(message) { }
        public NavigationException(string message, Exception innerException) : base(message, innerException) { }
    }
}