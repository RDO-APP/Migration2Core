# M2 — Cards homolog (EQ-R)

**Início:** 2026-10-17 · **Trilha:** EQ-R (backend BFF mínimo **EQ-W/R** no Core)  
**Pré-requisito:** M1 fechado — [`../m1-execucao-checklist.md`](../m1-execucao-checklist.md) · contrato [`../api-client-equipamentos-v1.md`](../api-client-equipamentos-v1.md)

---

## Objetivo (done)

Operador autenticado vê **etapas/tarefas com dados** na UI **React** (paridade mínima legado `cards.html`), acessível a partir do fluxo homolog (`homolog.sistema`), sem depender do placeholder Razor.

---

## Estratégia (fechada 2026-10-17 — Lucio: segue M2)

| Item | Escolha |
|------|---------|
| Auth/sessão obra | Cookie MVC + `SessionKeys.ObraId` |
| Dados Cards | **BFF homolog-only** — `GET /api/bff/etapas` lê **EF / `homol_rdoapp`** (mesma connection do Core). **Não** proxy prod: `idObra` da sessão homolog ≠ prod. |
| Prod API (`etapa/Get`) | Permanece referência **EQ-M** (cenário A); opção prod no BFF = **M6+** ou flag config |
| SPA | Build Vite → `RdoApp.Core/wwwroot/app` · `/Tarefa/Cards` serve `index.html` |
| Tipos | `client/src/api/equipamentos-api.types.ts` (espelho M1) |

---

## Checklist implementação

| # | Item | OK | Notas |
|---|------|:--:|-------|
| M2.1 | BFF etapas no Core (sessão obra + idObra) | ☑ | `CardsQueryService` + `BffEtapasController` |
| M2.2 | Copiar tipos M1 para `client/src/api/` | ☑ | |
| M2.3 | Página React **Cards** (accordion + cards: head, datas, %, status) | ☑ | `client/src/App.tsx` · homolog 2026-10-19 obra 42 |
| M2.4 | Servir build Vite no Core (`wwwroot/app`) | ☑ | `TarefaController.Cards` → `PhysicalFile` |
| M2.5 | Entrada E2E: URL homolog abre React Cards **com dados** | ☑ | Lucio 2026-10-19 · obra 42 · M3 PASS |
| M2.6 | Doc: atualizar orquestrador + gap #1 | ☑ | |

---

## Paralelo (não gate M2.5 local)

| ID | Item | Trilha |
|----|------|--------|
| EQ-W0.5 | Redeploy EC2 + branding Equipamentos + fix `POST /Obra/Selecionar` | EQ-W + **I** |
| M3 | Assinar [`../e2e-fase0-checklist.md`](../e2e-fase0-checklist.md) fluxo completo | Lucio |

---

## Critério de fechamento M2

- [x] Lucio vê **≥1 etapa** com dados reais — obra 42 · 3 etapas · 13 cards (2026-10-19 · M3).
- [x] Código M2 commitados em **`RDO-APP/Migration2Core`** (`89adbe4`); docs orquestrador neste push.

---

## Pendências herdadas (não são M2 sozinhas)

Ver [`../m0-registro-encerramento.md`](../m0-registro-encerramento.md) §5 · E2E localhost E2 · workshop Dimas (async doc only).
