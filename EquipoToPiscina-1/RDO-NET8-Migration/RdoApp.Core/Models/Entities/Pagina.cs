using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RdoApp.Core.Models.Entities
{
    [Table("pagina")]
    public class Pagina
    {
        [Key]
        [Column("pag_id_pagina")]
        public int Id { get; set; }

        [Column("pag_ds_url")]
        public string Url { get; set; } = string.Empty;

        [Column("pag_nm_titulo")]
        public string Titulo { get; set; } = string.Empty;

        [Column("pag_ds_alias")]
        public string Alias { get; set; } = string.Empty;

        [Column("pag_st_status")]
        public int Status { get; set; }

        // Navigation Properties
        public virtual ICollection<MenuPagina> MenuPaginas { get; set; } = new List<MenuPagina>();
        public virtual ICollection<PaginaAcao> PaginaAcoes { get; set; } = new List<PaginaAcao>();
    }
}