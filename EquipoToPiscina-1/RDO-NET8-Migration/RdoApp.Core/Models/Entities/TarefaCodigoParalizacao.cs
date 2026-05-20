using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RdoApp.Core.Models.Entities
{
    [Table("tarefa_codigo_paralizacao")]
    public class TarefaCodigoParalizacao
    {
        [Key]
        [Column("tarcp_codigo_paralizacao")]
        public string CodigoParalizacao { get; set; } = string.Empty;

        [Column("tarcp_ds_paralizacao")]
        public string DescricaoParalizacao { get; set; } = string.Empty;

        // Navigation Properties removed to prevent auto-relationship detection
        // public virtual ICollection<Tarefa> Tarefas { get; set; } = new List<Tarefa>();
    }
}