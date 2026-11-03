# M4.7g — RBAC operador P1 → P3 (`GET /api/bff/shell`)

**Trilha:** EQ-R · **Atualizado:** 2026-10-26  
**Código:** `ShellContextService` · `PermissionHelper` (espelho `Permission.check` em `app.js`) · React `OperadorShell` / `CardsToolbar`

---

## Regra única (legado = Core)

1. Sessão guarda `LoginData` (JSON) com `Routes[]`: `{ path, permissions[] }`.
2. `Permission.check(perm, route)` / `PermissionHelper.HasPermission(context, perm, route)`:
   - rota **não** listada → **false** (oculta UI);
   - rota listada sem `permissions` → **false**;
   - permissão presente na lista → **true**.

Paths usados no BFF (minúsculas, como no BD):

| Campo JSON `shell` | Permissão | Rota (`path`) | Onde aparece |
|--------------------|-----------|---------------|--------------|
| `showChart` | `visualizar` | `/chart` | Header — Dashboard geral |
| `showNovaObra` | `visualizar` | `/obra/cadastro` | Header — Nova obra (+) |
| `showDashboardObra` | `acessarDashboard` | `/dashboard/index` | Header P3 — Dashboard da obra |
| `showGerarRdo` | `gerarRdo` | `/tarefa/cards` | Toolbar linha título — ícone RDO |
| `showEditarObra` | `editarObra` | `/tarefa/cards` | Toolbar linha título — lápis |
| `showCriarNovoTarefa` | `criarNovo` | `/tarefa/cards` | FILTRO / ADICIONAR TAREFA |
| `showCriarNovaEtapa` | `criarNovo` | `/etapa/index` | ADICIONAR ETAPA (`permission-route`) |
| `showAlterarStatusEmMassa` | `aterarStatusEmMassa` | `/tarefa/cards` | Botão abaixo de SELECIONAR TUDO |
| *(sempre)* | — | — | **Efetivo diário** (prod sem `permission` em `cards.html`) |

Menu lateral: itens vêm de `LoginData.Menu` (grupo), href via `LegacyOperadorRoutes.MapHref` — ver [`m4-7-menu-nav-stubs.md`](m4-7-menu-nav-stubs.md).

---

## Quando as rotas mudam (P1 → P2 → P3)

| Etapa | Evento | `Routes` na sessão |
|-------|--------|---------------------|
| **P1** | `POST` login | `ObterRotasDefault` — grupo do **colaborador** |
| **P2** | Listar obras | Mesmo JSON até **Selecionar** |
| **P2** | **Selecionar obra** | `LoginObraService` recarrega `GetRoutesForGroupAsync(oco_id_grupo)` — grupo **da obra** |
| **P3** | Cards | Shell lê sessão **pós-obra** → toolbar RDO/editar dependem do grupo da obra |

**Smoke RBAC na P3:** sempre **Selecionar obra** de novo após trocar usuário ou comparar com prod.

---

## Checklist operador (1 sessão — item A)

1. Login homolog → P2 → Selecionar obra (ex. 42).
2. Abrir P3 `/Tarefa/Cards` → DevTools → **Network** → `GET /api/bff/shell` → copiar JSON.
3. Contar ícones na **linha do título** (não confundir com FILTRO/ADICIONAR):
   - `showGerarRdo` → ícone RDO
   - `showEditarObra` → lápis
   - Efetivo → sempre
4. Repetir no **prod** (mesmo CPF) e anotar 2 vs 3 ícones.
5. Se homolog ≠ prod com **mesmo CPF e mesma obra**: comparar `homol_rdoapp` × prod (`grupo_pagina_acao` / grupo da obra), não culpar deploy.

### Interpretação rápida

| Sintoma | Causa provável |
|---------|----------------|
| Chart / Nova obra aparecem antes do menu carregar e somem | Corrigido **2026-10-26**: header fail-closed até shell |
| 3 ícones homolog, 2 prod | JSON com `showEditarObra: true` — **dado/perfil**, se prod não tem `editarObra` em `/tarefa/cards` |
| Nenhum ícone RDO/editar | Grupo sem permissões na rota `/tarefa/cards` |
| Menu vazio | `Menu` do grupo ou sessão sem `LoginData` |

---

## B–D (2026-10-26)

Menu, botões P3 e polish header: [`m4-7-menu-nav-stubs.md`](m4-7-menu-nav-stubs.md).

**Doc irmão:** [`p3-botoes-habilitacao-m7.md`](p3-botoes-habilitacao-m7.md) · roteiro **G5–G6** · [`fontello-fa-legado-marcos-ui.md`](fontello-fa-legado-marcos-ui.md).
