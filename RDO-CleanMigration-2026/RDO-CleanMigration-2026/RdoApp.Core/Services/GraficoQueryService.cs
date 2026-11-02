using Microsoft.EntityFrameworkCore;
using RdoApp.Core.Data;
using RdoApp.Core.Models.Dtos;

namespace RdoApp.Core.Services;

/// <summary>M5 web #2 — SQL GraficoModel, com C1: rdo_dt_rdo BETWEEN periodoIni AND periodoFim (prod ignora ini).</summary>
public class GraficoQueryService
{
    private readonly RdoDbContext _context;

    public GraficoQueryService(RdoDbContext context)
    {
        _context = context;
    }

    public async Task<GraficoResumoDto> GetResumoAsync(
        int colaboradorId,
        DateTime periodoIni,
        DateTime periodoFim,
        CancellationToken cancellationToken)
    {
        var ini = periodoIni.ToString("yyyy-MM-dd");
        var fim = periodoFim.ToString("yyyy-MM-dd");
        var dto = new GraficoResumoDto
        {
            PeriodoIni = ini,
            PeriodoFim = fim,
            RdosAtrasados = await Query<GraficoRdoAtrasadoRow>(SqlRdoAtrasado, colaboradorId, ini, fim, cancellationToken),
            RdosGerados = await Query<GraficoRdoGeradoRow>(SqlRdoGerado, colaboradorId, ini, fim, cancellationToken),
            DiasImprodutivos = await Query<GraficoDiaImprodutivoRow>(SqlDiaImprodutivo, colaboradorId, ini, fim, cancellationToken),
            Tarefas = await Query<GraficoTarefaRow>(SqlTarefa, colaboradorId, ini, fim, cancellationToken),
            StatusTarefas = await Query<GraficoStatusTarefaRow>(SqlStatusTarefa, colaboradorId, ini, fim, cancellationToken),
            Comentarios = await Query<GraficoComentarioRow>(SqlComentario, colaboradorId, ini, fim, cancellationToken),
        };

        foreach (var row in dto.RdosAtrasados)
        {
            row.dias_atraso = Math.Abs(row.dias_atraso ?? 0);
        }

        return dto;
    }

    private async Task<List<T>> Query<T>(
        string sql,
        int colaboradorId,
        string periodoIni,
        string periodoFim,
        CancellationToken cancellationToken)
        where T : class =>
        await _context.Database.SqlQueryRaw<T>(sql, colaboradorId, periodoIni, periodoFim).ToListAsync(cancellationToken);

    private const string SqlRdoGerado = """
        SELECT o.obr_ds_obra AS obr_ds_obra,
          (SELECT count(rdo.rdo_id_rdo) FROM rdo
           INNER JOIN status_rdo ON status_rdo.str_id_status = rdo.rdo_id_status
           WHERE rdo.rdo_id_obra = o.obr_id_obra
             AND status_rdo.str_ds_status = 'GERADO'
             AND rdo.rdo_dt_rdo BETWEEN {1} AND {2}) AS gerado,
          (SELECT count(rdo.rdo_id_rdo) FROM rdo
           INNER JOIN status_rdo ON status_rdo.str_id_status = rdo.rdo_id_status
           WHERE rdo.rdo_id_obra = o.obr_id_obra
             AND status_rdo.str_ds_status = 'ASSINADO CONTRATANTE'
             AND rdo.rdo_dt_rdo BETWEEN {1} AND {2}) AS assinado_contratante,
          (SELECT count(rdo.rdo_id_rdo) FROM rdo
           INNER JOIN status_rdo ON status_rdo.str_id_status = rdo.rdo_id_status
           WHERE rdo.rdo_id_obra = o.obr_id_obra
             AND status_rdo.str_ds_status = 'ASSINADO CONTRATADA'
             AND rdo.rdo_dt_rdo BETWEEN {1} AND {2}) AS assinado_contratada,
          (datediff(o.obr_dt_previsao_fim, o.obr_dt_inicio) -
            (SELECT count(rdo.rdo_id_rdo) FROM rdo WHERE rdo.rdo_id_obra = o.obr_id_obra)) AS a_gerar
        FROM obra o
        INNER JOIN obra_colaborador oc ON o.obr_id_obra = oc.oco_id_obra
        WHERE oc.oco_id_colaborador = {0}
        """;

