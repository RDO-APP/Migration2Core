using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RdoApp.Core.Models.Entities
{
    [Table("imagem")]
    public class Imagem
    {
        [Key]
        [Column("ima_id_imagem")]
        public int Id { get; set; }

        [Column("ima_ds_caminho")]
        public string Caminho { get; set; } = string.Empty;

        [Column("ima_id_historico_tarefa_rdo")]
        public int? HistoricoTarefaRdoId { get; set; }

        [Column("ima_id_tarefa")]
        public int TarefaId { get; set; }

        [Column("ima_dt_imagem")]
        public DateTime DataImagem { get; set; }

        // Navigation Properties
        public virtual Tarefa Tarefa { get; set; } = null!;
        public virtual ICollection<RdoImagem> RdoImagens { get; set; } = new List<RdoImagem>();
    }
}