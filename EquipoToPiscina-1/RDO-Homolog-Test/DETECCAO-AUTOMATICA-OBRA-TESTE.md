# DETECÇÃO AUTOMÁTICA DA OBRA DE TESTE

## OBJETIVO
Identificar automaticamente qual obra você está usando para testes e criar um usuário dedicado para acelerar o desenvolvimento.

## COMO FUNCIONA

### 🔍 **Detecção Inteligente**
O script analisa:
- ✅ **Laudos mais recentes** criados
- ✅ **Tarefas atualizadas** nos últimos 7 dias  
- ✅ **Atividade por obra** (qual tem mais movimento)
- ✅ **Colaborador mais ativo** (você)

### 🎯 **Criação Automática**
- Detecta a obra com **mais atividade de teste**
- Cria usuário **automaticamente** para essa obra
- **Zero configuração manual** necessária

## ARQUIVOS CRIADOS

### 1. `detectar-obra-teste-atual.sql`
**Análise detalhada** - mostra:
- Laudos recentes por obra
- Tarefas atualizadas recentemente  
- Obra com mais atividade
- Colaborador mais ativo
- Recomendação final

### 2. `criar-usuario-automatico-obra-teste.sql`
**Criação automática** - faz:
- Detecta obra mais usada
- Cria colaborador dedicado
- Associa à obra detectada
- Mostra resultado final

## COMO USAR

### 🚀 **Opção Rápida (Recomendada)**
```sql
-- Execute no DBeaver:
criar-usuario-automatico-obra-teste.sql
```

### 🔍 **Opção Detalhada**
```sql
-- 1. Primeiro execute para ver análise:
detectar-obra-teste-atual.sql

-- 2. Depois execute para criar usuário:
criar-usuario-automatico-obra-teste.sql
```

## CREDENCIAIS CRIADAS

```
CPF: 999.999.999-99
Senha: 1234  
Nome: Teste Rapido Obra
```

## RESULTADO ESPERADO

### ✅ **Antes (Usuário Atual)**
- Login com 567.065.455-20
- Carrega **todas as obras** (lento)
- Interface pesada
- Dificulta testes

### ✅ **Depois (Usuário Dedicado)**  
- Login com 999.999.999-99
- Carrega **apenas uma obra** (rápido)
- Interface responsiva
- Ideal para testes

## VANTAGENS DA DETECÇÃO AUTOMÁTICA

✅ **Inteligente** - encontra a obra que você realmente usa  
✅ **Automático** - zero configuração manual  
✅ **Preciso** - analisa atividade real dos últimos dias  
✅ **Rápido** - um script resolve tudo  
✅ **Seguro** - não afeta dados existentes  

## COMO TESTAR

### 1. **Executar Script**
- Abrir DBeaver
- Executar `criar-usuario-automatico-obra-teste.sql`
- Verificar mensagem de sucesso

### 2. **Fazer Login**
- Logout do usuário atual
- Login: `999.999.999-99` / `1234`
- Verificar carregamento rápido

### 3. **Testar Laudo**
- Entrar na obra detectada
- Preencher formulário de laudo
- Salvar e verificar funcionamento

## TROUBLESHOOTING

### ❌ **Nenhuma obra detectada**
- Verificar se existem laudos ou tarefas no banco
- Executar `detectar-obra-teste-atual.sql` para análise
- Usar script manual se necessário

### ❌ **Login não funciona**
- Verificar CPF sem formatação: `99999999999`
- Confirmar execução do script sem erros
- Verificar associação obra_colaborador

### ❌ **Obra errada detectada**
- Usar script manual `criar-usuario-obra-personalizada.sql`
- Especificar ID da obra desejada manualmente

## PRÓXIMOS PASSOS

1. ✅ **Executar** script de detecção automática
2. ✅ **Testar** login com novas credenciais
3. ✅ **Verificar** performance melhorada  
4. ✅ **Testar** correção do LINQ to Entities
5. ✅ **Validar** funcionalidade completa de laudo

---

**Recomendação**: Use a **detecção automática** - ela é mais inteligente e precisa que a configuração manual!

**Arquivo principal**: `criar-usuario-automatico-obra-teste.sql`