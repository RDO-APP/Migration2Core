using System.Collections.Generic;

namespace RdoApp.Core.Models.DTOs
{
    /// <summary>
    /// Task Card Response DTO - API response structure
    /// Used for returning task cards data with permissions
    /// </summary>
    public class TaskCardResponseDto
    {
        public List<EtapaWithTasksDto> Etapas { get; set; } = new();
        public int TotalTasks { get; set; }
        public bool CanCreateTasks { get; set; }
        public bool CanEditTasks { get; set; }
        public bool CanDeleteTasks { get; set; }
    }
}