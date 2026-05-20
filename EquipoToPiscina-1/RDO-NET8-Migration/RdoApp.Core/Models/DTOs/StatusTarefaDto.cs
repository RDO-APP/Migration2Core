namespace RdoApp.Core.Models.DTOs
{
    /// <summary>
    /// Status Tarefa DTO - For status transition management
    /// Used for displaying allowed status changes in task cards
    /// </summary>
    public class StatusTarefaDto
    {
        public int Id { get; set; }
        public string Nome { get; set; } = string.Empty;
        public string CssClass { get; set; } = string.Empty;
        public string IconClass { get; set; } = string.Empty;
    }
}