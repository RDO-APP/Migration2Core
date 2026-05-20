namespace RdoApp.Core.Models.DTOs
{
    public class TarefaDto
    {
        public int Id { get; set; }
        public Guid Agrupador { get; set; }
        public string Descricao { get; set; } = string.Empty;
        public DateTime DataInicio { get; set; }
        public DateTime? DataPrevisaoFim { get; set; }
        public DateTime? DataFim { get; set; }
        public int StatusId { get; set; }
        public string StatusDescricao { get; set; } = string.Empty;
        public int EtapaId { get; set; }
        public string EtapaDescricao { get; set; } = string.Empty;
        public int ObraId { get; set; }
        public string ObraDescricao { get; set; } = string.Empty;
        public int? UnidadeId { get; set; }
        public float? QuantidadeConstruida { get; set; }
        public decimal? QuantidadePrevisao { get; set; }
        public string? Comentario { get; set; }
        public string? Foto { get; set; }
        public int? HorasTrabalhadas { get; set; }
        public TimeSpan? HoraMedicaoInicial { get; set; }
        public TimeSpan? HoraMedicaoFinal { get; set; }
        public DateTime DataMedicao { get; set; }
        public decimal? ValorUnitario { get; set; }
        public float? HorimetroInicial { get; set; }
        public float? HorimetroFinal { get; set; }
        public float? HorimetroTotal { get; set; }
        public string? CodigoParalizacao { get; set; }
        public int ColaboradorInsercaoId { get; set; }
        public string ColaboradorInsercaoNome { get; set; } = string.Empty;
        public DateTime DataInsercao { get; set; }
        public DateTime? DataUltimaAtualizacao { get; set; }
    }

    public class CreateTarefaDto
    {
        public string Descricao { get; set; } = string.Empty;
        public DateTime DataInicio { get; set; }
        public DateTime? DataPrevisaoFim { get; set; }
        public int StatusId { get; set; }
        public int EtapaId { get; set; }
        public int? UnidadeId { get; set; }
        public float? QuantidadeConstruida { get; set; }
        public decimal? QuantidadePrevisao { get; set; }
        public string? Comentario { get; set; }
        public string? Foto { get; set; }
        public int? HorasTrabalhadas { get; set; }
        public TimeSpan? HoraMedicaoInicial { get; set; }
        public TimeSpan? HoraMedicaoFinal { get; set; }
        public decimal? ValorUnitario { get; set; }
        public float? HorimetroInicial { get; set; }
        public float? HorimetroFinal { get; set; }
        public string? CodigoParalizacao { get; set; }
        public int ColaboradorInsercaoId { get; set; }
    }

    public class UpdateTarefaDto
    {
        public string Descricao { get; set; } = string.Empty;
        public DateTime DataInicio { get; set; }
        public DateTime? DataPrevisaoFim { get; set; }
        public DateTime? DataFim { get; set; }
        public int StatusId { get; set; }
        public int EtapaId { get; set; }
        public int? UnidadeId { get; set; }
        public float? QuantidadeConstruida { get; set; }
        public decimal? QuantidadePrevisao { get; set; }
        public string? Comentario { get; set; }
        public string? Foto { get; set; }
        public int? HorasTrabalhadas { get; set; }
        public TimeSpan? HoraMedicaoInicial { get; set; }
        public TimeSpan? HoraMedicaoFinal { get; set; }
        public decimal? ValorUnitario { get; set; }
        public float? HorimetroInicial { get; set; }
        public float? HorimetroFinal { get; set; }
        public string? CodigoParalizacao { get; set; }
    }

    public class TarefaFilterDto
    {
        public string? Descricao { get; set; }
        public int? StatusId { get; set; }
        public int? ObraId { get; set; }
        public int? EtapaId { get; set; }
        public DateTime? DataInicioFrom { get; set; }
        public DateTime? DataInicioTo { get; set; }
        public DateTime? DataPrevisaoFimFrom { get; set; }
        public DateTime? DataPrevisaoFimTo { get; set; }
        public int Page { get; set; } = 1;
        public int PageSize { get; set; } = 10;
    }

    public class TarefaHistoricoDto
    {
        public int Id { get; set; }
        public int TarefaId { get; set; }
        public string Acao { get; set; } = string.Empty;
        public string? Observacao { get; set; }
        public DateTime DataHora { get; set; }
        public int UsuarioId { get; set; }
        public string UsuarioNome { get; set; } = string.Empty;
        
        // NEW: Measurement History Properties for History Modal
        public string Descricao { get; set; } = string.Empty;
        public DateTime DataMedicao { get; set; }
        public string DataMedicaoFormatada { get; set; } = string.Empty;
        public string HoraMedicaoInicial { get; set; } = string.Empty;
        public string HoraMedicaoFinal { get; set; } = string.Empty;
        public int StatusId { get; set; }
        public string StatusDescricao { get; set; } = string.Empty;
        
        // Water Quality Parameters
        public decimal NivelCloro { get; set; }
        public string NivelCloroTexto { get; set; } = string.Empty;
        public decimal Ph { get; set; }
        public string PhTexto { get; set; } = string.Empty;
        public decimal Alcalinidade { get; set; }
        public string AlcalinidadeTexto { get; set; } = string.Empty;
        
        // Boolean Parameters
        public bool Limpidez { get; set; }
        public bool Superficie { get; set; }
        public bool Fundo { get; set; }
        public bool NivelDetritos { get; set; }
        public bool NivelProliferacao { get; set; }
    }
}