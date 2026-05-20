namespace RdoApp.Core.Data.Entities;

/// <summary>
/// Tarefa (Task) entity - Individual tasks within project stages
/// Maps to legacy 'tarefa' table
/// IMPORTANT: Contains water quality measurement fields for pool maintenance
/// </summary>
public class Tarefa
{
    public Tarefa()
    {
        // Navigation properties will be added when related entities are fully implemented
        // Acidentes = new HashSet<Acidente>();
        // HistoricoTarefaRdos = new HashSet<HistoricoTarefaRdo>();
        // Imagens = new HashSet<Imagem>();
        // ObraTarefaColaboradores = new HashSet<ObraTarefaColaborador>();
        // ObraTarefaEquipamentos = new HashSet<ObraTarefaEquipamento>();
        // RdoTarefas = new HashSet<RdoTarefa>();
    }

    /// <summary>
    /// Primary key - Task ID
    /// Maps to: tar_id_tarefa
    /// </summary>
    public int TarIdTarefa { get; set; }

    /// <summary>
    /// GUID for grouping related tasks
    /// Maps to: tar_nr_agrupador
    /// </summary>
    public Guid TarNrAgrupador { get; set; }

    /// <summary>
    /// Foreign key - Task status ID
    /// Maps to: tar_id_status
    /// </summary>
    public int TarIdStatus { get; set; }

    /// <summary>
    /// Foreign key - Stage ID
    /// Maps to: tar_id_etapa
    /// </summary>
    public int TarIdEtapa { get; set; }

    /// <summary>
    /// Foreign key - Unit of measurement ID
    /// Maps to: tar_id_unidade
    /// </summary>
    public int? TarIdUnidade { get; set; }

    /// <summary>
    /// Task description
    /// Maps to: tar_ds_tarefa
    /// </summary>
    public string TarDsTarefa { get; set; } = null!;

    /// <summary>
    /// Quantity built/completed
    /// Maps to: tar_nr_qtd_construida
    /// </summary>
    public float? TarNrQtdConstruida { get; set; }

    /// <summary>
    /// Start date
    /// Maps to: tar_dt_inicio
    /// </summary>
    public DateTime TarDtInicio { get; set; }

    /// <summary>
    /// Expected end date
    /// Maps to: tar_dt_previsao_fim
    /// </summary>
    public DateTime? TarDtPrevisaoFim { get; set; }

    /// <summary>
    /// Actual end date
    /// Maps to: tar_dt_fim
    /// </summary>
    public DateTime? TarDtFim { get; set; }

    /// <summary>
    /// Comments
    /// Maps to: tar_ds_comentario
    /// </summary>
    public string TarDsComentario { get; set; } = null!;

    /// <summary>
    /// Photo filename/path
    /// Maps to: tar_ds_foto
    /// </summary>
    public string TarDsFoto { get; set; } = null!;

    /// <summary>
    /// Hours worked
    /// Maps to: tar_nr_horas_trabalhadas
    /// </summary>
    public int? TarNrHorasTrabalhadas { get; set; }

    /// <summary>
    /// Measurement end time
    /// Maps to: tar_dt_medicao_hora_final
    /// </summary>
    public TimeSpan? TarDtMedicaoHoraFinal { get; set; }

    /// <summary>
    /// Measurement start time
    /// Maps to: tar_dt_medicao_hora_inicial
    /// </summary>
    public TimeSpan? TarDtMedicaoHoraInicial { get; set; }

    /// <summary>
    /// Measurement date
    /// Maps to: tar_dt_medicao
    /// </summary>
    public DateTime TarDtMedicao { get; set; }

    /// <summary>
    /// Unit value/price
    /// Maps to: tar_vl_valor_unitario
    /// </summary>
    public decimal? TarVlValorUnitario { get; set; }

    /// <summary>
    /// Foreign key - Creator worker ID
    /// Maps to: tar_id_colaborador_insercao
    /// </summary>
    public int TarIdColaboradorInsercao { get; set; }

    /// <summary>
    /// Creation date
    /// Maps to: tar_dt_insercao
    /// </summary>
    public DateTime TarDtInsercao { get; set; }

    /// <summary>
    /// Last update date
    /// Maps to: tar_dt_ultima_atualizacao
    /// </summary>
    public DateTime? TarDtUltimaAtualizacao { get; set; }

    /// <summary>
    /// Expected quantity
    /// Maps to: tar_nr_qtd_previsao
    /// </summary>
    public decimal? TarNrQtdPrevisao { get; set; }

    /// <summary>
    /// Total hour meter reading
    /// Maps to: tar_dt_medicao_horimetro_total
    /// </summary>
    public float? TarDtMedicaoHorimetroTotal { get; set; }

    /// <summary>
    /// Foreign key - Stoppage code
    /// Maps to: tar_codigo_paralizacao
    /// </summary>
    public string? TarCodigoParalizacao { get; set; }

    /// <summary>
    /// Initial hour meter reading
    /// Maps to: tar_dt_medicao_horimetro_inicial
    /// </summary>
    public float? TarDtMedicaoHorimetroInicial { get; set; }

    /// <summary>
    /// Final hour meter reading
    /// Maps to: tar_dt_medicao_horimetro_final
    /// </summary>
    public float? TarDtMedicaoHorimetroFinal { get; set; }

    // Navigation properties (will be added when related entities are implemented)
    // public virtual Colaborador Colaborador { get; set; }
    // public virtual Etapa Etapa { get; set; }
    // public virtual StatusTarefa StatusTarefa { get; set; }
    // public virtual UnidadeDeMedida UnidadeDeMedida { get; set; }
    // public virtual TarefaCodigoParalizacao TarefaCodigoParalizacao { get; set; }
    // public virtual ICollection<Acidente> Acidentes { get; set; }
    // public virtual ICollection<HistoricoTarefaRdo> HistoricoTarefaRdos { get; set; }
    // public virtual ICollection<Imagem> Imagens { get; set; }
    // public virtual ICollection<ObraTarefaColaborador> ObraTarefaColaboradores { get; set; }
    // public virtual ICollection<ObraTarefaEquipamento> ObraTarefaEquipamentos { get; set; }
    // public virtual ICollection<RdoTarefa> RdoTarefas { get; set; }
}
