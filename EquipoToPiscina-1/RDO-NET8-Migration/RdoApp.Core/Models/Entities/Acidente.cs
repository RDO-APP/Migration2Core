using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RdoApp.Core.Models.Entities
{
    [Table("acidente")]
    public class Acidente
    {
        [Key]
        [Column("aci_id_acidente")]
        public int Id { get; set; }

        [Column("aci_id_tarefa")]
        public int TarefaId { get; set; }

        [Column("aci_ds_acidente")]
        public string Descricao { get; set; } = string.Empty;

        [Column("aci_dt_data_hora")]
        public DateTime? DataHora { get; set; }

        [Column("aci_st_afastamento")]
        public string Afastamento { get; set; } = string.Empty;

        // Navigation Properties
        public virtual Tarefa Tarefa { get; set; } = null!;
        public virtual ICollection<AcidenteColaborador> AcidenteColaboradores { get; set; } = new List<AcidenteColaborador>();
    }
}