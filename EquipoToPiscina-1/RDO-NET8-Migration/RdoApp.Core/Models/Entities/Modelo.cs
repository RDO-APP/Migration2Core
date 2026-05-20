using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RdoApp.Core.Models.Entities
{
    [Table("modelo")]
    public class Modelo
    {
        [Key]
        [Column("mod_id_modelo")]
        public int Id { get; set; }

        [Column("mod_ds_modelo")]
        public string Descricao { get; set; } = string.Empty;

        [Column("mod_ds_observacao")]
        public string Observacao { get; set; } = string.Empty;
    }
}