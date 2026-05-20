namespace RdoApp.Core.Data.Entities;

/// <summary>
/// TarefaCodigoParalizacao (Task Stoppage Code) entity - Reasons for task stoppage/paralyzation
/// Maps to legacy 'tarefa_codigo_paralizacao' table
/// </summary>
public class TarefaCodigoParalizacao
{
    public TarefaCodigoParalizacao()
    {
        // Navigation properties will be added when Tarefa is fully implemented
        // Tarefas = new HashSet<Tarefa>();
    }

    /// <summary>
    /// Primary key - Stoppage code
    /// Maps to: tarcp_codigo_paralizacao
    /// </summary>
    public string TarcpCodigoParalizacao { get; set; } = null!;

    /// <summary>
    /// Stoppage description
    /// Maps to: tarcp_ds_paralizacao
    /// </summary>
    public string TarcpDsParalizacao { get; set; } = null!;

    // Navigation properties (will be added when Tarefa is implemented)
    // public virtual ICollection<Tarefa> Tarefas { get; set; }
}
