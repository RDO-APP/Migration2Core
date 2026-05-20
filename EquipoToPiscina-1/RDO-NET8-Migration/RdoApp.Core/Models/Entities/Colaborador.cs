using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RdoApp.Core.Models.Entities
{
    [Table("colaborador")]
    public class Colaborador
    {
        [Key]
        [Column("col_id_colaborador")]
        public int Id { get; set; }

        [Column("col_id_municipio")]
        public int? MunicipioId { get; set; }

        [Column("col_nr_cpf")]
        [StringLength(14)]
        public string? Cpf { get; set; }

        [Column("col_nm_colaborador")]
        [StringLength(255)]
        public string? Nome { get; set; }

        [Column("col_ds_email")]
        [StringLength(255)]
        public string? Email { get; set; }

        [Column("col_ds_telefone_principal")]
        [StringLength(20)]
        public string? Telefone { get; set; }

        [Column("col_ds_telefone_secundario")]
        [StringLength(20)]
        public string? TelefoneSecundario { get; set; }

        [Column("col_ds_foto")]
        [StringLength(500)]
        public string? Foto { get; set; }

        [Column("col_ds_assinatura")]
        [StringLength(500)]
        public string? Assinatura { get; set; }

        [Column("col_ds_senha")]
        [StringLength(255)]
        public string? Senha { get; set; }

        [Column("col_ds_logradouro")]
        [StringLength(255)]
        public string? Logradouro { get; set; }

        [Column("col_ds_bairro")]
        [StringLength(100)]
        public string? Bairro { get; set; }

        [Column("col_ds_numero")]
        [StringLength(20)]
        public string? Numero { get; set; }

        [Column("col_dt_nascimento")]
        public DateTime? DataNascimento { get; set; }

        [Column("col_ds_crea")]
        [StringLength(50)]
        public string? Crea { get; set; }

        [Column("col_ds_login")]
        [StringLength(100)]
        public string? Login { get; set; }

        [Column("col_ds_sexo")]
        [StringLength(1)]
        public string? Sexo { get; set; }

        [Column("col_ds_cep")]
        [StringLength(10)]
        public string? Cep { get; set; }

        [Column("col_ds_complemento")]
        [StringLength(100)]
        public string? Complemento { get; set; }

        [Column("col_st_admin")]
        public bool? Ativo { get; set; }

        // Navigation Properties
        public virtual Municipio? Municipio { get; set; }
        public virtual ICollection<Empresa> Empresas { get; set; } = new HashSet<Empresa>();
        public virtual ICollection<ObraColaborador> ObraColaboradores { get; set; } = new HashSet<ObraColaborador>();
        public virtual ICollection<Obra> Obras { get; set; } = new HashSet<Obra>();
        public virtual ICollection<Rdo> Rdos { get; set; } = new HashSet<Rdo>();
        public virtual ICollection<Tarefa> TarefasInseridas { get; set; } = new HashSet<Tarefa>();
    }
}