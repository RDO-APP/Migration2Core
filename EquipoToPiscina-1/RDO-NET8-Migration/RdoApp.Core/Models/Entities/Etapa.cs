using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RdoApp.Core.Models.Entities
{
    [Table("etapa")]
    public class Etapa
    {
        [Key]
        [Column("eta_id_etapa")]
        public int Id { get; set; }

        [Column("eta_id_obra")]
        public int ObraId { get; set; }

        [Column("eta_ds_etapa")]
        [StringLength(200)]
        public string? Descricao { get; set; }

        // Relacionamentos
        public virtual Obra? Obra { get; set; }
        public virtual ICollection<Tarefa> Tarefas { get; set; } = new HashSet<Tarefa>();
    }
}