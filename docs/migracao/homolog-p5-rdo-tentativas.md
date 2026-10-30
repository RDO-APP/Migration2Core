# Homolog P5a — RDO `/Rdo/Index` · registro de tentativas

**Objetivo:** contar smoke, classificar falha (MVC / deploy / React / BFF) e **não repetir** o mesmo erro.  
**Diagnóstico:** [`/Homolog/F12`](https://homolog.sistema.rdoapp.com.br/Homolog/F12) · `GET /api/bff/diag` · cabeçalhos `X-RdoApp-*` (Rede → Doc) · manual §10.8

**Meta produto (paridade):** prod `#/rdo/index` → homolog **`/Rdo/Index`** — listagem Status, datas, tabela RDO, PESQUISAR/NOVO.

---

## Fase atual

| Marco | Estado |
|-------|--------|
| P3 Cards | ☑ homolog |
| P5a RDO listagem | ☑ **T5 E** · **W1/W2** no Git **`fd8a144`** (smoke **T6** pendente) · **W3/M7** ações |
| **M7 `/Rdo/Cadastro`** | ◐ **T7** **2026-10-29 23:11** — P0 `3c061b6` · matriz **19** itens · **5** parciais · smoke checklist **2/3** · ver linha **T7** |
| Diagnóstico | ☑ **`/Homolog/F12`** + API diag — **sem** rodapé nas telas P1–P5 |

---

## Tentativas (contagem)

| # | Data/hora (BR) | Deploy D+E? | Commit / bundle | O que você viu | Classe | Próximo |
|---|----------------|-------------|-----------------|----------------|--------|---------|
| **T0** | 2026-10-26 | ❓ | ≤ `3e3709b` | HTTP **500** `AmbiguousMatch` em `/Rdo/Index` | rota MVC | `3e3709b` |
| **T1** | 2026-10-26 | ❓ | ≤ `3e3709b` | `ERR_TOO_MANY_REDIRECTS` | **A** | anti-loop `3a7f5ad` |
| **T2** | 2026-10-26 | ❓ | `3a7f5ad` local · EC2 ? | Mesmo loop após RDO | **B** ou **A** | SSM Success + D+E |
| **T3** | **2026-10-27 08:05** | ✅ SSM `46901ecd…` ~1,4 min | `c0d09e8` · `index-C4fKCj64.js` | P1/P3 OK · RDO → loop (print) | **A** | F12 + `6574ae5` |
| **T4** | **2026-10-27 ~09:43** | ✅ SSM `50efd8f3…` · zip `20261027-093531` | `6574ae5` · `index-DVRJFW-_.js` | Loop · F12 **Network/Doc** | **A′** | fix rota legado |
| **T4b** | **2026-10-27 ~09:58** | (mesmo deploy) | — | F12: **302** `Location: /Rdo/Index` · `X-RdoApp-Diag: logado; obra=42; LoginData-ok` | **A′** self-302 | **T5** |
| **T5** | **2026-10-27 ~11:00** (BR) | ✅ D+E · SSM `775cda4a…` · zip `20261027-105734` | `056eb29`+ | **200** `/Rdo/Index` · listagem (print) · paridade vs prod parcial | **E** | W1/W2 no Git |
| **T6** | _após deploy_ | | **`fd8a144`** | W1/W2: header obra, nav, botões, tabela centralizada | _pendente_ | W3 ou Chart |
| **T7** | **2026-10-29 23:11** (BR) | ✅ D+E (pós-`3c061b6`) | **`3c061b6`** + SPA `498ebc4` | **`/Rdo/Cadastro`** obra FACHADA · **`cadastro/etapas` 200** (antes 500) · **~3 etapas** na UI (lista simples, ≠ accordion/tabela prod) · clima/data OK · **SALVAR** não confirmado neste smoke · **Matriz paridade:** **19** itens ([`m7-rdo-cadastro-paridade-homolog-prod.md`](m7-rdo-cadastro-paridade-homolog-prod.md)) · **5** com resultado parcial · **14** em aberto · Lucio: *melhorou pouco* | **E′** cadastro parcial | **7a-P1** · checklist T7 **3/3** quando SALVAR OK |

### Classes de falha

| Classe | Significado | React carrega? |
|--------|-------------|----------------|
| **A** | Loop **Login ↔ `/Rdo/Index`** (`ReturnUrl`) | **Não** |
| **A′** | **302 `/Rdo/Index` → `/Rdo/Index`** (rota legado `/rdo/index` case-insensitive) | **Não** |
| **B** | Git novo · **EC2 zip antigo** (pull ≠ deploy) | — |
| **C** | **200** + SPA · rota/`RdoIndexPage` errada | Sim |
| **D** | **200** + UI RDO · BFF `/api/bff/rdos` falha | Sim |
| **E** | Listagem RDO = prod | Sim |
| **E′** | Cadastro novo RDO: etapas **200** + UI ≠ prod (improd/comentários/tabela/fotos) | Sim |

---

## Aprendizado por tentativa

| # | Erro / sintoma | Causa provável | Aprendizado (não repetir) |
|---|----------------|----------------|---------------------------|
| **T0** | 500 AmbiguousMatch | `[HttpGet("/Rdo/Index")]` **e** rota convencional | P5a: **só** `[HttpGet]` convencional no `Index` (ASP0023). |
| **T1** | Loop redirect | Login GET logado voltava ao `ReturnUrl` | Nunca **302** logado → `ReturnUrl=/Rdo/Index`. |
| **T2** | Loop igual | Deploy não aplicado **ou** mesma classe A | **A2 → D → E** + confirmar SSM **Success**; pull ≠ EC2. |
| **T3** | Loop pós-deploy OK | Classe **A** (não B) | SSM Success **não** prova RDO; smoke **só** no ícone RDO / `/Rdo/Index`. |
| **T4** | Loop pós-deploy | Hipótese Login↔Rdo | F12 provou outra coisa (**A′**). |
| **T4b** | **302 para a mesma URL** | Kiro **`#/rdo/index`** → stub M4.7h **`/rdo/index` → 302 `/Rdo/Index`**; case-insensitive = loop (não cookie) | P5a no **RdoController**, não redirect no **ModuloLegado**; F12 **Location** + **X-RdoApp-Diag**. |
| **T5** | Listagem OK | Fix **`056eb29`** + publish 10:57 | P5a **E** | **T6** smoke **`fd8a144`** (W1/W2) |
| **T7** | 500 → 200 em `cadastro/etapas` | Materializar entidade `Tarefa` inteira no BFF | **P0** projeção `TarefaAgrupadorQuery` · paridade ainda **19−5=14** itens | **7a-P1+** |

---

## Erros de operação (não confundir com RDO)

| O que aconteceu | O que é | O que fazer |
|-----------------|---------|-------------|
| PowerShell `>>` e “Projeto: não é reconhecido” | **Log colado** no terminal como comando | **Ctrl+C** · rodar **só** `.\publish-homolog-ec2.ps1` ou deploy **uma linha** |
| CS9000 `HomologController.cs` | `"""` na mesma linha do HTML | Corrigido em **`6574ae5`** · publish de novo |
| “Publish OK” + erros vermelhos depois | Log antigo colado **depois** do OK | Vale a última **`Publish OK.`** + **`Deploy SSM OK.`** |

---

## Como ler F12 (leigo)

1. **`/Homolog/F12`** (logado) — snapshot + JSON; copiar para o chat Migração.
2. **Rede:** filtro **Fetch/XHR** (não só `app/assets`) → `diag`, `etapas`.
3. **RDO com loop:** Rede → **Doc** `Rdo/Index` → **Cabeçalhos** → `X-RdoApp-Diag`, `X-RdoApp-Redirect-Motivo`.
4. **Cards:** Console opcional `[RDO homolog]` — sem barra no rodapé.

---

## Referência

Manual §10.8 · [`m5-web-paridade-prod-ordem.md`](m5-web-paridade-prod-ordem.md) · deploy [`roteiro-deploy-homolog-operador.md`](roteiro-deploy-homolog-operador.md)
