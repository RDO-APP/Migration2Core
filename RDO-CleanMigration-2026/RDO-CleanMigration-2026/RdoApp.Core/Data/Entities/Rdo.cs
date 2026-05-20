namespace RdoApp.Core.Data.Entities;

/// <summary>
/// Rdo (Daily Report) entity - Daily work reports for construction projects
/// Maps to legacy 'rdo' table
/// RDO = Relatório Diário de Obra (Daily Work Report)
/// </summary>
public class Rdo
{
    public Rdo()
    {
        // Navigation properties will be added when related entities are fully implemented
        // AssinaturaRdos = new HashSet<AssinaturaRdo>();
        // HistoricoTarefaRdos = new HashSet<HistoricoTarefaRdo>();
        // RdoImagens = new HashSet<RdoImagem>();
        // RdoTarefas = new HashSet<RdoTarefa>();
    }

    /// <summary>
    /// Primary key - Daily report ID
    /// Maps to: rdo_id_rdo
    /// </summary>
    public int RdoIdRdo { get; set; }

    /// <summary>
    /// Foreign key - Report status ID
    /// Maps to: rdo_id_status
    /// </summary>
    public int RdoIdStatus { get; set; }

    /// <summary>
    /// Foreign key - Project ID
    /// Maps to: rdo_id_obra
    /// </summary>
    public int RdoIdObra { get; set; }

    /// <summary>
    /// Report date
    /// Maps to: rdo_dt_rdo
    /// </summary>
    public DateTime RdoDtRdo { get; set; }

    /// <summary>
    /// Signature comment
    /// Maps to: rdo_ds_comentario_assinatura
    /// </summary>
    public string RdoDsComentarioAssinatura { get; set; } = null!;

    /// <summary>
    /// Morning weather description
    /// Maps to: rdo_ds_clima_manha
    /// </summary>
    public string RdoDsClimaManha { get; set; } = null!;

    /// <summary>
    /// Afternoon weather description
    /// Maps to: rdo_ds_clima_tarde
    /// </summary>
    public string RdoDsClimaTarde { get; set; } = null!;

    /// <summary>
    /// Night weather description
    /// Maps to: rdo_ds_clima_noite
    /// </summary>
    public string RdoDsClimaNoite { get; set; } = null!;

    /// <summary>
    /// Morning rain status
    /// Maps to: rdo_ds_chuva_manha
    /// </summary>
    public string RdoDsChuvaManha { get; set; } = null!;

    /// <summary>
    /// Afternoon rain status
    /// Maps to: rdo_ds_chuva_tarde
    /// </summary>
    public string RdoDsChuvaTarde { get; set; } = null!;

    /// <summary>
    /// Night rain status
    /// Maps to: rdo_ds_chuva_noite
    /// </summary>
    public string RdoDsChuvaNoite { get; set; } = null!;

    /// <summary>
    /// Foreign key - Worker who created the report
    /// Maps to: rdo_id_colaborador
    /// </summary>
    public int? RdoIdColaborador { get; set; }

    /// <summary>
    /// Foreign key - Unproductive time tracking ID
    /// Maps to: rdo_id_improdutividade
    /// </summary>
    public int RdoIdImprodutividade { get; set; }

    /// <summary>
    /// Report generation date
    /// Maps to: rdo_dt_geracao
    /// </summary>
    public DateTime? RdoDtGeracao { get; set; }

    /// <summary>
    /// Signature comment type
    /// Maps to: rdo_tp_comentario_assinatura
    /// </summary>
    public string RdoTpComentarioAssinatura { get; set; } = null!;

    /// <summary>
    /// Generation comment
    /// Maps to: rdo_ds_comentario_geracao
    /// </summary>
    public string RdoDsComentarioGeracao { get; set; } = null!;

    /// <summary>
    /// Generation comment type
    /// Maps to: rdo_tp_comentario_geracao
    /// </summary>
    public string RdoTpComentarioGeracao { get; set; } = null!;

    // Navigation properties (will be added when related entities are implemented)
    // public virtual Colaborador Colaborador { get; set; }
    // public virtual Improdutividade Improdutividade { get; set; }
    // public virtual Obra Obra { get; set; }
    // public virtual StatusRdo StatusRdo { get; set; }
    // public virtual ICollection<AssinaturaRdo> AssinaturaRdos { get; set; }
    // public virtual ICollection<HistoricoTarefaRdo> HistoricoTarefaRdos { get; set; }
    // public virtual ICollection<RdoImagem> RdoImagens { get; set; }
    // public virtual ICollection<RdoTarefa> RdoTarefas { get; set; }
}
