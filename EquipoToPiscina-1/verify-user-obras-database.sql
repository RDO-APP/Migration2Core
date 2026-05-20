-- VERIFICAR SE USUÁRIO TEM OBRAS NO BANCO
-- CPF: 567.065.455-20

-- 1. Verificar se usuário existe
SELECT 'USUÁRIO ENCONTRADO' as Status, 
       usu_id_usuario as UserId,
       usu_nm_usuario as Nome,
       usu_nr_cpf as CPF
FROM usuario 
WHERE usu_nr_cpf = '56706545520';

-- 2. Verificar colaborador associado
SELECT 'COLABORADOR ENCONTRADO' as Status,
       c.col_id_colaborador as ColaboradorId,
       c.col_nm_colaborador as Nome,
       c.col_nr_cpf as CPF
FROM colaborador c
WHERE c.col_nr_cpf = '56706545520';

-- 3. Verificar obras do colaborador
SELECT 'OBRAS DO COLABORADOR' as Status,
       oc.oco_id_obra_colaborador as ObraColaboradorId,
       oc.oco_id_obra as ObraId,
       oc.oco_id_colaborador as ColaboradorId,
       o.obr_ds_obra as ObraDescricao,
       m.mun_ds_municipio as Municipio,
       uf.ufe_ds_sigla as UF
FROM obra_colaborador oc
INNER JOIN obra o ON o.obr_id_obra = oc.oco_id_obra
INNER JOIN municipio m ON m.mun_id_municipio = o.obr_id_municipio
INNER JOIN uf ON uf.ufe_id_uf = m.mun_id_uf
INNER JOIN colaborador c ON c.col_id_colaborador = oc.oco_id_colaborador
WHERE c.col_nr_cpf = '56706545520';

-- 4. Verificar grupos do colaborador
SELECT 'GRUPOS DO COLABORADOR' as Status,
       oc.oco_id_obra_colaborador as ObraColaboradorId,
       g.gru_id_grupo as GrupoId,
       g.gru_nm_nome as GrupoNome,
       g.gru_st_contratante as StatusContratante,
       CASE 
           WHEN g.gru_st_contratante = 1 THEN 'Contratante'
           ELSE 'Contratada'
       END as TipoContrato
FROM obra_colaborador oc
INNER JOIN grupo g ON g.gru_id_grupo = oc.oco_id_grupo
INNER JOIN colaborador c ON c.col_id_colaborador = oc.oco_id_colaborador
WHERE c.col_nr_cpf = '56706545520';

-- 5. Query completa como no código
SELECT 'QUERY COMPLETA COMO NO CÓDIGO' as Status,
       o.obr_id_obra as Id,
       o.obr_ds_obra as Descricao,
       CONCAT(m.mun_ds_municipio, '/', uf.ufe_ds_sigla) as CidadeEstado,
       g.gru_nm_nome as StatusBasicaGratuita,
       CONCAT(g.gru_nm_nome, ' ', 
              CASE WHEN g.gru_st_contratante = 1 THEN 'Contratante' ELSE 'Contratada' END
       ) as ContratanteContratada,
       o.obr_dt_inicio as DataInicio,
       o.obr_dt_previsao_fim as DataPrevisaoFim
FROM obra o
INNER JOIN municipio m ON m.mun_id_municipio = o.obr_id_municipio
INNER JOIN uf ON uf.ufe_id_uf = m.mun_id_uf
INNER JOIN obra_colaborador oc ON oc.oco_id_obra = o.obr_id_obra
INNER JOIN grupo g ON g.gru_id_grupo = oc.oco_id_grupo
INNER JOIN colaborador c ON c.col_id_colaborador = oc.oco_id_colaborador
WHERE c.col_nr_cpf = '56706545520';

-- 6. Contar total de obras
SELECT 'TOTAL DE OBRAS' as Status,
       COUNT(*) as TotalObras
FROM obra o
INNER JOIN obra_colaborador oc ON oc.oco_id_obra = o.obr_id_obra
INNER JOIN colaborador c ON c.col_id_colaborador = oc.oco_id_colaborador
WHERE c.col_nr_cpf = '56706545520';