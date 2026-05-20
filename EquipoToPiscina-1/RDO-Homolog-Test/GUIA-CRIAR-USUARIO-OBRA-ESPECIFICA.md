# GUIA: CRIAR USUÁRIO PARA OBRA ESPECÍFICA

## OBJETIVO
Criar um usuário dedicado à obra que você está usando para teste, acelerando o carregamento e focando nos testes.

## PASSO A PASSO

### 1️⃣ IDENTIFICAR A OBRA ATUAL
Execute no DBeaver: `identificar-obra-atual.sql`

Este script mostra:
- Qual obra o usuário atual (567.065.455-20) está usando
- Todas as obras disponíveis
- Obras com mais tarefas (melhores para teste)

### 2️⃣ ESCOLHER A OBRA
Anote o **ID da obra** que você quer usar para teste.

Exemplo:
```
ID_OBRA: 5
NOME_OBRA: Escola Municipal João Silva
```

### 3️⃣ CONFIGURAR O SCRIPT
Abra o arquivo: `criar-usuario-obra-personalizada.sql`

Altere a linha:
```sql
SET @obra_id = 1;  -- <-- ALTERAR ESTE NUMERO
```

Para:
```sql
SET @obra_id = 5;  -- <-- SEU ID ESCOLHIDO
```

### 4️⃣ EXECUTAR O SCRIPT
Execute no DBeaver: `criar-usuario-obra-personalizada.sql`

O script vai:
- ✅ Verificar se a obra existe
- ✅ Criar o colaborador
- ✅ Associar à obra específica
- ✅ Mostrar o resultado

### 5️⃣ CREDENCIAIS CRIADAS
```
CPF: 222.222.222-22 (ou 22222222222)
Senha: 1234
Nome: Teste Obra Especifica
```

## COMO TESTAR

### 1. Fazer Logout
- Sair do usuário atual (567.065.455-20)

### 2. Fazer Login
- CPF: `222.222.222-22`
- Senha: `1234`

### 3. Verificar Performance
- Deve carregar **muito mais rápido**
- Deve mostrar **apenas uma obra**
- Interface mais **responsiva**

### 4. Testar Laudo
- Entrar na obra
- Selecionar uma tarefa
- Preencher formulário de laudo
- Salvar e verificar funcionamento

## PERSONALIZAÇÃO

### Alterar Credenciais
No script `criar-usuario-obra-personalizada.sql`, modifique:

```sql
SET @cpf_usuario = '33333333333';      -- Seu CPF desejado
SET @senha_usuario = 'minhasenha';     -- Sua senha desejada
SET @nome_usuario = 'Meu Usuario';     -- Seu nome desejado
```

### Usar Obra Diferente
Altere apenas:
```sql
SET @obra_id = 10;  -- ID da obra desejada
```

## TROUBLESHOOTING

### ❌ Erro: "Obra não encontrada"
- Verificar se o ID da obra existe
- Executar `identificar-obra-atual.sql` novamente
- Escolher um ID válido da lista

### ❌ Login não funciona
- Verificar se o script executou sem erros
- Confirmar CPF sem formatação: `22222222222`
- Verificar se a associação obra_colaborador foi criada

### ❌ Não aparece nenhuma obra
- Verificar se a obra está ativa
- Verificar se a associação foi criada corretamente
- Executar a query de verificação no final do script

## VANTAGENS

✅ **Login 10x mais rápido**  
✅ **Carrega apenas uma obra**  
✅ **Ideal para desenvolvimento**  
✅ **Foco nos testes de laudo**  
✅ **Interface mais responsiva**  

## ARQUIVOS NECESSÁRIOS

1. `identificar-obra-atual.sql` - Para escolher a obra
2. `criar-usuario-obra-personalizada.sql` - Para criar o usuário
3. Este guia - Para seguir os passos

---

**Dica**: Anote o ID da obra escolhida para referência futura!

**Próximo passo**: Após criar o usuário, testar a correção do LINQ to Entities que fizemos anteriormente.