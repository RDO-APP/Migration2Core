-- Colunas em novo_rdoapp.tarefa que NÃO existem em homol_rdoapp.tarefa.
-- DBeaver · RDS equipamentos · só leitura.
-- 31/out PDF L11 já mostrou: tar_dt_medicao_horimetro_*.
-- Pós-ALTER 11:54 este SELECT deve voltar 0 linhas.
-- Diff de TODAS as tabelas: homol-vs-prod-schema-diff.sql

SELECT p.column_name, p.column_type, p.is_nullable
FROM information_schema.columns p
WHERE p.table_schema = 'novo_rdoapp'
  AND p.table_name = 'tarefa'
  AND p.column_name NOT IN (
    SELECT h.column_name
    FROM information_schema.columns h
    WHERE h.table_schema = 'homol_rdoapp'
      AND h.table_name = 'tarefa'
  )
ORDER BY p.ordinal_position;
