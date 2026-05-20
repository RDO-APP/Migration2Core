using System.ComponentModel.DataAnnotations;

namespace RdoApp.Core.Models.DTOs
{
    /// <summary>
    /// Represents an action button in the RDO header toolbar
    /// </summary>
    public class ActionButtonDto
    {
        public ActionButtonType Type { get; set; }
        
        [Required]
        public string IconClass { get; set; } = string.Empty;
        
        [Required]
        public string TooltipText { get; set; } = string.Empty;
        
        [Required]
        public string NavigationUrl { get; set; } = string.Empty;
        
        public string OnClickFunction { get; set; } = string.Empty;
        
        public bool RequiresPermission { get; set; }
        
        public string? PermissionRoute { get; set; }
        
        public int DisplayOrder { get; set; }
        
        public bool IsVisible { get; set; } = true;
    }

    /// <summary>
    /// Enumeration of action button types in the RDO header toolbar
    /// </summary>
    public enum ActionButtonType
    {
        Laudos = 1,
        DashboardUnidade = 2,
        RelatoriosDiarios = 3,
        Tarefas = 4,
        DashboardGeral = 5,
        NovaUnidade = 6
    }
}