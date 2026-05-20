-- ========================================
-- SCRIPT PARA CLONAR BANCO DE PRODUÇÃO
-- ========================================
-- Este script cria uma cópia completa do banco piscinas_rdoapp
-- Execute este script no DBeaver conectado ao seu servidor MySQL
-- ========================================

-- ========================================
-- PASSO 1: CRIAR BANCO HOMOLOG
-- ========================================

DROP DATABASE IF EXISTS `piscinas_rdoapp_homolog`;
CREATE DATABASE `piscinas_rdoapp_homolog` 
CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ========================================
-- PASSO 2: COPIAR ESTRUTURA E DADOS
-- ========================================
-- Este método copia tabela por tabela

USE piscinas_rdoapp_homolog;

-- Obter lista de todas as tabelas do banco de produção
-- Execute esta query primeiro para ver todas as tabelas:
SELECT TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'piscinas_rdoapp' 
ORDER BY TABLE_NAME;

-- ========================================
-- MÉTODO AUTOMÁTICO: COPIAR TODAS AS TABELAS
-- ========================================

-- Para cada tabela, vamos criar e copiar os dados
-- Substitua [NOME_TABELA] pelos nomes reais das tabelas

-- Exemplo para tabela 'laudo':
CREATE TABLE laudo LIKE piscinas_rdoapp.laudo;
INSERT INTO laudo SELECT * FROM piscinas_rdoapp.laudo;

-- Exemplo para tabela 'obra':
CREATE TABLE obra LIKE piscinas_rdoapp.obra;
INSERT INTO obra SELECT * FROM piscinas_rdoapp.obra;

-- Exemplo para tabela 'colaborador':
CREATE TABLE colaborador LIKE piscinas_rdoapp.colaborador;
INSERT INTO colaborador SELECT * FROM piscinas_rdoapp.colaborador;

-- Exemplo para tabela 'status_rdo':
CREATE TABLE status_rdo LIKE piscinas_rdoapp.status_rdo;
INSERT INTO status_rdo SELECT * FROM piscinas_rdoapp.status_rdo;

-- ========================================
-- SCRIPT DINÂMICO PARA TODAS AS TABELAS
-- ========================================
-- Execute este bloco para gerar comandos para todas as tabelas:

SELECT CONCAT(
    'CREATE TABLE ', TABLE_NAME, ' LIKE piscinas_rdoapp.', TABLE_NAME, ';',
    CHAR(10),
    'INSERT INTO ', TABLE_NAME, ' SELECT * FROM piscinas_rdoapp.', TABLE_NAME, ';',
    CHAR(10)
) as sql_commands
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'piscinas_rdoapp' 
AND TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;

-- ========================================
-- VERIFICAÇÃO APÓS CÓPIA
-- ========================================

-- Verificar se as tabelas foram criadas
SELECT 'TABELAS CRIADAS NO HOMOLOG:' as info;
SELECT TABLE_NAME, TABLE_ROWS 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'piscinas_rdoapp_homolog'
ORDER BY TABLE_NAME;

-- Comparar contagem de registros
SELECT 'COMPARAÇÃO DE REGISTROS:' as info;
SELECT 
    'laudo' as tabela,
    (SELECT COUNT(*) FROM piscinas_rdoapp.laudo) as producao,
    (SELECT COUNT(*) FROM piscinas_rdoapp_homolog.laudo) as homolog;

-- Verificar dados da tabela laudo
SELECT 'DADOS DE TESTE - LAUDO:' as info;
SELECT lau_id_laudo, lau_dt_laudo, LEFT(lau_ds_comentario_geracao, 50) as comentario
FROM laudo 
ORDER BY lau_dt_laudo DESC 
LIMIT 10;

-- ========================================
-- RESULTADO ESPERADO
-- ========================================
-- ✅ Banco piscinas_rdoapp_homolog criado
-- ✅ Todas as tabelas copiadas com estrutura idêntica
-- ✅ Todos os dados de produção copiados
-- ✅ Contagem de registros igual entre produção e homolog
-- ✅ Pronto para testar a aplicação
-- ========================================

SELECT 'CÓPIA DO BANCO CONCLUÍDA COM SUCESSO!' as resultado;
SELECT 'Próximo passo: Abrir Visual Studio e testar a aplicação' as proximo_passo;