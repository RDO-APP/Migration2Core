namespace RdoApp.Core.Models.ViewModels
{
    /// <summary>
    /// ViewModel for Tarefa display in task cards
    /// Provides strong typing, formatted dates, and calculated fields for UI display
    /// Replaces direct entity binding and dynamic objects
    /// </summary>
    public class TarefaViewModel
    {
        public int Id { get; set; }
        public Guid Agrupador { get; set; }
        public string Descricao { get; set; } = string.Empty;
        
        // Date fields with formatting
        public DateTime DataInicio { get; set; }
        public DateTime? DataPrevisaoFim { get; set; }
        public DateTime DataMedicao { get; set; }
        public DateTime? DataFim { get; set; }
        
        // Formatted date strings for display
        public string DataInicioFormatada => DataInicio.ToString("dd/MM/yyyy");
        public string DataPrevisaoFimFormatada => DataPrevisaoFim?.ToString("dd/MM/yyyy") ?? "N/A";
        public string DataMedicaoFormatada => DataMedicao.ToString("dd/MM/yyyy");
        public string DataFimFormatada => DataFim?.ToString("dd/MM/yyyy") ?? "N/A";
        
        // Status information
        public int StatusId { get; set; }
        public string StatusDescricao { get; set; } = string.Empty;
        public string StatusCssClass { get; set; } = string.Empty;
        public string StatusIcon { get; set; } = string.Empty;
        
        // Progress and quantities
        public float? QuantidadeConstruida { get; set; }
        public decimal? QuantidadePrevisao { get; set; }
        public double PercentualConclusao { get; set; }
        public string PercentualConclusaoFormatado => $"{PercentualConclusao:F1}%";
        public bool PercentualExtrapolado => PercentualConclusao > 100;
        
        // Safe property for UI rendering
        public double SafePercentualConclusao => Math.Max(0, Math.Min(100, PercentualConclusao));
        
        // Resource counts
        public int QuantidadeColaboradores { get; set; }
        public int QuantidadeEquipamentos { get; set; }
        
        // Time tracking
        public int? HorasTrabalhadas { get; set; }
        public TimeSpan? HoraMedicaoInicial { get; set; }
        public TimeSpan? HoraMedicaoFinal { get; set; }
        
        // Water quality fields (for pool management)
        public int? NivelCloro { get; set; }
        public int? Ph { get; set; }
        public int? Alcalinidade { get; set; }
        public bool? Limpidez { get; set; }
        public bool? Superficie { get; set; }
        public bool? Fundo { get; set; }
        public bool? NivelDetritos { get; set; }
        public bool? NivelProliferacao { get; set; }
        
        // Water quality display helpers
        public string NivelCloroTexto => NivelCloro switch
        {
            1 => "Baixo",
            2 => "Normal", 
            3 => "Alto",
            _ => "N/A"
        };
        
        public string PhTexto => Ph switch
        {
            1 => "Ácido",
            2 => "Normal",
            3 => "Básico", 
            _ => "N/A"
        };
        
        public string AlcalinidadeTexto => Alcalinidade switch
        {
            1 => "Baixa",
            2 => "Normal",
            3 => "Alta",
            _ => "N/A"
        };
        
        // Permission-based action flags
        public bool PodeEditar { get; set; } = true;
        public bool PodeExcluir { get; set; } = true;
        public bool PodeIniciar { get; set; } = true;
        public bool PodeFinalizar { get; set; } = true;
        public bool PodePausar { get; set; } = true;
        public bool PodeAdicionarMedicao { get; set; } = true;
        
        // Display helpers
        public string PeriodoPlanejado => $"{DataInicioFormatada} à {DataPrevisaoFimFormatada}";
        public string PeriodoExecutado => $"{DataMedicaoFormatada} à {DataFimFormatada}";
        
        // Comments and additional info
        public string? Comentario { get; set; }
        public string? Foto { get; set; }
        public string? CodigoParalizacao { get; set; }
        
        // Audit fields
        public int ColaboradorInsercaoId { get; set; }
        public DateTime DataInsercao { get; set; }
        public DateTime? DataUltimaAtualizacao { get; set; }
        
        // NULL SAFETY FIX: Enhanced validation and safe properties
        public bool IsValid => Id > 0 && !string.IsNullOrEmpty(Descricao);
        public bool HasNullProperties => 
            string.IsNullOrEmpty(Descricao) || 
            string.IsNullOrEmpty(StatusDescricao) ||
            DataInicio == default(DateTime);
        
        // Safe property access with fallbacks
        public string SafeDescricao => Descricao ?? $"Tarefa {Id}";
        public string SafeStatusDescricao => StatusDescricao ?? "Status Desconhecido";
        public int SafeStatusId => StatusId > 0 ? StatusId : 1; // Default to status 1
    }
}