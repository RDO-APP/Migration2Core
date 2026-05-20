namespace RdoApp.Core.Data.Entities;

/// <summary>
/// StatusRdo (Report Status) entity - Status values for daily reports
/// Maps to legacy 'status_rdo' table
/// </summary>
public class StatusRdo
{
    public StatusRdo()
    {
        // Navigation properties will be added when Rdo is fully implemented
        // Rdos = new HashSet<Rdo>();
    }

    /// <summary>
    /// Primary key - Status ID
    /// Maps to: str_id_status
    /// </summary>
    public int StrIdStatus { get; set; }

    /// <summary>
    /// Status description (e.g., "Aberto", "Fechado", "Aprovado")
    /// Maps to: str_ds_status
    /// </summary>
    public string StrDsStatus { get; set; } = null!;

    // Navigation properties (will be added when Rdo is implemented)
    // public virtual ICollection<Rdo> Rdos { get; set; }
}
