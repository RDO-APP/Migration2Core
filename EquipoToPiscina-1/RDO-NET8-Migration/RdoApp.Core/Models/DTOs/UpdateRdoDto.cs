using System.ComponentModel.DataAnnotations;

namespace RdoApp.Core.Models.DTOs
{
    public class UpdateRdoDto
    {
        public int? ColaboradorId { get; set; }
        
        [MaxLength(1000)]
        public string? Observacao { get; set; }
        
        [Range(-50, 60)]
        public decimal? Temperatura { get; set; }
        
        [MaxLength(200)]
        public string? CondicoesTempo { get; set; }
        
        [MaxLength(20)]
        public string? Status { get; set; }
    }
}