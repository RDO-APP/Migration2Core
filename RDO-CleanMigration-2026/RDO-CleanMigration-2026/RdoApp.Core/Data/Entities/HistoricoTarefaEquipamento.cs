namespace RdoApp.Core.Data.Entities;

/// <summary>
/// HistoricoTarefaEquipamento (Task-Equipment History) entity - Historical record of equipment assignments to tasks
/// Maps to legacy 'historico_tarefa_equipamento' table
/// </summary>
public class HistoricoTarefaEquipamento
{
    /// <summary>
    /// Primary key - Task-Equipment history ID
    /// Maps to: hte_id_tarefa_equipamento
    /// </summary>
    public int HteIdTarefaEquipamento { get; set; }

    /// <summary>
    /// Foreign key - Task-RDO history record ID
    /// Maps to: hte_id_historico_tarefa_rdo
    /// </summary>
    public int HteIdHistoricoTarefaRdo { get; set; }

    /// <summary>
    /// Foreign key - Project-Equipment assignment ID
    /// Maps to: hte_id_obra_equipamento
    /// </summary>
    public int HteIdObraEquipamento { get; set; }

    // Navigation properties (will be added when related entities are implemented)
    // public virtual HistoricoTarefaRdo HistoricoTarefaRdo { get; set; }
    // public virtual ObraEquipamento ObraEquipamento { get; set; }
}
