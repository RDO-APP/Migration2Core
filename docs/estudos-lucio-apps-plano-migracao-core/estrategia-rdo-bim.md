# Estratégia — conexão RDO App × BIM

**Atualizado:** 2026-09-20  
**Chats de origem:** [Migração .NET Core](ee6f7379-dfb3-4995-a6cd-1c691007e9b0) · [Edital FAPESC — Execução](7bd737a8-9e2c-4022-a549-24c06dd8c5f5) · histórico vivo em [FAPESC certidões e termo](de87e91a-baa5-422d-b295-c7e481f7fe3b)  
**Canvas:** `canvases/rdo-app-bim-bridge.canvas.tsx`  
**Relacionados:** [estudo-migracao-fapesc-9-meses.md](./estudo-migracao-fapesc-9-meses.md) · [storytelling-unificado-dimas-migracao-fapesc.md](./storytelling-unificado-dimas-migracao-fapesc.md)

Ponte FAPESC × Migração (cópia canônica): `Mercado\Editais\FAPESC\Documentos\Pós Aprovação\Cursor\10_PONTE_MIGRACAO_TIME.md`. EDI fase 2: mesmo folder, `07_EDI_FASE2.md`.

---

## 0. Decisão — duas estratégias de produto

Download e upload **não** são as duas opções. São os dois sentidos da **opção A**.

| | **A · Ponte** (escolher) | **B · RDO vira BIM** (não agora) |
|--|--------------------------|----------------------------------|
| Ideia | RDO continua diário; BIM/CDE continua modelo; um módulo troca dados | RDO abre o modelo 3D, pinta 4D e compete com CDE |
| Encarregado no celular | Tarefa, foto, assinatura de sempre | Viewer IFC + card de elemento |
| Tarefas | Vêm do WBS/CDE (CSV agora, API depois) | Vêm dos objetos do modelo |
| IFC usável no piloto | Não obrigatório na v1 | Obrigatório, senão o produto não liga |
| Core Dimas | Onda 4 + OpenAPI + evento TSK-32 | Backlog novo (viewer, 4D, CDE) |
| FAPESC | Hash só no upload, depois da PoC | Outro edital |
| Risco | Cliente sem WBS → import vazio | Dois anos de P&D e zero SKU |

**Por que A:** o grafo obra/etapa/tarefa, a foto e as duas assinaturas já existem. A ponte só mapeia. A opção B foi o recorte que o RHAE recusou: cliente SME quase não entrega IFC vivo.

---

## 1. Tese (opção A)

**BIM** = as-designed (WBS, quantitativos, 4D, CDE).  
**RDO App** = as-executed (diário, foto, apontamento, duas assinaturas).  
**Âncora FAPESC** = prova de que o RDO fechado não foi adulterado.

A conexão é um **adaptador** no Core .NET 8 (`RdoApp.BimBridge`), no mesmo espírito do EDI: payload canônico + conector por destino. Não é viewer IFC, não é objeto do fomento FAPESC, não é objeto do RHAE.

Regra de ouro (igual TSK-32 × Imutabilidade): o produto **dispara evento**; o módulo BIM **não mistura** entregável de edital.

---

## 2. Download (BIM → RDO)

Popular o grafo que o canteiro já usa (`obra → etapa → tarefa`).

| Origem BIM/CDE | Destino RDO | Nota |
|----------------|-------------|------|
| Projeto / modelo | `obra` | 1 modelo vivo por obra piloto |
| WBS, pavimento, disciplina | `etapa` | TSK-21 |
| IfcTask / atividade 4D | `tarefa` | `tar_ds_tarefa` |
| `GlobalId` | `bim_guid` (campo novo) | chave de idempotência |
| QTO previsto | planejamento / qtd prevista | não inventar unidade |
| Datas 4D | cronograma da tarefa | início/fim planejados |

**v1 sem parser IFC:** CSV/JSON exportado do CDE do cliente (ACC, Trimble, planilha). Idempotente por `bim_guid`.

---

## 3. Upload (RDO → BIM)

Devolver avanço e evidência. O RDO **não edita** o modelo; publica fato.

Gatilho: **depois das duas assinaturas** (`status_rdo` 1 → 3 → 2) — o mesmo gatilho da âncora FAPESC.

| Origem RDO | Destino BIM/CDE | Nota |
|------------|-----------------|------|
| `tar_nr_qtd_construida`, % concluído | QTO / 4D actual | já calculado no `TarefaModel` |
| `rdo_imagem` + GPS | BCF topic ou documento no CDE | foto já tem caminho em disco |
| `rdo` fechado + `rdo_ancoragem` | `Pset_RdoEvidence` (hash, tx, verify URL) | só depois da API A8 |
| apontamento equipamento | ocupação do elemento | fase posterior; não bloquear v1 |

---

## 4. Arquitetura

```
CDE / IFC / CSV
        │  adaptador
        ▼
RdoApp.BimBridge     ← este módulo (OpenAPI /bim/*)
        │
        ▼
RdoApp Core          ← Onda 4 TSK-17…23 + TSK-40
        │  evento TSK-32 (duas assinaturas)
        ├──────────► RdoApp.Imutabilidade   (FAPESC)
        └──────────► BimProgressEvent       (write-back)
```

**Contrato interno**

- `BimImportJob`: `obraId`, `source`, `elements[]` (`guid`, nome, wbs, qtoPrevisto, datas, storey)
- `BimProgressEvent`: `guid`, `tarefaId`, `%`, `qtdActual`, `rdoId`, `fotoUris`, `hash`, `txId`, `verifiedAt`

Um schema. Vários adaptadores. O RDO não fala Revit.

---

## 5. Fases

| Fase | O quê | Depende de | Fora |
|------|-------|------------|------|
| **0** agora | Mapa GUID + CSV/JSON em 1 obra piloto | RDO atual (Framework) | Parser IFC, Dimas TSK extra |
| **1** | `POST /bim/import` + `POST /bim/progress` no Core | Onda 4 + TSK-40 OpenAPI | Front comercial FAPESC |
| **2** | IFC subset (`IfcTask`, elemento, QTO) | Cliente com modelo usável | Viewer no AngularJS |
| **3** | BCF + Pset com hash FAPESC | API verify (A8) | Substituir a âncora por BIM |

---

## 6. Fronteiras (não reabrir)

| Tema | Cabe? | Por quê |
|------|-------|---------|
| FAPESC 031/2026 (R$ 79.990, 9 meses) | **Não** | Objeto = imutabilidade TRL 3→5. BIM = integração, igual EDI fase 2 |
| RHAE IA 29/2026 | **Não** | Objeto = 3 agentes no Controle de Equipamentos |
| Migração Core | **Hospedeiro** | Domínio obra/etapa/tarefa + OpenAPI. Não é o parser BIM |
| EDI fase 2 | **Irmão** | Mesmo barramento canônico; destinos diferentes (TCE vs CDE) |

---

## 7. Primeiro ROI

1. Importar WBS para o apontador **não cadastrar 200 tarefas à mão**.  
2. Devolver % e foto ao BIM manager no fechamento do dia.  
3. Selo de integridade (hash + link de verificação) no elemento — só quando a PoC FAPESC existir.
