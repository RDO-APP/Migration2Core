using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RdoApp.Core.Models.Entities
{
    [Table("obra_tarefa_equipamento")]
    public class ObraTarefaEquipamento
    {
        [Key]
        [Column("ote_id_obra_tarefa_euipamento")] // Note: keeping original typo for compatibility
        public int Id { get; set; }

        [Column("ote_id_obra_equipamento")]
        public int ObraEquipamentoId { get; set; }

        [Column("ote_id_tarefa")]
        public int TarefaId { get; set; }

        // Navigation Properties
        public virtual ObraEquipamento ObraEquipamento { get; set; } = null!;
        public virtual Tarefa Tarefa { get; set; } = null!;
    }
}