using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RdoApp.Core.Models.Entities
{
    [Table("ramo")]
    public class Ramo
    {
        [Key]
        [Column("ram_id_ramo")]
        public int Id { get; set; }

        [Column("ram_ds_ramo")]
        public string Descricao { get; set; } = string.Empty;

        [Column("ram_id_ramo_loja")]
        public string IdRamoLoja { get; set; } = string.Empty;

        // Navigation Properties
        public virtual ICollection<Empresa> Empresas { get; set; } = new List<Empresa>();
    }
}