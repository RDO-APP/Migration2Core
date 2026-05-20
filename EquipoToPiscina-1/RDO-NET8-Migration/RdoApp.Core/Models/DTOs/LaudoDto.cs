namespace RdoApp.Core.Models.DTOs
{
    public class LaudoDto
    {
        public int Id { get; set; }
        public int StatusId { get; set; }
        public string? StatusDescricao { get; set; }
        public int ObraId { get; set; }
        public string? ObraDescricao { get; set; }
        public DateTime DataLaudo { get; set; }
        public string? ComentarioAssinatura { get; set; }
        public int? ColaboradorId { get; set; }
        public string? ColaboradorNome { get; set; }
        public DateTime? DataGeracao { get; set; }
        public string? TipoComentarioAssinatura { get; set; }
        public string? ComentarioGeracao { get; set; }
        public string? TipoComentarioGeracao { get; set; }

        // Water Quality Fields - Pool Management
        public int? NivelCloro { get; set; }
        public int? Ph { get; set; }
        public int? Alcalinidade { get; set; }
        public bool? Limpidez { get; set; }
        public bool? Superficie { get; set; }
        public bool? Fundo { get; set; }
        public bool? NivelCloro2 { get; set; }
        public bool? NivelBacterias { get; set; }
        public bool? NivelProliferacao { get; set; }

        // Additional Properties
        public string? DiaDaSemana { get; set; }
        public bool? GerarRelatorioFotografico { get; set; }
    }

    public class CreateLaudoDto
    {
        public int ObraId { get; set; }
        public DateTime DataLaudo { get; set; }
        public int? ColaboradorId { get; set; }
        public string? ComentarioGeracao { get; set; }
        public string? TipoComentarioGeracao { get; set; }

        // Water Quality Fields - Pool Management
        public int? NivelCloro { get; set; }
        public int? Ph { get; set; }
        public int? Alcalinidade { get; set; }
        public bool? Limpidez { get; set; }
        public bool? Superficie { get; set; }
        public bool? Fundo { get; set; }
        public bool? NivelCloro2 { get; set; }
        public bool? NivelBacterias { get; set; }
        public bool? NivelProliferacao { get; set; }
    }

    public class UpdateLaudoDto
    {
        public string? ComentarioAssinatura { get; set; }
        public string? TipoComentarioAssinatura { get; set; }
        public string? ComentarioGeracao { get; set; }
        public string? TipoComentarioGeracao { get; set; }

        // Water Quality Fields - Pool Management
        public int? NivelCloro { get; set; }
        public int? Ph { get; set; }
        public int? Alcalinidade { get; set; }
        public bool? Limpidez { get; set; }
        public bool? Superficie { get; set; }
        public bool? Fundo { get; set; }
        public bool? NivelCloro2 { get; set; }
        public bool? NivelBacterias { get; set; }
        public bool? NivelProliferacao { get; set; }
    }
}