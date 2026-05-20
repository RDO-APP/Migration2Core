using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RdoApp.Core.Models.Entities
{
    [Table("historico_tarefa_rdo")]
    public class HistoricoTarefaRdo
    {
        [Key]
        [Column("his_id_historico_tarefa_rdo")]
        public int Id { get; set; }

        [Column("his_id_tarefa")]
        public int TarefaId { get; set; }

        [Column("his_id_rdo")]
        public int RdoId { get; set; }

        [Column("his_id_status")]
        public int StatusId { get; set; }

        [Column("his_dt_data")]
        public DateTime? Data { get; set; }

        [Column("his_ds_foto")]
        public string Foto { get; set; } = string.Empty;

        [Column("his_ds_comentario")]
        public string Comentario { get; set; } = string.Empty;

        [Column("his_nr_horas_trabalhadas")]
        public int HorasTrabalhadas { get; set; }

        // Navigation Properties
        public virtual ICollection<HistoricoTarefaColaborador> HistoricoTarefaColaboradores { get; set; } = new List<HistoricoTarefaColaborador>();
        public virtual ICollection<HistoricoTarefaEquipamento> HistoricoTarefaEquipamentos { get; set; } = new List<HistoricoTarefaEquipamento>();
        public virtual Tarefa Tarefa { get; set; } = null!;
        public virtual Rdo Rdo { get; set; } = null!;
        public virtual StatusTarefa StatusTarefa { get; set; } = null!;
    }
}