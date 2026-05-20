-- Verificar estrutura do banco homologa
USE piscinas_rdoapp_homologa;

-- Listar todas as tabelas
SHOW TABLES;

-- Verificar se tabela colaborador existe e tem dados
SELECT COUNT(*) as TotalColaboradores FROM colaborador;

-- Verificar usuário teste específico (usando nomes reais das colunas)
SELECT col_id_colaborador, col_nm_colaborador, col_nr_cpf, col_st_admin, col_ds_senha 
FROM colaborador 
WHERE col_nr_cpf LIKE '%567%' OR col_nr_cpf LIKE '%065%' OR col_nr_cpf LIKE '%455%';

-- Verificar algumas tabelas principais
SELECT COUNT(*) as TotalObras FROM obra;
SELECT COUNT(*) as TotalTarefas FROM tarefa;
SELECT COUNT(*) as TotalLaudos FROM laudo;