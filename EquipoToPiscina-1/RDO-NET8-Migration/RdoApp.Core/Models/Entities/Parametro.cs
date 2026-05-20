using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RdoApp.Core.Models.Entities
{
    [Table("parametro")]
    public class Parametro
    {
        [Key]
        [Column("par_id_parametro")]
        public int Id { get; set; }

        [Column("par_ds_parametro")]
        public string Descricao { get; set; } = string.Empty;

        [Column("par_vl_parametro")]
        public string Valor { get; set; } = string.Empty;
    }
}