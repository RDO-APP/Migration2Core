using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RdoApp.Core.Models.Entities
{
    [Table("status_tarefa")]
    public class StatusTarefa
    {
        [Key]
        [Column("stt_id_status")]
        public int Id { get; set; }

        [Column("stt_ds_status")]
        [StringLength(100)]
        public string? Descricao { get; set; }

        // Relacionamentos
        public virtual ICollection<Tarefa> Tarefas { get; set; } = new HashSet<Tarefa>();
    }
}