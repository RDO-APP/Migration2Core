namespace RdoApp.Core.Data.Entities;

/// <summary>
/// Improdutividade (Unproductive Time) entity - Tracks reasons for unproductive time
/// Maps to legacy 'improdutividade' table
/// Tracks various factors that cause work delays or stoppages
/// </summary>
public class Improdutividade
{
    public Improdutividade()
    {
        // Navigation properties will be added when related entities are fully implemented
        // Rdos = new HashSet<Rdo>();
    }

    /// <summary>
    /// Primary key - Unproductive time record ID
    /// Maps to: imp_id_improdutividade
    /// </summary>
    public int ImpIdImprodutividade { get; set; }

    /// <summary>
    /// Weather-related stoppage flag
    /// Maps to: imp_st_clima
    /// </summary>
    public bool ImpStClima { get; set; }

    /// <summary>
    /// Material shortage flag
    /// Maps to: imp_st_material
    /// </summary>
    public bool ImpStMaterial { get; set; }

    /// <summary>
    /// Work stoppage flag
    /// Maps to: imp_st_paralizacao
    /// </summary>
    public bool ImpStParalizacao { get; set; }

    /// <summary>
    /// Equipment failure flag
    /// Maps to: imp_st_equipamento
    /// </summary>
    public bool ImpStEquipamento { get; set; }

    /// <summary>
    /// Contractor-related delay flag
    /// Maps to: imp_st_contratante
    /// </summary>
    public bool ImpStContratante { get; set; }

    /// <summary>
    /// Supplier-related delay flag
    /// Maps to: imp_st_fornecedores
    /// </summary>
    public bool ImpStFornecedores { get; set; }

    /// <summary>
    /// Labor shortage flag
    /// Maps to: imp_st_maodeobra
    /// </summary>
    public bool ImpStMaodeobra { get; set; }

    /// <summary>
    /// Project/design issue flag
    /// Maps to: imp_st_projeto
    /// </summary>
    public bool ImpStProjeto { get; set; }

    /// <summary>
    /// Planning issue flag
    /// Maps to: imp_st_planejamento
    /// </summary>
    public bool ImpStPlanejamento { get; set; }

    /// <summary>
    /// Accident-related stoppage flag
    /// Maps to: imp_st_acidentes
    /// </summary>
    public bool ImpStAcidentes { get; set; }

    // Navigation properties (will be added when related entities are implemented)
    // public virtual ICollection<Rdo> Rdos { get; set; }
}
