using System;
using System.Collections.Generic;

namespace RdoApp.Core.Models.DTOs
{
    /// <summary>
    /// Task Card DTO - Matches Gilberto's original task card data structure
    /// Used for displaying task cards in the Etapas/Tarefas page
    /// </summary>
    public class TaskCardDto
    {
        public int Id { get; set; }
        public Guid Agrupador { get; set; }
        public string Descricao { get; set; } = string.Empty;
        public DateTime DataInicio { get; set; }
        public DateTime? DataPrevisaoFim { get; set; }
        public DateTime? PrimeiraExecucao { get; set; }
        public DateTime? UltimaExecucao { get; set; }
        public bool ExisteExecucao { get; set; }
        public int StatusId { get; set; }
        public string StatusDescricao { get; set; } = string.Empty;
        public string ClasseStatusCss { get; set; } = string.Empty;
        public int PercentualConcluido { get; set; }
        public bool PercentualExtrapolado { get; set; }
        public int QuantidadeColaboradores { get; set; }
        public int QuantidadeEquipamentos { get; set; }
        public List<StatusTarefaDto> ListaStatusPermitidos { get; set; } = new();
        public List<TaskHistoryDto> ListaHistoricoTarefa { get; set; } = new();
        
        // Note: No CodigoParalisacao field - simplified pause workflow as per business rule change
    }
}