    private const string SqlRdoAtrasado = """
        SELECT obra.obr_ds_obra AS obr_ds_obra,
          (SELECT DATEDIFF(IFNULL(MAX(rdo.rdo_dt_rdo), {1}), {2})
           FROM rdo
           WHERE rdo.rdo_id_obra = obra.obr_id_obra
             AND rdo_dt_rdo BETWEEN {1} AND {2}) AS dias_atraso,
          (SELECT COUNT(RDO_OBRA_COLABORADOR.RDO_ID_RDO)
           FROM
             (SELECT rdo.rdo_id_rdo, obra.obr_id_obra
              FROM obra_colaborador
              INNER JOIN rdo ON rdo.rdo_id_obra = obra_colaborador.oco_id_obra
              INNER JOIN obra ON obra.obr_id_obra = obra_colaborador.oco_id_obra
                AND obra.obr_id_obra = rdo.rdo_id_obra
              WHERE rdo_dt_rdo BETWEEN {1} AND {2}
                AND obra_colaborador.oco_st_contratante_contratada = 'd') AS RDO_OBRA_COLABORADOR
           LEFT OUTER JOIN assinatura_rdo ON assinatura_rdo.ass_id_rdo = RDO_OBRA_COLABORADOR.RDO_ID_RDO
           WHERE assinatura_rdo.ass_id_rdo IS NULL
             AND RDO_OBRA_COLABORADOR.obr_id_obra = obra.obr_id_obra) AS sem_ass_contratada,
          (SELECT COUNT(RDO_OBRA_COLABORADOR.RDO_ID_RDO)
           FROM
             (SELECT rdo.rdo_id_rdo, obra.obr_id_obra
              FROM obra_colaborador
              INNER JOIN rdo ON rdo.rdo_id_obra = obra_colaborador.oco_id_obra
              INNER JOIN obra ON obra.obr_id_obra = obra_colaborador.oco_id_obra
                AND obra.obr_id_obra = rdo.rdo_id_obra
              WHERE rdo_dt_rdo BETWEEN {1} AND {2}
                AND obra_colaborador.oco_st_contratante_contratada = 't') AS RDO_OBRA_COLABORADOR
           LEFT OUTER JOIN assinatura_rdo ON assinatura_rdo.ass_id_rdo = RDO_OBRA_COLABORADOR.RDO_ID_RDO
           WHERE assinatura_rdo.ass_id_rdo IS NULL
             AND RDO_OBRA_COLABORADOR.obr_id_obra = obra.obr_id_obra) AS sem_ass_contratante
        FROM obra
        INNER JOIN obra_colaborador oc ON obra.obr_id_obra = oc.oco_id_obra
        WHERE oc.oco_id_colaborador = {0}
        """;

