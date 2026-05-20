# 🦫 Guia Rápido - DBeaver em Português

## 🎯 **3 Métodos para Clonar o Banco**

### **Método 1: Dump do Banco (Recomendado)**
1. **Botão direito** em `piscinas_rdoapp`
2. **"Dump do banco de dados"** (seta para cima ⬆️)
3. **Salvar arquivo** (ex: `producao.sql`)
4. **Editar arquivo**: trocar `piscinas_rdoapp` por `piscinas_rdoapp_homolog`
5. **Executar arquivo** modificado no DBeaver

### **Método 2: Script SQL Automático (Mais Fácil)**
1. **Abrir arquivo**: `clone-production-database.sql`
2. **Executar no DBeaver**
3. **Aguardar conclusão**
4. **Verificar resultado**

### **Método 3: Restaurar Banco**
1. **Criar banco vazio** primeiro:
   ```sql
   CREATE DATABASE piscinas_rdoapp_homolog;
   ```
2. **Botão direito** no banco vazio
3. **"Restaurar banco de dados"** (seta para baixo ⬇️)
4. **Escolher fonte**: `piscinas_rdoapp`

---

## 🚀 **Recomendação: Use o Método 2**

**Mais simples**: Abra `clone-production-database.sql` e execute!

### **Passos:**
1. **Abrir DBeaver**
2. **Conectar ao MySQL**
3. **Abrir arquivo**: `RDO-Homolog-Test/clone-production-database.sql`
4. **Executar script completo** (Ctrl+Enter)
5. **Aguardar mensagem**: "CÓPIA DO BANCO CONCLUÍDA COM SUCESSO!"

### **Tempo estimado**: 5-10 minutos
### **Resultado**: Banco `piscinas_rdoapp_homolog` com todos os dados de produção

---

## ✅ **Verificação**

Após executar, você deve ver:
- ✅ Banco `piscinas_rdoapp_homolog` criado
- ✅ Mesmas tabelas que produção
- ✅ Mesma quantidade de registros
- ✅ Dados reais para testar

---

## 🎯 **Próximo Passo**

Depois que o banco estiver pronto:
1. **Abrir Visual Studio**
2. **Abrir solução**: `RDO-Homolog-Test/solution/rdoapp.sln`
3. **Testar aplicação** com dados reais

---

**💡 Dica**: Se tiver dúvidas, use o **Método 2** (script SQL) - é o mais confiável!