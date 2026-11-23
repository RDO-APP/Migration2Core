# M6 — Paridade botões/campos Apontador × Web (EQ-L / Core)

**Trilha:** EQ-M · **Atualizado:** 2026-11-22  
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
| S7 | + horímetro inicial | carrega último final | campo | `CarregarHorimetroFinalUltimoHistoricoTarefa` | ☑ |
| S8 | Histórico `idObra` | `history-screen` keyBinding | bind | Equipments: bind=`obraId`(tarefa); `idObra`=obra real (**não** id etapa) | ☑ código |
| S9 | Impressora → **GERAR EXCEL** | `gerarRelatorio` + `downloadFileMobile` | sub-botão | Datas **`dd/MM/yyyy`** (não ISO); arquivo **`.xls`** + mime `application/vnd.ms-excel` (= Core **HTML.xls**). **Não** OpenXML/`xlsx` (corrompe) | ☑ código · 🟡 smoke |
| S10 | Impressora → **GERAR PDF** | `gerarRelatorio` + QuestPDF | sub-botão | Mesmo período; base64 normalizado; BadRequest → mensagem no modal; PDF com páginas | ☑ código · 🟡 smoke |

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

## Smoke (Lucio · APK/EAS após merge)

1. Card com tarefa **Pausada** → **+** → status = Pausada + código preenchido.  
2. Alterar status / quantidade / Salvar → linha no histórico.  
3. Relógio → **EDITAR** → form carrega (sem HTTP 404) → mudar quantidade → Salvar → lista atualizada.  
4. ⋮ status rápido → histórico (já OK).  
5. Impressora → **GERAR EXCEL** abre no Sheets/Excel (não “arquivo corrompido”).  
6. Impressora → **GERAR PDF** com páginas (não 0 bytes).

## Rotas App (sem `/` final no Core)

`ObterTarefa` · `ObterImagensTarefa` · `CarregarHistoricoTarefa` · `GerarRelatorioControleHorasEquipamentoTarefa` · `Salvar` · `AtualizarStatus`.
