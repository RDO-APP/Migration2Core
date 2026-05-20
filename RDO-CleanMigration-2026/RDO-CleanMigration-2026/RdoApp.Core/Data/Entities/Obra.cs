namespace RdoApp.Core.Data.Entities;

/// <summary>
/// Obra (Project/Work) entity - Central hub for construction projects
/// Maps to legacy 'obra' table
/// </summary>
public class Obra
{
    public Obra()
    {
        // Navigation properties will be added when related entities are fully implemented
        // Efetivos = new HashSet<Efetivo>();
        // Etapas = new HashSet<Etapa>();
        // ObraColaboradores = new HashSet<ObraColaborador>();
        // ObraEquipamentos = new HashSet<ObraEquipamento>();
        // Rdos = new HashSet<Rdo>();
        // Laudos = new HashSet<Laudo>();
    }

    /// <summary>
    /// Primary key - Project ID
    /// Maps to: obr_id_obra
    /// </summary>
    public int ObrIdObra { get; set; }

    /// <summary>
    /// Foreign key - City ID (project location)
    /// Maps to: obr_id_municipio
    /// </summary>
    public int ObrIdMunicipio { get; set; }

    /// <summary>
    /// Foreign key - Contracting company ID
    /// Maps to: obr_id_empresa_contratante
    /// </summary>
    public int? ObrIdEmpresaContratante { get; set; }

    /// <summary>
    /// Foreign key - Contracted company ID
    /// Maps to: obr_id_empresa_contratada
    /// </summary>
    public int? ObrIdEmpresaContratada { get; set; }

    /// <summary>
    /// Foreign key - Owner company ID
    /// Maps to: obr_id_dono
    /// </summary>
    public int? ObrIdDono { get; set; }

    /// <summary>
    /// Project name/description
    /// Maps to: obr_ds_obra
    /// </summary>
    public string ObrDsObra { get; set; } = null!;

    /// <summary>
    /// Total area (m²)
    /// Maps to: obr_nr_area_total
    /// </summary>
    public int? ObrNrAreaTotal { get; set; }

    /// <summary>
    /// Total built area (m²)
    /// Maps to: obr_nr_area_total_construida
    /// </summary>
    public int? ObrNrAreaTotalConstruida { get; set; }

    /// <summary>
    /// Street address
    /// Maps to: obr_ds_logradouro
    /// </summary>
    public string ObrDsLogradouro { get; set; } = null!;

    /// <summary>
    /// Address number
    /// Maps to: obr_ds_numero
    /// </summary>
    public string ObrDsNumero { get; set; } = null!;

    /// <summary>
    /// Neighborhood
    /// Maps to: obr_ds_bairro
    /// </summary>
    public string ObrDsBairro { get; set; } = null!;

    /// <summary>
    /// Postal code (CEP)
    /// Maps to: obr_ds_cep
    /// </summary>
    public string ObrDsCep { get; set; } = null!;

    /// <summary>
    /// Photo filename/path
    /// Maps to: obr_ds_foto
    /// </summary>
    public string ObrDsFoto { get; set; } = null!;

    /// <summary>
    /// Start date
    /// Maps to: obr_dt_inicio
    /// </summary>
    public DateTime ObrDtInicio { get; set; }

    /// <summary>
    /// Expected end date
    /// Maps to: obr_dt_previsao_fim
    /// </summary>
    public DateTime? ObrDtPrevisaoFim { get; set; }

    /// <summary>
    /// Actual end date
    /// Maps to: obr_dt_fim
    /// </summary>
    public DateTime? ObrDtFim { get; set; }

    /// <summary>
    /// Due date
    /// Maps to: obr_dt_vencimento
    /// </summary>
    public DateTime? ObrDtVencimento { get; set; }

    /// <summary>
    /// Working hours per week
    /// Maps to: obr_nr_horas_semana
    /// </summary>
    public int? ObrNrHorasSemana { get; set; }

    /// <summary>
    /// Working hours on Saturday
    /// Maps to: obr_nr_horas_sabado
    /// </summary>
    public int? ObrNrHorasSabado { get; set; }

    /// <summary>
    /// Working hours on Sunday
    /// Maps to: obr_nr_horas_domingo
    /// </summary>
    public int? ObrNrHorasDomingo { get; set; }

    /// <summary>
    /// Address complement
    /// Maps to: obr_ds_complemento
    /// </summary>
    public string ObrDsComplemento { get; set; } = null!;

    /// <summary>
    /// ART (Technical Responsibility Annotation)
    /// Maps to: obr_ds_art
    /// </summary>
    public string ObrDsArt { get; set; } = null!;

    /// <summary>
    /// Foreign key - Responsible worker ID
    /// Maps to: obr_id_colaborador
    /// </summary>
    public int? ObrIdColaborador { get; set; }

    /// <summary>
    /// Invitation code for worker access
    /// Maps to: obr_cd_convite
    /// </summary>
    public string ObrCdConvite { get; set; } = null!;

    // Navigation properties (will be added when related entities are implemented)
    // public virtual Colaborador Colaborador { get; set; }
    // public virtual Municipio Municipio { get; set; }
    // public virtual Empresa EmpresaDono { get; set; }
    // public virtual Empresa EmpresaContratante { get; set; }
    // public virtual Empresa EmpresaContratada { get; set; }
    // public virtual ICollection<Efetivo> Efetivos { get; set; }
    // public virtual ICollection<Etapa> Etapas { get; set; }
    // public virtual ICollection<ObraColaborador> ObraColaboradores { get; set; }
    // public virtual ICollection<ObraEquipamento> ObraEquipamentos { get; set; }
    // public virtual ICollection<Rdo> Rdos { get; set; }
    // public virtual ICollection<Laudo> Laudos { get; set; }
}
