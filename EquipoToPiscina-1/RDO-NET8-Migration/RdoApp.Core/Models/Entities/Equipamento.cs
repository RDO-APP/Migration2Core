using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RdoApp.Core.Models.Entities
{
    [Table("equipamento")]
    public class Equipamento
    {
        [Key]
        [Column("equ_id_equipamento")]
        public int Id { get; set; }

        [Column("equ_ds_equipamento")]
        [StringLength(255)]
        public string Descricao { get; set; } = string.Empty;

        [Column("equ_ds_marca")]
        [StringLength(100)]
        public string? Marca { get; set; }

        [Column("equ_ds_modelo")]
        [StringLength(100)]
        public string? Modelo { get; set; }

        [Column("equ_id_tipo_equipamento")]
        public int TipoEquipamentoId { get; set; }

        [Column("equ_ds_imagem")]
        [StringLength(255)]
        public string? Imagem { get; set; }

        // Navigation Properties
        public virtual TipoEquipamento TipoEquipamento { get; set; } = null!;
        public virtual ICollection<ObraEquipamento> ObraEquipamentos { get; set; } = new HashSet<ObraEquipamento>();
    }
}