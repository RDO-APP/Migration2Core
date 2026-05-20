namespace RdoApp.Core.Data.Entities;

/// <summary>
/// Setor (Department/Sector) entity - Business sectors
/// Maps to legacy 'setor' table
/// </summary>
public class Setor
{
    public Setor()
    {
        // Navigation properties will be added when Empresa is fully implemented
        // Empresas = new HashSet<Empresa>();
    }

    /// <summary>
    /// Primary key - Sector ID
    /// Maps to: set_id_setor
    /// </summary>
    public int SetIdSetor { get; set; }

    /// <summary>
    /// Sector name
    /// Maps to: set_ds_setor
    /// </summary>
    public string SetDsSetor { get; set; } = null!;

    /// <summary>
    /// Legacy shop system ID
    /// Maps to: set_id_setor_loja
    /// </summary>
    public string? SetIdSetorLoja { get; set; }

    // Navigation properties (will be added when Empresa is implemented)
    // public virtual ICollection<Empresa> Empresas { get; set; }
}
