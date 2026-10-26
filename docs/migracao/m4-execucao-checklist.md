# M4 — Shell + paridade visual P2/P3 (EQ-R)

**Início:** 2026-10-20 · **Pré:** M3 PASS · **Trilha:** EQ-R · **Referência prod:** `escolher.html` · `cards.html` (EQ-L)

### Numeração **P** (canônica — alinhar chat, QA e docs)

| P | Página operador | Matriz # | Rota homolog (ref.) |
|---|-----------------|:--------:|---------------------|
| **P1** | **Login** | 1 | `/Account/Login` |
| **P2** | **Escolher obra** (cards de obra) | 2 | `/Obra/Escolher` |
| **P3** | **Etapas / Tarefas** (Cards) | 3 | `/Tarefa/Cards` |
| **P4** | **Nova medição** (modal) | 4 | em `cards.html` · **M7+** |

Detalhe bloco a bloco: manual **§10** · resumo: [`ORQUESTRADOR-MIGRACAO.md`](../ORQUESTRADOR-MIGRACAO.md) § Paridade visual.

---

## Objetivo

Homolog **②** aproxima **①** por **blocos de UI** (header, cards, accordion, toolbar) numa **SPA React** — sem expandir Razor de produto.

---

## Checklist (marcos)

| # | Item | OK | Tela | Notas |
|---|------|:--:|------|-------|
| M4.1 | **OperadorShell** no Cards (**P3 · header**) | ☑ | P3 | homolog 2026-10-20 |
| M4.2 | BFF `usuarioNome` | ☑ | P3 | |
| M4.3 | Deploy homolog (zip + SSM) | ☑ | — | `fb301c23-…` · `20261020-100219` |
| **M4.4** | **P2** Escolher React — BFF + filtros + legenda + fluxo Selecionar | ☑ | P2 | homolog smoke Lucio |
| **M4.4b** | **P2** **card obra** — grid 5/linha + ícone/tipo prod (`custom.css`) | ☑ | P2 | polish 2026-10-21 · deploy homolog |
| **M4.4c** | **P2** **header Escolher** — paridade prod (logo, ordem ícones, dropdown, RBAC) | ☑ | P2 | `GET /api/bff/shell` + `OperadorShell` |
| **M4.5** | **P3** toolbar + **accordion** + ícones nav obra | ☑ | P3 | pacote P2+P3 · deploy **2026-10-21** |
| **M4.6** | **P3** **card tarefa** + placeholder “Adicionar nova tarefa” | ☑ | P3 | BFF colab/equip · ícones ação stub M7 |
| **M4.7b** | **P3** navegação botões → rotas MVC (`p3-operador-routes.ts` + EmMigracao) | ☑ | P3 | Git **`7e19d47`** |
| **M4.7g** | Menu drawer + shell RBAC P1–P3 + `LegacyOperadorRoutes` | 🟡 | P2/P3 | código ☑ · smoke **G5/G6** pendente |
| **M4.7c** | Toolbar RDO/Efetivo + faixa LISTA · RBAC `showCriarNovo*` | 🟡 | P3 | smoke G6 |
| **M4.7** | UI-M1/M2c fontello/FA · UI-M2/M2b | ☐ | P3 | fecha paridade visual M4 |
| **M4.8** | **P1** Login SPA + congela EQ-W | ☐ | P1 | critério M4 fim |
| — | **P4** Nova medição modal | — | P4 | **M7+** |

---

## Critério M4.4 (**P2** Escolher — fechar antes de M4.5)

| Bloco | Done quando | Sub |
|-------|-------------|-----|
| Dados / fluxo | `GET/POST /api/bff/obras` · 7 obras · Selecionar → **P3** Cards | **M4.4** |
| Filtros + legenda | Obra + Município · legenda cores | **M4.4** |
| Card obra | Ícone 97px · h5 24px · **5 cards/linha** (≥1200px) · %/status | **M4.4b** |
| Header Escolher | ≈ prod Escolher (`nav` / `_HeaderEscolher`): logo, chart/+, usuário+caret+menu, RBAC | **M4.4c** |

**Gate:** marcar **M4.4☑** (incl. 4b+4c) + smoke Lucio · **depois** abrir **M4.5** (só **P3** Etapas/Cards).

## Critério M4.5–M4.6 (**P3** Cards — blocos)

| Bloco | Done quando |
|-------|-------------|
| Toolbar | FILTRO, + tarefa, + etapa visíveis (ação pode stub até M7) |
| Accordion | Estilo faixa etapa ≈ prod |
| Card tarefa | Mesma **informação** que prod (efetivo/equip, ícones, checkbox, %) |
| Placeholder | Card tracejado “Adicionar nova tarefa” |

---

## Fora M4

Toolbar medição · APIs de escrita · **M5** Apontador · **M9** D1 pacote completo · **P4** medição (**M7+**).

---

## Melhorias UI (backlog — não bloqueiam M4.7)

Ver tabela P1–P4 e IDs **UI-M1…UI-M6** em [`pendencias-melhorias-ui-stack.md`](pendencias-melhorias-ui-stack.md).  
Inventário botões P3 (header / toolbar / card): [`p3-botoes-habilitacao-m7.md`](p3-botoes-habilitacao-m7.md).

| ID | Resumo | Quando |
|----|--------|--------|
| UI-M1, UI-M2c | FA 4.7 + **fontello** (subset → paridade prod) — inventário [`fontello-fa-legado-marcos-ui.md`](fontello-fa-legado-marcos-ui.md) | **M4.7** |
| UI-M2–M2b | Flex card, progress — paridade híbrida | **M4.7** |
| UI-M3 | Redesign sem BS3/legado **e sem fontello/FA na SPA** | **⏸ pós-M4.7 ☑ + M7** — gates em [`fontello-fa-legado-marcos-ui.md`](fontello-fa-legado-marcos-ui.md) |
| UI-M5–M6 | Esqueci senha smoke · Login SPA | M4.8 |
