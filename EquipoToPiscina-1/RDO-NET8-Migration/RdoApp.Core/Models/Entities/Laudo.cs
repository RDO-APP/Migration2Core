using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RdoApp.Core.Models.Entities
{
    [Table("laudo")]
    public class Laudo
    {
        [Key]
        [Column("lau_id_laudo")]
        public int Id { get; set; }

        [Column("lau_id_status")]
        public int StatusId { get; set; }

        [Column("lau_id_obra")]
        public int ObraId { get; set; }

        [Column("lau_dt_laudo")]
        public DateTime DataLaudo { get; set; }

        [Column("lau_ds_comentario_assinatura")]
        [StringLength(500)]
        public string? ComentarioAssinatura { get; set; }

        [Column("lau_id_colaborador")]
        public int? ColaboradorId { get; set; }

        [Column("lau_dt_geracao")]
        public DateTime? DataGeracao { get; set; }

        [Column("lau_tp_comentario_assinatura")]
        [StringLength(1)]
        public string? TipoComentarioAssinatura { get; set; }

        [Column("lau_ds_comentario_geracao")]
        [StringLength(500)]
        public string? ComentarioGeracao { get; set; }

        [Column("lau_tp_comentario_geracao")]
        [StringLength(1)]
        public string? TipoComentarioGeracao { get; set; }

        // Water Quality Fields - Pool Management (9 fields)
        [Column("lau_tp_nivel_cloro")]
        public int? NivelCloro { get; set; }

        [Column("lau_tp_ph")]
        public int? Ph { get; set; }

        [Column("lau_tp_alcalinidade")]
        public int? Alcalinidade { get; set; }

        [Column("lau_tp_limpidez")]
        public bool? Limpidez { get; set; }

        [Column("lau_tp_superficie")]
        public bool? Superficie { get; set; }

        [Column("lau_tp_fundo")]
        public bool? Fundo { get; set; }

        [Column("lau_tp_nivel_cloro_2")]
        public bool? NivelCloro2 { get; set; }

        [Column("lau_tp_nivel_bacterias")]
        public bool? NivelBacterias { get; set; }

        [Column("lau_tp_nivel_proliferacao")]
        public bool? NivelProliferacao { get; set; }

        // Navigation Properties
        public virtual StatusRdo? Status { get; set; }
        public virtual Obra? Obra { get; set; }
        public virtual Colaborador? Colaborador { get; set; }
    }
}