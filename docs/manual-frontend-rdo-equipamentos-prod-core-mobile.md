# Manual técnico e gráfico (front-end) — RDO App · 5 vetores

**Escopo:** Equipamentos (obras) · Migration Core · Apontador · **Piscinas (web)** · **Piscineiro (app)**  
**Data:** 2026-10-19 · **Status:** rascunho — col. ④ **EquipoToPiscina** confirmada (Lucio) · demais itens §10  
**Público:** UX, front-end (EQ-R / PQ-R futuro), mobile (EQ-M / PQ-M), QA E2E, migração  

**Instância RDS (comum):** `equipamentos.cslrikufb7hm.us-east-2.rds.amazonaws.com:3306` · governança: [`rds-equipamentos-governanca-catalogos.md`](rds-equipamentos-governanca-catalogos.md)

---

## Referência rápida — repositórios e bancos (5 vetores)

Hosts: ① `https://sistema.rdoapp.com.br` · ② `https://homolog.sistema.rdoapp.com.br` (:5081) · ③ APK **Apontador** · ④ `https://piscinas.rdoapp.com.br` · ⑤ APK **Piscineiro**

| | **① Equipamentos · produção (EQ-L)** | **② Migration → Core · homolog (EQ-W/R)** | **③ App Apontador (EQ-M)** | **④ Piscinas · web produção (PQ-L)** | **⑤ Piscineiro (PQ-M)** |
|---|------|------|------|------|------|
| **Repositório GitHub** | https://github.com/RDO-APP/Equipamentos | https://github.com/RDO-APP/Migration2Core | https://github.com/RDO-APP/EquipamentosMobile · branch ref. `feature/alteracoes_apontador` | https://github.com/RDO-APP/EquipoToPiscina · IIS `inetpub\piscinas` · **≠** pasta Kiro `Migration2Core/EquipoToPiscina-1/` (só referência) | https://github.com/RDO-APP/RDOAppPiscinasMobile · ref. histórica: https://github.com/RDO-APP/PiscinasMobile |
| **Banco de dados MySQL (catálogo)** | **`novo_rdoapp`** | **`homol_rdoapp`** | Consumo via API → **`novo_rdoapp`** (prod) | **`piscinas_rdoapp`** · homolog web legado: **`piscinas_rdoapp_homologa`** (`homologacao.piscinas.rdoapp.com.br`) | Consumo via API → **`piscinas_rdoapp`** (prod) · homolog: **`piscinas_rdoapp_homologa`** |

**Notas RDS:** não usar `homol_rdoapp` para Piscinas nem `piscinas_rdoapp*` para Core Equipamentos. CPF teste Equipamentos homolog: `53821963549` / `homol_rdoapp` — **não** confundir com dataset Piscinas/Kiro (`567.065.455-20`).

---

## Diagrama — 5 vetores e fluxo operador (até Nova Medição)

**Legenda fluxo:** Login → Escolher → Cards → Nova medição (web modal ou tela mobile).

```mermaid
flowchart TB
  subgraph RDS["RDS us-east-2 · equipamentos.cslrikufb7hm"]
    N["novo_rdoapp"]
    H["homol_rdoapp"]
    P["piscinas_rdoapp"]
    PH["piscinas_rdoapp_homologa"]
  end

  subgraph V1["① EQ-L · produção obras"]
    R1["GitHub Equipamentos"]
    U1["sistema.rdoapp.com.br"]
    A1["AngularJS + Web API"]
    R1 --> U1 --> A1 --> N
  end

  subgraph V2["② EQ-W/R · homolog Core"]
    R2["GitHub Migration2Core"]
    U2["homolog.sistema.rdoapp.com.br"]
    W2["MVC cookie + React Cards"]
    R2 --> U2 --> W2 --> H
  end

  subgraph V3["③ EQ-M · Apontador"]
    R3["GitHub EquipamentosMobile"]
    M3["Expo RN · APK"]
    M3 -->|"API prod"| U1
  end

  subgraph V4["④ PQ-L · produção Piscinas web"]
    R4["GitHub EquipoToPiscina"]
    U4["piscinas.rdoapp.com.br"]
    A4["AngularJS + Web API · Laudo"]
    R4 --> U4 --> A4 --> P
  end

  subgraph V5["⑤ PQ-M · Piscineiro"]
    R5["GitHub RDOAppPiscinasMobile"]
    M5["Expo RN · appPiscinas"]
    M5 -->|"API prod"| U4
  end

  A1 --> F1["1 Login"]
  F1 --> F2["2 Escolher obra"]
  F2 --> F3["3 Etapas / Cards"]
  F3 --> F4["4 Nova medição"]

  W2 -.->|"paridade alvo"| F1
  W2 -.-> F2
  W2 -.-> F3
  W2 -.-> F4

  M3 -.-> F1
  M3 -.-> F2
  M3 -.-> F3
  M3 -.-> F4

  A4 -.-> F1
  A4 -.-> F2
  A4 -.-> F3
  A4 -.-> F4

  M5 -.-> F1
  M5 -.-> F2
  M5 -.-> F3
  M5 -.-> F4
```

