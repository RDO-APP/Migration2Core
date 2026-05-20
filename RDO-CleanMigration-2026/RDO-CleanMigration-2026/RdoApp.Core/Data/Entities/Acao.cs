using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RdoApp.Core.Data.Entities;

/// <summary>
/// Acao (Action) - Available actions/permissions (Create, Read, Update, Delete, etc.)
/// Table: acao
/// </summary>
[Table("acao")]
public class Acao
{
    [Key]
    [Column("aca_id_acao")]
    public int AcaIdAcao { get; set; }

    [Column("aca_ds_acao")]
    [StringLength(255)]
    public string AcaDsAcao { get; set; } = string.Empty;

    [Column("aca_ds_alias")]
    [StringLength(255)]
    public string AcaDsAlias { get; set; } = string.Empty;

    [Column("aca_vl_ordem")]
    public int AcaVlOrdem { get; set; }

    // Navigation properties - commented until all entities are implemented
    // public virtual ICollection<PaginaAcao> PaginaAcoes { get; set; } = new List<PaginaAcao>();
}
