using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RdoApp.Core.Models.Entities
{
    [Table("cargo")]
    public class Cargo
    {
        [Key]
        [Column("car_id_cargo")]
        public int Id { get; set; }

        [Column("car_ds_cargo")]
        [StringLength(255)]
        public string Descricao { get; set; } = string.Empty;

        // Navigation Properties
        public virtual ICollection<ObraColaborador> ObraColaboradores { get; set; } = new HashSet<ObraColaborador>();
    }
}