using System.ComponentModel.DataAnnotations;

namespace RdoApp.Core.Models.ViewModels
{
    /// <summary>
    /// ViewModel for Nova Medição (New Measurement) form
    /// Matches Gilberto's original Nova Medição functionality
    /// </summary>
    public class NovaMedicaoViewModel
    {
        [Required]
        public int TarefaId { get; set; }

        [Required]
        [Range(1, 5, ErrorMessage = "Status é obrigatório")]
        public int Status { get; set; }

        [Required]
        [DataType(DataType.Date)]
        public DateTime DataMedicao { get; set; }

        [DataType(DataType.Time)]
        public TimeSpan? HoraInicial { get; set; }

        [DataType(DataType.Time)]
        public TimeSpan? HoraFinal { get; set; }

        [Range(0, double.MaxValue, ErrorMessage = "Quantidade deve ser um valor positivo")]
        public float? QtdConstruida { get; set; }

        // Water Quality Parameters - matching Gilberto's original dropdowns
        [Range(0, 5)]
        public int? NivelCloro { get; set; }

        [Range(0, 6)]
        public int? Ph { get; set; }

        [Range(0, 6)]
        public int? Alcalinidade { get; set; }

        // Boolean Water Quality Parameters
        public bool Limpidez { get; set; }

        public bool Superficie { get; set; }

        public bool Fundo { get; set; }

        public bool NivelDetritos { get; set; }

        public bool NivelProliferacao { get; set; }

        [MaxLength(1400)]
        public string? Comentario { get; set; }

        // Display properties
        public string? TarefaDescricao { get; set; }
    }
}