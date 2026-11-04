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

## Toolbar Gerar RDO / Efetivo — rotas vs UI (M4.7c)

| Camada | Status |
|--------|--------|
| **Rotas + clique** (M4.7b) | `P3_NAV.toolbar.gerarRdo` → `/Rdo/Cadastro` · `efetivoDiario` → `/Efetivo` · `CardsPage` já chama `goOperador()` |
| **Onde aparecem no prod** | Ícones na **linha do título** (`panel-heading`), à direita de “Etapas / Tarefas” — não são os botões azuis FILTRO / ADICIONAR |
| **Por que sumiam no homolog** | Layout legado (`float` + `.pull-right`) no host BS5: a faixa `.action` colapsava e só um ícone ficava visível; **não** era falta de rota |
| **M4.7c** | Flex em `.cards-toolbar-heading` · paridade `custom.css` (ícones fontello/FA) · RDO / Editar / Efetivo **só** na linha do título (acima da faixa LISTA/FILTRO, como `cards.html`) · `padding-top: 103px` em `.operador-conteudo` |
| **Ver na EC2** | Commit + deploy com bundle SPA novo (ex. `index-CwiQ705n.js` pós-build M4.7c) |

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

### 2) Toolbar (`CardsToolbar`) — duas faixas (como o print prod)

```
┌─ Linha 1 · panel-heading (borda inferior) ─────────────────────────────┐
│  Etapas / Tarefas          [RDO] [Editar obra] [Efetivo]  (ícones)      │
└─────────────────────────────────────────────────────────────────────────┘
┌─ Linha 2 · desktop (hidden-xs) ──────────────────────────────────────────┐
│  LISTA                              FILTRO | ADICIONAR TAREFA | ETAPA    │
└─────────────────────────────────────────────────────────────────────────┘
```

| Botão | Prod | Rota homolog | Status (Lucio 04/11) |
|-------|------|--------------|---------------------|
| Gerar RDO | `cadastroRdo()` · **`permission="gerarRdo"`** | `/Rdo/Cadastro` | ✅ OK |
| Editar obra **1.1** | `editarObra()` · **`permission="editarObra"`** | `/Obra/Cadastro` | ❌ stub / não funciona |
| Efetivo diário **1.2** | `#/efetivo/index` | `/Efetivo` | ❌ stub / não funciona |
| FILTRO **1.3** | collapse `.filtro` | `/Tarefa/Cards?filtro=1` | 🟡 painel + filtro cliente — smoke pós-deploy |
| Adicionar tarefa **1.4** | `#/tarefa/cadastro` | `/Tarefa/Cadastro` | ❌ stub / sem id |
| Adicionar etapa **1.5** | `#/etapa/cadastro` | `/Etapa/Cadastro` | ❌ stub Em migração |
| LISTA **2.1** | `#/tarefa/index` | `/Tarefa/Index` | ❌ rota; ícone sobrepõe texto |
| SELECIONAR TUDO **2.2** | modal `#alterar-status` | `/Tarefa/AlterarStatusEmMassa` | ❌ inoperante |

**Menu ☰ (shell):** reformatar + conferir opções vs prod (Equipamentos, Colaboradores, Card de Tarefas, RDOs, Obras, Empresas, Etapas…).

**Accordion etapa:** ✅ expand/collapse (sem rota).

### 3) Card de tarefa (`TaskCardAgrupador`)

Substituir `{id}` pelo `tarefa.id` do BFF.

| Controle | Prod | Rota homolog | Marco |
|----------|------|--------------|-------|
| ⋮ Alterar status | painel `.status` | painel no card + `POST /api/bff/tarefas/{id}/status` | ✅ 04/nov · hover `09ae5fe` |
| ⋮ → Pausada | (prod: sem código) | **futuro** pedir/gravar `codigoParalizacao` | ⬜ orquestrador **3.1** (Lucio) |
| Olho | `visualizar` → cadastro read-only | `/Tarefa/Cadastro?id={id}&modo=visualizar` | ✅ SPA M7 (mesmo form, campos desabilitados) |
| Relógio | modal `#historico-tarefa` | modal em Cards (`HistoricoMedicaoModal`) | ✅ smoke 04/nov (layout **depois**) |
| Lápis | `#/tarefa/cadastro` | `/Tarefa/Cadastro?id={id}` | ✅ SPA M7 (mesmo form, salvar · smoke 03/nov) |
| Impressora | modal horas equipamento | modal + BFF PDF/Excel | 🟡 gera · **formatação PDF + Excel** pendente |
| + medição | `editar(..., true)` | modal P4 em Cards (`NovaMedicaoModal`) | ✅ **P4** smoke 03/nov (Foto persist / NOVO* **depois**) |
| Lixeira | `deletar` | `/Tarefa/Excluir?id={id}` (não no card M4.7 UI) | ⏳ M7 RBAC |
| Checkbox card | seleção massa | (local) | ⏳ M7 |
| Adicionar nova tarefa | `novaTarefa(etapaId)` | `/Tarefa/Cadastro?etapaId={etapaId}` | ⏳ M7 |

---

## Resumo por marco

| Marco | Escopo |
|-------|--------|
| **M4.7** | Layout card · FA · sem pill status / lixeira no card |
| **M4.7b** | **Todas as ações acima navegam** · placeholder Razor **Em migração** |
| **M4.7c** | Toolbar P3 visível (RDO · efetivo · spacing header) · CSS `CardsToolbar` / `operador-shell` |
| **M4.8** | Login SPA |
| **M5** | Dashboard / Chart / RDO listagem reais |
| **M7+** | Formulários, modais, RBAC, APIs · **P4** medição |

**Doc irmão:** [`pendencias-melhorias-ui-stack.md`](pendencias-melhorias-ui-stack.md) · manual **§10.4** · orquestrador gap P3.
