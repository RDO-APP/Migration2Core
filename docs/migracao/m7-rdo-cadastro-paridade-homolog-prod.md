# O que falta em homolog vs produção (lista completa)

**Trilha:** EQ-R · **Rota:** `/Rdo/Cadastro` · **Prod:** `#/rdo/cadastro` (AngularJS) · **Homolog:** React M7 **7a**  
**Referência legado:** `Equipamentos/rdoappProject/Client/Views/Rdo/cadastro.html` · **BFF:** `GET/POST /api/bff/rdos/cadastro/*`  
**Atualizado:** 2026-10-29 · **Git homolog:** `3c061b6` (7a-P0) sobre `498ebc4` (7a inicial)

**Colunas de solução**

| Coluna | Significado |
|--------|-------------|
| **1) Solução aplicada** | O que já está no Git / deploy (commit ou fase) |
| **2) Resultado** | O que Lucio vê no homolog **hoje** (smoke) |
| **3) Próxima solução** | Próximo incremento planejado |

---

## A. Bloqueio funcional (etapas / tarefas)

| # | Produção | Homolog | 1) Solução aplicada | 2) Resultado | 3) Próxima solução |
|---|----------|---------|---------------------|--------------|-------------------|
| A1 | Accordion de etapas (OBRA, TESTE ETAPA, EQUIPAMENTOS…) com tarefas | Antes: **500** `cadastro/etapas` + “nenhuma tarefa” | **7a-P0** `3c061b6` — `TarefaAgrupadorQuery` (projeção EF), paridade `ObterEtapasParaRDO` | **T7** **2026-10-29 23:11** · **200** · **~3 etapas** UI · ≠ prod · *melhorou pouco* ([`homolog-p5-rdo-tentativas.md`](homolog-p5-rdo-tentativas.md)) | **7a-P2** tabela · **7a-P4** accordion azul |
| A2 | Checkbox por tarefa + marcar/desmarcar etapa | Lista simples ▶/▼ + checkbox | **7a** `498ebc4` — UI React `RdoCadastroPage` | Depende de A1: se etapas carregam, seleção **funciona**; UX **≠** prod (sem tabela) | **7a-P2** “marcar etapa” + paridade tabela |

---

## B. Formulário superior (data, clima, improdutividade, comentários)

| # | Produção | Homolog | 1) Solução aplicada | 2) Resultado | 3) Próxima solução |
|---|----------|---------|---------------------|--------------|-------------------|
| B1 | Título **“RDO”** | **“Gerar RDO”** | — | Título diferente | **7a-P4** copy/CSS |
| B2 | Ícones clima (nascer / sol / lua) | Só texto | — | Sem ícones | **7a-P4** fontello/FA |
| B3 | **Motivos de improdutividade** (10 toggles) | Ausente | **7a** save: `Improdutividade` criada **vazia** (`498ebc4`) | Sem toggles na tela; PDF/gráficos **não** refletem prod | **7a-P1** UI + flags no POST (paridade `RdoModel.Salvar`) |
| B4 | **Comentários** + 👍/👎 | Ausente | DTO + POST `Comentario` / `TipoComentarioGeracao` (`498ebc4`) | Sem UI | **7a-P1** |
| B5 | Datepicker legado | Input mascarado `dd/mm/aaaa` | Máscara manual React **7a** | **OK** funcional; visual diferente | **7a-P4** opcional |

---

## C. Bloco ETAPAS / TAREFAS

