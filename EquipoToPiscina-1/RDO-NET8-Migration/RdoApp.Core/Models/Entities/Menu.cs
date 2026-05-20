using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RdoApp.Core.Models.Entities
{
    [Table("menu")]
    public class Menu
    {
        [Key]
        [Column("men_id_menu")]
        public int Id { get; set; }

        [Column("men_nm_titulo")]
        public string Titulo { get; set; } = string.Empty;

        [Column("men_ds_alias")]
        public string Alias { get; set; } = string.Empty;

        [Column("men_st_status")]
        public int Status { get; set; }

        // Navigation Properties
        public virtual ICollection<Grupo> Grupos { get; set; } = new List<Grupo>();
        public virtual ICollection<MenuPagina> MenuPaginas { get; set; } = new List<MenuPagina>();
    }
}