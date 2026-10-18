# M0 — Plano de execução + checklists

**Marco:** M0 Arranque · **Data início:** 2026-10-17  
**Referências:** [`m0-duvidas-dimas-solucoes.md`](m0-duvidas-dimas-solucoes.md) · [`plano-execucao-migracao-v1.md`](plano-execucao-migracao-v1.md)

---

## A. Decisões Lucio (sem Dimas) — registrar

| # | Decisão | Valor M0 | OK |
|---|---------|----------|:--:|
| A1 | Dono EQ-R homolog | Lucio + Cursor | ☑ |
| A2 | Cenário mobile homolog | **A** — app prod API; web homolog Core/RDS | ☑ |
| A3 | SPA React local | `Migration2Core/RDO-CleanMigration-2026/client/` | ☑ |
| A4 | Branch mobile inventário | `feature/alteracoes_apontador` @ `14cf5d3` | ☑ |
| A5 | Cards: EQ-R (não Razor) | Confirmado orquestrador | ☑ |

---

## B. Git / inventário EQ-M

| # | Item | OK | Notas |
|---|------|:--:|-------|
| B1 | `git fetch` EquipamentosMobile | ☑ | 2026-10-17 |
| B2 | Checkout `feature/alteracoes_apontador` | ☑ | HEAD `14cf5d3` |
| B3 | Doc endpoints v0 | ☑ | [`api-client-equipamentos-v0.md`](api-client-equipamentos-v0.md) |
| B4 | Migration2Core: sem branch React | ☑ | só main, ci/*, homolog/* |

---

## C. EQ-R scaffold (greenfield)

| # | Item | OK | Notas |
|---|------|:--:|-------|
| C1 | Plano scaffold | ☑ | `Migration2Core/.../EQ-R-SCAFFOLD-M0.md` |
| C2 | `npm create vite` pasta `client/` | ☑ | `RDO-CleanMigration-2026/client` react-ts |
| C3 | Build `client` (`npm run build`) | ☑ | 2026-10-17 · host Core = M2 |

---

## D. E2E ponte EQ-W (homolog remoto)

**URL:** `https://homolog.sistema.rdoapp.com.br`  
**Usuário:** CPF `53821963549` / senha `1234` · catálogo `homol_rdoapp`

| # | Passo | Agente | Lucio |
|---|--------|:------:|:-----:|
| D1 | Login carrega | — | ☑ |
| D2 | Login OK → Escolher | — | ☑ |
| D3 | Lista obras (7 cards) | — | ☑ |
| D4 | Selecionar → `/Tarefa/Cards` | — | ☐ **erro** |
| D5 | Cards placeholder | — | ☐ N/A |

**Lucio 2026-10-17:** homolog OK até Escolher; branding **Piscinas**; clique obra **FAIL** → [`m0-registro-encerramento.md`](m0-registro-encerramento.md).

**Resultado M0 E2E:** ☑ **PARCIAL PASS**

---

## E. E2E local opcional (dev PC)

Ver [`e2e-fase0-checklist.md`](e2e-fase0-checklist.md) — `https://localhost:7176` se RDS acessível.

| # | Item | OK |
|---|------|:--:|
| E1 | `dotnet build` RdoApp.Core | ☑ | 2026-10-17 agente — warnings only |
| E2 | Checklist localhost completo | ☐ |

---

## F. Fechamento M0

| Critério | Status |
|----------|--------|
| Decisões A* | ☑ |
| Inventário B* | ☑ |
| Plano EQ-R C1 | ☑ |
| E2E homolog D* | ☑ PARCIAL |
| Orquestrador → M1 | ☑ 2026-10-17 |

**M0 = FECHADO (PARCIAL PASS)** — registro completo: [`m0-registro-encerramento.md`](m0-registro-encerramento.md)

---

## Próximo marco

**M1** — [`m1-execucao-checklist.md`](m1-execucao-checklist.md) · **M2** em seguida (Cards EQ-R).
