# Plano de estudo — execução da migração (Core × Mobile × FAPESC)

**Chat dono:** Migração .NET Core (`ee6f7379-dfb3-4995-a6cd-1c691007e9b0`)  
**Criado:** 2026-10-17  
**Status:** **Estudos E0–E6 concluídos** (2026-10-17) — ver §4 abaixo. **Deploy CI homolog pausado** (`PLANO-CI-HOMOLOG-EC2.md`, branch `ci/homolog-ec2-s3-ssm`).

**Objetivo deste doc:** Inventário do que **já foi estudado**, o que **falta saber**, e **fases de estudo** para montar depois um **plano de execução** da migração — conectado a **FAPESC** e **Apontador (EquipamentosMobile)** — sem misturar escopo de chats.

**Orquestrador (pré-estudo):** §8 — artefato canônico para o agente retomar contexto entre sessões/chats.

---

## 1. Escopo e fronteiras

| Frente | Repo / chat | Neste plano |
|--------|-------------|-------------|
| **Web Core homolog** | `RDO-APP/Migration2Core` | Sim — Razor MVC, homolog only até Linux |
| **Web prod obras** | `RDO-APP/Equipamentos` | Referência legado + AngularJS; **não** cutover |
| **Mobile Apontador** | `RDO-APP/EquipamentosMobile` | Sim — API, auth, homolog coordenado |
| **FAPESC Termo / PoC** | Chat **FAPESC Execução** + `docs/editais-fapesc/` | **Ponte** — cronograma e dependências, não codar PoC aqui |
| **Loja / assinatura** | Chat Loja + `ponte-loja-sistema-assinatura.md` | Só onde impacta licença/homolog Core |
| **Deploy homolog AWS** | `PLANO-CI-HOMOLOG-EC2.md` | **Pausado** — executar após estudo §4–6 |

Regra **hub-govtech-equipamentos-only:** prontidão B2G técnica fala só Equipamentos/obras — FAPESC entra como **eixo temporal e entregáveis**, não como produto Piscinas.

---

## 2. O que já foi estudado (evidência no Git / sessões)

### 2.1 Kiro × Clean Migration 2026

| Tema | Achado | Fonte |
|------|--------|--------|
| Linha do tempo | Jan–fev/2026: 48 entidades, login, Escolher Obra ~80%, pausa ~35% | `migracao-kiro-mapa-estudo.md` §3 |
| Stack web escolhida | **ASP.NET Core MVC + Razor** — **não** React/Vite do backlog Dimas (TSK-10) | §4 TSK × U; `4-CRITICAL-PAGES-IMPLEMENTATION-PLAN.md` |
| Abandono Piscinas spike | `EquipoToPiscina-1` — crises **blank page**, laudo | §3 mapa Kiro |
| Fundação OK | EF Core + Pomelo, cookie auth estilo legado, `PermissionHelper` parcial | §4 mapa |
| Gap imediato pós-Escolher | Seleção obra → sessão → redirect Cards **incompleto** | §5 mapa; README Kiro |
| Homolog RDS 2026-10 | `homol_rdoapp`, 47 tbl, E2E login Equipamentos | `rds-equipamentos-governanca-catalogos.md` |

### 2.2 Front-end — o que “quebrava” ou divergia (síntese, não forense completa)

| Sintoma / decisão | Hipótese documentada | Estudar de novo? |
|-------------------|----------------------|------------------|
| **Razor vs React** | Dimas: SPA React strangler; Kiro: MVC Razor para operador web **agora** | **Sim** — decisão 2026 com Mobile no ar |
| Botões header / RBAC | Rotas legado vs Core; partials `_HeaderEscolher` | **Sim** — diff legado Gilberto × Core |
| UI “Piscinas” no homolog | Connection + branding copiados de `piscinas_hm` | **Feito** branding Equipamentos; validar todas views |
| Fontes / `user.png` | Assets não copiados do legado | **Sim** — checklist visual |
| Anti-padrão JS inline | Plano 4 páginas manda evitar | **Sim** — auditoria Escolher/Cards |
| ALB / cookies | `UseForwardedHeaders`, HTTPS redirect | **Parcial** — `Program.cs` tocado na homolog |

**Ainda não estudado a fundo nesta sessão:** leitura linha a linha dos ~80 `.md` forenses Kiro (`HEADER-*`, `BUTTONS-*`); comparativo visual print a print.

### 2.3 Ondas U × Dimas × Lucio

