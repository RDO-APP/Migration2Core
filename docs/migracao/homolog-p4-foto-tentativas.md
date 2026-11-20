# P4 / RDO — Foto medição · log de tentativas

**Trilha:** EQ-R · **Homolog:** `homolog.sistema.rdoapp.com.br` · obra **MIGRAÇÃO 15/11**  
**Canônico código:** `TarefaCadastroSaveService.SyncNovasImagensAsync` · `RdoCadastroQueryService.LoadImagensPorAgrupadorAsync` · `NovaMedicaoModal`  
**Regra:** toda tentativa nova = **uma linha** na tabela abaixo (erro → diagnóstico → correção → resultado → próxima).

---

## Fluxo esperado (prod × homolog)

1. Nova Medição / cadastro tarefa → **Escolher** + **Adicionar foto** + **SALVAR**  
2. BFF grava arquivo em `FileStorage:UploadsRoot/Imagens/{obra}/{tarefa}/{yyyyMM}/` + row `imagem` (`ima_id_tarefa`)  
3. Novo RDO → **Habilitar relatório fotográfico = Sim** + marcar tarefas → galeria lê `GET /api/bff/rdos/cadastro/etapas` → `listaImagem[]`  
4. Sem row em `imagem` → UI: *“Nenhuma foto adicionada nesta tarefa.”* (não é bug do radio **Sim**)

---

## Tentativas

| # | Data (BR) | Erro / sintoma | Diagnóstico | Correção | Resultado | Solução proposta / próxima |
|---|-----------|----------------|-------------|----------|-----------|----------------------------|
| **F0** | 2026-11-03 | Preview Foto no modal; RDO sem fotos | UI só `blob:` — **não** POST base64 · BFF sem `ListaImagens` | Adiado O6/O7 | Preview OK · **0** persist | Implementar persist |
| **F1** | 2026-11-15 | RDO Sim + tarefas → *Nenhuma foto…* | Confirmado: save não enviava fotos | Código **M7-FOTO-PERSIST** tip **`51e0dfe`** (base64→disco+`imagem`) | Publish **falhou** CS1503 `Replace(char)` | Fix compile |
| **F2** | 2026-11-15 ~17:05 | Publish CS1503 | `Replace('\\','/', StringComparison)` inválido p/ char | `Replace('\\','/')` + push | Publish/deploy Lucio | Smoke: **re-salvar** foto pós-deploy |
| **F3** | 2026-11-16 ~08:46 | Pós-deploy ainda *Nenhuma foto…* nas 3 tarefas RDO | Galeria vazia = `listaImagem: []` do BFF → **sem rows utilizáveis** em `imagem` p/ esses agrupadores **ou** save silencioso (base64 vazio / skip) · **Sim**/checkbox OK | Harden: `JsonPropertyName` · fail se POST com fotos e 0 gravadas · `imagensGravadas` no toast · limite 40MB · load RDO sem `.Date` no SQL | **código local** (commit/push/deploy pendente) | Smoke F4: toast “N foto(s) gravada(s)” + F12 POST body `listaImagens[].base64` + SQL abaixo |
| **F4** | 2026-11-16 ~09:25 | 400 `listaImagens[0].id` não converte p/ Int32 | Client usava `id: -Date.now()` (~1.7e12) → **fora de Int32** | `fileToTarefaImagem`: id temp -1,-2,… · POST força `id: 0` p/ novas | **código local** | Commit/push/deploy → F5 smoke |
| **F5** | 2026-11-16 ~09:40 | (pós F4) miniaturas no Novo RDO OK | Persistência foto OK | — | Galeria RDO OK | Smoke PDF |
| **F6** | 2026-11-16 ~09:51 | Galeria OK · PDF **sem** 2ª página fotográfica | `ima_ds_caminho` = `{obra}/{tarefa}/{yyyyMM}/file` · `LoadImageBytes` buscava `UploadsRoot/{obra}/…` **sem** `Imagens/` → bytes vazios → `HasFotoBytes` false | `RdoPdfService.LoadImageBytes`: prefixa `Imagens/` + PageBreak antes do relatório | PDF com fotos OK | Layout ≠ prod |
| **F7** | 2026-11-16 ~10:12 | Fotos no PDF **esticam** a linha (1–2 fotos = largura total) | Prod `Rdo.rdlc`: até **4**/linha · cada **4 cm × ~2,65 cm** `FitProportional` · QuestPDF usava `RelativeItem`+`MaxHeight(140)` | `Fotos`: `ConstantItem` 4 cm + altura fixa · título faixa cinza · const `FotosPorLinhaPadrao` | **código local** | Deploy → smoke: 2 fotos **não** ocupam a página inteira · backlog **M7-PDF-FOTOS-LINHA** / **GEO-LEG** / **LEGENDA** |
| **F8** | 2026-11-20 ~17:15 | Toast *Tarefa salva, mas nenhuma foto foi gravada* ao salvar Editar; fantasma cinza na galeria; Nova Medição sem toast de foto | (1) BFF **não** devolvia `imagensGravadas` · front usava `fotos.length` (inclui já gravadas sem base64) → falso positivo; (2) href 404 → quadrado cinza | DTO+`SyncNovasImagens` contam `ImagensGravadas`; toast só conta `base64` novas; `onError` esconde thumb morta; GET ignora caminho vazio | **código local** | Publish/deploy → smoke: salvar **sem** foto nova = sucesso; **com** foto nova = toast `N foto(s) gravada(s)` |

