namespace RdoApp.Core.Data.Entities;

/// <summary>
/// RdoTarefa (Daily Report Task) entity - Links tasks to daily reports
/// Maps to legacy 'rdo_tarefa' table
/// Junction table connecting Rdo to Tarefa
/// </summary>
public class RdoTarefa
{
    /// <summary>
    /// Primary key - Report-Task link ID
    /// Maps to: rta_id_rta
    /// </summary>
    public int RtaIdRta { get; set; }

    /// <summary>
    /// Foreign key - Daily report ID
    /// Maps to: rta_id_rdo
    /// </summary>
    public int RtaIdRdo { get; set; }

    /// <summary>
    /// Foreign key - Task ID
    /// Maps to: rta_id_tarefa
    /// </summary>
    public int RtaIdTarefa { get; set; }

    // Navigation properties (will be added when related entities are implemented)
    // public virtual Rdo Rdo { get; set; }
    // public virtual Tarefa Tarefa { get; set; }
}
