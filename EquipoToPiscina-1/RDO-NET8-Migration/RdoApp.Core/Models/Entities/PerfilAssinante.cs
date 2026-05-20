using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RdoApp.Core.Models.Entities
{
    [Table("perfil_assinante")]
    public class PerfilAssinante
    {
        [Key]
        [Column("per_id_perfil")]
        public int Id { get; set; }

        [Column("per_ds_perfil")]
        public string Descricao { get; set; } = string.Empty;

        [Column("per_nr_qtd_obras")]
        public int? QuantidadeObras { get; set; }

        [Column("per_st_acesso_dashboard")]
        public byte[] AcessoDashboard { get; set; } = new byte[0];

        [Column("per_st_assina_rdo")]
        public byte[] AssinaRdo { get; set; } = new byte[0];
    }
}