namespace RdoApp.Core.Data.Entities;

/// <summary>
/// EfetivoStatus (Workforce Status) entity - Status values for workforce records
/// Maps to legacy 'efetivo_status' table
/// </summary>
public class EfetivoStatus
{
    public EfetivoStatus()
    {
        // Navigation properties will be added when Efetivo is fully implemented
        // Efetivos = new HashSet<Efetivo>();
    }

    /// <summary>
    /// Primary key - Workforce Status ID
    /// Maps to: est_id_efetivo_status
    /// </summary>
    public int EstIdEfetivoStatus { get; set; }

    /// <summary>
    /// Status description (e.g., "Presente", "Ausente", "Férias")
    /// Maps to: est_ds_efetivo_status
    /// </summary>
    public string EstDsEfetivoStatus { get; set; } = null!;

    /// <summary>
    /// Color code for UI display (e.g., "#00FF00" for green)
    /// Maps to: est_ds_color
    /// </summary>
    public string EstDsColor { get; set; } = null!;

    // Navigation properties (will be added when Efetivo is implemented)
    // public virtual ICollection<Efetivo> Efetivos { get; set; }
}
