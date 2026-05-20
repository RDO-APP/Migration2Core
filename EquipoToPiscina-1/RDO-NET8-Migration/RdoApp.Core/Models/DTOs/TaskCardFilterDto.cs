using System;

namespace RdoApp.Core.Models.DTOs
{
    /// <summary>
    /// Task Card Filter DTO - Matches Gilberto's original filter parameters
    /// Used for filtering task cards in the Etapas/Tarefas page
    /// </summary>
    public class TaskCardFilterDto
    {
        public string? Descricao { get; set; }
        public int? StatusTarefa { get; set; }
        public DateTime? DataInicial { get; set; }
        public DateTime? DataFinalPlanejada { get; set; }
        public DateTime? DataInicialExecutada { get; set; }
        public DateTime? DataFinalExecutada { get; set; }
        public int? IdEtapa { get; set; }
        public int IdObra { get; set; } // Required for filtering by project
    }
}