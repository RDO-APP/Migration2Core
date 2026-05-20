using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RdoApp.Core.Data.Entities;

/// <summary>
/// PaginaAcao (Page-Action) - Links actions to pages
/// Table: pagina_acao
/// </summary>
[Table("pagina_acao")]
public class PaginaAcao
{
    [Key]
    [Column("paa_id_pagina_acao")]
    public int PaaIdPaginaAcao { get; set; }

    [Column("paa_id_pagina")]
    public int PaaIdPagina { get; set; }

    [Column("paa_id_acao")]
    public int PaaIdAcao { get; set; }

    // Navigation properties - commented until all entities are implemented
    // public virtual Acao? Acao { get; set; }
    // public virtual Pagina? Pagina { get; set; }
    // public virtual ICollection<GrupoPaginaAcao> GrupoPaginaAcoes { get; set; } = new List<GrupoPaginaAcao>();
}
