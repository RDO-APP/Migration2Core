-- Cards Equipamentos — contagem CORRETA de TAREFAS vs historico de MEDICOES
--
-- **Tarefa (card na UI)** = 1 tar_nr_agrupador por etapa (TarefaModel: GroupBy agrupador).
-- **Nova medicao** = nova LINHA em `tarefa` com o MESMO agrupador — NAO e tarefa nova.
--
-- Colunas de produto:
--   tarefas_cards  = cards na tela / BFF (1 por agrupador; linha "atual" ObterEtapaTarefa)
--   registros_historico = COUNT(*) em `tarefa` (somente diagnostico; inclui medicoes)
--
-- Regra linha "atual": ORDER BY tar_id_tarefa DESC, tar_dt_medicao DESC, tar_dt_medicao_hora_final DESC
--
-- Homolog doc: obra 42 = FACHADA OESTE SHOPPING BARRA (homol_rdoapp).
-- Prod: obr_id_obra pode ser **diferente** — use Q1 para achar o id.

-- =============================================================================
-- Q0 — Comparativo homol vs prod (mesma obra_id=42 neste caso; mesmo servidor RDS)
-- Se falhar "Unknown database", rode Q3 em cada conexao (equipamentos vs rdoapp).
-- =============================================================================
WITH
homol_ranked AS (
    SELECT e.eta_id_etapa, t.tar_nr_agrupador,
        ROW_NUMBER() OVER (
            PARTITION BY e.eta_id_etapa, t.tar_nr_agrupador
            ORDER BY t.tar_id_tarefa DESC, t.tar_dt_medicao DESC,
                COALESCE(t.tar_dt_medicao_hora_final, TIME('00:00:00')) DESC
        ) AS rn
    FROM homol_rdoapp.etapa e
    INNER JOIN homol_rdoapp.tarefa t ON t.tar_id_etapa = e.eta_id_etapa
    WHERE e.eta_id_obra = 42
),
novo_ranked AS (
    SELECT e.eta_id_etapa, t.tar_nr_agrupador,
        ROW_NUMBER() OVER (
            PARTITION BY e.eta_id_etapa, t.tar_nr_agrupador
            ORDER BY t.tar_id_tarefa DESC, t.tar_dt_medicao DESC,
                COALESCE(t.tar_dt_medicao_hora_final, TIME('00:00:00')) DESC
        ) AS rn
    FROM novo_rdoapp.etapa e
    INNER JOIN novo_rdoapp.tarefa t ON t.tar_id_etapa = e.eta_id_etapa
    WHERE e.eta_id_obra = 42
)
SELECT 'homol_rdoapp' AS banco,
    42 AS obr_id_obra,
    (SELECT COUNT(*) FROM homol_rdoapp.etapa WHERE eta_id_obra = 42) AS etapas_total,
    (SELECT COUNT(*) FROM homol_ranked WHERE rn = 1) AS tarefas_cards,
    (SELECT COUNT(*) FROM homol_rdoapp.tarefa t
        INNER JOIN homol_rdoapp.etapa e ON e.eta_id_etapa = t.tar_id_etapa
        WHERE e.eta_id_obra = 42) AS registros_historico_tarefa,
    (SELECT COUNT(DISTINCT eta_id_etapa) FROM homol_ranked WHERE rn = 1) AS etapas_com_card
UNION ALL
SELECT 'novo_rdoapp',
    42,
    (SELECT COUNT(*) FROM novo_rdoapp.etapa WHERE eta_id_obra = 42),
    (SELECT COUNT(*) FROM novo_ranked WHERE rn = 1),
    (SELECT COUNT(*) FROM novo_rdoapp.tarefa t
        INNER JOIN novo_rdoapp.etapa e ON e.eta_id_etapa = t.tar_id_etapa
        WHERE e.eta_id_obra = 42),
    (SELECT COUNT(DISTINCT eta_id_etapa) FROM novo_ranked WHERE rn = 1);