    private const string SqlDiaImprodutivo = """
        SELECT obra.obr_ds_obra AS obr_ds_obra,
          (SELECT count(rdo.rdo_id_rdo) FROM rdo
           INNER JOIN improdutividade ON rdo.rdo_id_improdutividade = improdutividade.imp_id_improdutividade
           WHERE improdutividade.imp_st_clima = 1 AND obra.obr_id_obra = rdo.rdo_id_obra
             AND rdo_dt_rdo BETWEEN {1} AND {2}) AS imp_clima,
          (SELECT count(rdo.rdo_id_rdo) FROM rdo
           INNER JOIN improdutividade ON rdo.rdo_id_improdutividade = improdutividade.imp_id_improdutividade
           WHERE improdutividade.imp_st_material = 1 AND obra.obr_id_obra = rdo.rdo_id_obra
             AND rdo_dt_rdo BETWEEN {1} AND {2}) AS imp_falta_material,
          (SELECT count(rdo.rdo_id_rdo) FROM rdo
           INNER JOIN improdutividade ON rdo.rdo_id_improdutividade = improdutividade.imp_id_improdutividade
           WHERE improdutividade.imp_st_paralizacao = 1 AND obra.obr_id_obra = rdo.rdo_id_obra
             AND rdo_dt_rdo BETWEEN {1} AND {2}) AS imp_paralizacao,
          (SELECT count(rdo.rdo_id_rdo) FROM rdo
           INNER JOIN improdutividade ON rdo.rdo_id_improdutividade = improdutividade.imp_id_improdutividade
           WHERE improdutividade.imp_st_acidentes = 1 AND obra.obr_id_obra = rdo.rdo_id_obra
             AND rdo_dt_rdo BETWEEN {1} AND {2}) AS imp_acidente,
          (SELECT count(rdo.rdo_id_rdo) FROM rdo
           INNER JOIN improdutividade ON rdo.rdo_id_improdutividade = improdutividade.imp_id_improdutividade
           WHERE improdutividade.imp_st_contratante = 1 AND obra.obr_id_obra = rdo.rdo_id_obra
             AND rdo_dt_rdo BETWEEN {1} AND {2}) AS imp_contratante,
          (SELECT count(rdo.rdo_id_rdo) FROM rdo
           INNER JOIN improdutividade ON rdo.rdo_id_improdutividade = improdutividade.imp_id_improdutividade
           WHERE improdutividade.imp_st_equipamento = 1 AND obra.obr_id_obra = rdo.rdo_id_obra
             AND rdo_dt_rdo BETWEEN {1} AND {2}) AS imp_equipamento,
          (SELECT count(rdo.rdo_id_rdo) FROM rdo
           INNER JOIN improdutividade ON rdo.rdo_id_improdutividade = improdutividade.imp_id_improdutividade
           WHERE improdutividade.imp_st_fornecedores = 1 AND obra.obr_id_obra = rdo.rdo_id_obra
             AND rdo_dt_rdo BETWEEN {1} AND {2}) AS imp_fornecedores,
          (SELECT count(rdo.rdo_id_rdo) FROM rdo
           INNER JOIN improdutividade ON rdo.rdo_id_improdutividade = improdutividade.imp_id_improdutividade
           WHERE improdutividade.imp_st_maodeobra = 1 AND obra.obr_id_obra = rdo.rdo_id_obra
             AND rdo_dt_rdo BETWEEN {1} AND {2}) AS imp_maodeobra,
          (SELECT count(rdo.rdo_id_rdo) FROM rdo
           INNER JOIN improdutividade ON rdo.rdo_id_improdutividade = improdutividade.imp_id_improdutividade
           WHERE improdutividade.imp_st_projeto = 1 AND obra.obr_id_obra = rdo.rdo_id_obra
             AND rdo_dt_rdo BETWEEN {1} AND {2}) AS imp_projeto,
          (SELECT count(rdo.rdo_id_rdo) FROM rdo
           INNER JOIN improdutividade ON rdo.rdo_id_improdutividade = improdutividade.imp_id_improdutividade
           WHERE improdutividade.imp_st_planejamento = 1 AND obra.obr_id_obra = rdo.rdo_id_obra
             AND rdo_dt_rdo BETWEEN {1} AND {2}) AS imp_planejamento
        FROM obra
        INNER JOIN obra_colaborador oc ON obra.obr_id_obra = oc.oco_id_obra
        WHERE oc.oco_id_colaborador = {0}
        """;

    private const string SqlTarefa = """
        WITH ultima_tarefa AS (
            SELECT t.tar_nr_agrupador, t.tar_id_status, t.tar_dt_previsao_fim, e.eta_id_obra
            FROM (
                SELECT t_inner.tar_nr_agrupador, t_inner.tar_id_status, t_inner.tar_dt_previsao_fim,
                       t_inner.tar_id_etapa,
                       ROW_NUMBER() OVER (
                           PARTITION BY t_inner.tar_nr_agrupador
                           ORDER BY t_inner.tar_dt_ultima_atualizacao DESC, t_inner.tar_id_tarefa DESC
                       ) AS rn
                FROM tarefa t_inner
            ) t
            INNER JOIN etapa e ON e.eta_id_etapa = t.tar_id_etapa
            WHERE t.rn = 1
        )
        SELECT o.obr_ds_obra AS obr_ds_obra,
          (SELECT COUNT(tabela.tar_ds_tarefa) FROM (
             SELECT e.eta_id_obra, t.tar_nr_agrupador, t.tar_ds_tarefa, MAX(t.tar_id_status) AS tar_id_status
             FROM tarefa t
             INNER JOIN etapa e ON e.eta_id_etapa = t.tar_id_etapa
             WHERE t.tar_dt_inicio <= NOW()
             GROUP BY e.eta_id_obra, t.tar_nr_agrupador, t.tar_ds_tarefa
             HAVING MAX(t.tar_id_status) = 1
           ) tabela WHERE tabela.eta_id_obra = o.obr_id_obra) AS atraso_inicio,
          SUM(CASE WHEN ut.tar_dt_previsao_fim <= NOW() AND ut.tar_id_status NOT IN (3, 5) THEN 1 ELSE 0 END) AS atraso_fim,
          SUM(CASE WHEN ut.tar_id_status = 4 THEN 1 ELSE 0 END) AS pausadas,
          SUM(CASE WHEN ut.tar_id_status = 5 THEN 1 ELSE 0 END) AS canceladas
        FROM obra o
        INNER JOIN obra_colaborador oc ON o.obr_id_obra = oc.oco_id_obra
        LEFT JOIN ultima_tarefa ut ON ut.eta_id_obra = o.obr_id_obra
        WHERE oc.oco_id_colaborador = {0}
          AND LENGTH({1}) >= 0 AND LENGTH({2}) >= 0
        GROUP BY o.obr_id_obra, o.obr_ds_obra
        """;

