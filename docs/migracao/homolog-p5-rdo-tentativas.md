# Homolog P5a — RDO `/Rdo/Index` · registro de tentativas

**Objetivo:** contar smoke e classificar falha (MVC vs deploy vs React vs BFF).  
**Diagnóstico F12:** § [Como ler](#como-ler-f12) · API `GET /api/bff/diag` · cabeçalho `X-RdoApp-Diag`

---

## Fase atual

| Marco | Estado |
|-------|--------|
| P3 Cards | ☑ homolog |
| P5a RDO listagem | 🟡 loop redirect **até deploy** com fix `3a7f5ad`+ |
| Diagnóstico visível | ☑ a partir do commit pós-`3a7f5ad` (faixa verde + API diag) |

**Por que “trava” aqui:** RDO usa **nova URL MVC** (`/Rdo/Index`) com **full page**; se o pacote na EC2 for antigo ou o servidor responder **302 Login ↔ Rdo**, o React **nem carrega** — a faixa verde só aparece quando a SPA recebe **200**.

---

## Tentativas (contagem)

| # | Data (BR) | Deploy D+E? | Commit alvo | O que você viu | Classe | Próximo passo |
|---|-----------|-------------|-------------|----------------|--------|----------------|
| **T0** | 2026-10-26 | ❓ | ≤ `3e3709b` | HTTP **500** AmbiguousMatch em `/Rdo/Index` | rota MVC | Fix `3e3709b` |
| **T1** | 2026-10-26 | ❓ | ≤ `3e3709b` | `ERR_TOO_MANY_REDIRECTS` em `/Rdo/Index` | **A** loop MVC/auth | Deploy `3a7f5ad` |
| **T2** | 2026-10-26 | ❓ | `3a7f5ad` local, EC2 ? | Mesmo loop após clique RDO | **B** EC2 desatualizada **ou** A | Confirmar SSM Success pós-D |
| **T3** | _a preencher_ | | pós-diag + D+E | Após deploy EC2 com anti-loop + diag | **E** se OK | Chart/Index ou nova linha T4 |

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

1. **Cards (P3):** faixa **preta/verde embaixo** → `pagina=cards` · Console: `[RDO homolog]`.
2. **Rede:** apague filtro `app/assets` → clique **Fetch/XHR** → deve aparecer **`diag`** e **`etapas`** (200).
3. **Clique RDO:**
   - **Doc** `Rdo/Index` → **Cabeçalhos** → `X-RdoApp-Diag` e `X-RdoApp-Redirect-Motivo` (se 302).
4. **Colar no chat:** abra `https://homolog.sistema.rdoapp.com.br/api/bff/diag` (logado) e copie o JSON.

---

## Referência

Manual §10.8 · [`m5-web-paridade-prod-ordem.md`](m5-web-paridade-prod-ordem.md) · deploy [`roteiro-deploy-homolog-operador.md`](roteiro-deploy-homolog-operador.md)
