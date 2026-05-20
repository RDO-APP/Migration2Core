using System.Linq;

namespace RdoApp.Core.Models.ViewModels
{
    /// <summary>
    /// ViewModel for Etapa display in the accordion interface
    /// Provides strong typing and calculated fields for UI display
    /// Replaces direct entity binding and dynamic objects
    /// FRONTEND INTEGRITY FIX: Enhanced with safety properties and null handling
    /// </summary>
    public class EtapaViewModel
    {
        public int Id { get; set; }
        public string Descricao { get; set; } = string.Empty;
        public int ObraId { get; set; }
        
        // Aggregated task statistics
        public int TotalTarefas { get; set; }
        public int TarefasConcluidas { get; set; }
        public int TarefasEmAndamento { get; set; }
        public int TarefasPlanejadas { get; set; }
        public int TarefasParalisadas { get; set; }
        
        // Calculated fields for UI display
        public double PercentualConclusao { get; set; }
        public string PercentualConclusaoFormatado => $"{PercentualConclusao:F1}%";
        
        // Task collection
        public List<TarefaViewModel> Tarefas { get; set; } = new List<TarefaViewModel>();
        
        // UI state management
        public bool IsExpanded { get; set; } // For accordion state
        public bool CanAddTasks { get; set; } = true; // Permission-based
        
        // FRONTEND INTEGRITY FIX: Safety properties for UI rendering
        public string DisplayName => !string.IsNullOrEmpty(Descricao) ? Descricao : $"Etapa {Id}";
        public bool HasTarefas => Tarefas?.Any() == true;
        public bool HasValidData => Id > 0 && !string.IsNullOrEmpty(Descricao);
        public string SafeDescricao => Descricao ?? $"Etapa {Id}";
        
        // Display helpers with null safety
        public string BadgeText => $"{TotalTarefas} tarefa{(TotalTarefas != 1 ? "s" : "")}";
        public string StatusSummary => TotalTarefas == 0 
            ? "Nenhuma tarefa cadastrada" 
            : $"{TarefasConcluidas}/{TotalTarefas} concluídas ({PercentualConclusaoFormatado})";
            
        // FRONTEND INTEGRITY FIX: Error state management
        public bool HasLoadingError { get; set; } = false;
        public string ErrorMessage { get; set; } = string.Empty;
        public bool IsFallbackData { get; set; } = false;
        
        // FRONTEND INTEGRITY FIX: Safe task access
        public List<TarefaViewModel> SafeTarefas => Tarefas ?? new List<TarefaViewModel>();
        public int SafeTotalTarefas => Math.Max(0, TotalTarefas);
        public double SafePercentualConclusao => Math.Max(0, Math.Min(100, PercentualConclusao));
        
        // NULL SAFETY FIX: Enhanced null-safe task filtering
        public List<TarefaViewModel> ValidTarefas => 
            SafeTarefas?.Where(t => t != null && t.Id > 0 && !string.IsNullOrEmpty(t.Descricao)).ToList() ?? new List<TarefaViewModel>();
        
        public bool HasValidTarefas => ValidTarefas.Any();
        
        public string SafeIterationDebug => 
            $"Total: {SafeTarefas?.Count ?? 0}, Valid: {ValidTarefas.Count}, Nulls: {(SafeTarefas?.Count(t => t == null) ?? 0)}";
    }
}