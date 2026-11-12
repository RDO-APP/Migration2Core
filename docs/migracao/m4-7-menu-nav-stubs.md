# M4.7 / M5-nav — Menu drawer + botões P3 (B–D)

**Atualizado:** 2026-11-12 — tip **`b90cc54`** · drawer P6a listagens SPA · **Mapa href:** `LegacyOperadorRoutes.cs` · **ServeSpa:** Obra/Etapa/Empresa/Colaborador/Equipamento (+ RDO/Chart/Dashboard/Efetivo/Cards)

## B — Menu principal

| Origem | Comportamento homolog |
|--------|------------------------|
| `GET /api/bff/shell` → `menuPaginas[]` | `href` mapeado; entradas `#` omitidas |
| Clique drawer | `goOperador(href)` → MVC **200** SPA ou EmMigracao |
| **P6a index** (obra, etapa, empresa, colaborador, equipamento) | `ServeSpaIndex` + BFF lista · cadastros empresa/colaborador/equipamento ainda EmMigracao |
| Admin (grupo, menu, páginas, histórico) + Relatórios | `/grupo/*`, `/menu/*`, `/relatorio*`… → **Em migração** |
| Paralizações | `/tarefa/paralizacoes/index` → EmMigracao (**CAT-PARALIZ-01**) |
| Card de tarefas (`#/pagina/index`) | → `/Tarefa/Cards` |
| Colaborador alterar senha no menu | → `/Account/ChangePassword` |

**Smoke G5:** abrir cada item do drawer logado + obra — nenhum 404; tabela cms §2.1.

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
