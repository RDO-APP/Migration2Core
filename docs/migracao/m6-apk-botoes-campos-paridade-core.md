# M6 — Paridade botões/campos Apontador × Web (EQ-L / Core)

**Trilha:** EQ-M · **Atualizado:** 2026-11-23 12:54 BRT  
**Repos:** `EquipamentosMobile` + contrato Core `/api/tarefa/*` JWT  
**Regra:** cada botão/campo do App = mesma regra de negócio da Web (`cards.html` / `TarefaController.js`), via hop API no mesmo esquema auth (Bearer homolog).

## Matriz — botões principais (card)

| # | Web (EQ-L) | App | API | Status |
|---|------------|-----|-----|--------|
| 1 | ⋮ status rápido | `taskCard` → `atualizarStatusTarefa` | `POST /api/tarefa/AtualizarStatus` | ☑ salva no histórico (smoke Lucio) |
| 2 | Relógio (histórico) | `history-screen` | `POST /api/tarefa/CarregarHistoricoTarefa` | ☑ lista |
| 3 | + Nova medição | `AddRegisterModal` | `ObterTarefa` + `Salvar` (`novaMedicao:true`) | ☑ após fix status default |
| 4 | Impressora controle horas | `report-print-screen` | `GerarRelatorioControleHoras…` | 🟡 código fix 22/11 · **smoke EAS** |
| 5 | Olho / lápis cadastro | — (web SPA) | BFF / legado | fora Apontador campo |

## Matriz — botões/campos secundários (histórico + formulário)

| # | Web | App | Campo/ação | Regra paridade | Status 2026-11-22 |
|---|-----|-----|------------|----------------|-------------------|
| S1 | EDITAR linha histórico | `editModal` → `loadTarefa` + `handleSaveEdit` | load | `ObterTarefa(idLinha)`; imagens **soft-fail** (não 404-bloqueia) | ☑ código |
| S2 | EDITAR → quantidade | input `qtdConstruida` | campo | Web `cadastroParam.qtdConstruida`; App **não** usar `quantidade` (pools) | ☑ código |
| S3 | EDITAR → Salvar | `handleSaveEdit` | save | `novaMedicao:false`; status/horímetro/qtd/código; `IdObra` = obra real | ☑ código |
| S4 | + status default | `AddRegisterModal` init | status | Web mantém status atual da tarefa (ex. **Pausada**); App **não** forçar `2` | ☑ código |
| S5 | + código paralisação | `pausedCode` | campo | Se status=4, obrigatório (igual web) | ☑ |
| S6 | + quantidade | `qtdConstruida` | campo | `toFiniteNumber` aceita BR (`1,5`); payload numérico | ☑ código |
| S7 | + horímetro inicial / final | carrega último final | campo | Inicial = último Final (readonly); **Final inicia 0** (= Web legado) · App alinhado 23/11 | ☑ |
| S8 | Histórico `idObra` | `history-screen` keyBinding | bind | Equipments: bind=`obraId`(tarefa); `idObra`=obra real (**não** id etapa) | ☑ código |
| S9 | Impressora → **GERAR EXCEL** | `gerarRelatorio` + `downloadFileMobile` | sub-botão | Datas **`dd/MM/yyyy`** (não ISO); arquivo **`.xls`** + mime `application/vnd.ms-excel` (= Core **HTML.xls**). **Não** OpenXML/`xlsx` (corrompe) | ☑ código · 🟡 smoke |
| S10 | Impressora → **GERAR PDF** | `gerarRelatorio` + QuestPDF | sub-botão | Mesmo período; base64 normalizado; BadRequest → mensagem no modal; PDF com páginas | ☑ código · 🟡 smoke |
| S11 | + / EDITAR → qtd × status | `qtdConstruida` | campo | Web: só editável status **1/2/3**; Pausada limpa/desabilita | ☑ código 23/11 |
| S12 | + / EDITAR → **hora ini ≤ hora fim** | `validateEquipamentosMedicao` | save | Web **não** valida no JS; App **bloqueia** (Lucio 23/11) — mensagem igual estilo horímetro | ☑ código 23/11 |

## Matriz — validações Nova Medição (legado × Core10 × App)

Fontes (2026-11-23):  
- **EQ-L:** `TarefaController.js` `salvar` · `cards.html`  
- **Core10:** `validateTarefaForm` (`tarefaCadastroShared.ts`) · `NovaMedicaoModal.tsx` · `TarefaCadastroSaveService` (`DiffHorasRelogio`)  
- **App:** `validateEquipamentosMedicao` (`equipamentos.tsx`)

