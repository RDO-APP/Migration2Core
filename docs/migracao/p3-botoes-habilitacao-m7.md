# P3 — Etapas / Tarefas (`/Tarefa/Cards`) — botões, rotas e o que falta

**Trilha:** EQ-R · **Prod ref:** `rdoappProject/Client/Views/Tarefa/cards.html` · **Homolog:** React + BFF  
**Atualizado:** 2026-10-25 · **Código rotas:** `client/src/nav/p3-operador-routes.ts` · **Placeholders MVC:** `EmMigracao.cshtml`

Legenda **Homolog:**

| Símbolo | Significado |
|---------|-------------|
| 🔗 | Navega (`window.location`) → rota Core abaixo · tela **Em migração** até M5/M7 |
| ✅ | Funcional (dados/UI local) |
| ⏳ | Rota existe · falta tela/API real (**M5** / **M7+**) |
| 👁 | Oculto ou read-only de propósito |

---

## Por que `/Chart` e `/Dashboard` “não mudavam” antes (M4.7b)

Rotas como `/Chart` **não tinham action MVC**. O host devolvia o `index.html` da SPA; o React trata qualquer path ≠ Escolher como **Cards** — parecia que o clique não funcionava.

**Correção:** actions MVC + `goOperador()` (full page) em ícones de header e toolbar.

---

## Mapa canônico — prod Angular → homolog Core

Fonte TS (não duplicar manualmente): `RDO-CleanMigration-2026/client/src/nav/p3-operador-routes.ts`

### 1) Header (`OperadorShell`)

| Botão / ação | Prod (`TarefaController.js` / menu) | Rota homolog (M4.7b) | Marco tela real |
|--------------|--------------------------------------|----------------------|-----------------|
| Logo → Escolher | `#/obra/escolher` | `/Obra/Escolher` | ✅ SPA P2 |
| Título obra | sessão | (texto) | ✅ |
| Trocar senha | alterar senha | `/Account/ChangePassword` | M4.8 SPA opcional |
| Sair | logout | `POST /Account/Logout` | ✅ |
| Dashboard da obra | `#/dashboard/index` | `/Dashboard` | ⏳ **M5** · ícone se `showDashboardObra` |
| RDO's | `#/rdo/index` | `/Rdo` | ⏳ **M5** |
| Tarefas (grade) | `#/tarefa/cards` | `/Tarefa/Cards` | ✅ SPA P3 |
| Dashboard geral | `#/chart` | `/Chart` | ⏳ **M5** · se `showChart` |
| Nova obra (+) | `#/obra/cadastro` | `/Obra/Cadastro` | ⏳ **M5** · se `showNovaObra` |

### 2) Toolbar (`CardsToolbar`)

| Botão | Prod | Rota homolog | Marco |
|-------|------|--------------|-------|
| Gerar RDO | `cadastroRdo()` → `#/rdo/cadastro` | `/Rdo/Cadastro` | ⏳ M7 API + `gerarRdo` |
| Editar obra | `editarObra()` → `#/obra/cadastro` | `/Obra/Cadastro` | ⏳ M5/M7 |
| Efetivo diário | `#/efetivo/index` | `/Efetivo` | ⏳ M7 |
| Lista | `#/tarefa/index` | `/Tarefa/Index` | ⏳ M7 lista EQ-R |
| Adicionar tarefa | `#/tarefa/cadastro` | `/Tarefa/Cadastro` | ⏳ M7 CRUD |
| Adicionar etapa | `#/etapa/cadastro` | `/Etapa/Cadastro` | ⏳ M7 CRUD |
| FILTRO | collapse `.filtro` | `/Tarefa/Cards?filtro=1` | ⏳ M7 UI filtro + BFF |
| SELECIONAR TUDO | modal `#alterar-status` | (checkbox local) · destino massa: `/Tarefa/AlterarStatusEmMassa` | ⏳ M7 |

**Accordion etapa:** ✅ expand/collapse (sem rota).

### 3) Card de tarefa (`TaskCardAgrupador`)

Substituir `{id}` pelo `tarefa.id` do BFF.

| Controle | Prod | Rota homolog | Marco |
|----------|------|--------------|-------|
| ⋮ Alterar status | painel `.status` | `/Tarefa/AlterarStatus?id={id}` | ⏳ M7 |
| Olho | `visualizar` → cadastro read-only | `/Tarefa/Cadastro?id={id}&modo=visualizar` | ⏳ M7 |
| Relógio | modal `#historico-tarefa` | `/Tarefa/HistoricoMedicao?id={id}` | ⏳ M7 |
| Lápis | `#/tarefa/cadastro` | `/Tarefa/Cadastro?id={id}` | ⏳ M7 |
| Impressora | modal horas equipamento | `/Tarefa/RelatorioHorasEquipamento?id={id}` | ⏳ M7 |
| + medição | `editar(..., true)` | `/Tarefa/Cadastro?id={id}&novaMedicao=1` | ⏳ **P4 / M7+** |
| Lixeira | `deletar` | `/Tarefa/Excluir?id={id}` (não no card M4.7 UI) | ⏳ M7 RBAC |
| Checkbox card | seleção massa | (local) | ⏳ M7 |
| Adicionar nova tarefa | `novaTarefa(etapaId)` | `/Tarefa/Cadastro?etapaId={etapaId}` | ⏳ M7 |

---

## Resumo por marco

| Marco | Escopo |
|-------|--------|
| **M4.7** | Layout card · FA · sem pill status / lixeira no card |
| **M4.7b** | **Todas as ações acima navegam** · placeholder Razor **Em migração** |
| **M4.8** | Login SPA |
| **M5** | Dashboard / Chart / RDO listagem reais |
| **M7+** | Formulários, modais, RBAC, APIs · **P4** medição |

**Doc irmão:** [`pendencias-melhorias-ui-stack.md`](pendencias-melhorias-ui-stack.md) · manual **§10.4** · orquestrador gap P3.
