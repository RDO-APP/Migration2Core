using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RdoApp.Core.Models.Entities
{
    [Table("status_rdo")]
    public class StatusRdo
    {
        [Key]
        [Column("str_id_status")]
        public int Id { get; set; }

        [Column("str_ds_status")]
        [StringLength(100)]
        public string? Descricao { get; set; }

        // Navigation Properties
        public virtual ICollection<Laudo> Laudos { get; set; } = new HashSet<Laudo>();
    }
}