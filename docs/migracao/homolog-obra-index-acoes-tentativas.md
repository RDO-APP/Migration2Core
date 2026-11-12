# Homolog — Obras `/Obra/Index` ações (convite / copiar)

**Trilha:** EQ-R · **Página:** menu ☰ Obras · SPA `ObraIndexPage` · BFF `GET /api/bff/obras/index/bootstrap`  
**Usuário smoke:** CPF `538.219.635-49` · Diretor Contratada  
**Prod ref:** `Client/Views/Obra/index.html` — `fa-send` · `fa-copy` · `fa-edit` · `fa-trash-o`

---

## Tentativas

| # | Hipótese | Solução aplicada | Resultado | Evidência |
|---|----------|------------------|-----------|-----------|
| **O1** | Ações faltavam por GPA só em `/obra/index` | Bootstrap com `PermissionHelper(…, "/obra/index")` | Só **editar** + **excluir** | Print migração sem avião/copiar; prod com 4 ícones |
| **O2** | GPA canônico em `/obra/lista` (cms §3.1) | `CanObraLista` = `/obra/index` **∪** `/obra/lista` + BFF delete/convidar | Botões **no DOM** (title funciona) mas **ícones invisíveis** | Tooltip «Enviar Convite» / «Copiar Obra» no espaço vazio; editar/lixeira OK |
| **O3** | Subset FA em `escolher.css` sem `fa-send`/`fa-copy` | Glifos `\f1d8` / `\f0c5` (+ `fa-search`) em `wwwroot/css/escolher.css` e `.lista-tarefas` em `cards-page.css` | **Smoke OK 11/nov** — homolog (lista `1a ETAPA…`) com avião+copiar+editar+lixeira na FACHADA | Print Lucio FACHADA OESTE |

---

## Próxima solução (O3 → smoke)

1. Publish + deploy (roteiro homolog).
2. Hard refresh / logout-login Diretor.
3. Esperado: **avião + copiar + editar + lixeira** (olho só se `visualizarRegistro`).
4. Se ainda vazio: DevTools → `<i class="fa fa-send">` computed `content` / `font-family: FontAwesome`.

**Filtro «Contratante»:** paridade prod (filtro Contratada comentado no HTML legado) — **não** é bug desta fila.

**Não confundir:** O2 já liberou permissão; O3 é **só ícone** (UI-M1 subset).
