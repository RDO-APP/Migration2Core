using System.Collections.Generic;

namespace RdoApp.Core.Models.DTOs
{
    /// <summary>
    /// Etapa with Tasks DTO - Critical for Stage Management
    /// Used for accordion structure with dynamic card loading
    /// </summary>
    public class EtapaWithTasksDto
    {
        public int Id { get; set; }
        public string Titulo { get; set; } = string.Empty;
        public string Descricao { get; set; } = string.Empty;
        public List<TaskCardDto> Tarefas { get; set; } = new();
        public bool CanAddTasks { get; set; }
        public int TotalTasks { get; set; }
        public int CompletedTasks { get; set; }
    }
}