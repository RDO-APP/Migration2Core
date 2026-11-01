# Página 5 — Lista de RDOs (`/Rdo/Index`) · log de tentativas

**Rota homolog:** `https://homolog.sistema.rdoapp.com.br/Rdo/Index`  
**BFF:** `GET /api/bff/rdos` · `GET /api/bff/rdos/status-options` · `GET /api/bff/shell`  
**Prod ref:** `#/rdo/index` · `RdoModel.Lista`  
**Irmão:** [`homolog-p5-rdo-tentativas.md`](homolog-p5-rdo-tentativas.md) · roteiro [`roteiro-deploy-homolog-operador.md`](roteiro-deploy-homolog-operador.md)

---

## Tabela de tentativas

| # | Data/hora (BR) | Sintoma | Solução aplicada | Resultado | Aprendizado | Próxima solução |
|---|----------------|---------|------------------|-----------|-------------|-----------------|
| **L1** | 2026-10-27 ~11:00 | — | BFF listagem `056eb29` | **200** · tabela com RDOs · ações stub | Lista Core funciona **sem** W3 extra | Seguir W1/W2 visual |
| **L2** | 2026-10-27 pós-`fd8a144` | Botões cinza | CSS W1/W2; PDF/assinar/editar `disabled` | Listagem **OK** · botões desabilitados de propósito | Não mexer no query da lista para “ligar ícone” | W3 ações + RBAC |
| **L3** | **2026-10-30 ~22:10** | Banner **Erro 500 no servidor (lista RDO).** · tabela vazia · UI/shell OK | Deploy W3+7b: `select new RdoListRow(...)` no EF + `RdoPdfService` no mesmo controller da lista | **500** `GET /api/bff/rdos` · lista sumiu | Qualquer extra no BFF da lista (EF record / DI PDF) quebra a P5 inteira | Tirar `record` do IQueryable |
| **L4** | **2026-10-30 ~22:15** (código) · smoke **2026-10-31 ~10:48** | Mesmo banner genérico (sem tipo de exception) | Projeção **anônima** no SQL; try/catch texto no List | **Falhou no browser** — banner **idêntico** a L3 (HTML 500, front esconde o detalhe) | (1) catch em texto ainda vira HTML no pipeline; SPA mascara. (2) ou L4 **não** chegou na EC2. (3) causa real pode ser **DI**: construir `BffRdoController` carrega ReportViewer e derruba **todas** as actions `/api/bff/rdos*` | Isolar PDF noutro controller; JSON `{ message }`; `ToDictionary` sem chave duplicada; dono W3 não pode derrubar a lista |
| **L5** | **2026-10-31 ~11:17** (smoke) | Lista voltou; **Assinar e Editar sumiram**; só PDF; clique PDF → HTML `/Home/Error` | Isolar PDF do GET lista | **Lista 200 OK** · W3 ícones ocultos (`showAssinarRdo`/`showEditarRdo` false/undefined) · PDF 500 HTML (`UseExceptionHandler`) | Não esconder ícone por RBAC (prod mostra 3 colunas). API `/api` não pode cair em `/Home/Error`. NumberFormat read-only no ctor do PDF | **L6** sempre 3 ícones; JSON no PDF; clone NFI; ExceptionHandler só fora de `/api` |
| **L6** | **2026-10-31 ~11:29** (smoke) | 3 ícones voltaram; PDF JSON: `InvalidCastException: DBNull → String` | L6 front + ExceptionHandler `/api` | **Ícones OK** · PDF ainda falha no RDLC | ReportViewer não aceita célula nula em campo string (horímetro/comentário) | **L7** `ReplaceDbNulls` + `?? ""` |
| **L7** | **2026-10-31 ~11:32** (código) · smoke **~11:58** zip `20261031-115615` SSM **Success** | Mesmos ícones cinza; PDF clicável (tooltip Imprimir) → `InvalidCastException: DBNull → String` | `ReplaceDbNulls` só em **linhas existentes** | **Falhou** — RDO 30/10 tem 0 tarefas/colab/equip; datasets **sem linhas**; RDLC `Fields!x.Value` = DBNull | L7 não muda UI (Assinar/Editar **devem** ficar disabled em status **Gerado** + perfil **t**). PDF quebra em dataset **vazio**, não só célula null | **L8** schema `dtDadosRdo` + 1 linha placeholder em todo dataset; datas/qtd/id como string; foto só se houver imagem |
| **L8** | **2026-10-31 ~12:15** (código) · smoke **~12:26** | Clique PDF → **mesmo** `InvalidCastException: DBNull → String` | Schema + linha placeholder + DTO shell | **Falhou** (RDLC `UCase(Fields!DescricaoCargo.Value)` faz cast DBNull→String **dentro** do ReportViewer) | L7/L8 tratam DataTable; o motor RDLC ainda avalia Fields nulos. Parar de usar ReportViewer no homolog | **L9** QuestPDF, mesmos dados, sem RDLC |
| **L9** | **2026-10-31 ~12:30** (código) · zip `20261031-123930` SSM **12:41 Success** | Mesmo `InvalidCastException: DBNull → String` | QuestPDF no disco do PC | **Falhou no browser** — o erro ainda é **ReportViewer**. Zip 12:39 = **L8+DTO**, publish **antes** do QuestPDF entrar no compile | Publish e SSM não levam código que ainda não estava no `dotnet publish`. Banner sem `[L9-QuestPDF]` = zip velho | **L10** publish **agora** (QuestPDF + PDF após GERAR RDO). Banner tem de mudar ou o PDF baixa |
| **L10** | **2026-10-31 ~12:55** (código) · zip `20261031-130054` SSM **13:02** | `Erro ao gerar PDF [L9-QuestPDF]. InvalidCastException: DBNull → String` | QuestPDF + PDF no GERAR RDO | **Falhou** — marca prova que **não** é mais RDLC. EF materializa `Rdo`/`Obra` com `string` e coluna **NULL** (clima opcional no 30/10) | Pomelo: NULL MySQL + `string` não-nullable = o mesmo InvalidCast. Lista não carrega a entidade inteira | **L11** `Select` + `?? ""` no RDO/obra/tarefas/assinaturas/acidentes |
| **L11** | **2026-10-31 ~13:08** (código) · zip `20261031-131244` SSM **13:15** | `[L9-QuestPDF] PDF.gerar: MySqlException: Unknown column 't.tar_dt_medicao_horimetro_inicial'` | `?? ""` no RDO/obra | **Avanço** — saiu do DBNull; query de tarefas pede coluna que **não existe em `homol_rdoapp`** (existe em prod) | Schema homolog ≠ prod. Lista/cards não selecionam horímetro, por isso não quebravam | **L12** PDF **não** lê `tar_dt_medicao_horimetro_*` (Hi/Hf/Ht vazios no homolog) |
| **L12** | **2026-10-31 ~13:40** (código) · smoke **~14:40** `RDO_31_10_2026.pdf` | — | Query tarefas sem horímetro | **OK** · PDF QuestPDF baixou (obra, clima, comentário, assinaturas) | Homolog gera documento; layout ≠ RDLC prod | Paridade visual QuestPDF (não voltar ao ReportViewer) |
| **L13** | **2026-10-31 ~21:25** (código) | Até **29/08** PDF baixa; a partir de **30/08** `[L9-QuestPDF] PDF.gerar: InvalidCastException DBNull→String` | `(string?)` em **todas** as queries do PDF (Pomelo `?? ""` ainda chama GetString); tipos sem materializar entidade; concatenar etapa/tarefa **depois** do SQL; `PDF.cargos` / `PDF.imagens` / etc. | **Pendente smoke** após publish+SSM | 29/08 vs 30/08: mesmo status/tarefas; 30/08 entra foto/comentário/cargo NULL. L12 só cobriu RDO vazio 31/10 | Smoke **27/08 e 30/08**. Banner tem de ser `PDF.imagens` (ou o PDF baixa). |
| **L14** | **2026-10-31 ~21:50** (código) | PDF gera, layout ≠ RDLC prod | QuestPDF espelha blocos do `Rdo_def.rdlc` (cabeçalho 2×3, tarefas agrupadas, MO∥equip, clima∥acidentes, comentários/assinaturas) | **Pendente smoke** | Prints 28/08 = ouro | Publish+SSM; comparar 28/08 homolog × prod |
| **L15** | **2026-11-01** | Homolog 27/08: sem logo; faixa **RELATÓRIO FOTOGRÁFICO / Sem fotos neste RDO** (prod não tem) | Logo: `wwwroot/images/logo.jpg` + `Assets/images`; fotos só se houver bytes | **Pendente smoke** | Desktop = homolog; Downloads `(1)` = prod | Publish D→E |

