using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RdoApp.Core.Data.Entities;

/// <summary>
/// Parametro (Parameter) - System configuration parameters
/// Table: parametro
/// </summary>
[Table("parametro")]
public class Parametro
{
    [Key]
    [Column("par_id_parametro")]
    public int ParIdParametro { get; set; }

    [Column("par_ds_parametro")]
    [StringLength(255)]
    public string ParDsParametro { get; set; } = string.Empty;

    [Column("par_vl_parametro")]
    [StringLength(500)]
    public string ParVlParametro { get; set; } = string.Empty;
}
