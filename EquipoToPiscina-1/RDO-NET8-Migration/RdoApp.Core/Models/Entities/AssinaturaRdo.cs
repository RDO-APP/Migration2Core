using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RdoApp.Core.Models.Entities
{
    [Table("assinatura_rdo")]
    public class AssinaturaRdo
    {
        [Key]
        [Column("ass_id_assinatura")]
        public int Id { get; set; }

        [Column("ass_id_obra_colaborador_assinante")]
        public int ObraColaboradorAssinanteId { get; set; }

        [Column("ass_id_rdo")]
        public int RdoId { get; set; }

        [Column("ass_ds_ip")]
        public string Ip { get; set; } = string.Empty;

        [Column("ass_dt_assinatura")]
        public DateTime? DataAssinatura { get; set; }

        // Navigation Properties
        public virtual ObraColaborador ObraColaborador { get; set; } = null!;
        public virtual Rdo Rdo { get; set; } = null!;
    }
}