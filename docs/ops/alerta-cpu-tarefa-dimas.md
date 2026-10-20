# Alerta de CPU no Banco de Dados — Tabela `tarefa`

**Data:** 06/06/2026  
**Reportado por:** KXC (Alex Machado e Gustavo Belloni)  
**Banco afetado:** RDO - MySQL Community - equipamentos  
**Sintoma:** CPUUtilization > 90%

---

## O que aconteceu

A KXC identificou que a seguinte query está consumindo recursos excessivos no banco:

```sql
SELECT *
FROM tarefa AS Project1
WHERE Project1.tar_nr_agrupador = '5537a249-d3f0-48b0-855f-24925e074939'
ORDER BY Project1.tar_dt_medicao DESC
LIMIT 1
```

Esta query é gerada automaticamente pelo Entity Framework toda vez que o sistema
precisa buscar o registro mais recente de um grupo de tarefas (`tar_nr_agrupador`).

---

## Causa raiz

A tabela `tarefa` possui um índice simples na coluna `tar_nr_agrupador`, mas **não
possui índice composto em `(tar_nr_agrupador, tar_dt_medicao)`**.

Sem esse índice, o MySQL precisa:

1. Usar o índice simples para encontrar todas as linhas do GUID informado
   (podem ser dezenas ou centenas de registros por grupo de tarefa)
2. Fazer um **filesort** sobre esses registros para satisfazer o `ORDER BY tar_dt_medicao`

Isso é chamado de **"Using filesort"** no EXPLAIN do MySQL — caro em CPU e memória.

O agravante é que essa query **é chamada em loop** no código — uma vez para cada
tarefa em listas de etapas, relatórios e históricos. Com 50 tarefas abertas, isso
gera 100+ idas ao banco numa única requisição da aplicação.

---

## Como corrigir — Passo a passo

### Passo 1 — Aplicar os índices no banco de produção (urgente)

Conectar no MySQL de produção e executar:

```sql
-- Índice 1 (crítico): elimina o filesort nas buscas por agrupador + data
CREATE INDEX IX_tarefa_agrupador_medicao
    ON tarefa (tar_nr_agrupador, tar_dt_medicao);

-- Índice 2 (secundário): cobre queries de status mais recente por agrupador
CREATE INDEX IX_tarefa_agrupador_ultima_atualizacao
    ON tarefa (tar_nr_agrupador, tar_dt_ultima_atualizacao);
```

> **Segurança:** os comandos `CREATE INDEX` no MySQL são operações online por padrão
> — não travam a tabela e não causam downtime. Podem ser executados em produção.

O script completo está disponível em:
`c:\Dev\Migration2Core\fix-tarefa-cpu-indexes.sql`

---

### Passo 2 — Validar que o índice resolveu (após criar)

Executar o EXPLAIN para confirmar que o filesort sumiu:

```sql
EXPLAIN SELECT tar_id_tarefa, tar_nr_agrupador, tar_id_status, tar_dt_medicao
FROM tarefa
WHERE tar_nr_agrupador = '5537a249-d3f0-48b0-855f-24925e074939'
ORDER BY tar_dt_medicao DESC
LIMIT 1;
```

**Resultado esperado após o índice:**
- Coluna `type` = `ref`
- Coluna `key` = `IX_tarefa_agrupador_medicao`
- Coluna `Extra` = `Using index` *(sem "Using filesort")*

---

### Passo 3 — Corrigir o padrão de código para evitar recorrência

O problema não é só o índice — o código faz consultas individuais dentro de loops.
O arquivo `TarefaModel.cs` contém este padrão problemático:

```csharp
// PROBLEMA: chamado dentro de um loop — 2 queries por grupo de tarefa
tarefa tarefaUltimo = context.tarefa
    .Where(t => t.tar_nr_agrupador == tar.tar_nr_agrupador)
    .OrderByDescending(t => t.tar_dt_medicao).First();

tarefa tarefaPrimeiro = context.tarefa
    .Where(t => t.tar_nr_agrupador == tar.tar_nr_agrupador)
    .OrderBy(t => t.tar_dt_medicao).First();
```

**A forma correta** é buscar todos os grupos em uma única query antes do loop:

```csharp
// CORRETO: uma query, agrupamento em memória
var agrupadorIds = tarefas.Select(t => t.tar_nr_agrupador).Distinct().ToList();

var porGrupo = context.tarefa
    .Where(t => agrupadorIds.Contains(t.tar_nr_agrupador))
    .GroupBy(t => t.tar_nr_agrupador)
    .Select(g => new {
        Agrupador = g.Key,
        Ultimo    = g.OrderByDescending(t => t.tar_dt_medicao).First(),
        Primeiro  = g.OrderBy(t => t.tar_dt_medicao).First()
    })
    .ToList();
```

Arquivos onde este padrão ocorre e precisam ser revisados:

| Arquivo | Método |
|---|---|
| `Api/Models/TarefaModel.cs` | `ObterProgressoTarefa` (linha ~280) |
| `Api/Models/TarefaModel.cs` | `_ObterPrimeiroDiaExecutado`, `_ObterUltimoDiaExecutado` |
| `Api/Models/EtapaModel.cs` | listagens de tarefas por etapa |
| `Api/Models/GraficoModel.cs` | subqueries de contagem por status |

---

## Resumo das ações

| # | Ação | Prioridade | Responsável |
|---|---|---|---|
| 1 | Executar `fix-tarefa-cpu-indexes.sql` no banco de produção | **Urgente** | Dimas / KXC |
| 2 | Validar com EXPLAIN que filesort foi eliminado | Alta | Dimas |
| 3 | Refatorar queries em loop em `TarefaModel.cs` e `EtapaModel.cs` | Média | Dev |

---

## Arquivos de referência

- Script SQL pronto para executar: `c:\Dev\Migration2Core\fix-tarefa-cpu-indexes.sql`
- Configuração EF Core já atualizada: `RdoApp.Core\Data\Configurations\TarefaConfiguration.cs`