    private const string SqlStatusTarefa = """
        WITH ultima_tarefa AS (
            SELECT t.tar_nr_agrupador, t.tar_id_status, e.eta_id_obra
            FROM (
                SELECT t_inner.tar_nr_agrupador, t_inner.tar_id_status, t_inner.tar_id_etapa,
                       ROW_NUMBER() OVER (
                           PARTITION BY t_inner.tar_nr_agrupador
                           ORDER BY t_inner.tar_dt_ultima_atualizacao DESC, t_inner.tar_id_tarefa DESC
                       ) AS rn
                FROM tarefa t_inner
            ) t
            INNER JOIN etapa e ON e.eta_id_etapa = t.tar_id_etapa
            WHERE t.rn = 1
        )
        SELECT o.obr_ds_obra AS obr_ds_obra,
          SUM(CASE WHEN ut.tar_id_status = 1 THEN 1 ELSE 0 END) AS planejada,
          SUM(CASE WHEN ut.tar_id_status = 2 THEN 1 ELSE 0 END) AS em_execucao,
          SUM(CASE WHEN ut.tar_id_status = 3 THEN 1 ELSE 0 END) AS finalizada,
          SUM(CASE WHEN ut.tar_id_status = 4 THEN 1 ELSE 0 END) AS pausada,
          SUM(CASE WHEN ut.tar_id_status = 5 THEN 1 ELSE 0 END) AS cancelada
        FROM obra o
        INNER JOIN obra_colaborador oc ON o.obr_id_obra = oc.oco_id_obra
        LEFT JOIN ultima_tarefa ut ON ut.eta_id_obra = o.obr_id_obra
        WHERE oc.oco_id_colaborador = {0}
          AND LENGTH({1}) >= 0 AND LENGTH({2}) >= 0
        GROUP BY o.obr_id_obra, o.obr_ds_obra
        """;

    private const string SqlComentario = """
        SELECT obra.obr_ds_obra AS obr_ds_obra,
          (SELECT count(rdo.rdo_tp_comentario_geracao) FROM rdo
           WHERE rdo.rdo_id_obra = obra.obr_id_obra
             AND rdo.rdo_dt_rdo BETWEEN {1} AND {2}
             AND rdo.rdo_tp_comentario_geracao = 'P'
             AND rdo.rdo_tp_comentario_assinatura = 't') AS positivo_contratante,
          (SELECT count(rdo.rdo_tp_comentario_geracao) FROM rdo
           WHERE rdo.rdo_id_obra = obra.obr_id_obra
             AND rdo.rdo_dt_rdo BETWEEN {1} AND {2}
             AND rdo.rdo_tp_comentario_geracao = 'P'
             AND rdo.rdo_tp_comentario_assinatura = 'd') AS positivo_contratada,
          (SELECT count(rdo.rdo_tp_comentario_geracao) FROM rdo
           WHERE rdo.rdo_id_obra = obra.obr_id_obra
             AND rdo.rdo_dt_rdo BETWEEN {1} AND {2}
             AND rdo.rdo_tp_comentario_geracao = 'N'
             AND rdo.rdo_tp_comentario_assinatura = 't') AS negativo_contratante,
          (SELECT count(rdo.rdo_tp_comentario_geracao) FROM rdo
           WHERE rdo.rdo_id_obra = obra.obr_id_obra
             AND rdo.rdo_dt_rdo BETWEEN {1} AND {2}
             AND rdo.rdo_tp_comentario_geracao = 'N'
             AND rdo.rdo_tp_comentario_assinatura = 'd') AS negativo_contratada
        FROM obra
        INNER JOIN obra_colaborador oc ON obra.obr_id_obra = oc.oco_id_obra
        WHERE oc.oco_id_colaborador = {0}
        """;
}
