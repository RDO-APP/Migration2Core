using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RdoApp.Core.Models.Entities
{
    [Table("obra_equipamento")]
    public class ObraEquipamento
    {
        [Key]
        [Column("oeq_id_obra_equipamento")]
        public int Id { get; set; }

        [Column("oeq_id_obra")]
        public int ObraId { get; set; }

        [Column("oeq_id_equipamento")]
        public int EquipamentoId { get; set; }

        [Column("oeq_tp_aquisicao")]
        [StringLength(50)]
        public string? TipoAquisicao { get; set; }

        [Column("oeq_ds_fabricante_fornecedor")]
        [StringLength(255)]
        public string? FabricanteFornecedor { get; set; }

        [Column("oeq_dt_aquisicao")]
        public DateTime? DataAquisicao { get; set; }

        [Column("oeq_ds_contato")]
        [StringLength(255)]
        public string? Contato { get; set; }

        [Column("oeq_ds_telefone")]
        [StringLength(20)]
        public string? Telefone { get; set; }

        // Navigation Properties
        public virtual Obra Obra { get; set; } = null!;
        public virtual Equipamento Equipamento { get; set; } = null!;
        public virtual ICollection<ObraTarefaEquipamento> ObraTarefaEquipamentos { get; set; } = new HashSet<ObraTarefaEquipamento>();
    }
}