| Documento | Conteúdo assimilado |
|-----------|---------------------|
| `comparativo-e-plano-unificado.md` | 6 ondas, strangler |
| `comparativo-dimas-v20260818.md` / `v20260909` | TSK-01…56 × U-xx |
| `storytelling-unificado-dimas-migracao-fapesc.md` | Onda 0 apps **antes** TSK-01; FAPESC em paralelo |
| `estudo-migracao-fapesc-9-meses.md` | Picos h/sem Dimas × marcos FAPESC |
| `plano-preparacao-migracao-homolog.md` | Camadas homolog, W1→L1 |

### 2.4 Mobile (referência documental, código não auditado agora)

| Achado | Fonte |
|--------|--------|
| Apontador = `EquipamentosMobile`; ~94% compartilhado com Piscineiro (outro repo) | storytelling § |
| Decisões ago/2026: etapa **não** trancada no Apontador; perfil/RBAC | comparativo-dimas-v20260909 |
| Homolog mobile coordenado — branch/feature citadas em estudos | `analise-apontador-dimas-v1.md` (verificar commit atual) |

### 2.5 Automatização deploy (pausada)

| Item | Estado |
|------|--------|
| Publish + zip local | Testado |
| Plano S3 + SSM + Actions | Escrito; branch `ci/homolog-ec2-s3-ssm` |

---

## 3. O que falta saber (perguntas abertas)

### 3.1 Front-end web Core

1. **Razor MVC até quando?** Onde entra React (Onda 2)? Quais páginas **must** stay Razor (PDF, laudo, relatórios)?
2. **Paridade visual** Escolher/Cards vs legado Equipamentos — critério de aceite mensurável?
3. **RBAC 5 níveis** — matriz menu legado Angular × `PermissionHelper` × planos Loja (§10 proposta perfis).
4. **O que quebrou de fato** nas sessões Kiro (reproduzir bugs) vs documentação excessiva?

### 3.2 Mobile Apontador × Core

1. API hoje: **legado Web API / ASMX / só mobile offline?** — mapa endpoints EquipamentosMobile → backend.
2. Homolog mobile aponta para **qual host** e **qual catálogo** (`homol_rdoapp` vs outro)?
3. Auth mobile: **JWT** (TSK-07) vs sessão legado — impacto no Core homolog.
4. Feature flags: quando mobile passa a consumir **Core** vs legado (Onda 2)?

### 3.3 FAPESC × migração (ponte, não escopo técnico Equipamentos W4)

1. Quais marcos **M1–M3** competem por **mesmas horas** Dimas/Lúcio que TSK Core?
2. PoC imutabilidade: **API verify** depende de eventos do Core ou só legado export?
3. O que o Termo **exige** demonstrar na **web obras** vs app Apontador vs blockchain (evitar prometer cutover)?

### 3.4 Execução e time

1. Alinhamento formal **Dimas** — React vs Razor, prioridade Cards vs mobile sprint.
2. **Carlos/mobile** — branch homolog, EAS, `appVariant`.
3. Produção: confirmação explícita **Migration2Core nunca deploy prod** até Linux + Onda 6.

---

## 4. Fases de estudo — status 2026-10-17

| Fase | Entregável | Status |
|:----:|------------|:------:|
| **E0** | `migracao-kiro-mapa-estudo.md` §4–5, §8 | ✅ |
| **E1** | `migracao-frontend-razor-react-decisao.md` | ✅ estudo doc |
| **E2** | `migracao-matriz-rotas-legado-core.md` | ✅ |
| **E3** | `migracao-mobile-apontador-core-api.md` | ✅ doc; ⬜ refresh git mobile |
| **E4** | `estudo-migracao-fapesc-anexo-2026-q4.md` | ✅ |
| **E5** | `plano-execucao-migracao-v1.md` | ✅ |
| **E6** | `estudo-ci-homolog-readiness-e6.md` | ✅ prontidão; exec AWS ⬜ |

**Gate para codar Onda 1 pesada:** Lucio aprova `plano-execucao-migracao-v1.md`; refresh E3 git opcional paralelo.

**Gate CI (E6 exec):** E2E com Cards ≠ placeholder.

---

## 5. Conexão FAPESC × Mobile × Core (diagrama lógico)

