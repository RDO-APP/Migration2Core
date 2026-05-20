using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RdoApp.Core.Models.Entities
{
    [Table("licenca")]
    public class Licenca
    {
        [Key]
        [Column("lic_id_licenca")]
        public int Id { get; set; }

        [Column("lic_ds_licenca")]
        [StringLength(255)]
        public string? Descricao { get; set; }

        [Column("lic_nr_qtd_usuarios")]
        public int? QuantidadeUsuarios { get; set; }

        [Column("lic_nr_qtd_obras")]
        public int? QuantidadeObras { get; set; }

        [Column("lic_qtd_imagens_tarefas")]
        public int QuantidadeImagensTarefas { get; set; }

        [Column("lic_qtd_tarefas_obra")]
        public int QuantidadeTarefasObra { get; set; }

        [Column("lic_st_permite_logo_rdo")]
        public bool PermiteLogoRdo { get; set; }

        [Column("lic_id_licenca_loja")]
        [StringLength(50)]
        public string? LicencaLojaId { get; set; }

        // Navigation Properties
        public virtual ICollection<Empresa> Empresas { get; set; } = new HashSet<Empresa>();
        public virtual ICollection<Grupo> Grupos { get; set; } = new HashSet<Grupo>();
    }
}