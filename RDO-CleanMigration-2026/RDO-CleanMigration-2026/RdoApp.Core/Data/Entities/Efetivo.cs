namespace RdoApp.Core.Data.Entities;

/// <summary>
/// Efetivo (Workforce Tracking) entity - Daily workforce presence tracking
/// Maps to legacy 'efetivo' table
/// Tracks which workers are present on which days
/// </summary>
public class Efetivo
{
    /// <summary>
    /// Primary key - Workforce record ID
    /// Maps to: efe_id_efetivo
    /// </summary>
    public int EfeIdEfetivo { get; set; }

    /// <summary>
    /// Foreign key - Project ID
    /// Maps to: efe_id_obra
    /// </summary>
    public int EfeIdObra { get; set; }

    /// <summary>
    /// Foreign key - Project-Worker assignment ID
    /// Maps to: efe_id_obra_colaborador
    /// </summary>
    public int EfeIdObraColaborador { get; set; }

    /// <summary>
    /// Foreign key - Workforce status ID (present, absent, etc.)
    /// Maps to: efe_id_efetivo_status
    /// </summary>
    public int EfeIdEfetivoStatus { get; set; }

    /// <summary>
    /// Date of workforce record
    /// Maps to: efe_data
    /// </summary>
    public DateTime EfeData { get; set; }

    // Navigation properties (will be added when related entities are implemented)
    // public virtual Obra Obra { get; set; }
    // public virtual ObraColaborador ObraColaborador { get; set; }
    // public virtual EfetivoStatus EfetivoStatus { get; set; }
}
