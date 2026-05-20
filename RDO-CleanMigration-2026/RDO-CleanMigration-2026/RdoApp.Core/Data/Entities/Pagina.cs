using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RdoApp.Core.Data.Entities;

/// <summary>
/// Pagina (Page) - Application pages/screens
/// Table: pagina
/// </summary>
[Table("pagina")]
public class Pagina
{
    [Key]
    [Column("pag_id_pagina")]
    public int PagIdPagina { get; set; }

    [Column("pag_ds_url")]
    [StringLength(500)]
    public string PagDsUrl { get; set; } = string.Empty;

    [Column("pag_nm_titulo")]
    [StringLength(255)]
    public string PagNmTitulo { get; set; } = string.Empty;

    [Column("pag_ds_alias")]
    [StringLength(255)]
    public string PagDsAlias { get; set; } = string.Empty;

    [Column("pag_st_status")]
    public int PagStStatus { get; set; }

    // Navigation properties - commented until all entities are implemented
    // public virtual ICollection<MenuPagina> MenuPaginas { get; set; } = new List<MenuPagina>();
    // public virtual ICollection<PaginaAcao> PaginaAcoes { get; set; } = new List<PaginaAcao>();
}
