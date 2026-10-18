# Mapa de estudo — trabalho Kiro × Migração Cursor

**Chat:** Migração .NET Core (`ee6f7379-dfb3-4995-a6cd-1c691007e9b0`)  
**Criado:** 2026-10-16  
**Atualizado (E0):** 2026-10-17 — homolog `homol_rdoapp`, Selecionar/Cards, estudos E1–E6  
**Objetivo:** Ordem de leitura e cruzamento com **Ondas U** / **TSK Dimas**, sem depender da pasta OneDrive Kiro.

---

## 1. Qual fonte usar

| Prioridade | Onde | Para quê |
|:---:|---|---|
| **1** | `C:\Dev\Migration2Core` (GitHub `RDO-APP/Migration2Core`) | Código + ~80 `.md` de sessão Kiro |
| **2** | `docs/estudos-lucio-apps-plano-migracao-core/` (este repo Equipamentos) | Ondas U, TSK, FAPESC, Loja×Sistema |
| **3** | `…\.Net Piscina\Kiro\` (OneDrive) | Só complemento: `.docx`, prints — **quando baixar** |
| **Ref. legado** | `Migration2Core/EquipoToPiscina-1/RDO-Production-Gilberto/` | Comportamento visual e regras Gilberto |

**Regra:** estudar e codar pelo **GitHub/local `C:\Dev`**. Pasta Kiro **não bloqueia** o mapa.

---

## 2. Ordem de leitura (≈ 3–4 h concentradas)

### Fase A — Contexto em 30 min

| # | Arquivo | O que você leva |
|---|---|---|
| A1 | `Migration2Core/README.md` | Dois projetos (Piscinas abandonado vs Clean 2026) |
| A2 | `RDO-CleanMigration-2026/README.md` | Stack, ~35%, feito vs pendente, regras do codebase |
| A3 | `docs/…/storytelling-unificado-dimas-migracao-fapesc.md` | Ondas 0–6 vs TSK vs FAPESC (visão Lucio) |

### Fase B — O que o Kiro fez (jan–fev/2026) em 45 min

| # | Arquivo | O que você leva |
|---|---|---|
| B1 | `RDO-CleanMigration-2026/RETROSPECTIVE-JANUARY-2026.md` | Lições da 1ª migração |
| B2 | `RDO-CleanMigration-2026/FEBRUARY-2026-COMPLETE-SUMMARY-AND-NEXT-PLAN.md` | 4 fases: entidades, Escolher, header, permissões |
| B3 | `RDO-CleanMigration-2026/RESUMPTION-PLAN-FEBRUARY-2026.md` | Pausa 35%, mobile, próximos passos |
| B4 | `RDO-CleanMigration-2026/ESCOLHER-OBRA-TECHNICAL-BLUEPRINT.md` | Spec Escolher Obra (= docx Kiro v03/fev) |

**Pular na 1ª passada:** dezenas de `HEADER-*`, `BUTTONS-*`, `PHASE-*` — são diário forense; volte só se estiver debugando header/RBAC.

### Fase C — Plano de páginas críticas em 30 min

| # | Arquivo | O que você leva |
|---|---|---|
| C1 | `RDO-CleanMigration-2026/4-CRITICAL-PAGES-IMPLEMENTATION-PLAN.md` | Login, Escolher, Etapa/Tarefa, Nova Medição + anti-padrões |
| C2 | `RDO-CleanMigration-2026/analysis/01-LEGACY-CODE-STRUCTURE-ANALYSIS.md` | Mapa do legado (48 entidades) |
| C3 | `RDO-CleanMigration-2026/HOW-TO-RUN-IN-VISUAL-STUDIO.md` | Rodar local + RDS |

### Fase D — Alinhamento Dimas / Ondas U em 45 min

| # | Arquivo | O que você leva |
|---|---|---|
| D1 | `docs/…/comparativo-dimas-v20260818.md` §4 | Tabela **TSK-01…56 × U-xx** |
| D2 | `docs/…/comparativo-e-plano-unificado.md` | Strangler vs reescrita; divergências |
| D3 | `docs/…/comparativo-dimas-v20260909.md` | PDF set/2026 = mesmo backlog ago/2026 |

### Fase E — Código (explorar no VS / Cursor) em 60 min

Caminho do app:

`Migration2Core/RDO-CleanMigration-2026/RDO-CleanMigration-2026/RdoApp.Core/`

| Área | Pastas / arquivos |
|---|---|
| Auth | `Controllers/…/AccountController`, `Views/Account/Login.cshtml` |
| Escolher Obra | `ObraController`, `Views/Obra/Escolher.cshtml`, `wwwroot/css/escolher.css` |
| RBAC | `Utils/PermissionHelper.cs`, partial `_HeaderEscolher.cshtml` |
| Dados | `Data/Entities/*`, `Data/Configurations/*`, `RdoDbContext` |
| Legado compare | `EquipoToPiscina-1/RDO-Production-Gilberto/` |

---

## 3. Linha do tempo Kiro (resumo)

| Período | Entrega |
|---|---|
| Mai/2025 – Jan/2026 | `EquipoToPiscina-1` — legado, laudo, crises (blank page) → **abandonado** |
| 22–25 Jan/2026 | Clean Migration: solution .NET 8, **48 entidades** EF Core |
| 26 Jan/2026 | Login |
| 27 Jan – 5 Fev/2026 | Escolher Obra (cards, filtros, header, toolbar RBAC) |
| ~17 Fev/2026 | Última sessão registrada; **pausa** (~35%) — foco mobile (Carlos/Dimas) |
| Mai/2026 | GitHub: commits de org + docs Apontador/Equipamentos (sem novo código Clean Migration) |

---

## 4. Cruzamento — Clean Migration hoje × **Onda 1** (TSK-01…12)

Legenda: ✅ feito (ou equivalente) · 🟡 parcial · ⬜ não · 🔀 decisão diferente do backlog Dimas

| TSK / U | Dimas espera | Estado Kiro (`RdoApp.Core`) |
|---|---|---|
| TSK-01 / U-10 Solution .NET 8 | Clean Architecture, MediatR | 🟡 Solution MVC **sem** camadas Application/Domain separadas |
| TSK-02 / U-11 EF Core + MySQL | Migrations, Dapper | ✅ EF Core + Pomelo; schema legado; 🟡 Dapper não |
| TSK-03 / U-12 Domain entities | Modelo de domínio | ✅ 48 entidades mapeadas |
| TSK-04–05 / U-14 Observabilidade + auditoria EF | Serilog, interceptor | ⬜ |
| TSK-06 / U-16 Hardening | CORS, rate limit, Argon2 | 🟡 cookie auth legado-style; sem hardening completo |
| TSK-07 / U-16, U-21 JWT | Bearer + refresh | 🔀 **Cookies** (legado), não JWT |
| TSK-08–09 / U-17 Email + S3 | Infra | ⬜ |
| TSK-10 / U-19 React scaffold | SPA Vite | 🔀 **Razor MVC** — alinhado à pausa “web operador depois” |
| TSK-11 / U-22 Troca senha | React | ⬜ |
| TSK-12 / U-24 RBAC | usePermission React | 🟡 `PermissionHelper` + sessão — **lógica** iniciada, UI Razor |

**Atualização homolog 2026-10-17:** catálogo **`homol_rdoapp`** (47 tbl); Core aponta homolog Equipamentos; `POST /Obra/Selecionar` implementado; `/Tarefa/Cards` = **placeholder** (ver E1/E2).

**Leitura:** o Kiro **adiantou** boa parte da **fundação de dados + auth web legado-like + Escolher Obra**, mas **não** a Onda 1 “completa” do PDF Dimas (JWT, React, Clean Arch, S3, Serilog).

---

## 5. Cruzamento — próximo código Kiro × **Ondas U** (operacional)

| Item pendente (README Kiro) | Onda / TSK relacionada | Notas |
|---|---|---|
| Copiar fontes + `user.png` | — | Tarefa manual 5 min |
| Teste E2E login → Escolher → **clicar obra** | Onda 2 / U-25 obra ativa | 🟡 Selecionar OK; validar homolog URL |
| Dashboard Etapas/Tarefas (accordion) | Onda 3–4 / TSK-17…23, cards | Depois da seleção de obra |
| Task cards `/tarefa/cards` | Blueprint Escolher § navegação | **Gap #1** — view placeholder |
| Nova Medição, Laudo | TSK-35, laudo | Plano 4 páginas críticas |
| RBAC 5 níveis completo | TSK-12 | Parcial no header |
| React Strangler web | TSK-10+, Onda 2 | **Futuro** — Clean Migration é MVC proposital |

**Onda 0 (apps mobile)** segue **fora** deste repo — ver `storytelling-unificado` e chat mobile.

---

## 6. Documentos Kiro — quando abrir qual

| Situação | Documento |
|---|---|
| Entender **por que** não inline JS | `4-CRITICAL-PAGES-IMPLEMENTATION-PLAN.md` |
| Entender **Escolher Obra** (cards, progresso, API) | `ESCOLHER-OBRA-TECHNICAL-BLUEPRINT.md` |
| Botões header sumiram | `BUTTONS-FORENSIC-ANALYSIS-LEGACY-ROUTES.md` (só se debug) |
| Banco errado localhost vs RDS | `CONTEXT-TRANSFER-SUMMARY.md`, `DATABASE-CONNECTION-FIXED.md` |
| Retomar após pausa | `RESUMPTION-PLAN-FEBRUARY-2026.md` |
| Briefing mobile Carlos | `MOBILE-*-BRIEFING-CARLOS.md` |

---

## 7. Pasta Kiro (OneDrive) — uso opcional

| Item | Equivalente no GitHub |
|---|---|
| `Escolher Obra … v03Fev2026 Completa.docx` | `ESCOLHER-OBRA-TECHNICAL-BLUEPRINT.md` |
| `RDO-NET8-Migration/RdoApp.Core` | `…/RDO-CleanMigration-2026/RdoApp.Core` (mesmo nome de projeto) |
| `PLANO DE AÇÃO DEFINIDO.docx` | Ler após sync; pode repetir `RESUMPTION-PLAN` |
| `Prints Telas Kiro` | Screenshots — útil para QA visual |

---

## 8. Próximos passos sugeridos (Cursor Migração)

1. **Plano execução v1:** [`plano-execucao-migracao-v1.md`](plano-execucao-migracao-v1.md) (estudo E5).
2. **Cards EQ-R (React)** — paridade mínima com `Client/Views/Tarefa/cards.html`; EQ-W Razor = ponte only (`ORQUESTRADOR-MIGRACAO.md`).
3. **Mobile:** [`migracao-mobile-apontador-core-api.md`](migracao-mobile-apontador-core-api.md) — refresh git branch feature.
4. **Orquestrador:** [`ORQUESTRADOR-MIGRACAO.md`](ORQUESTRADOR-MIGRACAO.md) no início de cada sessão.
5. **CI homolog:** pausado — [`estudo-ci-homolog-readiness-e6.md`](estudo-ci-homolog-readiness-e6.md).

---

## 9. Links rápidos

| Recurso | Caminho |
|---|---|
| Clone local | `C:\Dev\Migration2Core` |
| Solução VS | `RDO-CleanMigration-2026/RDO-CleanMigration-2026/RDO-CleanMigration-2026.sln` |
| Estudos Ondas U | `docs/estudos-lucio-apps-plano-migracao-core/` |
| Mapa chats | `docs/CURSOR_MAPA_CHATS.md` |