---

## Checklist smoke F4 (Lucio)

1. Login → Escolher **MIGRAÇÃO 15/11** (session limpa pós-SSM).  
2. Cards → **+** Nova Medição na tarefa → Escolher + Adicionar + SALVAR.  
3. Toast deve dizer **`N foto(s) gravada(s)`** (N≥1). Se erro vermelho → copiar texto.  
4. F12 → Network → `POST /api/bff/tarefas` → Request: `listaImagens` com `base64` longo; Response: `imagensGravadas` ≥ 1.  
5. `/Rdo/Cadastro` → Sim → marcar a **mesma** tarefa → deve aparecer miniatura (não a frase vazia).

### SQL (DBeaver · `homol_rdoapp` só)

```sql
-- Fotos recentes da obra (ajuste obr_id)
SELECT i.ima_id_imagem, i.ima_id_tarefa, i.ima_ds_caminho, i.ima_dt_imagem,
       t.tar_ds_tarefa, t.tar_dt_medicao, t.tar_nr_agrupador
FROM imagem i
JOIN tarefa t ON t.tar_id_tarefa = i.ima_id_tarefa
JOIN etapa e ON e.eta_id_etapa = t.tar_id_etapa
WHERE e.eta_id_obra = /* id obra MIGRAÇÃO 15/11 */
ORDER BY i.ima_id_imagem DESC
LIMIT 30;
```

**Vazio** → problema no **save** (F3/F4). **Com linhas** e RDO ainda vazio → problema no **GET etapas** / filtro data (reabrir F5).

### Disco EC2 (após save OK)

`FileStorage:UploadsRoot\Imagens\{obraId}\{tarefaId}\{yyyyMM}\*.jpg`  
Se pasta não existe → `UploadsRoot` Staging / permissão gravar.

---

## Links

- Orquestrador: **M7-FOTO-PERSIST** / **M7-FOTO-PASTA-MES**  
- Pendências: [`pendencias-melhorias-ui-stack.md`](pendencias-melhorias-ui-stack.md)  
- Paridade RDO: [`m7-rdo-cadastro-paridade-homolog-prod.md`](m7-rdo-cadastro-paridade-homolog-prod.md) · **M7-FOTOS-01/02**  
- P3 cadastro: [`homolog-p3-tarefa-cadastro-tentativas.md`](homolog-p3-tarefa-cadastro-tentativas.md) O6–O7  
