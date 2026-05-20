using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RdoApp.Core.Data.Entities;

/// <summary>
/// PerfilAssinante (Subscriber Profile) - Subscription plans with feature access
/// Table: perfil_assinante
/// </summary>
[Table("perfil_assinante")]
public class PerfilAssinante
{
    [Key]
    [Column("per_id_perfil")]
    public int PerIdPerfil { get; set; }

    [Column("per_ds_perfil")]
    [StringLength(255)]
    public string PerDsPerfil { get; set; } = string.Empty;

    [Column("per_nr_qtd_obras")]
    public int? PerNrQtdObras { get; set; }

    [Column("per_st_acesso_dashboard")]
    public bool? PerStAcessoDashboard { get; set; }

    [Column("per_st_assina_rdo")]
    public bool? PerStAssinaRdo { get; set; }
}