-- =============================================================================
-- Q0b — Por etapa: homol vs novo (tarefas_cards; registros_historico opcional), obra 42
-- =============================================================================
WITH
homol_ranked AS (
    SELECT e.eta_nr_orderm, e.eta_id_etapa, e.eta_ds_etapa, t.tar_nr_agrupador,
        ROW_NUMBER() OVER (
            PARTITION BY e.eta_id_etapa, t.tar_nr_agrupador
            ORDER BY t.tar_id_tarefa DESC, t.tar_dt_medicao DESC,
                COALESCE(t.tar_dt_medicao_hora_final, TIME('00:00:00')) DESC
        ) AS rn
    FROM homol_rdoapp.etapa e
    INNER JOIN homol_rdoapp.tarefa t ON t.tar_id_etapa = e.eta_id_etapa
    WHERE e.eta_id_obra = 42
),
novo_ranked AS (
    SELECT e.eta_nr_orderm, e.eta_id_etapa, e.eta_ds_etapa, t.tar_nr_agrupador,
        ROW_NUMBER() OVER (
            PARTITION BY e.eta_id_etapa, t.tar_nr_agrupador
            ORDER BY t.tar_id_tarefa DESC, t.tar_dt_medicao DESC,
                COALESCE(t.tar_dt_medicao_hora_final, TIME('00:00:00')) DESC
        ) AS rn
    FROM novo_rdoapp.etapa e
    INNER JOIN novo_rdoapp.tarefa t ON t.tar_id_etapa = e.eta_id_etapa
    WHERE e.eta_id_obra = 42
),
homol_agg AS (
    SELECT eta_nr_orderm, eta_id_etapa, eta_ds_etapa,
        COUNT(DISTINCT tar_nr_agrupador) AS tarefas_cards,
        COUNT(*) AS registros_historico
    FROM homol_ranked
    GROUP BY eta_nr_orderm, eta_id_etapa, eta_ds_etapa
),
novo_agg AS (
    SELECT eta_nr_orderm, eta_id_etapa, eta_ds_etapa,
        COUNT(DISTINCT tar_nr_agrupador) AS tarefas_cards,
        COUNT(*) AS registros_historico
    FROM novo_ranked
    GROUP BY eta_nr_orderm, eta_id_etapa, eta_ds_etapa
)
SELECT
    COALESCE(h.eta_nr_orderm, n.eta_nr_orderm) AS ordem,
    COALESCE(h.eta_ds_etapa, n.eta_ds_etapa) AS etapa,
    h.tarefas_cards AS homol_tarefas,
    n.tarefas_cards AS novo_tarefas,
    h.registros_historico AS homol_registros_historico,
    n.registros_historico AS novo_registros_historico
FROM homol_agg h
LEFT JOIN novo_agg n
    ON n.eta_nr_orderm = h.eta_nr_orderm
   AND n.eta_ds_etapa = h.eta_ds_etapa
UNION ALL
SELECT
    n.eta_nr_orderm,
    n.eta_ds_etapa,
    NULL,
    n.tarefas_cards,
    NULL,
    n.registros_historico
FROM novo_agg n
LEFT JOIN homol_agg h
    ON h.eta_nr_orderm = n.eta_nr_orderm
   AND h.eta_ds_etapa = n.eta_ds_etapa
WHERE h.eta_nr_orderm IS NULL
ORDER BY ordem, etapa;

-- =============================================================================
-- Q1 — Resolver id da obra pelo nome
-- =============================================================================
SELECT
    o.obr_id_obra,
    o.obr_ds_obra
FROM obra o
WHERE o.obr_ds_obra LIKE '%FACHADA OESTE SHOPPING BARRA%'
ORDER BY o.obr_id_obra;

-- =============================================================================
-- Q2 — Definir obra (troque apos Q1)
-- Homolog tipico: SET @obra_id = 42;
-- Prod: SET @obra_id = <obr_id_obra da Q1 em novo_rdoapp>;
-- =============================================================================
SET @obra_id = 42;

SELECT DATABASE() AS db_atual, @obra_id AS obra_id;

-- =============================================================================
-- Q3 — Resumo (comparar com UI: "N etapa(s) · M tarefa(s)")
-- =============================================================================
WITH ranked AS (
    SELECT
        e.eta_id_etapa,
        t.tar_nr_agrupador,
        ROW_NUMBER() OVER (
            PARTITION BY e.eta_id_etapa, t.tar_nr_agrupador
            ORDER BY
                t.tar_id_tarefa DESC,
                t.tar_dt_medicao DESC,
                COALESCE(t.tar_dt_medicao_hora_final, TIME('00:00:00')) DESC
        ) AS rn
    FROM etapa e
    INNER JOIN tarefa t ON t.tar_id_etapa = e.eta_id_etapa
    WHERE e.eta_id_obra = @obra_id
),
cards AS (
    SELECT eta_id_etapa, tar_nr_agrupador
    FROM ranked
    WHERE rn = 1
)
SELECT
    (SELECT COUNT(*) FROM etapa WHERE eta_id_obra = @obra_id) AS etapas_total,
    (SELECT COUNT(*) FROM cards) AS tarefas_cards,
    (SELECT COUNT(*) FROM tarefa t
        INNER JOIN etapa e ON e.eta_id_etapa = t.tar_id_etapa
        WHERE e.eta_id_obra = @obra_id) AS registros_historico_tarefa,
    (SELECT COUNT(DISTINCT eta_id_etapa) FROM cards) AS etapas_com_card;