**Leitura:** duas **linhas de produção** web (① obras · ④ piscinas); homolog Equipamentos (②) **só** `homol_rdoapp`; apps ③⑤ consomem API do respectivo host prod.

---

## Colunas do manual (trilhas)

| Coluna | Sigla | Stack / host | Código principal |
|--------|-------|--------------|------------------|
| **Equipamentos produção** | EQ-L | AngularJS 1.x + Bootstrap 3 + Web API · IIS · `novo_rdoapp` | `Equipamentos` → `rdoappProject/Client/` |
| **Core Migration homolog** | EQ-W + EQ-R | ASP.NET Core MVC + cookie · React (Vite) em `wwwroot/app/` · `homol_rdoapp` | `Migration2Core` → `RDO-CleanMigration-2026/` |
| **Apontador** | EQ-M | Expo / RN · API prod (cenário **A** M1) | `EquipamentosMobile` |
| **Piscinas web** | PQ-L | Mesma família SPA legado (AngularJS) · IIS `piscinas` · `piscinas_rdoapp` | Repo col. ④ · EC2 `Web.config` |
| **Piscineiro** | PQ-M | Expo / RN · variant `appPiscinas` · API `piscinas.rdoapp.com.br` | `RDOAppPiscinasMobile` (base); evolução Apontador em `EquipamentosMobile` |

**Legenda de paridade:** ✅ alinhado · 🟡 parcial · ⬜ não feito · 🔀 equivalente intencional · ❌ divergência crítica · **—** não aplicável ao produto

**Regra:** paridade **web operador obras** = colunas ① vs ②. **Apontador** = fluxo campo Equipamentos (③), não layout Angular. **Piscinas / Piscineiro** = produto paralelo (④⑤); Core homolog **não** substitui Piscinas hoje. Trilha **PQ-R** futura espelha **EQ-R** ([`ORQUESTRADOR-MIGRACAO.md`](ORQUESTRADOR-MIGRACAO.md) § PQ).

---

## 0. Casca global (layout interno — pós-login)

| Elemento | ① EQ-L | ② Core homolog | ③ Apontador | ④ Piscinas web | ⑤ Piscineiro |
|----------|--------|----------------|-------------|----------------|--------------|
| Layout shell | `layout-interno*.html` · `ng-view` | MVC `_Layout`; Cards = React sem shell prod | Stack Navigator | 🔀 mesmo padrão legado (nav + ng-view) | Stack Navigator |
| Header `nav.html` | `NavController` · faixa azul | 🟡 partials Kiro; React sem nav prod | App bar | 🔀 nav + contexto unidade/obra piscina | App bar |
| Logo / trocar contexto | `mudarObra()` | Escolher MVC | Lista obras | 🔀 trocar unidade/obra | Lista obras/unidades |
| Menu RBAC | `userData.menu.listaPagina` | 🟡 Escolher | Reduzido | 🔀 | Reduzido |
| Usuário (senha / sair) | Dropdown | ✅ cookie MVC | Auth context | 🔀 | Auth context |
| Stack UI | Bootstrap 3, FA, fontello | Bootstrap + React cru | RN Paper / lucide | 🔀 Bootstrap/fontello | 🔀 compartilhado ~94% c/ ③ |

---

## 1. Página — Login

| Meta | ① `#/login` · `Login/index.html` | ② `/Account/Login` | ③ Auth nativo | ④ `#/login` (PQ-L) | ⑤ Auth nativo |
| API | `POST /api/login/LoginUser` | MVC + cookie | → **`sistema.rdoapp.com.br`** | → **`piscinas.rdoapp.com.br`** | → **`piscinas.rdoapp.com.br`** |

