namespace RdoApp.Core.Data.Entities;

/// <summary>
/// ObraColaborador (Project-Worker Assignment) entity - Assigns workers to projects
/// Maps to legacy 'obra_colaborador' table
/// </summary>
public class ObraColaborador
{
    public ObraColaborador()
    {
        // Navigation properties will be added when related entities are fully implemented
        // AcidenteColaboradores = new HashSet<AcidenteColaborador>();
        // AssinaturaRdos = new HashSet<AssinaturaRdo>();
        // Efetivos = new HashSet<Efetivo>();
        // HistoricoTarefaColaboradores = new HashSet<HistoricoTarefaColaborador>();
        // ObraTarefaColaboradores = new HashSet<ObraTarefaColaborador>();
    }

    /// <summary>
    /// Primary key - Project-Worker assignment ID
    /// Maps to: oco_id_obra_colaborador
    /// </summary>
    public int OcoIdObraColaborador { get; set; }

    /// <summary>
    /// Foreign key - Project ID
    /// Maps to: oco_id_obra
    /// </summary>
    public int OcoIdObra { get; set; }

    /// <summary>
    /// Foreign key - Worker ID
    /// Maps to: oco_id_colaborador
    /// </summary>
    public int OcoIdColaborador { get; set; }

    /// <summary>
    /// Foreign key - Position/Role ID
    /// Maps to: oco_id_cargo
    /// </summary>
    public int OcoIdCargo { get; set; }

    /// <summary>
    /// Foreign key - Group ID (security/RBAC)
    /// Maps to: oco_id_grupo
    /// </summary>
    public int OcoIdGrupo { get; set; }

    /// <summary>
    /// Hiring date
    /// Maps to: oco_dt_contratacao
    /// </summary>
    public DateTime? OcoDtContratacao { get; set; }

    /// <summary>
    /// Contractor/Contracted status
    /// Maps to: oco_st_contratante_contratada
    /// </summary>
    public string OcoStContratanteContratada { get; set; } = null!;

    // Navigation properties (will be added when related entities are implemented)
    // public virtual Cargo Cargo { get; set; }
    // public virtual Colaborador Colaborador { get; set; }
    // public virtual Grupo Grupo { get; set; }
    // public virtual Obra Obra { get; set; }
    // public virtual ICollection<AcidenteColaborador> AcidenteColaboradores { get; set; }
    // public virtual ICollection<AssinaturaRdo> AssinaturaRdos { get; set; }
    // public virtual ICollection<Efetivo> Efetivos { get; set; }
    // public virtual ICollection<HistoricoTarefaColaborador> HistoricoTarefaColaboradores { get; set; }
    // public virtual ICollection<ObraTarefaColaborador> ObraTarefaColaboradores { get; set; }
}
