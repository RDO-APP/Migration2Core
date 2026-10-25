# P3 — Etapas / Tarefas (`/Tarefa/Cards`) — botões e o que falta para habilitar

**Trilha:** EQ-R · **Prod ref:** `rdoappProject/Client/Views/Tarefa/cards.html` · **Homolog:** `CardsPage.tsx` + `OperadorShell` + `CardsToolbar` + `TaskCardAgrupador`  
**Atualizado:** 2026-10-24 · **Marco ações reais:** **M7+** (RBAC + rotas/modais/API)

Legenda **Homolog hoje:** ✅ clicável / navega · 🟡 alert stub · ⛔ disabled · 👁 oculto (RBAC prod) · — não existe na UI homolog

---

## 1) Header (`OperadorShell` · faixa azul)

| Botão / ação | Prod (permission / rota) | Homolog hoje | Falta para habilitar (M7+) |
|--------------|--------------------------|--------------|----------------------------|
| **Logo** → Escolher | `mudarObra` / `#/obra/escolher` | ✅ `href=/Obra/Escolher` | — |
| **Título obra** (centro) | Nome da obra sessão | ✅ `h2#tituloObra` | — |
| **Usuário** (dropdown) | Menu sessão | ✅ abre menu | — |
| → **Trocar senha** | Rota alterar senha | ✅ `/Account/ChangePassword` | Paridade SPA **M4.8** (opcional) |
| → **Sair** | POST logout + antiforgery | ✅ se BFF `shell` token OK | Token antiforgery sempre no BFF |
| **Dashboard da obra** | Menu obra / RBAC | 🟡 link `/Dashboard` se `showDashboardObra` | **M5:** `DashboardController` real (hoje placeholder EmMigracao) |
| **RDO's** (ícone) | Nav obra | 🟡 `/Rdo` | **M5:** fluxo RDO web Core |
| **Tarefas** (grade) | `#/tarefa/cards` | ✅ `/Tarefa/Cards` (atual) | — |
| **Dashboard geral** (gráfico) | `#/chart` · RBAC | 🟡 `/Chart` se `showChart` | **M5:** Chart real + permissão menu |
| **Nova obra** (+) | `#/obra/cadastro` · RBAC | 🟡 `/Obra/Cadastro` se `showNovaObra` | **M5:** cadastro obra Core + `PermissionHelper` |

**BFF:** `GET /api/bff/shell` — flags `showChart`, `showNovaObra`, `showDashboardObra` (parcial vs menu Angular `listaPagina`).

---

## 2) Toolbar — Filtro / adicionar / lista (`CardsToolbar` + faixa abaixo)

| Botão | Prod | Homolog hoje | Falta para habilitar |
|-------|------|--------------|----------------------|
| **Gerar RDO** | `permission="gerarRdo"` · `cadastroRdo()` | 🟡 alert M7 | API/post RDO · RBAC `gerarRdo` · desabilitar se `desabilitarSalvar` |
| **Editar obra** | `permission="editarObra"` · `editarObra()` | 🟡 alert M7 | Rota edição obra · RBAC |
| **Efetivo diário** | `efetivoDiario()` (sem permission no HTML) | 🟡 alert M7 | Tela/API efetivo (fora v1 Dimas) ou rota legado |
| **Lista** (colunas) | `lista()` → `#/tarefa/index` | 🟡 alert M7 | Página lista tarefas EQ-R ou redirect |
| **Adicionar tarefa** (ícone + botão azul) | `permission="criarNovo"` · `novaTarefa()` | 🟡 alert M7 | Fluxo cadastro tarefa · RBAC · `desabilitarSalvar` |
| **Adicionar etapa** | `permission="criarNovo"` + route `/etapa/index` | 🟡 alert M7 | CRUD etapa · RBAC |
| **Filtro** (ícone + FILTRO) | Collapse `.filtro` + campos busca | 🟡 abre stub texto | UI filtro prod + query BFF/listagem |
| **SELECIONAR TUDO** (abaixo toolbar) | Checkbox + alterar status massa | ⛔ checkbox UI sem lógica | Ligar checkboxes card · modal `#alterar-status` · `aterarStatusEmMassa` |

**Accordion etapa:** botão título etapa — ✅ **habilitado** (expand/collapse React).

---

## 3) Card de tarefa (`TaskCardAgrupador` + placeholder)

### 3.1 Cabeçalho do card (faixa verde/azul)

| Elemento | Prod | Homolog hoje | Falta para habilitar |
|----------|------|--------------|----------------------|
| **⋮ Alterar status** | `permission="editar"` · abre `.status.active` | ⛔ disabled | Toggle painel status · `listaStatusPermitidos` no BFF · `changeStatus` API |
| **Colaboradores / equipamentos** (contadores) | Exibição | ✅ dados BFF | — |

### 3.2 Faixa de ícones (ações)

| Ícone | Prod permission | Homolog M4.7 | Falta para habilitar |
|-------|-----------------|--------------|----------------------|
| **Olho** (visualizar) | `visualizarRegistro` | ⛔ disabled | `visualizar(tarefa)` · rota/modal read-only |
| **Relógio** (histórico medições) | — (modal) | ⛔ disabled | Modal `#historico-tarefa` + API histórico |
| **Lixeira** (excluir) | `deletar` | 👁 **oculto** M4.7 | Mostrar só com RBAC · `deletar(tarefa)` API |
| **Lápis** (editar) | `editar` | ⛔ disabled | `editar(id)` cadastro tarefa |
| **Impressora** (rel. horas equip.) | — | ⛔ disabled | Modal relatório + Excel/PDF |
| **+** (nova medição) | `editar` · `editar(..., true)` | ⛔ disabled | **P4 / M7+** modal medição rápida |

### 3.3 Corpo do card

| Elemento | Prod | Homolog | Falta |
|----------|------|---------|-------|
| Datas planejada / executada | ✅ | ✅ BFF | — |
| **Checkbox** seleção | Usado p/ status massa | ⛔ readOnly | Ligar a `selectAll` + ids |
| **Barra %** | ✅ | ✅ | Ajuste fino % (M4.7 UI) |
| **Faixa texto status** (“FINALIZADA”) | 👁 oculta (`.status` height 0) | ❌ removido M4.7 | No M7: painel status via ⋮, não rodapé fixo |

### 3.4 Dentro da etapa (grid)

| Botão | Prod | Homolog | Falta |
|-------|------|---------|-------|
| **Adicionar nova tarefa** (card tracejado) | `permission="criarNovo"` · `novaTarefa(etapaId)` | 🟡 alert stub | Mesmo que toolbar adicionar tarefa + etapaId |

---

## Resumo por marco

| Marco | Escopo botões |
|-------|----------------|
| **M4.7** | Layout card (sem status pill, sem lixeira visível); ícones ainda stub |
| **M4.8** | Login SPA (header senha opcional) |
| **M5** | Header Chart / RDO / Cadastro obra reais |
| **M7+** | Toolbar + card ações + RBAC + modais (medição P4, histórico, delete condicional) |

**Doc irmão:** [`pendencias-melhorias-ui-stack.md`](pendencias-melhorias-ui-stack.md) · manual **§10.4**
