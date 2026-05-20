using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RdoApp.Core.Models.Entities
{
    [Table("rdo_imagem")]
    public class RdoImagem
    {
        [Key]
        [Column("rim_id_rdo_imagem")]
        public int Id { get; set; }

        [Column("rim_id_rdo")]
        public int RdoId { get; set; }

        [Column("rim_id_imagem")]
        public int ImagemId { get; set; }

        // Navigation Properties
        public virtual Rdo Rdo { get; set; } = null!;
        public virtual Imagem Imagem { get; set; } = null!;
    }
}