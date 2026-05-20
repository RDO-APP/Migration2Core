using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RdoApp.Core.Models.Entities
{
    [Table("menu_pagina")]
    public class MenuPagina
    {
        [Key]
        [Column("mpa_id_menu_pagina")]
        public int Id { get; set; }

        [Column("mpa_id_menu")]
        public int MenuId { get; set; }

        [Column("mpa_id_pagina")]
        public int PaginaId { get; set; }

        [Column("mpa_id_pagina_pai")]
        public int? PaginaPaiId { get; set; }

        [Column("mpa_vl_nivel")]
        public int Nivel { get; set; }

        [Column("mpa_vl_ordem")]
        public int Ordem { get; set; }

        [Column("mpa_ds_class")]
        public string Classe { get; set; } = string.Empty;

        // Navigation Properties
        public virtual Menu Menu { get; set; } = null!;
        public virtual Pagina Pagina { get; set; } = null!;
        
        // Self-referencing relationship for hierarchy
        public virtual MenuPagina? MenuPaginaPai { get; set; }
        public virtual ICollection<MenuPagina> MenuPaginasFilhas { get; set; } = new List<MenuPagina>();
    }
}