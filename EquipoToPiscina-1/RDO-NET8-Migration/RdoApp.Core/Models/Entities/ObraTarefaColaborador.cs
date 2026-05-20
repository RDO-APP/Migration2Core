using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RdoApp.Core.Models.Entities
{
    [Table("obra_tarefa_colaborador")]
    public class ObraTarefaColaborador
    {
        [Key]
        [Column("otc_id_obra_tarefa_colaborador")]
        public int Id { get; set; }

        [Column("otc_id_obra_colaborador")]
        public int ObraColaboradorId { get; set; }

        [Column("otc_id_tarefa")]
        public int TarefaId { get; set; }

        // Navigation Properties
        public virtual ObraColaborador ObraColaborador { get; set; } = null!;
        public virtual Tarefa Tarefa { get; set; } = null!;
    }
}