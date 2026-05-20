using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RdoApp.Core.Models.Entities
{
    [Table("historico_tarefa_equipamento")]
    public class HistoricoTarefaEquipamento
    {
        [Key]
        [Column("hte_id_tarefa_equipamento")]
        public int Id { get; set; }

        [Column("hte_id_historico_tarefa_rdo")]
        public int HistoricoTarefaRdoId { get; set; }

        [Column("hte_id_obra_equipamento")]
        public int ObraEquipamentoId { get; set; }

        // Navigation Properties
        public virtual HistoricoTarefaRdo HistoricoTarefaRdo { get; set; } = null!;
        public virtual ObraEquipamento ObraEquipamento { get; set; } = null!;
    }
}