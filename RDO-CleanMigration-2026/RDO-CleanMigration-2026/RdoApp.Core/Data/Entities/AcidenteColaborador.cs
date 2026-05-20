namespace RdoApp.Core.Data.Entities;

/// <summary>
/// AcidenteColaborador (Accident-Worker Link) entity - Links workers to accidents
/// Maps to legacy 'acidente_colaborador' table
/// Tracks which workers were involved in each accident
/// Note: Legacy table has typo in column name (atastamento instead of afastamento)
/// </summary>
public class AcidenteColaborador
{
    /// <summary>
    /// Primary key - Accident-Worker link ID
    /// Maps to: acc_id_acidente_colaborador
    /// </summary>
    public int AccIdAcidenteColaborador { get; set; }

    /// <summary>
    /// Foreign key - Accident ID
    /// Maps to: acc_id_acidente
    /// </summary>
    public int AccIdAcidente { get; set; }

    /// <summary>
    /// Foreign key - Project-Worker assignment ID
    /// Maps to: acc_id_obra_colaborador
    /// </summary>
    public int AccIdObraColaborador { get; set; }

    /// <summary>
    /// Work leave status for this worker
    /// Maps to: acc_st_atastamento (note: typo in legacy column name)
    /// </summary>
    public string AccStAtastamento { get; set; } = null!;

    // Navigation properties (will be added when related entities are implemented)
    // public virtual Acidente Acidente { get; set; }
    // public virtual ObraColaborador ObraColaborador { get; set; }
}
