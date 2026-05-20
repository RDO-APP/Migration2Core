namespace RdoApp.Core.Data.Entities;

/// <summary>
/// AssinaturaRdo (Report Signature) entity - Digital signatures for daily reports
/// Maps to legacy 'assinatura_rdo' table
/// </summary>
public class AssinaturaRdo
{
    /// <summary>
    /// Primary key - Signature ID
    /// Maps to: ass_id_assinatura
    /// </summary>
    public int AssIdAssinatura { get; set; }

    /// <summary>
    /// Foreign key - Project-Worker assignment ID (signer)
    /// Maps to: ass_id_obra_colaborador_assinante
    /// </summary>
    public int AssIdObraColaboradorAssinante { get; set; }

    /// <summary>
    /// Foreign key - Daily report ID
    /// Maps to: ass_id_rdo
    /// </summary>
    public int AssIdRdo { get; set; }

    /// <summary>
    /// IP address of signature
    /// Maps to: ass_ds_ip
    /// </summary>
    public string AssDsIp { get; set; } = null!;

    /// <summary>
    /// Signature date/time
    /// Maps to: ass_dt_assinatura
    /// </summary>
    public DateTime? AssDtAssinatura { get; set; }

    // Navigation properties (will be added when related entities are implemented)
    // public virtual ObraColaborador ObraColaborador { get; set; }
    // public virtual Rdo Rdo { get; set; }
}
