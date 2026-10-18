# Orquestrador — Migração (Equipamentos × FAPESC × infra)

**Atualizado:** 2026-10-18 — **Marco M2** ativo · M1 FECHADO · M0 PARCIAL PASS  
**Ler primeiro** em toda sessão do chat **Migração .NET Core**.

**Fonte única docs:** este arquivo e irmãos em **`Migration2Core/docs/`** no GitHub — índice [`README.md`](README.md).

### Repositório Git (canônico)

| O quê | Repo | Não commitar aqui |
|-------|------|-------------------|
| Core homolog, `client/`, CI, **docs M0/M1/orquestrador** | **`RDO-APP/Migration2Core`** | — |
| Legado prod IIS / AngularJS | `RDO-APP/Equipamentos` | docs de migração homolog |
| Apontador | `RDO-APP/EquipamentosMobile` | — |

Workspace Cursor **Equipamentos** (OneDrive) pode ter cópia local dos `.md` — **push = Migration2Core** (`C:\Dev\Migration2Core`). Clone legado Equipamentos = referência **EQ-L** somente.

Plano mestre: [`plano-estudo-execucao-migracao-fapesc-mobile.md`](plano-estudo-execucao-migracao-fapesc-mobile.md) · execução: [`plano-execucao-migracao-v1.md`](plano-execucao-migracao-v1.md) · M0 sem Dimas: [`m0-duvidas-dimas-solucoes.md`](m0-duvidas-dimas-solucoes.md)

**Modelo:** orquestrador → agente (mesmo chat) → **uma sub-trilha por sessão**.  
**Web + App:** stack de produto = **React** (web **EQ-R** + Apontador **EQ-M**); compartilhar API, tipos e pacotes TS — não o mesmo bundle de componentes DOM/RN.

```mermaid
flowchart TB
  U[Você]
  O[ORQUESTRADOR-MIGRACAO.md]
  A[Agente — chat Migração]

  U --> O --> A

  A --> EQ[Trilha EQ — produto Equipamentos]
  A --> F[Trilha F — ponte FAPESC]
  A --> I[Trilha I — infra homolog CI]

  subgraph EQsub [Trilha EQ]
    EQL[EQ-L — legado prod]
    EQW[EQ-W — ponte Razor W1]
    EQR[EQ-R — web React alvo]
    EQM[EQ-M — Apontador RN]
  end

  EQ --> EQL
  EQ --> EQW
  EQ --> EQR
  EQ --> EQM

  EQR <-->|api-client · OpenAPI · JWT| EQM

  EQL --> EQLd[Equipamentos · AngularJS + api/* prod]
  EQW --> EQWd[Migration2Core Razor · homolog :5081]
  EQR --> EQRd[React Vite strangler · TSK-10+ · homolog]
  EQM --> EQMd[EquipamentosMobile · Expo/RN]

  F --> Fd[anexo E4 · marcos Ondas U]
  I --> Id[ci/homolog-ec2-s3-ssm · pausado]
  Fd -.-> FC[Chat FAPESC Execução]

  EQW -.->|encerrar quando EQ-R E2E OK| EQR
```

| Sigla | Papel | Foco | Repo / doc |
|:-----:|-------|------|------------|
| **EQ** | Guarda-chuva | Obras web + campo | — |
| **EQ-L** | Prod hoje | Referência, API prod, hotfix IIS | `Equipamentos` |
| **EQ-R** | **UI web alvo** | Login, Escolher, Cards, RBAC — React homolog → strangler | Dimas TSK-10+, `Migration2Core` (host/API) |
| **EQ-M** | **App campo** | Apontador; mesma API/pacotes que EQ-R | `EquipamentosMobile`, E3 |
| **EQ-W** | **Ponte W1** | Razor Kiro já no ar — **só** bugfix + E2E legado até EQ-R assumir | `RdoApp.Core` Razor |
| **F** | Cronograma | Capacidade, marcos M* | E4; PoC no chat FAPESC |
| **I** | Deploy homolog | S3 + SSM + Actions | `PLANO-CI-HOMOLOG-EC2.md` |

### Encerramento da ponte EQ-W

Parar investimento em **features Razor** quando **qualquer** critério:

1. **EQ-R homolog:** login → Escolher → Cards **com dados** (substitui placeholder EQ-W), **ou**
2. SPA React servida no mesmo host homolog (`homolog.sistema`) com backend Core estável.

Até lá: EQ-W mantém o que já funciona (login, Escolher, Selecionar); **não** expandir Cards Razor salvo fallback explícito Lucio.

### Evolução futura — Piscinas (**PQ**)

Espelhar **EQ** com **PQ-L / PQ-R / PQ-M** (Piscineiro); **PQ-W** só se houver ponte Razor residual. Ajustar numa sessão dedicada — fora do escopo Hub B2G Equipamentos.

*(Fases estudo **E0–E6** ≠ siglas **EQ-***.)*

---

## Fase atual

