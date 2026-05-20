using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RdoApp.Core.Data.Entities;

/// <summary>
/// Menu - Application menu definitions
/// Table: menu
/// </summary>
[Table("menu")]
public class Menu
{
    [Key]
    [Column("men_id_menu")]
    public int MenIdMenu { get; set; }

    [Column("men_nm_titulo")]
    [StringLength(255)]
    public string MenNmTitulo { get; set; } = string.Empty;

    [Column("men_ds_alias")]
    [StringLength(255)]
    public string MenDsAlias { get; set; } = string.Empty;

    [Column("men_st_status")]
    public int MenStStatus { get; set; }

    // Navigation properties - commented until all entities are implemented
    // public virtual ICollection<Grupo> Grupos { get; set; } = new List<Grupo>();
    // public virtual ICollection<MenuPagina> MenuPaginas { get; set; } = new List<MenuPagina>();
}
