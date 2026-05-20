using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RdoApp.Core.Models.Entities
{
    [Table("unidade_de_medida")]
    public class UnidadeDeMedida
    {
        [Key]
        [Column("unm_id_unidade")]
        public int Id { get; set; }

        [Column("unm_ds_unidade")]
        public string Descricao { get; set; } = string.Empty;

        [Column("unm_ds_simbolo")]
        public string Simbolo { get; set; } = string.Empty;

        // TEMPORARILY DISABLED: Navigation Properties
        // This navigation property is causing "Unknown column 't.UnidadeDeMedidaId'" error
        // We'll re-enable this after fixing the database mapping issues
        // public virtual ICollection<Tarefa> Tarefas { get; set; } = new List<Tarefa>();
    }
}