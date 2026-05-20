using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RdoApp.Core.Models.Entities
{
    [Table("tarefa")]
    public class Tarefa
    {
        [Key]
        [Column("tar_id_tarefa")]
        public int Id { get; set; }

        [Column("tar_nr_agrupador")]
        public Guid Agrupador { get; set; }

        [Column("tar_id_status")]
        public int StatusId { get; set; }

        [Column("tar_id_etapa")]
        public int EtapaId { get; set; }

        [Column("tar_id_unidade")]
        public int? UnidadeId { get; set; }

        [Column("tar_ds_tarefa")]
        [StringLength(500)]
        public string? Descricao { get; set; }

        [Column("tar_nr_qtd_construida")]
        public float? QuantidadeConstruida { get; set; }

        [Column("tar_dt_inicio")]
        public DateTime DataInicio { get; set; }

        [Column("tar_dt_previsao_fim")]
        public DateTime? DataPrevisaoFim { get; set; }

        [Column("tar_dt_fim")]
        public DateTime? DataFim { get; set; }

        [Column("tar_dt_medicao")]
        public DateTime DataMedicao { get; set; }

        // REMOVED: tar_id_obra column doesn't exist in database
        // Tasks are linked to obras through etapas (tar_id_etapa -> eta_id_obra)
        // [Column("tar_id_obra")]
        // public int IdObra { get; set; }

        [Column("tar_ds_comentario")]
        [StringLength(1000)]
        public string? Comentario { get; set; }

        [Column("tar_ds_foto")]
        [StringLength(500)]
        public string? Foto { get; set; }

        [Column("tar_nr_horas_trabalhadas")]
        public int? HorasTrabalhadas { get; set; }

        [Column("tar_dt_medicao_hora_final")]
        public TimeSpan? HoraMedicaoFinal { get; set; }

        [Column("tar_dt_medicao_hora_inicial")]
        public TimeSpan? HoraMedicaoInicial { get; set; }

        [Column("tar_vl_valor_unitario")]
        public decimal? ValorUnitario { get; set; }

        [Column("tar_id_colaborador_insercao")]
        public int ColaboradorInsercaoId { get; set; }

        [Column("tar_dt_insercao")]
        public DateTime DataInsercao { get; set; }

        [Column("tar_dt_ultima_atualizacao")]
        public DateTime? DataUltimaAtualizacao { get; set; }

        [Column("tar_nr_qtd_previsao")]
        public decimal? QuantidadePrevisao { get; set; }

        [Column("tar_dt_medicao_horimetro_total")]
        public float? HorimetroTotal { get; set; }

        [Column("tar_codigo_paralizacao")]
        [StringLength(50)]
        public string? CodigoParalizacao { get; set; }

        [Column("tar_dt_medicao_horimetro_inicial")]
        public float? HorimetroInicial { get; set; }

        [Column("tar_dt_medicao_horimetro_final")]
        public float? HorimetroFinal { get; set; }

        // Water Quality Fields - Pool Management (8 fields)
        [Column("tar_nr_nivel_cloro")]
        public int? NivelCloro { get; set; }

        [Column("tar_nr_ph")]
        public int? Ph { get; set; }

        [Column("tar_nr_alcalinidade")]
        public int? Alcalinidade { get; set; }

        [Column("tar_nr_limpidez")]
        public bool? Limpidez { get; set; }

        [Column("tar_nr_superficie")]
        public bool? Superficie { get; set; }

        [Column("tar_nr_fundo")]
        public bool? Fundo { get; set; }

        [Column("tar_nr_nivel_detritos")]
        public bool? NivelDetritos { get; set; }

        [Column("tar_nr_nivel_proliferacao")]
        public bool? NivelProliferacao { get; set; }

        // Navigation properties
        public virtual StatusTarefa? Status { get; set; }
        public virtual Etapa? Etapa { get; set; }
        public virtual Colaborador? ColaboradorInsercao { get; set; }
        public virtual ICollection<RdoTarefa>? RdoTarefas { get; set; } = new HashSet<RdoTarefa>();
    }
}

