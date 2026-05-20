namespace RdoApp.Core.Models.DTOs
{
    /// <summary>
    /// Create Task DTO - For creating new tasks within stages
    /// Used when user clicks "Adicionar nova tarefa" button in stage accordion
    /// </summary>
    public class CreateTaskDto
    {
        public string Descricao { get; set; } = string.Empty;
        public DateTime DataInicio { get; set; }
        public DateTime DataPrevisaoFim { get; set; }
        public int EtapaId { get; set; }
        public int StatusId { get; set; } = 1; // Default to "Planejada"
        public string? Comentario { get; set; }
        public int UnidadeId { get; set; }
        public decimal? QtdPlanejada { get; set; }
    }
}