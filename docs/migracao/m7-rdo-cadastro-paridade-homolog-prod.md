# O que falta em homolog vs produção (lista completa)

**Trilha:** EQ-R · **Rota:** `/Rdo/Cadastro` · **Prod:** `#/rdo/cadastro` (AngularJS) · **Homolog:** React M7 **7a**  
**Referência legado:** `Equipamentos/rdoappProject/Client/Views/Rdo/cadastro.html` · **BFF:** `GET/POST /api/bff/rdos/cadastro/*`  
**Atualizado:** 2026-10-28 · **Git homolog:** `3c061b6` (7a-P0) sobre `498ebc4` (7a inicial)

Legenda **O que foi feito:** ☑ entregue no Git · ◐ parcial · ☐ pendente · — fora escopo 7a

---

## A. Bloqueio funcional (etapas / tarefas)

| # | Produção | Homolog (antes/depois P0) | Solução planejada | O que foi feito |
|---|----------|---------------------------|-------------------|-----------------|
| A1 | Accordion de etapas (ex. OBRA, TESTE ETAPA, EQUIPAMENTOS) com tarefas | **500** em `cadastro/etapas` → lista vazia + erro vermelho | **7a-P0** — projeção EF (`TarefaAgrupadorQuery`), paridade `ObterEtapasParaRDO` | ☑ **`3c061b6`** — aguarda **deploy + smoke T7** para confirmar 200 |
| A2 | Checkbox por tarefa + marcar/desmarcar etapa | UI React pronta, sem dados enquanto A1 falha | Idem A1 | ☑ UI **7a** `498ebc4` · dados dependem smoke pós-P0 |

---

## B. Formulário superior (data, clima, improdutividade, comentários)

| # | Produção | Homolog | Solução planejada | O que foi feito |
|---|----------|---------|-------------------|-----------------|
| B1 | Título da página **“RDO”** | **“Gerar RDO”** | **7a-P4** copy/CSS | ☐ |
| B2 | Ícones clima (nascer do sol / sol / lua) nos rótulos Manhã/Tarde/Noite | Só texto | **7a-P4** fontello/FA como legado | ☐ |
| B3 | **Motivos de improdutividade** — 10 toggles (clima, materiais, paralisações, equipamentos, contratante, fornecedores, mão de obra, projeto, planejamento/execução, acidente) | **Ausente** na SPA | **7a-P1** React + DTO + `RdoModel.Salvar` / tabela `improdutividade` | ◐ Save grava registro **vazio** em `Improdutividade` (`498ebc4`); **flags não expostas na UI** |
| B4 | **Comentários** + 👍/👎 (`tipoComentarioGeracao`) | **Ausente** | **7a-P1** UI; DTO já tem `Comentario` / `TipoComentarioGeracao` | ◐ POST aceita campos (`498ebc4`); **sem UI** |
| B5 | Datepicker legado (`datepicker-here`, máscara) | Input texto com máscara `dd/mm/aaaa` | **7a-P4** opcional | ◐ Máscara manual React **7a** — funcional, visual diferente |

---

## C. Bloco ETAPAS / TAREFAS

| # | Produção | Homolog | Solução planejada | O que foi feito |
|---|----------|---------|-------------------|-----------------|
| C1 | Cabeçalho **“ETAPAS / TAREFAS”** | Seção **“Tarefas”** apenas | **7a-P2/P4** | ☐ |
| C2 | **“Habilitar relatório fotográfico?”** Sim/Não | Ausente | **7a-P3** + BFF imagens (`ListaImagem` legado) | ☐ |
| C3 | Accordion **faixa azul** estilo `panel-heading` prod | Accordion simples ▶/▼ | **7a-P4** `rdo-cadastro.css` | ☐ |
| C4 | Tabela: DESCRIÇÃO, **STATUS**, **QTD. COLABORADORES**, **QTD. EQUIPAMENTOS**, **AÇÕES** | Lista checkbox + descrição; tag “dia anterior” | **7a-P2** estender DTO (como Cards BFF) + colunas | ◐ Tag **dia anterior** **7a**; colunas prod **pendentes** |
| C5 | Botão **editar tarefa** na linha | Ausente | **7a-P2** → `/Tarefa/Cadastro?id=` ou modal legado | ☐ |
| C6 | Bloco **Fotos da(s) tarefa(s)** + galeria/checkboxes | Ausente | **7a-P3** | ☐ |

---

## D. Ações finais e regras de negócio

| # | Produção | Homolog | Solução planejada | O que foi feito |
|---|----------|---------|-------------------|-----------------|
| D1 | **VOLTAR** + **GERAR RDO** (ícones FA) | **Voltar** + **SALVAR** | **7a-P4** labels/ícones | ◐ Voltar → listagem **7a**; label **SALVAR** (não GERAR RDO) |
| D2 | Confirmar substituir RDO na data; copiar medições dia anterior | `window.confirm` no React | Ajuste fino **7a-P0/P1** após etapas OK | ☑ Fluxo confirm **7a** `498ebc4` — validar em smoke pós-P0 |

---

## E. Fora do cadastro “novo RDO” (roadmap M7)

| Item | Produção | Homolog | Solução | O que foi feito |
|------|----------|---------|---------|-----------------|
| E1 | Editar RDO existente | Listagem **7a** parcial; edição cadastro | **M7 7b** | ☐ |
| E2 | PDF | Ícones listagem **W3** / prod | **M7 7c** | ☐ |
| E3 | Assinar | Prod | **M7 7d** | ☐ |
| E4 | Redesign global SPA (sem BS5 paridade) | — | **UI-M3** (gate M7 estável) | — adiado |

---

## Fases de entrega (mapa)

| Fase | Escopo | Git / estado |
|------|--------|----------------|
| **7a** (MVP) | SPA + BFF bootstrap, etapas, save clima+tarefas | `498ebc4` |
| **7a-P0** | Fix **500** `cadastro/etapas` + save sem entidade tarefa completa | `3c061b6` |
| **7a-P1** | Improdutividade + comentários UI + flags no save | ☐ |
| **7a-P2** | Tabela tarefas paridade + editar | ☐ |
| **7a-P3** | Relatório fotográfico | ☐ |
| **7a-P4** | Visual (título, ícones, accordion azul, GERAR RDO) | ☐ |
| **7b–7d** | Editar / PDF / assinar | ☐ |

---

## Smoke homolog (pós-P0)

Registrar em [`homolog-p5-rdo-tentativas.md`](homolog-p5-rdo-tentativas.md) como **T7**:

1. `GET /api/bff/rdos/cadastro/etapas?dataRdo=dd/MM/yyyy` → **200**
2. Etapas visíveis como prod (mesma obra/data)
3. **SALVAR** → RDO na listagem `/Rdo/Index`

Deploy: [`roteiro-deploy-homolog-operador.md`](roteiro-deploy-homolog-operador.md) § **3b** · pacote ≥ **`3c061b6`**.

---

## Changelog deste doc

| Data | Nota |
|------|------|
| 2026-10-28 | Lista completa homolog×prod + coluna **O que foi feito**; P0 `3c061b6` |
