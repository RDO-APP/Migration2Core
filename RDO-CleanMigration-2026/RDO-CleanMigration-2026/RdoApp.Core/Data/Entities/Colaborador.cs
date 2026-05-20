namespace RdoApp.Core.Data.Entities;

/// <summary>
/// Colaborador (Worker/Employee) entity - Personnel information
/// Maps to legacy 'colaborador' table
/// </summary>
public class Colaborador
{
    public Colaborador()
    {
        // Navigation properties will be added when related entities are fully implemented
        // Empresas = new HashSet<Empresa>();
        // ObraColaboradores = new HashSet<ObraColaborador>();
        // Obras = new HashSet<Obra>();
        // Rdos = new HashSet<Rdo>();
        // Tarefas = new HashSet<Tarefa>();
    }

    /// <summary>
    /// Primary key - Worker ID
    /// Maps to: col_id_colaborador
    /// </summary>
    public int ColIdColaborador { get; set; }

    /// <summary>
    /// Foreign key - City ID
    /// Maps to: col_id_municipio
    /// </summary>
    public int? ColIdMunicipio { get; set; }

    /// <summary>
    /// CPF (Brazilian tax ID)
    /// Maps to: col_nr_cpf
    /// </summary>
    public string ColNrCpf { get; set; } = null!;

    /// <summary>
    /// Worker full name
    /// Maps to: col_nm_colaborador
    /// </summary>
    public string ColNmColaborador { get; set; } = null!;

    /// <summary>
    /// Email address
    /// Maps to: col_ds_email
    /// </summary>
    public string? ColDsEmail { get; set; }

    /// <summary>
    /// Primary phone number
    /// Maps to: col_ds_telefone_principal
    /// </summary>
    public string? ColDsTelefonePrincipal { get; set; }

    /// <summary>
    /// Secondary phone number
    /// Maps to: col_ds_telefone_secundario
    /// </summary>
    public string? ColDsTelefoneSecundario { get; set; }

    /// <summary>
    /// Photo filename/path
    /// Maps to: col_ds_foto
    /// </summary>
    public string? ColDsFoto { get; set; }

    /// <summary>
    /// Digital signature filename/path
    /// Maps to: col_ds_assinatura
    /// </summary>
    public string? ColDsAssinatura { get; set; }

    /// <summary>
    /// Password (legacy field - will be migrated to Identity)
    /// Maps to: col_ds_senha
    /// </summary>
    public string ColDsSenha { get; set; } = null!;

    /// <summary>
    /// Street address
    /// Maps to: col_ds_logradouro
    /// </summary>
    public string? ColDsLogradouro { get; set; }

    /// <summary>
    /// Neighborhood
    /// Maps to: col_ds_bairro
    /// </summary>
    public string? ColDsBairro { get; set; }

    /// <summary>
    /// Address number
    /// Maps to: col_ds_numero
    /// </summary>
    public string? ColDsNumero { get; set; }

    /// <summary>
    /// Birth date
    /// Maps to: col_dt_nascimento
    /// </summary>
    public DateTime? ColDtNascimento { get; set; }

    /// <summary>
    /// CREA registration (engineering license)
    /// Maps to: col_ds_crea
    /// </summary>
    public string? ColDsCrea { get; set; }

    /// <summary>
    /// Login username (legacy field - will be migrated to Identity)
    /// Maps to: col_ds_login
    /// </summary>
    public string? ColDsLogin { get; set; }

    /// <summary>
    /// Gender (M/F)
    /// Maps to: col_ds_sexo
    /// </summary>
    public string? ColDsSexo { get; set; }

    /// <summary>
    /// Postal code (CEP)
    /// Maps to: col_ds_cep
    /// </summary>
    public string? ColDsCep { get; set; }

    /// <summary>
    /// Address complement
    /// Maps to: col_ds_complemento
    /// </summary>
    public string? ColDsComplemento { get; set; }

    /// <summary>
    /// Administrator flag (legacy field - will be migrated to RBAC)
    /// Maps to: col_st_admin
    /// </summary>
    public bool? ColStAdmin { get; set; }

    // Navigation properties (will be added when related entities are implemented)
    // public virtual Municipio Municipio { get; set; }
    // public virtual ICollection<Empresa> Empresas { get; set; }
    // public virtual ICollection<ObraColaborador> ObraColaboradores { get; set; }
    // public virtual ICollection<Obra> Obras { get; set; }
    // public virtual ICollection<Rdo> Rdos { get; set; }
    // public virtual ICollection<Tarefa> Tarefas { get; set; }
}
