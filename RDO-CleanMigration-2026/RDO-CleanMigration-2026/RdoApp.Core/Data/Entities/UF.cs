namespace RdoApp.Core.Data.Entities;

/// <summary>
/// UF (State) entity - Brazilian states
/// Maps to legacy 'uf' table
/// </summary>
public class UF
{
    public UF()
    {
        Municipios = new HashSet<Municipio>();
    }

    /// <summary>
    /// Primary key - State ID
    /// Maps to: ufe_id_uf
    /// </summary>
    public int UfeIdUf { get; set; }

    /// <summary>
    /// State name (e.g., "São Paulo")
    /// Maps to: ufe_ds_uf
    /// </summary>
    public string UfeDsUf { get; set; } = null!;

    /// <summary>
    /// State abbreviation (e.g., "SP")
    /// Maps to: ufe_ds_sigla
    /// </summary>
    public string UfeDsSigla { get; set; } = null!;

    // Navigation properties
    public virtual ICollection<Municipio> Municipios { get; set; }
}
