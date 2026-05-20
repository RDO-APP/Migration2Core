namespace RdoApp.Core.Models.DTOs
{
    public class RdoDto
    {
        public int Id { get; set; }
        public int ObraId { get; set; }
        public int? ColaboradorId { get; set; }
        public DateTime Data { get; set; }
        public string? Observacao { get; set; }
        public decimal? Temperatura { get; set; }
        public string? CondicoesTempo { get; set; }
        public string? Status { get; set; }
        public DateTime DataCriacao { get; set; }
        public DateTime? DataAtualizacao { get; set; }
        
        // Navigation Properties
        public string? ObraNome { get; set; }
        public string? ColaboradorNome { get; set; }
        public int TotalTarefas { get; set; }
    }
}