using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RdoApp.Core.Data.Entities;

/// <summary>
/// Grupo (Group) - User groups with permissions and menu access
/// Table: grupo
/// </summary>
[Table("grupo")]
public class Grupo
{
    [Key]
    [Column("gru_id_grupo")]
    public int GruIdGrupo { get; set; }

    [Column("gru_nm_nome")]
    [StringLength(255)]
    public string GruNmNome { get; set; } = string.Empty;

    [Column("gru_id_menu")]
    public int GruIdMenu { get; set; }

    [Column("gru_id_licenca")]
    public int? GruIdLicenca { get; set; }

    [Column("gru_st_diretor")]
    public int? GruStDiretor { get; set; }

    [Column("gru_st_contratante")]
    public int? GruStContratante { get; set; }

    // Navigation properties - commented until all entities are implemented
    // public virtual Licenca? Licenca { get; set; }
    // public virtual Menu? Menu { get; set; }
    // public virtual ICollection<GrupoPaginaAcao> GrupoPaginaAcoes { get; set; } = new List<GrupoPaginaAcao>();
    // public virtual ICollection<ObraColaborador> ObraColaboradores { get; set; } = new List<ObraColaborador>();
    // public virtual ICollection<Usuario> Usuarios { get; set; } = new List<Usuario>();
}