| # | Produção | Homolog | 1) Solução aplicada | 2) Resultado | 3) Próxima solução |
|---|----------|---------|---------------------|--------------|-------------------|
| C1 | Cabeçalho **“ETAPAS / TAREFAS”** | **“Tarefas”** | — | Label diferente | **7a-P2/P4** |
| C2 | **“Habilitar relatório fotográfico?”** Sim/Não | Ausente | — | Ausente | **7a-P3** + BFF imagens |
| C3 | Accordion **faixa azul** (`panel-heading`) | Accordion simples | CSS mínimo **7a** | **≠ prod** | **7a-P4** `rdo-cadastro.css` |
| C4 | Tabela: STATUS, QTD colab/equip, AÇÕES | Lista + descrição; tag “dia anterior” | Tag **dia anterior** **7a** | Só descrição + checkbox; **sem** colunas prod | **7a-P2** DTO estendido (como Cards) |
| C5 | **Editar tarefa** na linha | Ausente | — | Ausente | **7a-P2** link `/Tarefa/Cadastro?id=` |
| C6 | **Fotos** + galeria | Ausente | — | Ausente | **7a-P3** |

---

## D. Ações finais e regras de negócio

| # | Produção | Homolog | 1) Solução aplicada | 2) Resultado | 3) Próxima solução |
|---|----------|---------|---------------------|--------------|-------------------|
| D1 | **VOLTAR** + **GERAR RDO** (ícones) | **Voltar** + **SALVAR** | Voltar → listagem **7a** | Navegação OK; label **SALVAR** | **7a-P4** ícones + “GERAR RDO” |
| D2 | Substituir RDO / copiar dia anterior | `window.confirm` React | Fluxo confirm **7a** `498ebc4` + validação save **P0** | A validar após **SALVAR** com tarefas (smoke) | Ajuste mensagens **7a-P1** se divergir do prod |

---

## E. Fora do cadastro “novo RDO” (roadmap M7)

| Item | Produção | Homolog | 1) Solução aplicada | 2) Resultado | 3) Próxima solução |
|------|----------|---------|---------------------|--------------|-------------------|
| E1 | Editar RDO existente | Listagem **7a** | Listagem BFF **P5a** | Cadastro edição **não** | **M7 7b** |
| E2 | PDF | Prod / listagem | — | **W3** pendente listagem | **M7 7c** |
| E3 | Assinar | Prod | — | Fora **7a** | **M7 7d** |
| E4 | Redesign SPA | — | Gate **UI-M3** | Adiado | Após **7a-P1–P4** estável |

---

## Fases de entrega (mapa)

| Fase | Escopo | Git |
|------|--------|-----|
| **7a** | SPA + BFF bootstrap, etapas, save clima+tarefas | `498ebc4` |
| **7a-P0** | Fix **500** `cadastro/etapas` | `3c061b6` |
| **7a-P1** | Improdutividade + comentários | ☐ |
| **7a-P2** | Tabela tarefas + editar | ☐ |
| **7a-P3** | Relatório fotográfico | ☐ |
| **7a-P4** | Visual paridade | ☐ |
| **7b–7d** | Editar / PDF / assinar | ☐ |

---

## Smoke homolog (T7)

Registro **T7** · **2026-10-29 23:11** (BR) · [`homolog-p5-rdo-tentativas.md`](homolog-p5-rdo-tentativas.md)

| Métrica | Valor |
|---------|--------|
| Itens na **matriz paridade** (A–E) | **19** |
| **Parciais** vs prod (T7) | **5** — A1, A2, B5, C4, D1 |
| **Em aberto** | **14** |
| Checklist smoke T7 (200 · etapas · SALVAR) | **2/3** |

Checklist operacional:

1. `GET …/cadastro/etapas` → **200** ☑ (T7)
2. Etapas visíveis (~**3**) ☑ (T7)
3. **SALVAR** → listagem ☐ (próximo smoke)

Deploy: [`roteiro-deploy-homolog-operador.md`](roteiro-deploy-homolog-operador.md) § **3b** · ≥ **`3c061b6`**.

---

## Changelog deste doc

| Data | Nota |
|------|------|
| 2026-10-29 | Colunas **Solução aplicada / Resultado / Próxima solução**; feedback smoke “melhorou pouco” |
| 2026-10-28 | Versão inicial + P0 `3c061b6` |
