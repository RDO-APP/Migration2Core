using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RdoApp.Core.Models.Entities
{
    [Table("grupo")]
    public class Grupo
    {
        [Key]
        [Column("gru_id_grupo")]
        public int Id { get; set; }

        [Column("gru_nm_nome")]
        [StringLength(255)]
        public string? Nome { get; set; }

        [Column("gru_id_menu")]
        public int MenuId { get; set; }

        [Column("gru_id_licenca")]
        public int? LicencaId { get; set; }

        [Column("gru_st_diretor")]
        public int? StatusDiretor { get; set; }

        [Column("gru_st_contratante")]
        public int? StatusContratante { get; set; }

        // Navigation Properties
        public virtual Licenca? Licenca { get; set; }
        public virtual Menu? Menu { get; set; }
        public virtual ICollection<GrupoPaginaAcao> GrupoPaginaAcoes { get; set; } = new List<GrupoPaginaAcao>();
        public virtual ICollection<ObraColaborador> ObraColaboradores { get; set; } = new List<ObraColaborador>();
        public virtual ICollection<Usuario> Usuarios { get; set; } = new List<Usuario>();
    }
}