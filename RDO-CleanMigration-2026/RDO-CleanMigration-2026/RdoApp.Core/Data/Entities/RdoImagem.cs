namespace RdoApp.Core.Data.Entities;

/// <summary>
/// RdoImagem (Daily Report Image) entity - Links images to daily reports
/// Maps to legacy 'rdo_imagem' table
/// Junction table connecting Rdo to Imagem
/// </summary>
public class RdoImagem
{
    /// <summary>
    /// Primary key - Report-Image link ID
    /// Maps to: rim_id_rdo_imagem
    /// </summary>
    public int RimIdRdoImagem { get; set; }

    /// <summary>
    /// Foreign key - Daily report ID
    /// Maps to: rim_id_rdo
    /// </summary>
    public int RimIdRdo { get; set; }

    /// <summary>
    /// Foreign key - Image ID
    /// Maps to: rim_id_imagem
    /// </summary>
    public int RimIdImagem { get; set; }

    // Navigation properties (will be added when related entities are implemented)
    // public virtual Imagem Imagem { get; set; }
    // public virtual Rdo Rdo { get; set; }
}
