using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RdoApp.Core.Models.Entities
{
    [Table("marca")]
    public class Marca
    {
        [Key]
        [Column("mar_id_marca")]
        public int Id { get; set; }

        [Column("mar_ds_marca")]
        public string Descricao { get; set; } = string.Empty;

        [Column("mar_ds_observacao")]
        public string Observacao { get; set; } = string.Empty;
    }
}