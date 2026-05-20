using System.ComponentModel.DataAnnotations;
using System.Linq;

namespace RdoApp.Core.Models.ViewModels
{
    /// <summary>
    /// ViewModel for filtering Etapa/Tarefa data
    /// Handles server-side form binding and validation
    /// Replaces AngularJS form binding
    /// </summary>
    public class EtapaFilterViewModel
    {
        [Display(Name = "Descrição")]
        [StringLength(200, ErrorMessage = "Descrição deve ter no máximo 200 caracteres")]
        public string? Descricao { get; set; }
        
        [Display(Name = "Status")]
        public int? StatusTarefa { get; set; }
        
        [Display(Name = "Data Inicial Planejada")]
        [DataType(DataType.Date)]
        public DateTime? DataInicial { get; set; }
        
        [Display(Name = "Data Final Planejada")]
        [DataType(DataType.Date)]
        public DateTime? DataFinalPlanejada { get; set; }
        
        [Display(Name = "Data Inicial Executada")]
        [DataType(DataType.Date)]
        public DateTime? DataInicialExecutada { get; set; }
        
        [Display(Name = "Data Final Executada")]
        [DataType(DataType.Date)]
        public DateTime? DataFinalExecutada { get; set; }
        
        [Display(Name = "Etapa")]
        public int? IdEtapa { get; set; }
        
        // Internal properties for data access layer
        public int IdObra { get; set; }
        
        // Validation helpers
        public bool IsValid()
        {
            if (DataInicial.HasValue && DataFinalPlanejada.HasValue && DataInicial > DataFinalPlanejada)
                return false;
                
            if (DataInicialExecutada.HasValue && DataFinalExecutada.HasValue && DataInicialExecutada > DataFinalExecutada)
                return false;
                
            return true;
        }
        
        // Display helpers
        public bool HasActiveFilters => 
            !string.IsNullOrWhiteSpace(Descricao) ||
            StatusTarefa.HasValue ||
            DataInicial.HasValue ||
            DataFinalPlanejada.HasValue ||
            DataInicialExecutada.HasValue ||
            DataFinalExecutada.HasValue ||
            IdEtapa.HasValue;
            
        public string GetSummary()
        {
            var filters = new List<string>();
            
            if (!string.IsNullOrWhiteSpace(Descricao))
                filters.Add($"Descrição: {Descricao}");
                
            if (StatusTarefa.HasValue)
                filters.Add($"Status: {StatusTarefa}");
                
            if (DataInicial.HasValue)
                filters.Add($"Data Inicial: {DataInicial:dd/MM/yyyy}");
                
            if (DataFinalPlanejada.HasValue)
                filters.Add($"Data Final: {DataFinalPlanejada:dd/MM/yyyy}");
                
            if (DataInicialExecutada.HasValue)
                filters.Add($"Executada Inicial: {DataInicialExecutada:dd/MM/yyyy}");
                
            if (DataFinalExecutada.HasValue)
                filters.Add($"Executada Final: {DataFinalExecutada:dd/MM/yyyy}");
                
            if (IdEtapa.HasValue)
                filters.Add($"Etapa específica");
                
            return filters.Any() ? string.Join(", ", filters) : "Nenhum filtro aplicado";
        }
        
        // Convert to legacy format for existing data access layer
        public object ToLegacyFilter()
        {
            return new
            {
                Id = IdEtapa ?? 0,
                Titulo = string.Empty,
                IdObra = IdObra,
                descricao = Descricao ?? string.Empty,
                dataInicial = DataInicial ?? DateTime.MinValue,
                dataFinalPlanejada = DataFinalPlanejada ?? DateTime.MinValue,
                dataInicialExecutada = DataInicialExecutada ?? DateTime.MinValue,
                dataFinalExecutada = DataFinalExecutada ?? DateTime.MinValue,
                idStatus = StatusTarefa ?? 0
            };
        }
    }
}