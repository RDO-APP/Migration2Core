using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RdoApp.Core.Data.Entities;

/// <summary>
/// GrupoPaginaAcao (Group-Page-Action) - Assigns permissions to groups
/// Table: grupo_pagina_acao
/// </summary>
[Table("grupo_pagina_acao")]
public class GrupoPaginaAcao
{
    [Key]
    [Column("gpa_id_grupo_pagina_acao")]
    public int GpaIdGrupoPaginaAcao { get; set; }

    [Column("gpa_id_grupo")]
    public int GpaIdGrupo { get; set; }

    [Column("gpa_id_pagina_acao")]
    public int GpaIdPaginaAcao { get; set; }

    // Navigation properties - commented until all entities are implemented
    // public virtual Grupo? Grupo { get; set; }
    // public virtual PaginaAcao? PaginaAcao { get; set; }
}
