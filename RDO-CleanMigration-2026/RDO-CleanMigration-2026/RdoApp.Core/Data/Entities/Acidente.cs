namespace RdoApp.Core.Data.Entities;

/// <summary>
/// Acidente (Accident) entity - Workplace accident reports
/// Maps to legacy 'acidente' table
/// </summary>
public class Acidente
{
    public Acidente()
    {
        // Navigation properties will be added when related entities are fully implemented
        // AcidenteColaboradores = new HashSet<AcidenteColaborador>();
    }

    /// <summary>
    /// Primary key - Accident ID
    /// Maps to: aci_id_acidente
    /// </summary>
    public int AciIdAcidente { get; set; }

    /// <summary>
    /// Foreign key - Task ID where accident occurred
    /// Maps to: aci_id_tarefa
    /// </summary>
    public int AciIdTarefa { get; set; }

    /// <summary>
    /// Accident description
    /// Maps to: aci_ds_acidente
    /// </summary>
    public string AciDsAcidente { get; set; } = null!;

    /// <summary>
    /// Accident date and time
    /// Maps to: aci_dt_data_hora
    /// </summary>
    public DateTime? AciDtDataHora { get; set; }

    /// <summary>
    /// Work leave status (if worker needs time off)
    /// Maps to: aci_st_afastamento
    /// </summary>
    public string AciStAfastamento { get; set; } = null!;

    // Navigation properties (will be added when related entities are implemented)
    // public virtual Tarefa Tarefa { get; set; }
    // public virtual ICollection<AcidenteColaborador> AcidenteColaboradores { get; set; }
}
