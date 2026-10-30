# O que falta em homolog vs produção (lista completa)

**Trilha:** EQ-R · **Rota:** `/Rdo/Cadastro` · **Prod:** `#/rdo/cadastro` · **Homolog:** React M7 **7a**  
**Referência legado:** `cadastro.html` · `custom.css` (`fieldset legend`, `.panel fieldset`) · BFF cadastro  
**Atualizado:** 2026-10-30 — **D2 ☑ T7g** · **7a-P5 ☑ T7h** (SELECIONAR TUDO + save E2E) · pend. **M7-FOTOS-01/02** (thumbs + `rdo_imagem`)

| Coluna | Significado |
|--------|-------------|
| **Bloco** | **1** = caixa branca · **2** = etapas/tarefas + fotográfico + rodapé |
| **2) Resultado T7e** | Último smoke Lucio (pós P4b) |
| **3) P4c / T7f** | Implementado no Git local; validar no browser após deploy |

## Lista completa (homolog vs produção)

| # | Bloco | Produção (referência) | 2) **T7e** | 3) **P4c → reteste T7f** |
|---|-------|----------------------|------------|---------------------------|
| **F0** | **1** | `div.panel` branca única | **OK** | — |
| **B1** | **1** | `h3` “RDO” | **OK** “Gerar RDO” | — |
| **B0** | **1** | Tipografia uniforme bloco 1 | **Gap** | **P4c** — `.rdo-bloco1-label` 14px em Data/Clima/Comentários + legend |
| **B5** | **1** | Data + calendário | **Parcial** | **P4c** — `max-width:280px` · `onFocus`/`onClick` → `showPicker()` |
| **B6** | **1** | Tempo/chuva vazios | **OK** | — |
| **B6a** | **1** | Tempo \| Chuva 50%+50% | **Parcial** empilhado | **P4c** — `.row.rdo-clima-cols` |
| **B6b** | **1** | Legend sobre borda | **Gap** | **P4c** — `display:table` + `background:#fff` |
| **B2** | **1** | Ícones clima | **OK** | — |
| **B3** | **1** | Toggles | **OK** | — |
| **B3a** | **1** | Improd legend + toggles | **Parcial** | **P4c** — legend B6b + toggles 13px |
| **B4** | **1** | Comentários | **OK** | — |
| **B4a** | **1** | Thumbs grandes | **Parcial** | **P4c** — FA **48px** + `.rdo-thumb-inner` 125px |
| **C1–C7, A1, A2, D1** | **2** | Etapas/tarefas/rodapé | **OK** (T7e) | — |
| **C6** | **2** | Galeria thumbs + AMPLIAR | **Gap** (só lupas) | **P4d/C6** CSS · reteste |
| **C8** | **2** | **Relatório fotográfico (regra RF1–RF6)** | **Parcial** — ver § abaixo | **7a-P5** |
| **D2** | **2** | Confirm salvar + **GERAR RDO** E2E | **OK** smoke **T7g** | — |
| **E1–E4** | — | Pós-7a | Fora escopo | **7b–7d** |

### Resumo smoke **T7e** (baseline antes P4c)

| # | Feedback | Itens |
|---|----------|--------|
| 0 | Fontes desiguais | **B0** |
| 1 | Data larga; calendário só botão | **B5** |
| 2 | Clima empilhado | **B6a** |
| 3 | Legends na linha | **B6b**, **B3a** |
| 4 | Thumbs pequenos | **B4a** |
| 5 | Etapas/tarefas OK | bloco 2 |

---

## Regra de negócio — **Habilitar relatório fotográfico?**

Referência prod: `rdoappProject/Client/Views/Rdo/cadastro.html` · `RdoController.js` (`mostrarFotos`, `acordeonTarefas`, `selectTarefa`, `listaImagems`).

