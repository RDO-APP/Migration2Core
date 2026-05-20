namespace RdoApp.Core.Data.Entities;

/// <summary>
/// HistoricoTarefaRdo (Task-RDO History) entity - Historical record of task work in daily reports
/// Maps to legacy 'historico_tarefa_rdo' table
/// </summary>
public class HistoricoTarefaRdo
{
    public HistoricoTarefaRdo()
    {
        // Navigation properties will be added when related entities are fully implemented
        // HistoricoTarefaColaboradores = new HashSet<HistoricoTarefaColaborador>();
        // HistoricoTarefaEquipamentos = new HashSet<HistoricoTarefaEquipamento>();
    }

    /// <summary>
    /// Primary key - History record ID
    /// Maps to: his_id_historico_tarefa_rdo
    /// </summary>
    public int HisIdHistoricoTarefaRdo { get; set; }

    /// <summary>
    /// Foreign key - Task ID
    /// Maps to: his_id_tarefa
    /// </summary>
    public int HisIdTarefa { get; set; }

    /// <summary>
    /// Foreign key - Daily report ID
    /// Maps to: his_id_rdo
    /// </summary>
    public int HisIdRdo { get; set; }

    /// <summary>
    /// Foreign key - Task status ID
    /// Maps to: his_id_status
    /// </summary>
    public int HisIdStatus { get; set; }

    /// <summary>
    /// History record date
    /// Maps to: his_dt_data
    /// </summary>
    public DateTime? HisDtData { get; set; }

    /// <summary>
    /// Photo filename/path
    /// Maps to: his_ds_foto
    /// </summary>
    public string HisDsFoto { get; set; } = null!;

    /// <summary>
    /// Comment/notes
    /// Maps to: his_ds_comentario
    /// </summary>
    public string HisDsComentario { get; set; } = null!;

    /// <summary>
    /// Hours worked
    /// Maps to: his_nr_horas_trabalhadas
    /// </summary>
    public int HisNrHorasTrabalhadas { get; set; }

    // Navigation properties (will be added when related entities are implemented)
    // public virtual Tarefa Tarefa { get; set; }
    // public virtual Rdo Rdo { get; set; }
    // public virtual StatusTarefa StatusTarefa { get; set; }
    // public virtual ICollection<HistoricoTarefaColaborador> HistoricoTarefaColaboradores { get; set; }
    // public virtual ICollection<HistoricoTarefaEquipamento> HistoricoTarefaEquipamentos { get; set; }
}