**Marco ativo:** **M2** — Cards com dados (**EQ-R**) — [`migracao/m2-execucao-checklist.md`](migracao/m2-execucao-checklist.md).

**Histórico:** **M1** FECHADO 2026-10-17 ([`m1-execucao-checklist.md`](m1-execucao-checklist.md) · [`api-client-equipamentos-v1.md`](api-client-equipamentos-v1.md)). **M0** PARCIAL PASS — [`m0-registro-encerramento.md`](m0-registro-encerramento.md).

**Dívida paralela:** **EQ-W0.5** (redeploy + branding + `Selecionar`) — gate **M3** E2E assinado, não bloqueia codar M2 local.

### Pendências por marco (snapshot)

| Marco | Feito | Ainda pendente |
|-------|--------|----------------|
| **M0** | Decisões A1–A5; inventário mobile `14cf5d3`; v0 API; Vite `client/` + build; `dotnet build` Core; E2E login→Escolher (7 obras); docs E0–E6/orquestrador | E2E **Selecionar→Cards** FAIL; branding Piscinas no ar; Escolher CSS; E2 localhost completo; **Dimas** workshop (substituído por doc async) |
| **M1** | Cenário **A**; v1 endpoints; tipos TS Auth/Obra/Cards; mapa Core vs legado; orquestrador | Pacote npm publicado; EQ-M ainda não consome tipos; arquivos **só OneDrive** até commit **Migration2Core** |

---

## Decisões fechadas

- **UI web de produto** = **React (EQ-R)**, compartilhada com **EQ-M** via API/contratos TS (não duplicar regra em Razor).
- **EQ-W (Razor)** = ponte W1 no `Migration2Core` — **sem** roadmap de features novas.
- **Migration2Core** = homolog only até Linux L1; backend + host; **sem** prod `:80`.
- RDS homolog Core: **`homol_rdoapp`** (47 tbl).
- URL homolog: **`https://homolog.sistema.rdoapp.com.br`** (:5081).
- **EQ-M** prod hoje → API legado; alvo = mesma API que EQ-R (JWT / U-05).
- **Trilha I (CI):** pausada até E2E homolog com Cards **com dados** (EQ-R preferencial).
- **M2 BFF Cards:** **homolog-only** (EF `homol_rdoapp`) — não proxy prod API (ids de obra divergem).
- Branch CI: `ci/homolog-ec2-s3-ssm`.
- Prod web: **EQ-L** até cutover Onda 6.

---

## Decisões abertas

- Monorepo vs pacotes npm (`@rdo/api-client`, etc.) — Dimas + Lucio.
- Onde hospedar build EQ-R no homolog (static no Core vs CDN vs subpath).
- ~~Cenário mobile homolog E3~~ → **A** fechado M1 ([`api-client-equipamentos-v1.md`](api-client-equipamentos-v1.md)).
- Merge `EquipamentosMobile` `feature/alteracoes_apontador`.
- Marco FAPESC vs horas TSK (**Trilha F**).
- Abertura trilha **PQ** (Piscinas).

---

## Entregáveis estudo (índice)

| Fase | Documento |
|:----:|-----------|
| E0 | `migracao-kiro-mapa-estudo.md` |
| E1 | `migracao-frontend-razor-react-decisao.md` (+ decisão EQ-R) |
| E2 | `migracao-matriz-rotas-legado-core.md` |
| E3 | `migracao-mobile-apontador-core-api.md` |
| E4 | `estudo-migracao-fapesc-anexo-2026-q4.md` |
| E5 | `plano-execucao-migracao-v1.md` |
| E6 | `estudo-ci-homolog-readiness-e6.md` |

---

## Ponte FAPESC (Trilha F)

- Chat: **Edital FAPESC — Execução** (`6a7186f9-…`)
- Cronograma: `estudos-lucio-apps-plano-migracao-core/estudo-migracao-fapesc-9-meses.md`
- Anexo: `estudo-migracao-fapesc-anexo-2026-q4.md`
- **Não** implementar PoC blockchain neste chat.

---

## Par EQ-R + EQ-M

| Camada | EQ-R (web) | EQ-M (Apontador) |
|--------|------------|------------------|
| UI | React 19 + Vite | Expo / React Native |
| Compartilhável | OpenAPI, Zod/types, hooks auth, tokens UI | idem (pacotes TS) |
| Backend alvo | Core API + legado strangler | mesma base URL homolog/prod |
| Doc | E1, TSK-10+ | E3 |

---

## Gap técnico #1

**M2:** Cards **com dados** (**EQ-R**) via contrato M1 (`etapa/Get`). EQ-W placeholder + clique instável — **EQ-W0.5** antes de M3 E2E assinado.

---

## Histórico de marcos

| Marco | Status | Doc |
|:-----:|:------:|-----|
| M0 | PARCIAL PASS | [`m0-registro-encerramento.md`](m0-registro-encerramento.md) |
| M1 | FECHADO | [`m1-execucao-checklist.md`](m1-execucao-checklist.md) |
| M2 | **em curso** | [`migracao/m2-execucao-checklist.md`](migracao/m2-execucao-checklist.md) |

