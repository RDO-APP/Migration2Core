using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RdoApp.Core.Data.Entities;

/// <summary>
/// MenuPagina (Menu-Page) - Links pages to menus with hierarchy
/// Table: menu_pagina
/// </summary>
[Table("menu_pagina")]
public class MenuPagina
{
    [Key]
    [Column("mpa_id_menu_pagina")]
    public int MpaIdMenuPagina { get; set; }

    [Column("mpa_id_menu")]
    public int MpaIdMenu { get; set; }

    [Column("mpa_id_pagina")]
    public int MpaIdPagina { get; set; }

    [Column("mpa_id_pagina_pai")]
    public int? MpaIdPaginaPai { get; set; }

    [Column("mpa_vl_nivel")]
    public int MpaVlNivel { get; set; }

    [Column("mpa_vl_ordem")]
    public int MpaVlOrdem { get; set; }

    [Column("mpa_ds_class")]
    [StringLength(255)]
    public string MpaDsClass { get; set; } = string.Empty;

    // Navigation properties - commented until all entities are implemented
    // public virtual Menu? Menu { get; set; }
    // public virtual Pagina? Pagina { get; set; }
    // public virtual MenuPagina? MenuPaginaPai { get; set; }
    // public virtual ICollection<MenuPagina> MenuPaginasFilhas { get; set; } = new List<MenuPagina>();
}