-- =============================================================================
-- Q4 — Por etapa: tarefas (agrupador) vs registros historico (medicoes)
-- =============================================================================
WITH ranked AS (
    SELECT
        e.eta_id_etapa,
        e.eta_ds_etapa,
        e.eta_nr_orderm,
        t.tar_id_tarefa,
        t.tar_nr_agrupador,
        t.tar_ds_tarefa,
        t.tar_id_status,
        ROW_NUMBER() OVER (
            PARTITION BY e.eta_id_etapa, t.tar_nr_agrupador
            ORDER BY
                t.tar_id_tarefa DESC,
                t.tar_dt_medicao DESC,
                COALESCE(t.tar_dt_medicao_hora_final, TIME('00:00:00')) DESC
        ) AS rn
    FROM etapa e
    INNER JOIN tarefa t ON t.tar_id_etapa = e.eta_id_etapa
    WHERE e.eta_id_obra = @obra_id
),
agg AS (
    SELECT
        eta_id_etapa,
        MAX(eta_ds_etapa) AS eta_ds_etapa,
        MAX(eta_nr_orderm) AS eta_nr_orderm,
        COUNT(DISTINCT tar_nr_agrupador) AS tarefas_cards,
        COUNT(*) AS registros_historico
    FROM ranked
    GROUP BY eta_id_etapa
)
SELECT
    eta_nr_orderm,
    eta_id_etapa,
    eta_ds_etapa,
    tarefas_cards,
    registros_historico
FROM agg
WHERE tarefas_cards > 0
ORDER BY eta_nr_orderm, eta_id_etapa;

-- =============================================================================
-- Q5 — Lista de cards (detalhe = o que BFF / ObterEtapaTarefa deveria listar)
-- =============================================================================
WITH ranked AS (
    SELECT
        e.eta_nr_orderm,
        e.eta_id_etapa,
        e.eta_ds_etapa,
        t.tar_id_tarefa,
        t.tar_nr_agrupador,
        t.tar_ds_tarefa,
        t.tar_id_status,
        st.stt_ds_status,
        ROW_NUMBER() OVER (
            PARTITION BY e.eta_id_etapa, t.tar_nr_agrupador
            ORDER BY
                t.tar_id_tarefa DESC,
                t.tar_dt_medicao DESC,
                COALESCE(t.tar_dt_medicao_hora_final, TIME('00:00:00')) DESC
        ) AS rn
    FROM etapa e
    INNER JOIN tarefa t ON t.tar_id_etapa = e.eta_id_etapa
    LEFT JOIN status_tarefa st ON st.stt_id_status = t.tar_id_status
    WHERE e.eta_id_obra = @obra_id
)
SELECT
    eta_nr_orderm,
    eta_ds_etapa,
    tar_id_tarefa,
    tar_ds_tarefa,
    tar_id_status,
    stt_ds_status,
    tar_nr_agrupador
FROM ranked
WHERE rn = 1
ORDER BY eta_nr_orderm, stt_ds_status, tar_ds_tarefa;

-- =============================================================================
-- Q6 — Sanity: agrupadores com linhas em mais de uma etapa (raro; investigar se >0)
-- =============================================================================
SELECT
    t.tar_nr_agrupador,
    COUNT(DISTINCT t.tar_id_etapa) AS etapas_distintas,
    GROUP_CONCAT(DISTINCT t.tar_id_etapa ORDER BY t.tar_id_etapa) AS eta_ids
FROM tarefa t
INNER JOIN etapa e ON e.eta_id_etapa = t.tar_id_etapa
WHERE e.eta_id_obra = @obra_id
GROUP BY t.tar_nr_agrupador
HAVING COUNT(DISTINCT t.tar_id_etapa) > 1
LIMIT 20;
