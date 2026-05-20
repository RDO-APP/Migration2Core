namespace RdoApp.Core.Data.Entities;

/// <summary>
/// HistoricoTarefaColaborador (Task-Worker History) entity - Historical record of worker assignments to tasks
/// Maps to legacy 'historico_tarefa_colaborador' table
/// </summary>
public class HistoricoTarefaColaborador
{
    /// <summary>
    /// Primary key - Task-Worker history ID
    /// Maps to: htc_id_tarefa_colaborador
    /// </summary>
    public int HtcIdTarefaColaborador { get; set; }

    /// <summary>
    /// Foreign key - Task-RDO history record ID
    /// Maps to: htc_id_historico_tarefa_rdo
    /// </summary>
    public int HtcIdHistoricoTarefaRdo { get; set; }

    /// <summary>
    /// Foreign key - Project-Worker assignment ID
    /// Maps to: htc_id_obra_colaborador
    /// </summary>
    public int HtcIdObraColaborador { get; set; }

    // Navigation properties (will be added when related entities are implemented)
    // public virtual HistoricoTarefaRdo HistoricoTarefaRdo { get; set; }
    // public virtual ObraColaborador ObraColaborador { get; set; }
}
