# M4.7 / M5-nav — Menu drawer + botões P3 (B–D)

**Atualizado:** 2026-11-13 — auditoria drawer+subpáginas · Paralizações stub · aliases `/chart/atrasado` · `/relatoriomedicao/index` · `/obra/lista`

## B — Menu principal

| Origem | Comportamento homolog |
|--------|------------------------|
| `GET /api/bff/shell` → `menuPaginas[]` | `href` mapeado; entradas `#` omitidas |
| Clique drawer | `goOperador(href)` → MVC **200** SPA ou EmMigracao |
| **P6a index** (obra, etapa, empresa, colaborador, equipamento) | `ServeSpaIndex` + BFF · cadastros SPA |
| Admin + Relatórios | EmMigracao |
| Paralizações | EmMigracao (**CAT-PARALIZ-01**) |
| Card (`#/pagina/index`) | → `/Tarefa/Cards` |
| Alterar senha | → `/Account/ChangePassword` |

### Cobertura G5 (audit 13/11) — drawer 9 + subpáginas

| Drawer | Index | Sub (NOVO/editar) | Status rota |
|--------|-------|-------------------|-------------|
| Card de Tarefas | SPA `/Tarefa/Cards` | LISTA · Cadastro · status/excluir/rel.horas | ✅ SPA / EmMigracao |
| Colaboradores | SPA | `/colaborador/cadastro` SPA | ✅ |
| Códigos de Paralizações | EmMigracao | cadastro → stub | ✅ (CRUD = CAT-PARALIZ-01) |
| Efetivo Diário | SPA | sem sub-rota drawer (gaps Copiar/Novo = feature) | ✅ |
| Empresas | SPA | `/empresa/cadastro` SPA | ✅ |
| Equipamentos | SPA | `/equipamentos/cadastro` SPA | ✅ |
| Etapas | SPA | `/Etapa/Cadastro` SPA | ✅ |
| Obras | SPA | `/Obra/Cadastro` · `/obra/lista` stub | ✅ |
| RDOs | SPA | `/Rdo/Cadastro` SPA | ✅ |

**Header:** Chart + `/chart/*` (incl. atrasado) · Dashboard · senha · nova obra. **Catálogo fora do ☰:** Relatórios ×3 · Admin Grupo/Menu/Página → EmMigracao.

**Smoke G5:** cada item do drawer → 200; cms §2.1.

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
