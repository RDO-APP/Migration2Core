namespace RdoApp.Core.Data.Entities;

/// <summary>
/// StatusTarefa (Task Status) entity - Task status lookup
/// Maps to legacy 'status_tarefa' table
/// </summary>
public class StatusTarefa
{
    public StatusTarefa()
    {
        // Navigation properties will be added when related entities are implemented
        // HistoricoTarefaRdos = new HashSet<HistoricoTarefaRdo>();
        // Tarefas = new HashSet<Tarefa>();
    }

    /// <summary>
    /// Primary key - Status ID
    /// Maps to: stt_id_status
    /// </summary>
    public int SttIdStatus { get; set; }

    /// <summary>
    /// Status description (e.g., "Pendente", "Em Andamento", "Concluída")
    /// Maps to: stt_ds_status
    /// </summary>
    public string SttDsStatus { get; set; } = null!;

    // Navigation properties (will be added when related entities are implemented)
    // public virtual ICollection<HistoricoTarefaRdo> HistoricoTarefaRdos { get; set; }
    // public virtual ICollection<Tarefa> Tarefas { get; set; }
}