| Elemento | ① | ② | ③ | ④ | ⑤ |
|----------|---|---|---|---|---|
| CPF + senha | ✅ | ✅ | ✅ | 🔀 | 🔀 |
| Branding produto | Equipamentos | 🟡 dívida copy Piscinas em views Kiro | Apontador | Piscinas / RDO piscinas | Piscineiro |
| Redirect | `/obra/escolher` | `/Obra/Escolher` | Dashboard obras | 🔀 escolher unidade/obra | Dashboard cards LIMPEZA |
| RDS | `novo_rdoapp` | `homol_rdoapp` | via API | `piscinas_rdoapp` | via API |

---

## 2. Página — Escolher obra / unidade

| Meta | ① `escolher.html` | ② `/Obra/Escolher` + Selecionar | ③ `normal-dasboard` + `workCard` | ④ escolher (PQ-L) | ⑤ dashboard obras / cards piscina |
| API | `LoginObra` | `LoginObraService` | `ObterObras` + `LoginObra` | 🔀 `LoginObra` piscinas API | 🔀 idem host piscinas |

| Elemento | ① | ② | ③ | ④ | ⑤ |
|----------|---|---|---|---|---|
| Título / convite | “Selecione uma das obras…” | ✅ | Filtro “Obra” | 🔀 terminologia unidade escolar | 🔀 cards piscina |
| Grid cards + progresso | ✅ fontello + % | 🟡 lista (STRATEGY-2 ⬜) | ✅ `workCard` | 🔀 paridade web | 🟡 card menor; ícone obra |
| Ícone `contratanteContratada` | `icon-*` | ⬜ | 🟡 HardHat (gap item 4) | 🔀 | 🔀 |
| Legenda progresso | ✅ | ⬜ | ✅ pós-lista | 🔀 | 🔀 |
| Clique → sessão obra | → `#/tarefa/cards` | ✅ Selecionar | → etapas | 🔀 → cards/laudos | → etapa **LIMPEZA** / cards |

---

## 3. Página — Etapas / Tarefas (Cards)

| Meta | ① `cards.html` | ② `/Tarefa/Cards` React | ③ `normal-work-details` + `taskCard` | ④ cards/lista PQ-L | ⑤ `PiscineiroCardsContext` / cards LIMPEZA |
| API cards | `ObterEtapaTarefa` (**agrupador**) | `/api/bff/etapas` (**sem agrupador**) | prod Equipamentos | 🔀 `ObterEtapaTarefa` piscinas | 🔀 API piscinas |

### 3.1 Toolbar

| Elemento | ① | ② | ③ | ④ | ⑤ |
|----------|---|---|---|---|---|
| Título “Etapas / Tarefas” | ✅ | 🟡 | 🔀 | 🔀 | 🔀 foco etapa limpeza |
| FILTRO / + tarefa / + etapa | ✅ RBAC | ⬜ | ⬜ removido | 🔀 | ⬜ / 🔀 |
| Alternância Cards ↔ Lista | ✅ | ⬜ | 🔀 | 🔀 | 🔀 |
| Header obra no topo | `nav.html` | ⬜ | app bar | 🔀 | 🔀 |

### 3.2 Etapas (accordion)

| Elemento | ① | ② | ③ | ④ | ⑤ |
|----------|---|---|---|---|---|
| Accordion faixas azuis | ✅ | ⬜ | ✅ todas etapas | 🔀 | ✅ accordion |
| Títulos etapas (ex. obra 42) | ✅ 3 etapas | ✅ títulos OK | ✅ | 🔀 | 🔀 OBRA / TESTE / LIMPEZA… |
| Trancar etapa fixa | — | — | **Não** (ago/2026) | 🔀 | 🔀 opcional só LIMPEZA (produto) |

### 3.3 Tarefas (cards)

| Elemento | ① | ② | ③ | ④ | ⑤ |
|----------|---|---|---|---|---|
| Modelo de card | 1 card = **agrupador** | ❌ lista raw DB | API prod agrupador | 🔀 | 🔀 cards limpeza |
| Grid visual verde/status | ✅ | ⬜ | ✅ `taskCard` | 🔀 | 🔀 |
| % + datas + colab/equip | ✅ | ⬜ | 🟡 | 🔀 | 🔀 química no card contexto piscina |
| Impressora no card | web relatórios | ⬜ | 🔀 | 🔀 | 🟡 backlog U-01 |

---

## 4. Nova medição / registro de campo

| Elemento | ① EQ-L modal `cards.html` | ② Core | ③ Apontador | ④ Piscinas web | ⑤ Piscineiro |
|----------|---------------------------|--------|-------------|----------------|--------------|
| UI | Modal bootstrap rápido | ⬜ M2+ | `equipamentos.tsx` vertical | 🔀 modal web | `piscinas.tsx` (PH, cloro, …) |
| Campos | horímetro, paralisação, datas | — | equipamentos | 🔀 | química / limpeza |
| RDS | `novo_rdoapp` | — | via API | `piscinas_rdoapp` | via API |

