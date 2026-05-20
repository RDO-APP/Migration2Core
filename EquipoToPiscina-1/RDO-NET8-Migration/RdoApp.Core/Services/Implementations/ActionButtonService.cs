using RdoApp.Core.Models.DTOs;
using RdoApp.Core.Services.Interfaces;

namespace RdoApp.Core.Services.Implementations
{
    /// <summary>
    /// Service implementation for managing RDO header action buttons
    /// </summary>
    public class ActionButtonService : IActionButtonService
    {
        private readonly ILogger<ActionButtonService> _logger;
        
        /// <summary>
        /// Default action button configuration based on legacy RDO system
        /// </summary>
        private static readonly List<ActionButtonDto> DefaultButtons = new()
        {
            new ActionButtonDto
            {
                Type = ActionButtonType.Laudos,
                IconClass = "fa fa-folder",
                TooltipText = "Laudos",
                NavigationUrl = "/Laudo",
                DisplayOrder = 1,
                RequiresPermission = false,
                IsVisible = true
            },
            new ActionButtonDto
            {
                Type = ActionButtonType.DashboardUnidade,
                IconClass = "icon-dashboard",
                TooltipText = "Dashboard da Unidade Escolar",
                NavigationUrl = "/Dashboard/Index",
                DisplayOrder = 2,
                RequiresPermission = true,
                PermissionRoute = "/dashboard/index",
                IsVisible = true
            },
            new ActionButtonDto
            {
                Type = ActionButtonType.RelatoriosDiarios,
                IconClass = "icon-rdo-novo_2",
                TooltipText = "Relatórios Diários",
                NavigationUrl = "/Relatorio",
                DisplayOrder = 3,
                RequiresPermission = false,
                IsVisible = true
            },
            new ActionButtonDto
            {
                Type = ActionButtonType.Tarefas,
                IconClass = "fa fa-th",
                TooltipText = "Tarefas",
                NavigationUrl = "/Tarefa/Cards",
                DisplayOrder = 4,
                RequiresPermission = false,
                IsVisible = true
            },
            new ActionButtonDto
            {
                Type = ActionButtonType.DashboardGeral,
                IconClass = "fa fa-bar-chart",
                TooltipText = "Dashboard Geral",
                NavigationUrl = "/Chart",
                DisplayOrder = 5,
                RequiresPermission = true,
                PermissionRoute = "/chart",
                IsVisible = true
            },
            new ActionButtonDto
            {
                Type = ActionButtonType.NovaUnidade,
                IconClass = "fa fa-plus",
                TooltipText = "Nova Unidade Escolar",
                NavigationUrl = "/Obra/Cadastro",
                DisplayOrder = 6,
                RequiresPermission = true,
                PermissionRoute = "/obra/cadastro",
                IsVisible = true
            }
        };

        public ActionButtonService(ILogger<ActionButtonService> logger)
        {
            _logger = logger;
        }

        public async Task<List<ActionButtonDto>> GetActionButtonsAsync()
        {
            try
            {
                _logger.LogDebug("Getting all action buttons");
                
                // Return a copy of the default buttons to prevent modification
                var buttons = DefaultButtons.Select(b => new ActionButtonDto
                {
                    Type = b.Type,
                    IconClass = b.IconClass,
                    TooltipText = b.TooltipText,
                    NavigationUrl = b.NavigationUrl,
                    RequiresPermission = b.RequiresPermission,
                    PermissionRoute = b.PermissionRoute,
                    DisplayOrder = b.DisplayOrder,
                    IsVisible = b.IsVisible
                }).OrderBy(b => b.DisplayOrder).ToList();

                _logger.LogDebug("Retrieved {Count} action buttons", buttons.Count);
                return buttons;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting action buttons");
                return new List<ActionButtonDto>();
            }
        }

        public async Task<ActionButtonDto?> GetActionButtonByTypeAsync(ActionButtonType type)
        {
            try
            {
                _logger.LogDebug("Getting action button by type: {Type}", type);
                
                var button = DefaultButtons.FirstOrDefault(b => b.Type == type);
                if (button == null)
                {
                    _logger.LogWarning("Action button not found for type: {Type}", type);
                    return null;
                }

                // Return a copy to prevent modification
                var result = new ActionButtonDto
                {
                    Type = button.Type,
                    IconClass = button.IconClass,
                    TooltipText = button.TooltipText,
                    NavigationUrl = button.NavigationUrl,
                    RequiresPermission = button.RequiresPermission,
                    PermissionRoute = button.PermissionRoute,
                    DisplayOrder = button.DisplayOrder,
                    IsVisible = button.IsVisible
                };

                // Handle icon loading failures with fallback icons
                if (string.IsNullOrEmpty(result.IconClass))
                {
                    result.IconClass = GetFallbackIcon(type);
                    _logger.LogWarning("Using fallback icon for button type: {Type}", type);
                }

                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting action button by type: {Type}", type);
                return null;
            }
        }