Só campos do **modal de medição** (não cadastro completo de tarefa).

| # | Regra | EQ-L (legado) | Core10 (homolog) | App | Nota |
|---|-------|:-------------:|:----------------:|:---:|------|
| V1 | Status ≤ 0 → erro | ☑ JS | ☑ client+server | ☑ | alinhado |
| V2 | Status 4 → código | ☑ JS | ☑ client+server | ☑ | alinhado |
| V3 | Data medição se ≠ Planejada / nova | ☑ JS | ☑ client+server | ☑ | alinhado |
| V4 | Formato hora | ☑ `hourTime` | ☑ `timeToMinutes` em `validateTarefaForm` 23/11 | TimePicker | alinhado |
| V5 | **Hora ini > hora fim** → **bloquear save** | ❌ JS | **☑** client+server 23/11 | **☑ bloqueia** | Core alinhado App (legado JS ainda frouxo) |
| V6 | Horímetro ini > fim → erro | ☑ JS toastr | **☑** client+server 23/11 | **☑ bloqueia** | alinhado legado |
| V7 | Qtd só status 1/2/3 | ☑ ng-disabled | ☑ `disabled` modal/página | ☑ | alinhado |
| V8 | Datas planejadas ini>fim | ☑ JS (cadastro) | ❌ `validateTarefaForm` · server tem checks obra | N/A + | cadastro, não modal campo |
| V9 | `rdoAssinado` trava | ☑ | ☑ `locked` | 🟡 esconde EDITAR | |
| V10 | Limite fotos licença | ☑ | 🟡 MaxFotoBytes server | ⬜ | App backlog |

**Conclusão Core10 (23/11):** **V5/V6** client+server ☑ alinhados ao App. Legado JS ainda frouxo em V5 (não bloqueia hora). Residual App: **V10** max fotos licença.

### Residual sub-botões (não nesta leva)

| Item | Nota |
|------|------|
| Códigos paralisação | Modal/scroll no tip; contagem vs prod RDS = gap check Dimas, não blocker impressora |
| GERAR APONTAMENTO | Equipments **off** (só piscinas) |
| Laudo piscinas | N/A Apontador Equipamentos |

## Bugs corrigidos nesta leva

1. **EDITAR 404 load:** `Promise.all(ObterTarefa, ObterImagens)` — 404 em imagens derrubava o form; + trailing slash em rotas Core.  
2. **Imports trocados** em `edit-register-screen` (save equipamentos ↔ piscinas).  
3. **Load gravava `quantidade`** em vez de `qtdConstruida` → campo vazio / save 0.  
4. **+ default status=2** → agora `obterTarefa.status` (ex. Pausada).  
5. **`handleSaveEdit` equipamentos** era cópia quebrada (pools/`status` undefined).  
6. **Impressora Excel corrompido:** WIP mime/`xlsx` vs Core HTML.xls → revert `.xls` + `vnd.ms-excel`.  
7. **Impressora PDF vazio / erro opaco:** payload ISO → enviar BR; `normalizeReportBase64`; surfacer `BadRequest.message`.  
8. **Qtd em Pausada** editável no App → paridade Web (disable + clear).  
9. **Hora inicial > final** aceita no App → `validateEquipamentosMedicao` bloqueia.  
10. **Horímetro Final** no **+** iniciava = Inicial → agora **0** (= Web).  
11. Core `validateTarefaForm` + server: hora/horímetro ini>fim (paridade App).

## Smoke (Lucio · APK/EAS após merge)

1. Card com tarefa **Pausada** → **+** → status = Pausada + código preenchido · qtd bloqueada.  
2. Alterar status / quantidade / Salvar → linha no histórico.  
3. Relógio → **EDITAR** → form carrega (sem HTTP 404) → mudar quantidade → Salvar → lista atualizada.  
4. ⋮ status rápido → histórico (já OK).  
5. Impressora → **GERAR EXCEL** abre (aviso formato = pós-M10 ClosedXML).  
6. Impressora → **GERAR PDF** com páginas (não 0 bytes).  
7. **+** → Hora Inicial **depois** da Final → SALVAR → erro; inverter → salva.  
8. **+** → Horímetro Final inicia **0** · Final &lt; Inicial → erro.  
9. Web Nova Medição (homolog pós-deploy) → mesmos bloqueios hora/horímetro.

## Rotas App (sem `/` final no Core)

`ObterTarefa` · `ObterImagensTarefa` · `CarregarHistoricoTarefa` · `GerarRelatorioControleHorasEquipamentoTarefa` · `Salvar` · `AtualizarStatus`.
