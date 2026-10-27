# Homolog P5a — RDO `/Rdo/Index` · registro de tentativas

**Objetivo:** contar smoke e classificar falha (MVC vs deploy vs React vs BFF).  
**Diagnóstico F12:** § [Como ler](#como-ler-f12) · API `GET /api/bff/diag` · cabeçalho `X-RdoApp-Diag`

---

## Fase atual

| Marco | Estado |
|-------|--------|
| P3 Cards | ☑ homolog |
| P5a RDO listagem | 🟡 loop redirect **até deploy** com fix `3a7f5ad`+ |
| Diagnóstico visível | ☑ **`/Homolog/F12`** + `GET /api/bff/diag` (sem rodapé nas telas P1–P5) |

**Por que “trava” aqui:** RDO usa **nova URL MVC** (`/Rdo/Index`) com **full page**; se o servidor responder **302 Login ↔ Rdo**, o React **nem carrega** — use **`/Homolog/F12`** e Rede **Doc** (cabeçalhos), não rodapé na tela operador.

---

## Tentativas (contagem)

| # | Data (BR) | Deploy D+E? | Commit alvo | O que você viu | Classe | Próximo passo |
|---|-----------|-------------|-------------|----------------|--------|----------------|
| **T0** | 2026-10-26 | ❓ | ≤ `3e3709b` | HTTP **500** AmbiguousMatch em `/Rdo/Index` | rota MVC | Fix `3e3709b` |
| **T1** | 2026-10-26 | ❓ | ≤ `3e3709b` | `ERR_TOO_MANY_REDIRECTS` em `/Rdo/Index` | **A** loop MVC/auth | Deploy `3a7f5ad` |
| **T2** | 2026-10-26 | ❓ | `3a7f5ad` local, EC2 ? | Mesmo loop após clique RDO | **B** EC2 desatualizada **ou** A | Confirmar SSM Success pós-D |
| **T3** | **2026-10-27 08:05** (BR) | ✅ D+E · SSM `46901ecd-faff-47a0-97dc-28d5817f3185` Success · ~1,4 min | `c0d09e8` · publish `index-C4fKCj64.js` | P1/P3 OK · clique RDO → **`ERR_TOO_MANY_REDIRECTS`** em `/Rdo/Index` (print) · meta prod `#/rdo/index` | **A** | Deploy pós-fix F12 + auth scheme · **T4** |

### Classes de falha

| Classe | Significado |
|--------|-------------|
| **A** | Loop ou 302 Login ↔ Rdo (servidor / cookie) |
| **B** | Código novo no Git mas **EC2 ainda com zip antigo** |
| **C** | **200** + SPA mas tela errada (React `route.ts`) |
| **D** | **200** + RDO UI mas BFF `/api/bff/rdos` falha |
| **E** | OK — listagem RDO visível |

---

## Como ler F12 (leigo)

1. Abra **`https://homolog.sistema.rdoapp.com.br/Homolog/F12`** (logado) — snapshot + JSON automático.
2. **Cards (P3):** Console opcional `[RDO homolog]` — **sem** barra no rodapé.
3. **Rede:** apague filtro `app/assets` → **Fetch/XHR** → **`diag`**, **`etapas`** (200).
3. **Clique RDO:**
   - **Doc** `Rdo/Index` → **Cabeçalhos** → `X-RdoApp-Diag` e `X-RdoApp-Redirect-Motivo` (se 302).
4. **Colar no chat:** abra `https://homolog.sistema.rdoapp.com.br/api/bff/diag` (logado) e copie o JSON.

---

## Referência

Manual §10.8 · [`m5-web-paridade-prod-ordem.md`](m5-web-paridade-prod-ordem.md) · deploy [`roteiro-deploy-homolog-operador.md`](roteiro-deploy-homolog-operador.md)
