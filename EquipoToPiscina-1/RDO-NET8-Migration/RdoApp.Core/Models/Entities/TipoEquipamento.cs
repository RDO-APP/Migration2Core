using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RdoApp.Core.Models.Entities
{
    [Table("tipo_equipamento")]
    public class TipoEquipamento
    {
        [Key]
        [Column("teq_id_tipo_equipamento")]
        public int Id { get; set; }

        [Column("teq_ds_tipo_equipamento")]
        [StringLength(255)]
        public string Descricao { get; set; } = string.Empty;

        // Navigation Properties
        public virtual ICollection<Equipamento> Equipamentos { get; set; } = new HashSet<Equipamento>();
    }
}