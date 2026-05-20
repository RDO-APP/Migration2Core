using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RdoApp.Core.Models.Entities
{
    [Table("acao")]
    public class Acao
    {
        [Key]
        [Column("aca_id_acao")]
        public int Id { get; set; }

        [Column("aca_ds_acao")]
        public string Descricao { get; set; } = string.Empty;

        [Column("aca_ds_alias")]
        public string Alias { get; set; } = string.Empty;

        [Column("aca_vl_ordem")]
        public int Ordem { get; set; }

        // Navigation Properties
        public virtual ICollection<PaginaAcao> PaginaAcoes { get; set; } = new List<PaginaAcao>();
    }
}