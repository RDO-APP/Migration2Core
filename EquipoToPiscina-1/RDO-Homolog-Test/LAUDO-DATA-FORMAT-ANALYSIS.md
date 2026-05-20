# ANÁLISE: FORMATO DOS DADOS DO LAUDO

## PROBLEMA IDENTIFICADO

Há uma **incompatibilidade** entre como o frontend envia os dados e como o backend os salva.

## ANÁLISE DO CÓDIGO

### 1. FRONTEND (TarefaController.js)
```javascript
// Inicialização
this.cadastroParam = {
    NivelCloro: 0,      // Número (ID do array)
    NivelPH: 0,         // Número (ID do array) 
    NivelAlcalinidade: 0, // Número (ID do array)
    Limpidez: 'sim',    // String
    Superficie: 'sim',  // String
    Fundo: 'nao',       // String
    Proliferacao: 'nao' // String
};

// Arrays de opções
controller.cloro = [
    { id: 1, nome: '0 ppm' }, 
    { id: 2, nome: '0,5 < 1,0' }, 
    { id: 3, nome: '1,5 < 2,0' }, 
    { id: 4, nome: '2,5 < 3,0' }, 
    { id: 5, nome: '> 3,0' }
];

controller.ph = [
    { id: 1, nome: '< 7.0' }, 
    { id: 2, nome: '7.0 < 7.2' }, 
    { id: 3, nome: '7.2 < 7.4' }, 
    { id: 4, nome: '7.4 < 7.6' }, 
    { id: 5, nome: '7.6 < 7.8' }, 
    { id: 6, nome: '> 7.8' }
];
```

**FRONTEND ENVIA**: IDs numéricos (1, 2, 3, 4, 5, 6)

### 2. BACKEND (LaudoModel.cs)
```csharp
// Função Salvar
_laudo.lau_tp_nivel_cloro = param.nivelCloro == null ? false : param.nivelCloro;
_laudo.lau_tp_ph = param.ph == null ? false : param.ph;
_laudo.lau_tp_limpidez = param.limpidez == null ? false : param.limpidez;
```

**BACKEND SALVA**: Como boolean (true/false)

### 3. HISTÓRICO (TarefaModel.cs)
```csharp
// Integração atual
this.nivelCloro = laudo.lau_tp_nivel_cloro.HasValue ? 
    (laudo.lau_tp_nivel_cloro.Value ? "Sim" : "Não") : "-";
```

**HISTÓRICO MOSTRA**: "Sim/Não" (formato antigo)

## INCOMPATIBILIDADE DETECTADA

1. **Frontend**: Envia ID numérico (ex: 3 = "1,5 < 2,0")
2. **Backend**: Converte para boolean (3 → true)
3. **Banco**: Salva como bit(1) (true/false)
4. **Histórico**: Lê boolean e mostra "Sim/Não"

**RESULTADO**: Perda da informação específica (ex: "1,5 < 2,0" vira apenas "Sim")

## SOLUÇÕES POSSÍVEIS

### OPÇÃO 1: AJUSTAR BACKEND PARA SALVAR IDs
```csharp
// LaudoModel.cs - Função Salvar
_laudo.lau_tp_nivel_cloro = param.nivelCloro; // Salvar ID diretamente
_laudo.lau_tp_ph = param.ph; // Salvar ID diretamente
```

**Problema**: Mudaria estrutura do banco (bit → int)

### OPÇÃO 2: AJUSTAR FRONTEND PARA ENVIAR BOOLEAN
```javascript
// TarefaController.js
// Converter IDs para boolean antes de enviar
var laudoData = {
    nivelCloro: controller.cadastroParam.NivelCloro > 0,
    ph: controller.cadastroParam.NivelPH > 0
};
```

**Problema**: Perderia informação específica dos valores

### OPÇÃO 3: USAR ABORDAGEM DO GILBERTO (RECOMENDADA)
Salvar IDs na tabela `tarefa` em vez de `laudo`:
```csharp
// TarefaModel.cs - Update
entity.tar_nr_nivel_cloro = view.NivelCloro;
entity.tar_nr_ph = view.NivelPH;
entity.tar_nr_alcalinidade = view.NivelAlcalinidade;
```

### OPÇÃO 4: CRIAR CAMPOS SEPARADOS (HÍBRIDA)
Manter boolean na tabela `laudo` + adicionar campos int para valores específicos

## RECOMENDAÇÃO

**USAR OPÇÃO 3** (Abordagem do Gilberto):
1. Salvar IDs numéricos na tabela `tarefa`
2. Ajustar histórico para ler da tabela `tarefa`
3. Converter IDs para textos usando arrays do frontend

## PRÓXIMOS PASSOS

1. **EXECUTAR SQL**: `test-laudo-data-saving.sql` para confirmar estrutura atual
2. **DECIDIR ABORDAGEM**: Qual das opções implementar
3. **IMPLEMENTAR CORREÇÃO**: Ajustar código conforme decisão
4. **TESTAR**: Salvar laudo e verificar histórico

## COMANDOS SQL PARA INVESTIGAÇÃO

Execute no DBeaver:
```sql
-- Ver estrutura da tabela laudo
DESCRIBE laudo;

-- Ver dados existentes
SELECT * FROM laudo ORDER BY lau_dt_laudo DESC LIMIT 5;

-- Ver se campos tar_nr_* existem na tabela tarefa
DESCRIBE tarefa;
```