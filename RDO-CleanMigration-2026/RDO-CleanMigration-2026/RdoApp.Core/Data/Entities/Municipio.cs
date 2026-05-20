namespace RdoApp.Core.Data.Entities;

/// <summary>
/// Municipio (City) entity - Brazilian cities
/// Maps to legacy 'municipio' table
/// </summary>
public class Municipio
{
    public Municipio()
    {
        // Navigation properties will be added when other entities are fully implemented
        // Colaboradores = new HashSet<Colaborador>();
        // Empresas = new HashSet<Empresa>();
        // Obras = new HashSet<Obra>();
    }

    /// <summary>
    /// Primary key - City ID
    /// Maps to: mun_id_municipio
    /// </summary>
    public int MunIdMunicipio { get; set; }

    /// <summary>
    /// Foreign key to UF (State)
    /// Maps to: mun_id_uf
    /// </summary>
    public int MunIdUf { get; set; }

    /// <summary>
    /// City name (e.g., "São Paulo")
    /// Maps to: mun_ds_municipio
    /// </summary>
    public string MunDsMunicipio { get; set; } = null!;

    // Navigation properties
    public virtual UF UF { get; set; } = null!;
    
    // These will be added when other entities are fully implemented:
    // public virtual ICollection<Colaborador> Colaboradores { get; set; }
    // public virtual ICollection<Empresa> Empresas { get; set; }
    // public virtual ICollection<Obra> Obras { get; set; }
}
