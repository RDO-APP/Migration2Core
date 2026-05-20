using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RdoApp.Core.Models.Entities
{
    [Table("rdo_tarefa")]
    public class RdoTarefa
    {
        [Key]
        [Column("rdt_id_rdo_tarefa")]
        public int Id { get; set; }
        
        [Column("rdt_id_rdo")]
        public int RdoId { get; set; }
        
        [Column("rdt_id_tarefa")]
        public int TarefaId { get; set; }
        
        [Column("rdt_dt_inicio")]
        public DateTime? DataInicio { get; set; }
        
        [Column("rdt_dt_fim")]
        public DateTime? DataFim { get; set; }
        
        [Column("rdt_ds_observacao")]
        public string? Observacao { get; set; }
        
        // Navigation Properties
        public virtual Rdo? Rdo { get; set; }
        public virtual Tarefa? Tarefa { get; set; }
    }
}