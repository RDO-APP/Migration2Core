using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RdoApp.Core.Models.Entities
{
    [Table("obra_colaborador")]
    public class ObraColaborador
    {
        [Key]
        [Column("oco_id_obra_colaborador")]
        public int Id { get; set; }

        [Column("oco_id_obra")]
        public int ObraId { get; set; }

        [Column("oco_id_colaborador")]
        public int ColaboradorId { get; set; }

        [Column("oco_id_cargo")]
        public int CargoId { get; set; }

        [Column("oco_id_grupo")]
        public int GrupoId { get; set; }

        [Column("oco_dt_contratacao")]
        public DateTime? DataContratacao { get; set; }

        [Column("oco_st_contratante_contratada")]
        [StringLength(50)]
        public string? StatusContratanteContratada { get; set; }

        // Navigation Properties
        public virtual Obra Obra { get; set; } = null!;
        public virtual Colaborador Colaborador { get; set; } = null!;
        public virtual Cargo Cargo { get; set; } = null!;
        public virtual Grupo Grupo { get; set; } = null!;
        public virtual ICollection<ObraTarefaColaborador> ObraTarefaColaboradores { get; set; } = new HashSet<ObraTarefaColaborador>();
    }
}