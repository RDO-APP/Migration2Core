using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RdoApp.Core.Models.Entities
{
    [Table("grupo_pagina_acao")]
    public class GrupoPaginaAcao
    {
        [Key]
        [Column("gpa_id_grupo_pagina_acao")]
        public int Id { get; set; }

        [Column("gpa_id_grupo")]
        public int GrupoId { get; set; }

        [Column("gpa_id_pagina_acao")]
        public int PaginaAcaoId { get; set; }

        // Navigation Properties
        public virtual Grupo Grupo { get; set; } = null!;
        public virtual PaginaAcao PaginaAcao { get; set; } = null!;
    }
}