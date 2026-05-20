using System.Linq;

namespace RdoApp.Core.Models.ViewModels
{
    /// <summary>
    /// ViewModel for the Etapa/Tarefa Cards view
    /// Provides all data needed for server-side rendering of task cards
    /// Replaces AngularJS controller data binding
    /// </summary>
    public class EtapaCardsViewModel
    {
        public List<EtapaViewModel> Etapas { get; set; } = new List<EtapaViewModel>();
        public EtapaFilterViewModel Filter { get; set; } = new EtapaFilterViewModel();
        
        // Status options for filtering
        public List<StatusOption> StatusOptions { get; set; } = new List<StatusOption>();
        public List<EtapaOption> EtapaOptions { get; set; } = new List<EtapaOption>();
        
        // User permissions
        public bool CanEdit { get; set; } = true;
        public bool CanDelete { get; set; } = true;
        public bool CanCreateNew { get; set; } = true;
        public bool CanChangeStatus { get; set; } = true;
        
        // Work state
        public bool IsWorkFinalized { get; set; } = false;
        public int CurrentObraId { get; set; }
        public string CurrentObraName { get; set; } = string.Empty;
        
        // Display helpers
        public bool HasEtapas => Etapas?.Any() == true;
        public int TotalEtapas => Etapas?.Count ?? 0;
        public int TotalTarefas => Etapas?.Sum(e => e.TotalTarefas) ?? 0;
        public bool HasResults => HasEtapas && TotalTarefas > 0;
        
        // Filter state
        public bool HasActiveFilters => Filter?.HasActiveFilters == true;
        public string FilterSummary => Filter?.GetSummary() ?? string.Empty;
        
        // Error handling
        public bool HasError { get; set; } = false;
        public string ErrorMessage { get; set; } = string.Empty;
        
        // Loading state
        public bool IsLoading { get; set; } = false;
    }
}