---

## Próxima ação (1)

**M2.5:** Lucio — `npm run build` em `client/` · `dotnet run` Core · login → obra → `/Tarefa/Cards` com etapas. **EQ-W0.5** (Selecionar + redeploy) se homolog EC2 ainda falhar antes do M3.

---

## Links canônicos

| | |
|--|--|
| E2E | `e2e-fase0-checklist.md` |
| RDS | `rds-equipamentos-governanca-catalogos.md` |
| Chats | `CURSOR_MAPA_CHATS.md` |
| CI (I) | `PLANO-CI-HOMOLOG-EC2.md` |
| Ponte Razor (W) | `C:\Dev\Migration2Core\...\RdoApp.Core` |
| Legado (L) | repo `Equipamentos` |

---

## Mapa de impacto (canônico)

Antes de codar ou editar doc de migração, cruzar **sub-trilha** × **superfícies**. Regra Cursor: `.cursor/rules/orquestrador-migracao-impacto.mdc`.

| Tipo de mudança | Trilha dona | Onde commitar | Impacto cruzado (avisar / revisar) |
|-----------------|-------------|---------------|-------------------------------------|
| UI web React (telas, RBAC) | **EQ-R** | `Migration2Core` (+ SPA repo quando existir) | **EQ-M** se mesma regra de negócio; **EQ-W** só se ponte quebrar E2E; matriz E2 |
| UI web Razor (bugfix ponte) | **EQ-W** | `Migration2Core` `RdoApp.Core` | Não duplicar feature em EQ-W se alvo é **EQ-R**; homolog :5081 |
| Apontador / services mobile | **EQ-M** | `EquipamentosMobile` | **EQ-L** `api/*` prod hoje; **EQ-R** pacote TS/OpenAPI; E3 cenário homolog |
| Web API legado AngularJS | **EQ-L** | `Equipamentos` | **EQ-M** consumidores; strangler **EQ-R**; **não** confundir com Core homolog |
| EF / entidades / DDL homolog | **EQ-W/R** backend | `Migration2Core` + SQL `docs/scripts/` | **`homol_rdoapp`** · `rds-equipamentos-governanca-catalogos.md` · **EQ-M** se apontar homolog |
| EF / prod `novo_rdoapp` | **EQ-L** | `Equipamentos` + Dimas publish | Prod `:80`; **fora** Migration2Core até Onda 6 |
| Auth (cookie vs JWT) | **EQ-R** + **EQ-M** | Core + mobile | **EQ-W** cookie legado; Loja×Sistema só se licença/login loja |
| Deploy homolog EC2/CI | **I** | `Migration2Core` branch `ci/*` | Preservar `appsettings.Staging.json`; E6 gate Cards **EQ-R** |
| Cronograma / horas / M* FAPESC | **F** | `docs/` anexo E4 | Chat **FAPESC Execução** — não PoC aqui |
| Prontidão B2G / W4 Hub | — | `docs/hub-*` | Regra **hub-govtech-equipamentos-only** — só Equipamentos+Apontador |
| Piscinas (futuro) | **PQ-*** | TBD | Fora escopo EQ; nova sessão orquestrador |

**Saída obrigatória do agente** (1 parágrafo + bullets): sub-trilha escolhida · repos tocados · impacto cruzado · chat/repo **fora** deste workspace se houver.

---

## Como usar (agente)

1. Ler este arquivo + **Mapa de impacto** + **Gap #1** / **Decisões abertas**.
2. Uma sessão = **EQ-R**, **EQ-M**, **EQ-W** (só ponte/bugfix), **EQ-L**, **F** ou **I**.
3. Features web novas → **EQ-R**, não EQ-W.
4. Atualizar **Próxima ação** ao fechar sessão.
5. Commit: **Migration2Core** (código + docs migração/orquestrador) · **EQ-M** → `EquipamentosMobile` · **EQ-L** → `Equipamentos` só hotfix prod. **Não** push docs M* para Equipamentos.

---

## Git push (agente — obrigatório)

Repo de execução: `C:\Dev\Migration2Core` · detalhe: [`migracao/git-push-checklist.md`](migracao/git-push-checklist.md) (espelho em `Migration2Core/docs/migracao/`).

| # | Regra |
|---|--------|
| 1 | Arquivo **existente no disco** antes de `git add` (path novo → criar/gravar primeiro). |
| 2 | Sequência: `git status` → `git add` → **`git status` com “Changes to be committed”** → `commit` → `push` → confirmar **hash novo** no remoto. |
| 3 | Se `add` falhar, **não** commitar nem dizer “push feito”. |
| 4 | PowerShell: **`;`** entre comandos (não `&&`). |
| 5 | Só avisar Lucio após push OK; branch explícita (ex. `ci/homolog-ec2-s3-ssm`). |

**Incidente 2026-10-18:** `git add` com doc inexistente → stage vazio → push “up-to-date” sem commit — não repetir.
