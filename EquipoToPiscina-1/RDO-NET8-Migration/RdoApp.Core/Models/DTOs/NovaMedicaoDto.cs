using System.ComponentModel.DataAnnotations;

namespace RdoApp.Core.Models.DTOs
{
    public class NovaMedicaoDto
    {
        public int TarefaId { get; set; }
        
        [Required]
        public DateTime DataMedicao { get; set; }
        
        public string? HoraInicial { get; set; }
        public string? HoraFinal { get; set; }
        
        [Required]
        public int Status { get; set; }
        
        public int? CodigoParalizacao { get; set; }
        public decimal? QuantidadeConstruida { get; set; }
        
        // Campos simplificados
        public int? NivelCloro { get; set; }
        public int? NivelPH { get; set; }
        public int? NivelAlcalinidade { get; set; }
        
        public string? Limpidez { get; set; }
        public string? Superficie { get; set; }
        public string? Fundo { get; set; }
        public string? Proliferacao { get; set; }
        public string? Detritos { get; set; }
        
        [MaxLength(1400)]
        public string? Comentario { get; set; }
        
        public IFormFile? Foto { get; set; }
    }
}
