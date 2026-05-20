namespace RdoApp.Core.Data.Entities;

/// <summary>
/// Licenca (License) entity - Software license configuration
/// Maps to legacy 'licenca' table
/// </summary>
public class Licenca
{
    public Licenca()
    {
        // Navigation properties will be added when Empresa and Grupo are fully implemented
        // Empresas = new HashSet<Empresa>();
        // Grupos = new HashSet<Grupo>();
    }

    /// <summary>
    /// Primary key - License ID
    /// Maps to: lic_id_licenca
    /// </summary>
    public int LicIdLicenca { get; set; }

    /// <summary>
    /// License description/name
    /// Maps to: lic_ds_licenca
    /// </summary>
    public string LicDsLicenca { get; set; } = null!;

    /// <summary>
    /// Maximum number of users allowed
    /// Maps to: lic_nr_qtd_usuarios
    /// </summary>
    public int? LicNrQtdUsuarios { get; set; }

    /// <summary>
    /// Maximum number of works/projects allowed
    /// Maps to: lic_nr_qtd_obras
    /// </summary>
    public int? LicNrQtdObras { get; set; }

    /// <summary>
    /// Maximum number of images per task
    /// Maps to: lic_qtd_imagens_tarefas
    /// </summary>
    public int LicQtdImagensTarefas { get; set; }

    /// <summary>
    /// Maximum number of tasks per work
    /// Maps to: lic_qtd_tarefas_obra
    /// </summary>
    public int LicQtdTarefasObra { get; set; }

    /// <summary>
    /// Whether custom logo on RDO is allowed
    /// Maps to: lic_st_permite_logo_rdo
    /// </summary>
    public bool LicStPermiteLogoRdo { get; set; }

    /// <summary>
    /// License ID from external store/system
    /// Maps to: lic_id_licenca_loja
    /// </summary>
    public string LicIdLicencaLoja { get; set; } = null!;

    // Navigation properties (will be added when Empresa and Grupo are implemented)
    // public virtual ICollection<Empresa> Empresas { get; set; }
    // public virtual ICollection<Grupo> Grupos { get; set; }
}
