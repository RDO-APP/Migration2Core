namespace RdoApp.Core.Data.Entities;

/// <summary>
/// ObraTarefaEquipamento (Task-Equipment Assignment) entity - Assigns equipment to specific tasks
/// Maps to legacy 'obra_tarefa_equipamento' table
/// Junction table connecting ObraEquipamento to Tarefa
/// Note: Legacy table has typo in column name (euipamento instead of equipamento)
/// </summary>
public class ObraTarefaEquipamento
{
    /// <summary>
    /// Primary key - Task-Equipment assignment ID
    /// Maps to: ote_id_obra_tarefa_euipamento (note: typo in legacy column name)
    /// </summary>
    public int OteIdObraTarefaEuipamento { get; set; }

    /// <summary>
    /// Foreign key - Project-Equipment assignment ID
    /// Maps to: ote_id_obra_equipamento
    /// </summary>
    public int OteIdObraEquipamento { get; set; }

    /// <summary>
    /// Foreign key - Task ID
    /// Maps to: ote_id_tarefa
    /// </summary>
    public int OteIdTarefa { get; set; }

    // Navigation properties (will be added when related entities are implemented)
    // public virtual ObraEquipamento ObraEquipamento { get; set; }
    // public virtual Tarefa Tarefa { get; set; }
}
