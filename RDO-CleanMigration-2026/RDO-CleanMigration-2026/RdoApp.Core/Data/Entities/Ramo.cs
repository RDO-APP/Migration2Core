namespace RdoApp.Core.Data.Entities;

/// <summary>
/// Ramo (Business Branch/Sector) entity - Business activity sectors
/// Maps to legacy 'ramo' table
/// </summary>
public class Ramo
{
    public Ramo()
    {
        // Navigation properties will be added when Empresa is fully implemented
        // Empresas = new HashSet<Empresa>();
    }

    /// <summary>
    /// Primary key - Branch ID
    /// Maps to: ram_id_ramo
    /// </summary>
    public int RamIdRamo { get; set; }

    /// <summary>
    /// Branch name
    /// Maps to: ram_ds_ramo
    /// </summary>
    public string RamDsRamo { get; set; } = null!;

    /// <summary>
    /// Legacy shop system ID
    /// Maps to: ram_id_ramo_loja
    /// </summary>
    public string? RamIdRamoLoja { get; set; }

    // Navigation properties (will be added when Empresa is implemented)
    // public virtual ICollection<Empresa> Empresas { get; set; }
}
