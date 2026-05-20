using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RdoApp.Core.Models.Entities
{
    [Table("obra")]
    public class Obra
    {
        [Key]
        [Column("obr_id_obra")]
        public int Id { get; set; }

        [Column("obr_ds_obra")]
        [StringLength(200)]
        public string? Descricao { get; set; }

        // Campos de endereço corretos (baseado na análise do Gilberto)
        [Column("obr_ds_logradouro")]
        [StringLength(255)]
        public string? Logradouro { get; set; }

        [Column("obr_ds_numero")]
        [StringLength(20)]
        public string? Numero { get; set; }

        [Column("obr_ds_bairro")]
        [StringLength(100)]
        public string? Bairro { get; set; }

        [Column("obr_ds_cep")]
        [StringLength(10)]
        public string? Cep { get; set; }

        [Column("obr_ds_complemento")]
        [StringLength(100)]
        public string? Complemento { get; set; }

        [Column("obr_dt_inicio")]
        public DateTime DataInicio { get; set; }

        [Column("obr_dt_previsao_fim")]
        public DateTime? DataPrevisaoFim { get; set; }

        [Column("obr_dt_fim")]
        public DateTime? DataFim { get; set; }

        [Column("obr_id_municipio")]
        public int MunicipioId { get; set; }

        [Column("obr_id_colaborador")]
        public int? ColaboradorId { get; set; }

        // Business Relationship Fields (3 fields)
        [Column("obr_id_empresa_contratante")]
        public int? EmpresaContratanteId { get; set; }

        [Column("obr_id_empresa_contratada")]
        public int? EmpresaContratadaId { get; set; }

        [Column("obr_id_dono")]
        public int? DonoId { get; set; }

        // Area & Measurement Fields (2 fields)
        [Column("obr_nr_area_total")]
        public int? AreaTotal { get; set; }

        [Column("obr_nr_area_total_construida")]
        public int? AreaTotalConstruida { get; set; }

        // Media & Documentation Fields (1 field)
        [Column("obr_ds_foto")]
        [StringLength(255)]
        public string? Foto { get; set; }

        // Schedule & Timeline Fields (4 fields)
        [Column("obr_dt_vencimento")]
        public DateTime? DataVencimento { get; set; }

        [Column("obr_nr_horas_semana")]
        public int? HorasSemana { get; set; }

        [Column("obr_nr_horas_sabado")]
        public int? HorasSabado { get; set; }

        [Column("obr_nr_horas_domingo")]
        public int? HorasDomingo { get; set; }

        // Legal & Administrative Fields (2 fields)
        [Column("obr_ds_art")]
        [StringLength(100)]
        public string? Art { get; set; }

        [Column("obr_cd_convite")]
        [StringLength(50)]
        public string? CodigoConvite { get; set; }

        // Relacionamentos
        public virtual Municipio Municipio { get; set; } = null!;
        public virtual ICollection<Etapa> Etapas { get; set; } = new HashSet<Etapa>();
        public virtual ICollection<Rdo> Rdos { get; set; } = new HashSet<Rdo>();
        public virtual ICollection<ObraColaborador> ObraColaboradores { get; set; } = new HashSet<ObraColaborador>();
    }
}