| # | Comportamento (prod) | Homolog React hoje |
|---|----------------------|-------------------|
| **RF1** | Pergunta **só** se existir etapa com tarefas na data (`etapas.length > 0`). Default **Não**. | ☑ |
| **RF2** | Ao marcar **Sim**, exibir bloco **“Fotos da(s) Tarefa(s)”** **somente** quando houver **≥1 tarefa marcada** no grid ETAPAS/TAREFAS (`mostrarFotos && acordeonTarefas.length > 0`). | ☑ condição equivalente (`mostrarFotos && acordeonTarefas.length > 0`) |
| **RF3** | O bloco fotográfico lista **apenas as tarefas selecionadas** (derivadas das etapas carregadas para a data). Etapas sem tarefa marcada **não** entram no acordeon de fotos; cada tarefa selecionada traz a galeria **`listaImagem`** retornada com a etapa/tarefa (API `ObterTarefasParaRDO` / BFF `GET …/cadastro/etapas`). | ☑ accordion por tarefa · **não** agrupa por título de etapa (igual prod) |
| **RF3b** | Por tarefa: **0 fotos** → mensagem *“Nenhuma foto adicionada nesta tarefa.”* · **N fotos** → **N** miniaturas (~200×200) + lupa AMPLIAR no canto (prod `custom.css` `.galeria label`). | ☑ **C6** — `NormalizeImagemCaminho` → `/Uploads/Imagens/…` · static `/Uploads` · CSS thumb + checkbox · smoke pós-deploy |
| **RF4** | Marcar/desmarcar tarefa no grid **inclui/remove** a tarefa em `acordeonTarefas` em tempo real. | ☑ `selected` → `acordeonTarefas` |
| **RF5** | Por tarefa: **SELECIONAR TUDO** + checkbox em cada foto; seleção alimenta `cadastroParam.listaImagems` no **Salvar**. | ☑ React `selectedImagens` + POST `listaImagems` |
| **RF6** | No save/PDF: flag **`gerarRelatorioFotografico`** (= `mostrarFotos`) + imagens escolhidas persistidas (`RdoModel.IncluirImagens`). | ☑ save `SyncRdoImagensAsync` + flag no POST · PDF **7b** ☐ |

**Critério de aceite (smoke C8):** com **Sim**, marcar tarefas em **≥1 etapa** → aparece seção de fotos **só** dessas tarefas, com fotos quando existirem na medição; desmarcar tarefa some do acordeon; após **7a-P5**, seleção de fotos e save alinhados ao legado.

---

## Fases de entrega (mapa)

| Fase | Escopo | Estado |
|------|--------|--------|
| **7a-P4b** | Accordion, 📅, CSS inicial | ☑ deploy T7e |
| **7a-P4c** | B0, B5, B6a/b, B3a, B4a | ☑ código · ☑ smoke visual **T7f** (~9/10) |
| **7a-P5** | **C8 / RF1–RF6** — checkboxes galeria, `listaImagems`, `gerarRelatorioFotografico` no save/BFF | ☑ **T7h** (SELECIONAR TUDO + save E2E) |
| **D2** | **GERAR RDO** E2E (confirm + listagem) | ☑ **T7g** 2026-10-30 |
| **7b–7d** | E1–E3 (editar RDO, PDF, assinar) | ☐ |

### Pendências desta página (`/Rdo/Cadastro`)

| ID | O quê | Estado |
|----|--------|--------|
| **M7-FOTOS-01** | Miniaturas e lupa: validar `dsCaminho` BFF, HTTP **200** em `/Uploads/Imagens/…`, `FileStorage:UploadsRoot` na EC2; slots cinza = `ima_ds_caminho` vazio ou arquivo ausente no disco | ☐ |
| **M7-FOTOS-02** | Save com fotos marcadas: POST `listaImagems`, linhas em **`rdo_imagem`**, RDO “Gerado” com QTD tarefas/colab coerente | ☐ parcial (E2E OK · QTD 0/0/0 em T7g conferir) |

Detalhe: [`homolog-p5-rdo-tentativas.md`](homolog-p5-rdo-tentativas.md).

---

## D2 — validações no **Salvar** (paridade prod)

Referência: `RdoController.js` `salvar()` — só **data** (obrigatória/válida) e fluxo de **confirmações**; **não** exige tempo/chuva.

| Campo | Prod | Homolog BFF (`RdoCadastroSaveService`) |
|-------|------|----------------------------------------|
| Data | Obrigatória | Igual |
| ≥1 tarefa | Implícito no POST | Igual |
| Tempo (manhã/tarde/noite) | Opcional → PDF “Não Informado” | Opcional (`NormalizeLegadoChar` → NULL) |
| Chuva | Opcional | Opcional — **removida** regra errada “Preencha a chuva…” |
| Transação MySQL | N/A (EF6 legado) | `CreateExecutionStrategy()` + `BeginTransaction` (retry EF Core) |

Erro **`MySqlRetryingExecutionStrategy` … user-initiated transactions** = pacote na EC2 **sem** o wrapper acima; corrigido no working tree local — **republicar Core** (sem `git pull` que sobrescreva).

---

## Changelog deste doc

| Data | Nota |
|------|------|
| 2026-10-30 (g) | **D2** tabela validações salvar · chuva opcional · execution strategy MySQL |
| 2026-10-30 (f) | Regra **relatório fotográfico** (RF1–RF6) · item **C8** · fase **7a-P5** |
| 2026-10-30 (e) | **P4c** implementado · bundle `index-CbCyhEWE.js` · T7f deploy pendente |
| 2026-10-30 (d) | **T7e** matriz |
| 2026-10-30 (c) | **T7d** + **P4b** |
