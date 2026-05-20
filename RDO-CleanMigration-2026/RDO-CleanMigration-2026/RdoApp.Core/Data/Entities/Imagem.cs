using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RdoApp.Core.Data.Entities;

/// <summary>
/// Imagem (Image) - Image metadata and file paths
/// Table: imagem
/// </summary>
[Table("imagem")]
public class Imagem
{
    [Key]
    [Column("ima_id_imagem")]
    public int ImaIdImagem { get; set; }

    [Column("ima_ds_caminho")]
    [StringLength(500)]
    public string ImaDsCaminho { get; set; } = string.Empty;

    [Column("ima_id_historico_tarefa_rdo")]
    public int? ImaIdHistoricoTarefaRdo { get; set; }

    [Column("ima_id_tarefa")]
    public int ImaIdTarefa { get; set; }

    [Column("ima_dt_imagem")]
    public DateTime ImaDtImagem { get; set; }

    // Navigation properties - commented until all entities are implemented
    // public virtual Tarefa? Tarefa { get; set; }
    // public virtual ICollection<RdoImagem> RdoImagens { get; set; } = new List<RdoImagem>();
}
