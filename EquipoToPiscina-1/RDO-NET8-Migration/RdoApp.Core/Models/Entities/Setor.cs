using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RdoApp.Core.Models.Entities
{
    [Table("setor")]
    public class Setor
    {
        [Key]
        [Column("set_id_setor")]
        public int Id { get; set; }

        [Column("set_ds_setor")]
        public string Descricao { get; set; } = string.Empty;

        [Column("set_id_setor_loja")]
        public string IdSetorLoja { get; set; } = string.Empty;

        // Navigation Properties
        public virtual ICollection<Empresa> Empresas { get; set; } = new List<Empresa>();
    }
}