### Classes

| Classe | Significado |
|--------|-------------|
| **F-BFF** | `GET /api/bff/rdos` ≠ 200 |
| **F-401** | Obra não selecionada |
| **F-SPA** | BFF 200, UI vazia |
| **F-cache** | Deploy OK, JS antigo |

---

## L5 — o que muda no código (antes do deploy)

1. **Lista ≠ PDF:** `BffRdoController` deixa de injetar `RdoPdfService`. PDF = `POST /api/bff/rdos/{id}/pdf` em controller separado. ReportViewer não carrega ao abrir a P5.
2. **Dono W3 não mata a lista:** `GetDono…` em try/catch; `ToDictionary` via `GroupBy` (obra com 2 linhas do mesmo colaborador não gera `ArgumentException`).
3. **Erro visível:** 500 devolve JSON `{ message }`; o front mostra esse texto no banner.

---

## Smoke após L5 (Ctrl+F5)

- [ ] Login → Escolher obra → `/Rdo/Index`
- [ ] F12 → `GET /api/bff/rdos?page=1` **200** + `items[]`
- [ ] Se 500: copiar o **texto** da resposta (não só o print da tela)
- [ ] PDF: teste **depois** da lista OK

---

## L13 — smoke (Ctrl+F5)

- [ ] Imprimir RDO **27/08** (ou 29/08) — ainda baixa
- [ ] Imprimir RDO **30/08** — PDF baixa **ou** banner `[L9-QuestPDF] PDF.imagens:` / `PDF.tarefas:` / `PDF.cargos:` (não mais só `PDF.gerar`)
- [ ] Zip do publish **depois** desta alteração (não reusar zip L12)
