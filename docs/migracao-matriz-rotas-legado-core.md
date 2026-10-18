# Estudo E2 — Matriz rotas: legado Equipamentos × Core homolog

**Data:** 2026-10-17 · Fase 0 / páginas críticas.

Legado: **AngularJS ui-router** (`rdoappProject/Client/app.js`) + **Web API** `api/*` (`rdoappProject/Api/Controllers/`).

Core: **MVC** `RdoApp.Core/Controllers/` (4 controllers).

---

## 1. Fluxo crítico Fase 0

| Passo | Legado (UI) | Legado (API usada) | Core homolog (MVC) | Paridade |
|:-----:|-------------|-------------------|---------------------|:--------:|
| 1 | `#/login` → `Login/index.html` | `api/login/*` | `GET /Account/Login` | 🟡 UI diferente |
| 2 | pós-login → `#/obra/escolher` | obras colaborador | `GET /Obra/Escolher` | 🟡 |
| 3 | clique obra | `Obra/Selecionar` (API) | `POST /Obra/Selecionar` | ✅ lógica sessão |
| 4 | dashboard tarefas | `#/tarefa/cards` | `GET /Tarefa/Cards` | ⬜ **placeholder** |
| 5 | accordion/lista | `#/tarefa/index` | — | ⬜ |
| 6 | nova medição | modals / cadastro | — | ⬜ |

---

## 2. Rotas ui-router legado (amostra crítica)

| State name | URL hash | Template |
|------------|----------|----------|
| `layoutexterno.login` | `/login` | `Client/Views/Login/index.html` |
| `layoutinternoazul.obraescolher` | `/obra/escolher` | `Client/Views/Obra/escolher.html` |
| `layoutinterno.tarefacards` | `/tarefa/cards` | `Client/Views/Tarefa/cards.html` |
| `layoutinterno.tarefa` | `/tarefa/index` | `Client/Views/Tarefa/index.html` |
| `layoutinterno.tarefacadastro` | `/tarefa/cadastro` | cadastro |
| `layoutinterno.tarefaparalizacoes` | `/tarefa/paralizacoes/index` | paralisações |

Default route: `otherwise('/login')`.

---

## 3. Controllers Core (existentes)

| Controller | Actions | Notas |
|------------|---------|--------|
| `AccountController` | Login GET/POST, logout, cookie, `LoginData` session | CPF + senha legado |
| `ObraController` | `Escolher`, `Selecionar` | Redirect `Tarefa/Cards` |
| `TarefaController` | `Cards` | View placeholder |
| `HomeController` | Index, Privacy | Bootstrap template |

---

## 4. Web API legado — mobile + Angular

Controllers API (28+): incluem `LoginController`, `ObraController`, `TarefaController`, `EtapaController`, `MedicaoController`, `RdoController`, …

Padrão de rota: `api/{controller}/{action}` (ver `WebApiConfig.cs`).

**Mobile Apontador** (estudo E3): consome este host **`sistema.rdoapp.com.br`** prod — **não** homolog Core :5081.

---

## 5. Mapeamento prioridade Ondas U

| U / TSK | Legado | Core alvo homolog |
|---------|--------|-------------------|
| U-25 obra ativa | localStorage + API | Session `ObraId` ✅ |
| TSK-17…23 cards/accordion | `cards.html` + `TarefaController.js` | **Razor Cards** ⬜ |
| TSK-35 medição | modals Angular | fase posterior |
| Laudo | legado Piscinas-heavy | validar escopo Equipamentos |

---

## 6. Gilberto / referência visual

Comparar comportamento com:

`Migration2Core/EquipoToPiscina-1/RDO-Production-Gilberto/` (somente referência — prod Equipamentos = repo `Equipamentos`).

---

## 7. Conclusão E2

- **Eixo Login → Escolher → Selecionar** está mapeado no Core; **Cards** é o gargalo Fase 0.
- **Strangler** futuro: React substitui **Angular**, não necessariamente Razor homolog — ordem: Cards Razor MVP → E2E → React Onda 2.
- **API legado** permanece fonte do **mobile** até contrato Core/JWT (E3).
