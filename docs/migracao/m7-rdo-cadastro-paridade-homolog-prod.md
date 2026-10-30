# O que falta em homolog vs produção (lista completa)

**Trilha:** EQ-R · **Rota:** `/Rdo/Cadastro` · **Prod:** `#/rdo/cadastro` (AngularJS) · **Homolog:** React M7 **7a**  
**Referência legado:** `Equipamentos/rdoappProject/Client/Views/Rdo/cadastro.html` · **BFF:** `GET/POST /api/bff/rdos/cadastro/*`  
**Atualizado:** 2026-10-29 · **Git homolog:** **7a-P1** (B3/B4/B6) + `3c061b6` (P0) + `498ebc4` (7a) — branch `ci/homolog-ec2-s3-ssm`

| Coluna | Significado |
|--------|-------------|
| **Print** | Evidência Lucio (prod × homolog), quando houver |
| **1) Solução aplicada** | O que já está no Git / deploy |
| **2) Resultado** | O que aparece no homolog **hoje** (smoke **T7**) |
| **3) Próxima solução** | Próximo incremento planejado |

## Lista completa (homolog vs produção)

| # | Print | Produção | Homolog (gap) | 1) Solução aplicada | 2) Resultado | 3) Próxima solução |
|---|-------|----------|---------------|---------------------|--------------|-------------------|
| **A1** | — | Accordion de etapas (OBRA, TESTE ETAPA, EQUIPAMENTOS…) com tarefas dentro | Lista/accordion simplificado; antes **500** em `cadastro/etapas` | **7a-P0** `3c061b6` — `TarefaAgrupadorQuery` | **T7** 29/10 **23:11** · **200** · **~3 etapas** · *melhorou pouco* | **7a-P2** tabela · **7a-P4** accordion visual |
| **A2** | — | Checkbox **por tarefa** na linha da tabela | Checkbox na lista simples (sem tabela) | **7a** `498ebc4` | Marca tarefa; **≠** layout prod | **7a-P2** com **C4**, **C7** |
| **B1** | — | Título do painel **“RDO”** | **“Gerar RDO”** | — | ≠ prod | **7a-P4** |
| **B2** | 2–3 | Ícones clima (nascer / sol / lua) nos radios | Só rótulos de texto | — | Sem ícones | **7a-P4** |
| **B3** | **4** | Bloco **Motivos de improdutividade** (10 toggles) | **Ausente** na UI | **7a-P1** — UI 10 checkboxes + `Improdutividade` no save (`RdoCadastroPage` / `RdoCadastroSaveService`) | Aguarda smoke pós-deploy | Validar homolog (T7b) |
| **B4** | **5** | **Comentários** (textarea) + botões **positivo / negativo** | **Ausente** | **7a-P1** — textarea + 👍/👎 (`tipoComentarioGeracao` 1/2) + POST | Aguarda smoke pós-deploy | Validar homolog (T7b) |
| **B5** | **1** | Campo **data** abre **calendário** (`datepicker-here`) | Input texto + máscara `dd/mm/aaaa`, **sem** calendário | Máscara React **7a** | Só digitação manual | **7a-P4** datepicker (paridade legado) |
| **B6** | **2–3** | **Tempo** e **chuva**: radios **sem** opção marcada ao abrir | **Bom** + **Sem chuva** já selecionados | **7a-P1** — estado vazio no React; bootstrap sem defaults; validação save UI + BFF | Aguarda smoke pós-deploy | Validar homolog (T7b) |
| **C1** | **6** | Cabeçalho **“ETAPAS / TAREFAS”** | Só **“Tarefas”** | — | Título errado | **7a-P4** copy |
| **C2** | **6** | **“Habilitar relatório fotográfico?”** **Sim / Não** | **Ausente** | — | Pergunta não aparece | **7a-P3** |
| **C3** | **6–7** | Accordion: faixa azul e ícone **+** no cabeçalho | **▶ / ▼** seta, estilo simples | CSS mínimo **7a** | **+** vs seta | **7a-P4** markup/CSS legado |
| **C4** | **7–8** | Ao expandir etapa: **tabela** com **DESCRIÇÃO DA TAREFA**, **STATUS**, **QTD. COLABORADORES**, **QTD. EQUIPAMENTOS**, **AÇÕES** | Só lista (descrição + checkbox) | Tag **dia anterior** **7a** | Colunas da tabela ausentes | **7a-P2** + DTO BFF |
| **C5** | **7–8** | **Editar tarefa** (lápis em **AÇÕES**) | Ausente | — | Coluna AÇÕES incompleta | **7a-P2** |
| **C6** | — | **Fotos** / galeria (quando C2 = Sim) | Ausente | — | — | **7a-P3** |
| **C7** | **7–8** | Marcar etapa: **apenas** checkbox **“selecionar tudo”** no `<thead>` | Botão **“Marcar etapa” / “Desmarcar etapa”** | `selectAllEtapa()` **`498ebc4`** | Botão **extra** ≠ prod | **7a-P2** remover botão; checkbox no cabeçalho |
| **D1** | **8–10** | **VOLTAR** + **GERAR RDO** (ícones) | **Voltar** + **SALVAR** | Voltar **7a** | Label **SALVAR** em vez de **GERAR RDO** | **7a-P4** texto + ícone |
| **D2** | — | Substituir RDO / copiar dia anterior (fluxo legado) | `window.confirm` genérico | **7a** + **P0** save | **GERAR RDO** não validado no T7 | Reteste após **D1** |
| **E1** | — | Editar RDO existente | Só listagem **7a** | P5a | Fora do cadastro novo | **7b** |
| **E2** | — | PDF | Prod only | — | — | **7c** |
| **E3** | — | Assinar | Prod only | — | — | **7d** |
| **E4** | — | Redesign SPA global | Adiado | UI-M3 | — | Após **7a-P1…P4** |

**Totais (linhas A–E):** **21** · **Parciais T7:** **5** (A1, A2, B5, C4, D1) · **Em aberto:** **16** · Checklist smoke **T7:** **2/3** · Detalhe tentativa: [`homolog-p5-rdo-tentativas.md`](homolog-p5-rdo-tentativas.md) linha **T7**.

---

## Fases de entrega (mapa)

| Fase | Escopo | Git |
|------|--------|-----|
| **7a** | SPA + BFF bootstrap, etapas, save | `498ebc4` |
| **7a-P0** | Fix **500** `cadastro/etapas` | `3c061b6` |
| **7a-P1** | B3, B4, B6 | ☑ (commit desta entrega) |
| **7a-P1a** | Hotfix só B6 (opcional) | — (incorporado em P1) |
| **7a-P2** | C4, C5, C7 | ☐ |
| **7a-P3** | C2, C6 | ☐ |
| **7a-P4** | B1, B2, B5, C1, C3, D1 | ☐ |
| **7b–7d** | E1–E3 | ☐ |

---

## Changelog deste doc

| Data | Nota |
|------|------|
| 2026-10-29 (d) | **7a-P1** Git — col. **1)** B3, B4, B6 |
| 2026-10-29 (c) | **Uma** tabela lista completa + coluna **Print**; removidas seções A–E duplicadas |
| 2026-10-29 (b) | B6, C7; matriz 21 itens |
| 2026-10-29 | Colunas solução + T7 |
| 2026-10-28 | Versão inicial + P0 |
