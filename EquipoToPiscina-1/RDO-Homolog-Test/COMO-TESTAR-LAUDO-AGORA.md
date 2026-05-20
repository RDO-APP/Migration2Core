# COMO TESTAR O PROBLEMA DO LAUDO - PASSO A PASSO

## SITUAÇÃO ATUAL
- ✅ Aplicação compila sem erros
- ✅ Visual Studio está rodando
- ✅ IIS Express está rodando
- ❌ Backend retorna `{success: false, message: 'Erro ao salvar laudo'}`
- ❌ Histórico mostra apenas traços (-) nos campos de laudo

## TESTE IMEDIATO - SIGA EXATAMENTE ESTES PASSOS:

### 1. ABRIR VISUAL STUDIO OUTPUT
1. No Visual Studio, vá em **View > Output**
2. Na janela Output, no dropdown "Show output from:", selecione **Debug**
3. Deixe esta janela aberta e visível

### 2. ABRIR APLICAÇÃO NO BROWSER
1. No Visual Studio, pressione **F5** (se não estiver rodando)
2. Aguarde o browser abrir
3. Se não abrir automaticamente, vá para: `http://localhost:[PORTA]`
   - Tente: `http://localhost:44301`
   - Ou: `http://localhost:5000`
   - Ou veja a porta no Visual Studio (barra inferior)

### 3. FAZER LOGIN E NAVEGAR
1. Login: **567.065.455-20** / **1234**
2. Selecione uma unidade escolar
3. Clique em uma etapa
4. Clique em uma tarefa

### 4. TESTAR SALVAMENTO DO LAUDO
1. Preencha os campos do laudo:
   - **Quantidade**: qualquer número (ex: 100)
   - **Cloro**: selecione qualquer opção
   - **PH**: selecione qualquer opção
   - **Alcalinidade**: selecione qualquer opção
   - **Limpidez**: deixe "Sim" ou mude para "Não"
   - **Materiais flutuantes**: marque algumas opções

2. Clique no botão **"Salvar Laudo"**

3. **OBSERVE SIMULTANEAMENTE**:
   - Console do browser (F12 > Console)
   - Janela Output do Visual Studio (Debug)
   - Mensagem de sucesso/erro na tela

### 5. VERIFICAR RESULTADOS

#### A) NO CONSOLE DO BROWSER (F12):
Procure por mensagens como:
```
DEBUG LAUDO - Iniciando salvamento do laudo
DEBUG LAUDO - Dados a serem salvos: {IdTarefa: 123, NivelCloro: 2, ...}
DEBUG LAUDO - Laudo salvo com sucesso: {success: true}
```
OU
```
DEBUG LAUDO - Erro ao salvar: {success: false, message: "..."}
```

#### B) NO VISUAL STUDIO OUTPUT (Debug):
Procure por mensagens como:
```
DEBUG LAUDO - Controller recebeu: IdTarefa=123, NivelCloro=2, NivelPH=3
DEBUG LAUDO - Iniciando salvamento - IdTarefa: 123
DEBUG LAUDO - NivelCloro: 2, NivelPH: 3, NivelAlcalinidade: 4, Limpidez: sim
DEBUG LAUDO - Salvamento concluído, linhas afetadas: 1
DEBUG LAUDO - Resultado do salvamento: True
```
OU
```
DEBUG LAUDO - Erro ao salvar: [mensagem de erro]
DEBUG LAUDO - Tarefa não encontrada: 123
```

### 6. TESTAR HISTÓRICO
1. Após salvar o laudo, clique no botão **relógio** (histórico)
2. Verifique se os valores aparecem nas colunas:
   - CLORO
   - PH
   - ALCALIN.
   - LIMPIDEZ
   - FLUTUANTES
   - AREIA
   - DETRITOS
   - ALGAS

## POSSÍVEIS RESULTADOS E SOLUÇÕES:

### CASO 1: Erro "Tarefa não encontrada"
**Causa**: IdTarefa inválido
**Solução**: Verificar se a tarefa existe no banco

### CASO 2: Erro de Entity Framework
**Causa**: Problema de mapeamento ou conexão
**Solução**: Verificar connection string e estrutura do banco

### CASO 3: Salvamento aparenta sucesso mas dados não aparecem
**Causa**: Problema na consulta do histórico
**Solução**: Verificar método PreencherHistoricoTarefa

### CASO 4: Erro de validação
**Causa**: Dados inválidos sendo enviados
**Solução**: Verificar formato dos dados no frontend

## REPORTE OS RESULTADOS:

Copie e cole EXATAMENTE as mensagens que aparecem em:
1. **Console do browser** (todas as mensagens DEBUG LAUDO)
2. **Visual Studio Output** (todas as mensagens DEBUG LAUDO)
3. **Mensagem na tela** (sucesso ou erro)
4. **Estado do histórico** (mostra dados ou traços?)

## SQL PARA VERIFICAR NO DBEAVER:

Execute este SQL para ver se os dados foram salvos:

```sql
-- Verificar dados mais recentes
SELECT 
    tar_id_tarefa,
    tar_ds_tarefa,
    tar_nr_nivel_cloro,
    tar_nr_ph,
    tar_nr_alcalinidade,
    tar_nr_limpidez,
    tar_dt_ultima_atualizacao
FROM tarefa 
WHERE tar_dt_ultima_atualizacao >= CURDATE() - INTERVAL 1 DAY
ORDER BY tar_dt_ultima_atualizacao DESC
LIMIT 5;
```

**EXECUTE ESTE TESTE AGORA E REPORTE TODOS OS RESULTADOS!**