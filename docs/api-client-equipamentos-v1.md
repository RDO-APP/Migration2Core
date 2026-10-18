# api-client Equipamentos v1 (M1)

**Substitui:** v0 como referência ativa — v0 permanece histórico M0.  
**Tipos:** [`api-client/equipamentos-api.types.ts`](api-client/equipamentos-api.types.ts)

---

## Cenários de URL (E3 — fechado M1)

| ID | Cenário | Web homolog (EQ-W/R) | Mobile (EQ-M) | M1 |
|----|---------|----------------------|---------------|:--:|
| **A** | **Adotado** | `https://homolog.sistema.rdoapp.com.br` — MVC/Core cookie · `homol_rdoapp` | `https://sistema.rdoapp.com.br` — API legado prod | ☑ |
| B | API espelhada no Core | homolog + `/api/*` | homolog API | M6+ |
| C | JWT API mínima | Core | Core | M6 |
| D | Legado IIS homolog | site legado | legado homolog RDS | se infra existir |

**Regra M1–M2:** EQ-R Cards na homolog web consumem **legado API prod** (CORS/proxy BFF no Core) **ou** cookie MVC + dados server-side até BFF existir — ver § EQ-R homolog.

---

## Base URL

```text
PROD_API  = https://sistema.rdoapp.com.br     # EQ-L · EQ-M default
HOMOLOG_WEB = https://homolog.sistema.rdoapp.com.br  # EQ-W/R host (sem paridade api/* hoje)
```

Mobile (`appVariant.ts`): `EXPO_PUBLIC_API_ENV=prod` → **PROD_API**.

---

## Endpoints prioritários (M2 Cards)

| Prioridade | Método | Path | Consumer |
|:----------:|--------|------|----------|
| P0 | POST | `/api/login/LoginUser` | EQ-M · EQ-R (futuro) |
| P0 | POST | `/api/obra/ObterObras` | EQ-M · EQ-R Escolher |
| P0 | POST | `/api/Usuario/LoginObra` | EQ-M · EQ-R sessão obra |
| P0 | GET | `/api/etapa/Get/?idObra={id}` | EQ-M · **EQ-R Cards** |
| P1 | GET | `/api/etapa/ObterEtapaTarefa/?…` | filtros Cards |
| P1 | POST | `/api/tarefa/ObterTarefa/` | detalhe card |

Catálogo completo: [`api-client-equipamentos-v0.md`](api-client-equipamentos-v0.md).

---

## Estratégia EQ-R homolog (M2)

| Opção | Descrição | Quando |
|-------|-----------|--------|
| **2a (curto)** | React SPA atrás do Core; login/obra via **cookie MVC** existente; Cards fetch **BFF** no Core que chama `etapa/Get` server-side | M2 se CORS bloquear browser→prod |
| **2b** | React chama **PROD_API** com credenciais/session token | só se auth unificado |
| **2c** | Proxy dev Vite → prod | dev local only |

**Decisão M2 (2026-10-17):** **BFF homolog-only** — Core EF em `homol_rdoapp` (`GET /api/bff/etapas`). Proxy prod **2a** fica para M6 ou quando web homolog compartilhar ids com prod. Cenário **A** continua válido para **EQ-M** → prod.

---

## Tipos TypeScript

Arquivo canônico M1: [`equipamentos-api.types.ts`](api-client/equipamentos-api.types.ts) — espelho de `EquipamentosMobile` (`obraTypes`, `tarefasTypes`, `AuthContext`).

---

## Próximo (M2)

- Wire `client/` com P0 + tipos M1  
- Cards com dados (`Etapa[]`)  
- EQ-W0.5 em paralelo se E2E Razor ainda necessário
