-- homol_rdoapp: criar 4 tabelas que existem em novo_rdoapp (prod Equipamentos)
-- Rodar no DBeaver conectado ao RDS equipamentos (usuário com DDL).
-- Não copia dados de efetivo/historico_login (homolog começa vazio).
-- Copia cadastros de efetivo_status e tarefa_codigo_paralizacao (lookup).

USE homol_rdoapp;

CREATE TABLE IF NOT EXISTS efetivo LIKE novo_rdoapp.efetivo;
CREATE TABLE IF NOT EXISTS efetivo_status LIKE novo_rdoapp.efetivo_status;
CREATE TABLE IF NOT EXISTS historico_login LIKE novo_rdoapp.historico_login;
CREATE TABLE IF NOT EXISTS tarefa_codigo_paralizacao LIKE novo_rdoapp.tarefa_codigo_paralizacao;

-- Lookups (idempotente: só insere se homolog vazio)
INSERT IGNORE INTO efetivo_status SELECT * FROM novo_rdoapp.efetivo_status;
INSERT IGNORE INTO tarefa_codigo_paralizacao SELECT * FROM novo_rdoapp.tarefa_codigo_paralizacao;

-- Conferência (esperado: 47 tabelas base alinhadas a novo_rdoapp)
SELECT COUNT(*) AS qtd_tabelas_homol
FROM information_schema.tables
WHERE table_schema = 'homol_rdoapp' AND table_type = 'BASE TABLE';
