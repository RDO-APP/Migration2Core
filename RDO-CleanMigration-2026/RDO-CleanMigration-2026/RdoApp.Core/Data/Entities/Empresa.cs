namespace RdoApp.Core.Data.Entities;

/// <summary>
/// Empresa (Company) entity - Company/organization information
/// Maps to legacy 'empresa' table
/// </summary>
public class Empresa
{
    public Empresa()
    {
        // Navigation properties will be added when Obra is fully implemented
        // Obras = new HashSet<Obra>();
        // ObrasContratante = new HashSet<Obra>();
        // ObrasContratada = new HashSet<Obra>();
    }

    /// <summary>
    /// Primary key - Company ID
    /// Maps to: emp_id_empresa
    /// </summary>
    public int EmpIdEmpresa { get; set; }

    /// <summary>
    /// Foreign key - City ID
    /// Maps to: emp_id_municipio
    /// </summary>
    public int? EmpIdMunicipio { get; set; }

    /// <summary>
    /// Foreign key - Business Branch ID
    /// Maps to: emp_id_ramo
    /// </summary>
    public int? EmpIdRamo { get; set; }

    /// <summary>
    /// Foreign key - Department/Sector ID
    /// Maps to: emp_id_setor
    /// </summary>
    public int? EmpIdSetor { get; set; }

    /// <summary>
    /// Company legal name
    /// Maps to: emp_ds_razao_social
    /// </summary>
    public string EmpDsRazaoSocial { get; set; } = null!;

    /// <summary>
    /// Company trade name
    /// Maps to: emp_nm_fantasia
    /// </summary>
    public string EmpNmFantasia { get; set; } = null!;

    /// <summary>
    /// Company tax ID (CNPJ)
    /// Maps to: emp_nr_cnpj
    /// </summary>
    public string EmpNrCnpj { get; set; } = null!;

    /// <summary>
    /// Street address
    /// Maps to: emp_ds_logradouro
    /// </summary>
    public string EmpDsLogradouro { get; set; } = null!;

    /// <summary>
    /// Address number
    /// Maps to: emp_ds_numero
    /// </summary>
    public string EmpDsNumero { get; set; } = null!;

    /// <summary>
    /// Neighborhood
    /// Maps to: emp_ds_bairro
    /// </summary>
    public string EmpDsBairro { get; set; } = null!;

    /// <summary>
    /// Postal code (CEP)
    /// Maps to: emp_ds_cep
    /// </summary>
    public string EmpDsCep { get; set; } = null!;

    /// <summary>
    /// Company logo filename/path
    /// Maps to: emp_ds_logo
    /// </summary>
    public string EmpDsLogo { get; set; } = null!;

    /// <summary>
    /// Phone number
    /// Maps to: emp_ds_telefone
    /// </summary>
    public string EmpDsTelefone { get; set; } = null!;

    /// <summary>
    /// Foreign key - Responsible worker ID
    /// Maps to: emp_id_colaborador
    /// </summary>
    public int EmpIdColaborador { get; set; }

    /// <summary>
    /// Address complement
    /// Maps to: emp_ds_complemento
    /// </summary>
    public string EmpDsComplemento { get; set; } = null!;

    /// <summary>
    /// Foreign key - License ID
    /// Maps to: emp_id_licenca
    /// </summary>
    public int? EmpIdLicenca { get; set; }

    /// <summary>
    /// API token for external integrations
    /// Maps to: emp_id_token
    /// </summary>
    public string EmpIdToken { get; set; } = null!;

    // Navigation properties (will be added when related entities are implemented)
    // public virtual Colaborador Colaborador { get; set; }
    // public virtual Ramo Ramo { get; set; }
    // public virtual Setor Setor { get; set; }
    // public virtual Municipio Municipio { get; set; }
    // public virtual Licenca Licenca { get; set; }
    // public virtual ICollection<Obra> Obras { get; set; }
    // public virtual ICollection<Obra> ObrasContratante { get; set; }
    // public virtual ICollection<Obra> ObrasContratada { get; set; }
}