        public async Task<bool> IsActionButtonVisibleAsync(ActionButtonType type, string? userRole)
        {
            try
            {
                _logger.LogDebug("Checking visibility for button type: {Type}, user role: {UserRole}", type, userRole);
                
                var button = await GetActionButtonByTypeAsync(type);
                if (button == null || !button.IsVisible)
                {
                    return false;
                }

                // If no permission required, button is visible
                if (!button.RequiresPermission)
                {
                    return true;
                }

                // For now, we'll implement basic role-based visibility
                // This can be enhanced with more sophisticated permission checking
                if (string.IsNullOrEmpty(userRole))
                {
                    _logger.LogDebug("User role is null/empty, hiding permission-required button: {Type}", type);
                    return false;
                }

                // Basic permission logic - can be enhanced based on actual role system
                var hasPermission = userRole.ToLower() switch
                {
                    "admin" => true,
                    "manager" => true,
                    "supervisor" => button.Type != ActionButtonType.NovaUnidade, // Supervisors can't create new units
                    "user" => button.Type == ActionButtonType.Laudos || button.Type == ActionButtonType.Tarefas,
                    _ => false
                };

                _logger.LogDebug("Permission check result for {Type}: {HasPermission}", type, hasPermission);
                return hasPermission;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error checking button visibility for type: {Type}", type);
                return false;
            }
        }

        public async Task<string> GetNavigationUrlAsync(ActionButtonType type)
        {
            try
            {
                var button = await GetActionButtonByTypeAsync(type);
                return button?.NavigationUrl ?? "/";
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting navigation URL for type: {Type}", type);
                return "/";
            }
        }

        public async Task<List<ActionButtonDto>> GetVisibleActionButtonsAsync(string? userRole)
        {
            try
            {
                _logger.LogDebug("Getting visible action buttons for user role: {UserRole}", userRole);
                
                var allButtons = await GetActionButtonsAsync();
                var visibleButtons = new List<ActionButtonDto>();

                foreach (var button in allButtons)
                {
                    if (await IsActionButtonVisibleAsync(button.Type, userRole))
                    {
                        visibleButtons.Add(button);
                    }
                }

                _logger.LogDebug("Found {Count} visible buttons for role: {UserRole}", visibleButtons.Count, userRole);
                return visibleButtons.OrderBy(b => b.DisplayOrder).ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting visible action buttons for role: {UserRole}", userRole);
                return new List<ActionButtonDto>();
            }
        }

        /// <summary>
        /// Gets the 2 selection buttons for obra selection mode (World A)
        /// Based on legacy nav.html forensic analysis - EXACT SPECIFICATIONS
        /// </summary>
        public async Task<List<ActionButtonDto>> GetSelectionButtonsAsync()
        {
            try
            {
                _logger.LogDebug("Getting selection buttons for obra selection mode");
                
                var selectionButtons = new List<ActionButtonDto>
                {
                    new ActionButtonDto
                    {
                        Type = ActionButtonType.DashboardGeral,
                        IconClass = "fa fa-bar-chart",
                        TooltipText = "DASHBOARD GERAL",
                        NavigationUrl = "/Chart",
                        DisplayOrder = 1,
                        RequiresPermission = true,
                        PermissionRoute = "/chart",
                        IsVisible = true
                    },
                    new ActionButtonDto
                    {
                        Type = ActionButtonType.NovaUnidade,
                        IconClass = "fa fa-plus",
                        TooltipText = "NOVA UNIDADE ESCOLAR",
                        NavigationUrl = "/Obra/Cadastro",
                        DisplayOrder = 2,
                        RequiresPermission = true,
                        PermissionRoute = "/obra/cadastro",
                        IsVisible = true
                    }
                };

                _logger.LogDebug("Retrieved {Count} selection buttons", selectionButtons.Count);
                return selectionButtons;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting selection buttons");
                return new List<ActionButtonDto>();
            }
        }

        /// <summary>
        /// Gets fallback icon for action button types when primary icon fails to load
        /// </summary>
        /// <param name="type">The action button type</param>
        /// <returns>Fallback icon class</returns>
        private string GetFallbackIcon(ActionButtonType type)
        {
            return type switch
            {
                ActionButtonType.Laudos => "fa fa-file", // Fallback for fa fa-folder
                ActionButtonType.DashboardUnidade => "fa fa-tachometer", // Fallback for icon-dashboard
                ActionButtonType.RelatoriosDiarios => "fa fa-file-text", // Fallback for icon-rdo-novo_2
                ActionButtonType.Tarefas => "fa fa-list", // Fallback for fa fa-th
                ActionButtonType.DashboardGeral => "fa fa-chart", // Fallback for fa fa-bar-chart
                ActionButtonType.NovaUnidade => "fa fa-plus", // Same as primary
                _ => "fa fa-question-circle" // Generic fallback
            };
        }
    }
}