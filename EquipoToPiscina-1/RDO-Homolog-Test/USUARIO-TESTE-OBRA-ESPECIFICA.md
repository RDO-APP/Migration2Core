# USUÁRIO DE TESTE PARA OBRA ESPECÍFICA

## OBJETIVO
Criar um usuário dedicado a uma obra específica para acelerar os testes e evitar o carregamento lento de todas as unidades escolares.

## PROBLEMA ATUAL
- Login com 567.065.455-20 demora muito para carregar
- Sistema tenta carregar todas as obras/unidades escolares
- Dificulta os testes rápidos da funcionalidade de laudo

## SOLUÇÃO
Criar usuário associado apenas a uma obra específica.

## CREDENCIAIS DO USUÁRIO TESTE

```
CPF: 111.111.111-11 (ou 11111111111 sem formatação)
Senha: 1234
Nome: Usuario Teste Obra
```

## COMO CRIAR O USUÁRIO

### Opção 1: DBeaver (Recomendado)
1. Abrir DBeaver
2. Conectar ao banco `piscinas_rdoapp_homologa`
3. Executar o arquivo: `create-test-user-clean.sql`

### Opção 2: MySQL Command Line
```bash
mysql -u root -p piscinas_rdoapp_homologa < create-test-user-clean.sql
```

## SCRIPT SQL (create-test-user-clean.sql)

O script faz:
1. **Lista obras disponíveis** para verificação
2. **Cria o colaborador** (se não existir)
3. **Associa à obra ID 1** (primeira obra disponível)
4. **Verifica o resultado** da criação

## VANTAGENS

✅ **Login mais rápido** - carrega apenas uma obra  
✅ **Teste focado** - trabalha com dados específicos  
✅ **Menos dados** - interface mais responsiva  
✅ **Melhor performance** - ideal para desenvolvimento  

## COMO TESTAR

### 1. Após criar o usuário:
1. Fazer logout do sistema
2. Fazer login com: `111.111.111-11` / `1234`
3. Verificar se carrega apenas uma obra
4. Navegar para a obra disponível

### 2. Testar funcionalidade de laudo:
1. Entrar na obra
2. Selecionar uma tarefa
3. Preencher formulário de laudo
4. Salvar e verificar se funciona

## VERIFICAÇÃO NO BANCO

Para verificar se o usuário foi criado corretamente:

```sql
-- Verificar colaborador criado
SELECT 
    col_id_colaborador,
    col_nm_colaborador,
    col_nr_cpf,
    col_ds_senha
FROM colaborador 
WHERE col_nr_cpf = '11111111111';

-- Verificar associação com obra
SELECT 
    c.col_nm_colaborador,
    c.col_nr_cpf,
    o.obr_nm_obra,
    oc.oco_st_contratante_contratada
FROM colaborador c
JOIN obra_colaborador oc ON c.col_id_colaborador = oc.oco_id_colaborador
JOIN obra o ON oc.oco_id_obra = o.obr_id_obra
WHERE c.col_nr_cpf = '11111111111';
```

## TROUBLESHOOTING

### Se o login não funcionar:
1. Verificar se o usuário foi criado no banco
2. Verificar se a associação obra_colaborador existe
3. Verificar se os IDs de grupo e cargo existem

### Se não aparecer nenhuma obra:
1. Verificar se a obra ID 1 existe
2. Ajustar o script para usar uma obra válida
3. Verificar se o status da obra está ativo

### Para usar obra diferente:
Editar o script e alterar a linha:
```sql
-- Trocar o número 1 pelo ID da obra desejada
oco_id_obra = 1,  -- Alterar aqui
```

## PRÓXIMOS PASSOS

1. ✅ Executar o script SQL
2. ✅ Testar login com novas credenciais  
3. ✅ Verificar carregamento rápido
4. ✅ Testar funcionalidade de laudo
5. ✅ Validar salvamento no banco

---

**Arquivo SQL**: `create-test-user-clean.sql`  
**Data**: 27/12/2024  
**Objetivo**: Acelerar testes de desenvolvimento