---

## 5. Páginas satélite

| Função | ① | ② | ③ | ④ | ⑤ |
|--------|---|---|---|---|---|
| Laudos / Apontamentos | web legado | ⬜ | 🟡 pasta Apontamentos (≠ Laudo) | **Laudos** (`laudo-list-screen` ref.) | laudo / limpeza |
| Histórico medições | modal web | ⬜ | `history-screen` | 🔀 | 🔀 |
| Impressora PDF | web | ⬜ | `report-print-screen` | 🔀 | 🟡 TaskCard |
| Dashboard gráfico obra | `#/dashboard` | ⬜ | removido gráfico | 🔀 | — |

---

## 6. Contratos API (front ↔ backend)

| Operação | ① EQ-L | ② Core homolog | ③ Apontador | ④ Piscinas web | ⑤ Piscineiro |
|----------|--------|----------------|-------------|----------------|--------------|
| Login | `LoginUser` | MVC cookie | prod **sistema** | prod **piscinas** | prod **piscinas** |
| Obras / LoginObra | `sistema…/api/*` | MVC + cookie | prod | `piscinas…/api/*` | prod piscinas |
| Cards etapas/tarefas | `ObterEtapaTarefa` | BFF `homol_rdoapp` | prod sistema | 🔀 ObterEtapaTarefa | 🔀 |
| Homolog dedicado | — | `homolog.sistema…` | — | `homologacao.piscinas…` + `piscinas_rdoapp_homologa` | fraco hoje (E3) |

Tipos Equipamentos: [`equipamentos-api.types.ts`](api-client/equipamentos-api.types.ts). Piscinas: espelhar no api-client quando **PQ** abrir.

---

## 7. Marcos

| Marco | Vetores |
|-------|---------|
| **M0′** | Este manual + [`matriz-4-paginas-prod-kiro-mobile.md`](matriz-4-paginas-prod-kiro-mobile.md) |
| **EQ-W0.5 / M2** | ①②③ §2–§3 |
| **STRATEGY-2** | ①② Escolher cards |
| **EQ-M** | ③ gaps ícone obra, Apontamentos |
| **PQ** (futuro) | ④⑤ · **PQ-R** espelha EQ-R |

---

## 8. Referências de código

| Vetor | Onde ler |
|-------|----------|
| ① | `Equipamentos/rdoappProject/Client/` · `Api/Models/EtapaModel.cs` |
| ② | `Migration2Core/.../RdoApp.Core/` · `client/src/App.tsx` |
| ③ | `EquipamentosMobile` · [`analise-apontador-dimas-v1.md`](estudos-lucio-apps-plano-migracao-core/analise-apontador-dimas-v1.md) |
| ④ | https://github.com/RDO-APP/EquipoToPiscina · IIS `piscinas\Web.config` |
| ⑤ | `RDOAppPiscinasMobile` · variant `appPiscinas` · [`storytelling-unificado-dimas-migracao-fapesc.md`](estudos-lucio-apps-plano-migracao-core/storytelling-unificado-dimas-migracao-fapesc.md) §5 |

---

## 9. Checklist QA (Equipamentos — gate homolog)

1. Login ① vs ②  
2. Escolher + Selecionar  
3. Cards accordion + toolbar (①) vs React (②)  
4. Contagem cards = **agrupador**, não rows DB  
5. Medição: ③ ou modal ① — escopo apartado  

**Piscinas / Piscineiro:** repetir checklist em prod ④⑤ com CPF/dataset **Piscinas** (não misturar com obra 42 Equipamentos).

---

## 10. OK Lucio (preencher)

| Item | OK? | Observação |
|------|:---:|------------|
| Linha GitHub col. ④ (`RDO-APP/EquipoToPiscina`) | ☑ | Lucio 2026-10-19 |
| Catálogos RDS § tabela inicial | ☐ | |
| Colunas ④⑤ nas páginas §1–§5 | ☐ | |
| Host homolog Piscinas | ☐ | |

Documentos irmãos: [`matriz-4-paginas-prod-kiro-mobile.md`](matriz-4-paginas-prod-kiro-mobile.md) · [`ORQUESTRADOR-MIGRACAO.md`](ORQUESTRADOR-MIGRACAO.md).
