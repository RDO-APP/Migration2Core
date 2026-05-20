using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RdoApp.Core.Models.Entities
{
    [Table("acidente_colaborador")]
    public class AcidenteColaborador
    {
        [Key]
        [Column("acc_id_acidente_colaborador")]
        public int Id { get; set; }

        [Column("acc_id_acidente")]
        public int AcidenteId { get; set; }

        [Column("acc_id_obra_colaborador")]
        public int ObraColaboradorId { get; set; }

        [Column("acc_st_atastamento")] // Note: keeping original typo for compatibility
        public string Atastamento { get; set; } = string.Empty;

        // Navigation Properties
        public virtual Acidente Acidente { get; set; } = null!;
        public virtual ObraColaborador ObraColaborador { get; set; } = null!;
    }
}