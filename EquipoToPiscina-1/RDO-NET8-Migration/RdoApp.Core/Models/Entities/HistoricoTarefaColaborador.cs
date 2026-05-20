using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RdoApp.Core.Models.Entities
{
    [Table("historico_tarefa_colaborador")]
    public class HistoricoTarefaColaborador
    {
        [Key]
        [Column("htc_id_tarefa_colaborador")]
        public int Id { get; set; }

        [Column("htc_id_historico_tarefa_rdo")]
        public int HistoricoTarefaRdoId { get; set; }

        [Column("htc_id_obra_colaborador")]
        public int ObraColaboradorId { get; set; }

        // Navigation Properties
        public virtual HistoricoTarefaRdo HistoricoTarefaRdo { get; set; } = null!;
        public virtual ObraColaborador ObraColaborador { get; set; } = null!;
    }
}