-- ============================================================
-- FIX: tarefa table CPU spike - missing composite indexes
-- Reported by KXC (Alex Machado / Gustavo Belloni)
-- Issue: CPUUtilization > 90% on RDO-MySQL-equipamentos
-- Root cause: query pattern
--   SELECT * FROM tarefa
--   WHERE tar_nr_agrupador = '<guid>'
--   ORDER BY tar_dt_medicao DESC LIMIT 1
-- fires in a loop with no composite index, causing filesort
-- on every call. This composite index eliminates the filesort.
-- ============================================================

-- Check current indexes first (informational)
SHOW INDEX FROM tarefa;

-- --------------------------------------------------------------
-- INDEX 1 (critical): agrupador + medicao
-- Covers the pattern:
--   WHERE tar_nr_agrupador = ? ORDER BY tar_dt_medicao DESC
-- Used by: TarefaModel.ObterProgressoTarefa,
--          TarefaModel.PreencherHistoricoTarefa,
--          EtapaModel (various list queries)
-- --------------------------------------------------------------
CREATE INDEX IX_tarefa_agrupador_medicao
    ON tarefa (tar_nr_agrupador, tar_dt_medicao);

-- --------------------------------------------------------------
-- INDEX 2 (secondary): agrupador + ultima_atualizacao
-- Covers the pattern:
--   WHERE tar_nr_agrupador = ? ORDER BY tar_dt_ultima_atualizacao DESC
-- Used by: GraficoModel subqueries (status-per-agrupador queries)
-- --------------------------------------------------------------
CREATE INDEX IX_tarefa_agrupador_ultima_atualizacao
    ON tarefa (tar_nr_agrupador, tar_dt_ultima_atualizacao);

-- Verify the new indexes were created
SHOW INDEX FROM tarefa WHERE Key_name IN (
    'IX_tarefa_agrupador_medicao',
    'IX_tarefa_agrupador_ultima_atualizacao'
);

-- Validate with EXPLAIN (replace guid with a real value from prod)
-- EXPLAIN SELECT tar_id_tarefa, tar_nr_agrupador, tar_id_status,
--   tar_dt_medicao
-- FROM tarefa
-- WHERE tar_nr_agrupador = '5537a249-d3f0-48b0-855f-24925e074939'
-- ORDER BY tar_dt_medicao DESC LIMIT 1;
-- Expected: type=ref, Extra=Using index (no "Using filesort")
