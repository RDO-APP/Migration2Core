# Obra Cadastro — Salvar (editar) · log de tentativas

**Trilha:** EQ-R · **Rota:** `/Obra/Cadastro` · BFF PUT `/api/bff/obras/cadastro` · `ObraCadastroService.SaveAsync`  
**Smoke Dia 0:** item **A1** / orquestrador **1.1**  
**Fuso:** America/Sao_Paulo · **Regra:** tentativa = linha com data/hora.

**Lição (família L10/L13 / create `f389736`):** Pomelo + coluna MySQL **NULL** + propriedade `string` (ou materializar entidade `Obra` inteira) → `InvalidCastException: DBNull → String`. Create já evita strings do template; **edit** ainda fazia `Obras.FirstOrDefaultAsync` (entidade completa).

---

## Tentativas

| # | Data/hora (BR) | Erro / sintoma | Diagnóstico | Correção | Resultado |
|---|---------------|----------------|-------------|----------|-----------|
| **O0** | 2026-11-18 ~17:30 | HTTP **500** ao Salvar obra (banner genérico / sem detalhe) | Exception no `SaveAsync` sem catch → pipeline HTML 500; SPA mascara | try/catch → `Fail("Erro ao salvar obra: …")` + BadRequest (tip **`5b62953`**) | ☑ mensagem chega no browser · causa raiz **não** resolvida |
| **O1** | 2026-11-18 ~19:25 | `Erro ao salvar obra: Unable to cast object of type 'System.DBNull' to type 'System.String'.` | Catch O0 OK; cast na gravação/materialização `Obra` (coluna string NULL em `homol_rdoapp.obra`) — mesma família PDF L10 / create `f389736` | ver **O2** | ☑ sintoma Dia 0 |
| **O2** | 2026-11-18 ~19:45 | (código) | Edit: `FirstOrDefault` entidade completa | `Select` meta + `ExecuteUpdateAsync` (sem materializar strings NULL) | código local · smoke pós-deploy |
| **O2b** | 2026-11-18 ~19:50 | (código preventivo) | GET bootstrap: `EmpNmFantasia` `string` + NULL → mesmo cast (Pomelo `??` ainda GetString) | `Nome = (string?)e.EmpNmFantasia ?? ""` em `LoadEmpresasCadastroAsync` | código local |

---

## Smoke pós-O2

1. Editar obra (ex. **500**) → Salvar → toast/OK **sem** DBNull.  
2. Nova obra (`?nova=true`) continua OK (caminho `CreateAsync`).  
3. Atualizar orquestrador **1.1** só após smoke ☑.
