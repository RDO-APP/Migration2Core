using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RdoApp.Core.Models.Entities
{
    [Table("empresa")]
    public class Empresa
    {
        [Key]
        [Column("emp_id_empresa")]
        public int Id { get; set; }

        [Column("emp_id_municipio")]
        public int? MunicipioId { get; set; }

        [Column("emp_id_ramo")]
        public int? RamoId { get; set; }

        [Column("emp_id_setor")]
        public int? SetorId { get; set; }

        [Column("emp_ds_razao_social")]
        [StringLength(255)]
        public string? RazaoSocial { get; set; }

        [Column("emp_nm_fantasia")]
        [StringLength(255)]
        public string? NomeFantasia { get; set; }

        [Column("emp_nr_cnpj")]
        [StringLength(18)]
        public string? Cnpj { get; set; }

        [Column("emp_ds_logradouro")]
        [StringLength(255)]
        public string? Logradouro { get; set; }

        [Column("emp_ds_numero")]
        [StringLength(20)]
        public string? Numero { get; set; }

        [Column("emp_ds_bairro")]
        [StringLength(100)]
        public string? Bairro { get; set; }

        [Column("emp_ds_cep")]
        [StringLength(10)]
        public string? Cep { get; set; }

        [Column("emp_ds_logo")]
        [StringLength(500)]
        public string? Logo { get; set; }

        [Column("emp_ds_telefone")]
        [StringLength(20)]
        public string? Telefone { get; set; }

        [Column("emp_id_colaborador")]
        public int ColaboradorId { get; set; }

        [Column("emp_ds_complemento")]
        [StringLength(100)]
        public string? Complemento { get; set; }

        [Column("emp_id_licenca")]
        public int? LicencaId { get; set; }

        [Column("emp_id_token")]
        [StringLength(255)]
        public string? Token { get; set; }

        // Navigation Properties
        public virtual Colaborador? Colaborador { get; set; }
        public virtual Municipio? Municipio { get; set; }
        public virtual Ramo? Ramo { get; set; }
        public virtual Setor? Setor { get; set; }
        public virtual Licenca? Licenca { get; set; }
        public virtual ICollection<Obra> Obras { get; set; } = new HashSet<Obra>();
    }
}