-- Verificar tabelas existentes no banco antigo
SHOW TABLES LIKE '%tarefa%';
SHOW TABLES LIKE '%obra%';
SHOW TABLES LIKE '%colaborador%';
SHOW TABLES LIKE '%etapa%';
SHOW TABLES LIKE '%status%';

-- Verificar estrutura da tabela tarefa
DESCRIBE tarefa;

-- Verificar algumas tabelas relacionadas
DESCRIBE status_tarefa;
DESCRIBE etapa;
DESCRIBE colaborador;
DESCRIBE obra;