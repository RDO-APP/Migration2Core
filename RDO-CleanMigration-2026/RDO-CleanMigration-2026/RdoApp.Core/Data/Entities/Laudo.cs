namespace RdoApp.Core.Data.Entities;

/// <summary>
/// Laudo (Quality Control Report) entity - Pool water quality inspection reports
/// Maps to legacy 'laudo' table
/// </summary>
public class Laudo
{
    /// <summary>
    /// Primary key - Quality report ID
    /// Maps to: lau_id_laudo
    /// </summary>
    public int LauIdLaudo { get; set; }

    /// <summary>
    /// Foreign key - Report status ID
    /// Maps to: lau_id_status
    /// </summary>
    public int LauIdStatus { get; set; }

    /// <summary>
    /// Foreign key - Project ID
    /// Maps to: lau_id_obra
    /// </summary>
    public int LauIdObra { get; set; }

    /// <summary>
    /// Report date
    /// Maps to: lau_dt_laudo
    /// </summary>
    public DateTime LauDtLaudo { get; set; }

    /// <summary>
    /// Signature comment
    /// Maps to: lau_ds_comentario_assinatura
    /// </summary>
    public string LauDsComentarioAssinatura { get; set; } = null!;

    /// <summary>
    /// Foreign key - Worker who created the report
    /// Maps to: lau_id_colaborador
    /// </summary>
    public int? LauIdColaborador { get; set; }

    /// <summary>
    /// Report generation date
    /// Maps to: lau_dt_geracao
    /// </summary>
    public DateTime? LauDtGeracao { get; set; }

    /// <summary>
    /// Signature comment type
    /// Maps to: lau_tp_comentario_assinatura
    /// </summary>
    public string LauTpComentarioAssinatura { get; set; } = null!;

    /// <summary>
    /// Generation comment
    /// Maps to: lau_ds_comentario_geracao
    /// </summary>
    public string LauDsComentarioGeracao { get; set; } = null!;

    /// <summary>
    /// Generation comment type
    /// Maps to: lau_tp_comentario_geracao
    /// </summary>
    public string LauTpComentarioGeracao { get; set; } = null!;

    /// <summary>
    /// Chlorine level check result
    /// Maps to: lau_tp_nivel_cloro
    /// </summary>
    public bool? LauTpNivelCloro { get; set; }

    /// <summary>
    /// pH level check result
    /// Maps to: lau_tp_ph
    /// </summary>
    public bool? LauTpPh { get; set; }

    /// <summary>
    /// Water clarity check result
    /// Maps to: lau_tp_limpidez
    /// </summary>
    public bool? LauTpLimpidez { get; set; }

    /// <summary>
    /// Surface condition check result
    /// Maps to: lau_tp_superficie
    /// </summary>
    public bool? LauTpSuperficie { get; set; }

    /// <summary>
    /// Bottom condition check result
    /// Maps to: lau_tp_fundo
    /// </summary>
    public bool? LauTpFundo { get; set; }

    /// <summary>
    /// Secondary chlorine level check result
    /// Maps to: lau_tp_nivel_cloro_2
    /// </summary>
    public bool? LauTpNivelCloro2 { get; set; }

    /// <summary>
    /// Bacteria level check result
    /// Maps to: lau_tp_nivel_bacterias
    /// </summary>
    public bool? LauTpNivelBacterias { get; set; }

    /// <summary>
    /// Algae/proliferation check result
    /// Maps to: lau_tp_nivel_proliferacao
    /// </summary>
    public bool? LauTpNivelProliferacao { get; set; }

    // Navigation properties (will be added when related entities are implemented)
    // public virtual Colaborador Colaborador { get; set; }
    // public virtual Obra Obra { get; set; }
    // public virtual StatusRdo Status { get; set; }
}
