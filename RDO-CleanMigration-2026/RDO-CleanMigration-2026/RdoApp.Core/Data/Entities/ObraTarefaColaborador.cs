namespace RdoApp.Core.Data.Entities;

/// <summary>
/// ObraTarefaColaborador (Task-Worker Assignment) entity - Assigns workers to specific tasks
/// Maps to legacy 'obra_tarefa_colaborador' table
/// Junction table connecting ObraColaborador to Tarefa
/// </summary>
public class ObraTarefaColaborador
{
    /// <summary>
    /// Primary key - Task-Worker assignment ID
    /// Maps to: otc_id_obra_tarefa_colaborador
    /// </summary>
    public int OtcIdObraTarefaColaborador { get; set; }

    /// <summary>
    /// Foreign key - Project-Worker assignment ID
    /// Maps to: otc_id_obra_colaborador
    /// </summary>
    public int OtcIdObraColaborador { get; set; }

    /// <summary>
    /// Foreign key - Task ID
    /// Maps to: otc_id_tarefa
    /// </summary>
    public int OtcIdTarefa { get; set; }

    // Navigation properties (will be added when related entities are implemented)
    // public virtual ObraColaborador ObraColaborador { get; set; }
    // public virtual Tarefa Tarefa { get; set; }
}