```text
                    ┌─────────────────────────────────────┐
                    │  FAPESC Execução (chat separado)     │
                    │  PoC imutabilidade · marcos M1–M3   │
                    └──────────────┬──────────────────────┘
                                   │ ponte docs only
         ┌─────────────────────────┼─────────────────────────┐
         ▼                         ▼                         ▼
  Onda 0 Apps                 Onda 1–5 Core              Onda 6 cutover
  EquipamentosMobile          Migration2Core              (futuro)
  Apontador homolog           Razor homolog EC2           Equipamentos prod
         │                         │                         │
         └──────────── API / auth / RDS homol_rdoapp ────────┘
                    (legado ainda prod :80 / novo_rdoapp)
```

**Regra:** FAPESC não altera catálogo prod; Mobile homolog deve ser **explicitamente** configurado — não assumir Piscinas.

---

## 6. Plano de execução (produto deste estudo — ainda não escrito)

O documento **`plano-execucao-migracao-v1.md`** (fase E5) deve conter:

1. **Ondas U** recortadas com **critério de done** por onda.  
2. **Trilha EQ:** EQ-L legado · **EQ-R React web (alvo)** · **EQ-M Apontador (par API/TS)** · EQ-W ponte Razor W1.  
3. **Trilha F** (FAPESC): dependências e janelas (link `10_PONTE_MIGRACAO_TIME.md` quando existir).  
4. **Trilha I** + futura **PQ** (Piscinas): ver `ORQUESTRADOR-MIGRACAO.md`.  
5. **Riscos:** RBAC, JWT vs cookie, competição horas Dimas.  
6. **Fora de escopo:** deploy prod Core, token/EDI (chat EDI).

---

## 7. O que **não** fazer neste estudo

- Implementar CI AWS (pausado).  
- Commitar secrets ou homologar Piscinas no Core Equipamentos.  
- Fundir chat FAPESC (PoC blockchain) com código Cards/Razor.  
- Prometer TCE/MP homologação blockchain em produção municipal.

---

## 8. Orquestrador (pré-estudo — proposta)

**Problema:** três chats + três repos; memória de conversa não cruza.

**Solução proposta:** arquivo **`docs/ORQUESTRADOR-MIGRACAO.md`** (a criar na fase E0) — **single source of truth** lido no início de cada sessão Migração:

| Campo | Conteúdo |
|-------|----------|
| `ultima_atualizacao` | Data |
| `fase_estudo_atual` | E0…E6 |
| `decisoes_fechadas` | Lista bullet (ex.: homol_rdoapp, Razor W1) |
| `decisoes_abertas` | Link §3 deste doc |
| `ponte_fapesc` | 3 bullets max + link chat/transcript |
| `ponte_mobile` | branch homolog EquipamentosMobile, URL API |
| `proxima_acao` | Uma tarefa executável |
| `links_canonicos` | 5–10 paths |

**Fluxo agente:**

1. Ler `ORQUESTRADOR-MIGRACAO.md` + este plano.  
2. Executar **só** a fase estudo E* corrente **ou** uma sub-trilha **EQ-/F/I** (orquestrador).  
3. Atualizar orquestrador + commit docs (Equipamentos) ou analysis (Migration2Core).  
4. Escopo FAPESC → copiar recorte para chat FAPESC, não implementar lá.

**Opcional depois:** skill Cursor `orquestrador-migracao-rdo/SKILL.md` que aponta para estes arquivos.

---

## 9. Próximo passo imediato (Lucio)

Estudos E0–E6 **fechados em documentação**. Escolher **execução**:

| Opção | Ação |
|-------|------|
| **1** | Aprovar e iniciar **Semana 1–2** — Cards **EQ-R** + alinhamento **EQ-M** (`plano-execucao-migracao-v1.md`) |
| **2** | `git pull` **EquipamentosMobile** + completar E3 (mapa `services/*`) |
| **3** | Sincronizar marco FAPESC no chat Execução (E4) |

Deploy CI (**E6 exec**) permanece **pausado** até gate E6 doc.

---

## 10. Links canônicos

| Recurso | Caminho |
|---------|---------|
| Mapa estudo Kiro | `docs/migracao-kiro-mapa-estudo.md` |
| Mapa chats | `docs/CURSOR_MAPA_CHATS.md` |
| Ponte FAPESC time | `docs/editais-fapesc/10_PONTE_MIGRACAO_TIME.md` |
| Storytelling Dimas/FAPESC | `docs/estudos-lucio-apps-plano-migracao-core/storytelling-unificado-dimas-migracao-fapesc.md` |
| Homolog preparação | `docs/plano-preparacao-migracao-homolog.md` |
| CI homolog (pausado) | Migration2Core `RDO-CleanMigration-2026/PLANO-CI-HOMOLOG-EC2.md` |
| E2E | `docs/e2e-fase0-checklist.md` |
