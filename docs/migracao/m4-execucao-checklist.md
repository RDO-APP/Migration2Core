# M4 — Shell + paridade visual P1/P2 (EQ-R)

**Início:** 2026-10-20 · **Pré:** M3 PASS · **Trilha:** EQ-R · **Referência prod:** `escolher.html` · `cards.html` (EQ-L)

**Numeração:** **P1** = Escolher (matriz **#2**) · **P2** = Cards (**#3**). Detalhe item a item: manual **§10** · resumo executivo: [`ORQUESTRADOR-MIGRACAO.md`](../ORQUESTRADOR-MIGRACAO.md) § Paridade visual blocos P1/P2.

---

## Objetivo

Homolog **②** aproxima **①** por **blocos de UI** (header, cards, accordion, toolbar) numa **SPA React** — sem expandir Razor de produto.

---

## Checklist (marcos)

| # | Item | OK | Tela | Notas |
|---|------|:--:|------|-------|
| M4.1 | **OperadorShell** no Cards (**P2 · header**) | ☑ | P2 | homolog 2026-10-20 |
| M4.2 | BFF `usuarioNome` | ☑ | P2 | |
| M4.3 | Deploy homolog (zip + SSM) | ☑ | — | `fb301c23-…` · `20261020-100219` |
| **M4.4** | **P1** Escolher React — header + **card obra** + filtros + legenda | ☑ | P1 | código · BFF `GET/POST /api/bff/obras` · **deploy** homolog pendente |
| **M4.5** | **P2** toolbar + **accordion etapa** prod | ☐ | P2 | **próximo** · gap #1 |
| **M4.6** | **P2** **card tarefa** + placeholder “Adicionar nova tarefa” | ☐ | P2 | gap #1 |
| M4.7 / M4.8 | Login SPA + congela EQ-W | ☐ | matriz #1 | critério M4 fim |
| — | Nova medição modal | — | matriz #4 | **M7+** |

---

## Critério M4.4 (P1 — blocos)

| Bloco | Done quando |
|-------|-------------|
| Header | Mesmo `OperadorShell` (ou equivalente) na rota Escolher |
| Card obra | Ícone, título, cidade/UF, licença, barra % como prod |
| Filtros + legenda | Obra + Município funcionam; legenda status visível |
| Fluxo | POST Selecionar inalterado (M3) |

## Critério M4.5–M4.6 (P2 — blocos)

| Bloco | Done quando |
|-------|-------------|
| Toolbar | FILTRO, + tarefa, + etapa visíveis (ação pode stub até M7) |
| Accordion | Estilo faixa etapa ≈ prod |
| Card tarefa | Mesma **informação** que prod (efetivo/equip, ícones, checkbox, %) |
| Placeholder | Card tracejado “Adicionar nova tarefa” |

---

## Fora M4

Toolbar medição · APIs de escrita · **M5** Apontador · **M9** D1 pacote completo.
