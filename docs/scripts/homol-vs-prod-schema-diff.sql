-- Diff de SCHEMA (não de dados) · novo_rdoapp × homol_rdoapp
-- DBeaver · RDS equipamentos · SÓ LEITURA.
-- Não ALTER, não DROP, não gravar em novo_rdoapp.
-- Rodar os 4 SELECTs; colar o grid no chat Migração.
-- Rodado 2026-11-03 ~12:20: Q1 47 delta=0 · Q2 vazio · Q4 vazio.
-- Q3: 4 varchar menores no homolog (rdo comentários; tarefa ds/comentario).
-- Esperado pós-ALTER 11:54: Q2 sem as 4 colunas de tarefa.

-- Q1 — tabela a tabela: quantas colunas em cada catálogo (delta ≠ 0 = olhar Q2)
SELECT
  COALESCE(p.table_name, h.table_name) AS tabela,
  p.n_col AS col_prod,
  h.n_col AS col_homol,
  (IFNULL(p.n_col, 0) - IFNULL(h.n_col, 0)) AS delta_colunas
FROM (
  SELECT table_name, COUNT(*) AS n_col
  FROM information_schema.columns
  WHERE table_schema = 'novo_rdoapp'
  GROUP BY table_name
) p
LEFT JOIN (
  SELECT table_name, COUNT(*) AS n_col
  FROM information_schema.columns
  WHERE table_schema = 'homol_rdoapp'
  GROUP BY table_name
) h ON h.table_name = p.table_name
UNION
SELECT
  COALESCE(p.table_name, h.table_name),
  p.n_col,
  h.n_col,
  (IFNULL(p.n_col, 0) - IFNULL(h.n_col, 0))
FROM (
  SELECT table_name, COUNT(*) AS n_col
  FROM information_schema.columns
  WHERE table_schema = 'novo_rdoapp'
  GROUP BY table_name
) p
RIGHT JOIN (
  SELECT table_name, COUNT(*) AS n_col
  FROM information_schema.columns
  WHERE table_schema = 'homol_rdoapp'
  GROUP BY table_name
) h ON h.table_name = p.table_name
ORDER BY ABS(IFNULL(col_prod, 0) - IFNULL(col_homol, 0)) DESC, tabela;

-- Q2 — coluna existe só de um lado
SELECT 'falta_no_homol' AS diff, p.table_name, p.column_name, p.column_type, p.is_nullable
FROM information_schema.columns p
WHERE p.table_schema = 'novo_rdoapp'
  AND NOT EXISTS (
    SELECT 1 FROM information_schema.columns h
    WHERE h.table_schema = 'homol_rdoapp'
      AND h.table_name = p.table_name
      AND h.column_name = p.column_name)
UNION ALL
SELECT 'falta_no_prod', h.table_name, h.column_name, h.column_type, h.is_nullable
FROM information_schema.columns h
WHERE h.table_schema = 'homol_rdoapp'
  AND NOT EXISTS (
    SELECT 1 FROM information_schema.columns p
    WHERE p.table_schema = 'novo_rdoapp'
      AND p.table_name = h.table_name
      AND p.column_name = h.column_name)
ORDER BY diff, table_name, column_name;

-- Q3 — mesmo nome, tipo / NULL / default / extra diferentes
SELECT
  p.table_name,
  p.column_name,
  p.column_type AS prod_type,
  h.column_type AS homol_type,
  p.is_nullable AS prod_null,
  h.is_nullable AS homol_null,
  p.column_default AS prod_default,
  h.column_default AS homol_default,
  p.extra AS prod_extra,
  h.extra AS homol_extra
FROM information_schema.columns p
INNER JOIN information_schema.columns h
  ON h.table_schema = 'homol_rdoapp'
 AND h.table_name = p.table_name
 AND h.column_name = p.column_name
WHERE p.table_schema = 'novo_rdoapp'
  AND (
    p.column_type <> h.column_type
    OR p.is_nullable <> h.is_nullable
    OR IFNULL(p.column_default, '') <> IFNULL(h.column_default, '')
    OR IFNULL(p.extra, '') <> IFNULL(h.extra, '')
  )
ORDER BY p.table_name, p.ordinal_position;

-- Q4 — tabelas só em um catálogo (se Q1 tiver NULL num lado)
SELECT 'so_prod' AS lado, t.table_name
FROM information_schema.tables t
WHERE t.table_schema = 'novo_rdoapp'
  AND t.table_type = 'BASE TABLE'
  AND t.table_name NOT IN (
    SELECT table_name FROM information_schema.tables
    WHERE table_schema = 'homol_rdoapp' AND table_type = 'BASE TABLE')
UNION ALL
SELECT 'so_homol', t.table_name
FROM information_schema.tables t
WHERE t.table_schema = 'homol_rdoapp'
  AND t.table_type = 'BASE TABLE'
  AND t.table_name NOT IN (
    SELECT table_name FROM information_schema.tables
    WHERE table_schema = 'novo_rdoapp' AND table_type = 'BASE TABLE')
ORDER BY lado, table_name;
