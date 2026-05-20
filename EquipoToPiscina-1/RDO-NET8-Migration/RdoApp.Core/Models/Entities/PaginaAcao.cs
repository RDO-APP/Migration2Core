using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RdoApp.Core.Models.Entities
{
    [Table("pagina_acao")]
    public class PaginaAcao
    {
        [Key]
        [Column("paa_id_pagina_acao")]
        public int Id { get; set; }

        [Column("paa_id_pagina")]
        public int PaginaId { get; set; }

        [Column("paa_id_acao")]
        public int AcaoId { get; set; }

        // Navigation Properties
        public virtual Acao Acao { get; set; } = null!;
        public virtual Pagina Pagina { get; set; } = null!;
        public virtual ICollection<GrupoPaginaAcao> GrupoPaginaAcoes { get; set; } = new List<GrupoPaginaAcao>();
    }
}