# M4.7 / M5-nav — Menu drawer + botões P3 (B–D)

**Atualizado:** 2026-10-26 · **Mapa href:** `RdoApp.Core/Infrastructure/LegacyOperadorRoutes.cs` · **Stubs:** `ModuloLegadoController` + controllers Tarefa/Rdo/Chart/Efetivo/Obra/Etapa

## B — Menu principal

| Origem | Comportamento homolog |
|--------|------------------------|
| `GET /api/bff/shell` → `menuPaginas[]` | `href` mapeado; entradas `#` omitidas |
| Clique drawer | `goOperador(href)` → MVC **200** ou redirect SPA |
| Admin (grupo, menu, páginas, histórico, relatórios) | `/grupo/*`, `/menu/*`, … → **Em migração** |
| Card de tarefas (`#/pagina/index`) | → `/Tarefa/Cards` |
| Colaborador alterar senha no menu | → `/Account/ChangePassword` |

**Smoke G5:** abrir cada item do drawer logado + obra selecionada — nenhum 404.

## C — Botões P3

| Área | Destino | RBAC shell |
|------|---------|------------|
| Toolbar ícones | `/Rdo/Cadastro`, `/Obra/Cadastro`, `/Efetivo` | `showGerarRdo`, `showEditarObra` |
| LISTA / FILTRO / ADICIONAR | rotas em `p3-operador-routes.ts` | `showCriarNovo*` |
| Card (⋮, olho, lápis, …) | `/Tarefa/*` stubs | M7 (visibilidade fina depois) |
| alterar status em massa | `/Tarefa/AlterarStatusEmMassa` | `showAlterarStatusEmMassa` |

## D — Polish header (UI-M2d)

- `operador-shell.css`: gap logo ↔ ☰, largura hamburger desktop 63px (prod `header.css`).
- Logo → `/Obra/Escolher` via `goOperador`.

**Próximo marco produto:** M5 telas reais · M7 modais/API.
