# Dimas — entrada paralela (opcional) e pós-migração sem ele

**Trilha:** governança · **Marco de referência:** **M4** (homolog operador) → encaixe **M5/M6**  
**Atualizado:** 2026-10-25 · **Decisão Lucio:** executar **M\*** com **Lucio + Cursor** até Dimas decidir entrar.

---

## Decisão (canônica)

| Item | Texto |
|------|--------|
| **Dono da ordem** | Marcos **M\*** + [`ORQUESTRADOR-MIGRACAO.md`](../ORQUESTRADOR-MIGRACAO.md) |
| **Dono da execução (agora)** | **Lucio + Cursor** — homolog EQ-R, deploy, smoke |
| **Dimas** | **Não é pré-requisito** para M4.7, M4.8, homolog v1 |
| **Se Dimas entrar** | Trabalho **em paralelo** (Application, OpenAPI, U-05, EQ-L prod, revisão PR Core) **sobre** o que já está no Git (`RdoApp.Core`, BFF, `client/`) — **não** reiniciar Sprint linear do PDF |
| **PDF / TSK** | Inventário + gap check — [`dimas-tsk-rastreio-m.md`](dimas-tsk-rastreio-m.md) |

---

## Onde Dimas encaixa (sem bloquear M4)

| Marco | Dimas (exemplos) | Lucio + Cursor (continua) |
|-------|------------------|---------------------------|
| **M4.7–M4.8** | Opcional: revisão auth/sessão | UI paridade, drawer, stubs menu, Login SPA |
| **M5** | RDO/listagem, domínio RDO, Chart backend | Smoke, deploy, rotas stub → real |
| **M6** | JWT spike, OpenAPI v1, extrair use cases do BFF | Contrato TS ↔ mobile, homolog API |
| **M7+** | Apontamento Core, CRUD gestor | Cards ações, RBAC fino |
| **Onda 6 / M8+** | ETL, cutover (com Dimas ou consultoria) | Strangler prod Equipamentos |
| **FAPESC** | TSK-32 | Chat FAPESC Execução — **fora** EQ-R |

**Primeira semana Dimas (se vier):** ler orquestrador + smoke homolog; extrair **Application** por trás do BFF; mapa menu → MVC — ver conversa Migração 2026-10-25.

---

## Se Dimas **não** vier — “adaptar ao plano Dimas” depois do Core operador

**Não é segunda migração front.** É completar o que o PDF chama de fundação + API pública + módulos stub.

| Esforço | O quê |
|---------|--------|
| **Baixo** | Pastas Clean Arch explícitas, Serilog, health, Swagger do que já existe, backlog TSK→issues |
| **Médio** | BFF → Application + `/api/v1`; JWT se mobile/web unificados; RBAC contrato único |
| **Alto** | Apontamento/RDO/laudo **completos**, relatórios gestor, ETL cutover — **M5–M8** de qualquer forma |

**Reduz imposto Dimas durante M5/M6:** nova regra → handler Application; BFF só HTTP; DTOs alinhados ao mobile.

---

## Transição suave → estratégia Dimas (obrigatória, com ou sem Dimas no time)

**Princípio:** o plano Dimas (Clean Arch, API única, domínio, OpenAPI, ETL no fim) é o **estado alvo**. O plano M\* (BFF, cookie, React strangler) é a **rampa**. A transição **não** é “trocar de estratégia”; é **endurecer camadas** marco a marco, **sem** desligar homolog e **sem** big-bang.

### Regras de ouro (nunca violar)

| # | Regra | Evita |
|---|--------|--------|
| 1 | **Ordem = M\***; TSK Dimas = gap check, não cronograma Sprint 1→8 | Parar homolog para “refazer fundação” |
| 2 | **Comportamento homolog estável** antes de refator interno | Regressão invisível |
| 3 | **Nova regra de negócio** → Application (ou service dedicado); BFF/controller só HTTP | BFF eterno |
| 4 | **Cookie web homolog** até gate **M6-JWT**; mobile prod legado até gate **M6-API** | Retrabalho JWT cedo |
| 5 | **ETL/cutover (TSK-41…45)** só **Onda 6 / M8+** | Migrar dados antes do domínio |
| 6 | **Dimas entra** → trilhas **paralelas** no mesmo repo; **não** novo greenfield SPA | Dois fronts |

### Rampa em 4 ondas (suave)

```text
Onda A (M4 fechar)     UI operador + stubs MVC + BFF fino na leitura
        ↓ gate: M4.8 Login SPA · smoke P1–P3
Onda B (M5)            Stubs → telas/API reais prioritárias (RDO, Chart, Dashboard, menu)
        ↓ gate: header + menu com destino previsível
Onda C (M6)            CONVERGÊNCIA DIMas — Application explícita · OpenAPI v1 · BFF = proxy ou aposentado
        ↓ gate: contrato documentado = o que mobile passará a usar
Onda D (M7–M8+)        CRUD/apontamento/RBAC fino · JWT se adotado · ETL quando critério Onda 6
```

| Onda | Entregável “estratégia Dimas” | O que **permanece** do M\* |
|------|------------------------------|----------------------------|
| **A** | Rotas e RBAC server-side; menu mapeado | React, BFF agrupador, cookie |
| **B** | Domínio nas áreas P3/P5 (não só DTO) | Mesma URL homolog; usuário não percebe “migração de plano” |
| **C** | Projetos/pastas alinhados TSK-01…04; Swagger; handlers testáveis | SPA intacta; troca é backend + contrato |
| **D** | Paridade TSK operador+mobile+gestor; cutover planificado | Prod EQ-L até gate explícito |

### Gates explícitos (quando declarar “transição de fase”)

| Gate | ID | Critério PASS | Atualiza |
|------|-----|---------------|----------|
| Fim strangler UI operador | **G-M4** | P1–P3 React homolog; EQ-W congelado | Orquestrador · M4 checklist |
| Domínio mínimo operador | **G-M5** | RDO/Chart/Dashboard não só EmMigracao; lógica fora de “god BFF” | `dimas-tsk-rastreio-m.md` §3 |
| Alinhamento API Dimas | **G-M6** | OpenAPI v1 publicado; BFF delega 100% a Application **ou** rotas `/api/v1` espelham BFF; plano mobile homolog Core | `m1-execucao-checklist` / api-client |
| Prod cutover Equipamentos | **G-M8** | ETL + validação — **só** após G-M6 | Onda 6 |

### Se Dimas entrar no meio da rampa

| Situação | Ação suave |
|----------|------------|
| Entra na **Onda A/B** | Assume **Application + revisão PR**; Lucio/Cursor mantém M4.8 e deploy |
| Entra na **Onda C** | Co-dono **OpenAPI + extrair BFF**; não reabrir Razor operador |
| Entra só perto **ETL** | Foco TSK-41…45; rampa M\* já entregue operador |

**Handoff de 1 página para Dimas:** clone `Migration2Core` · branch `ci/homolog-ec2-s3-ssm` · smoke roteiro deploy · ler este doc § Rampa · primeiro PR = extrair **um** use case do BFF (ex.: `CardsQueryService` → Application).

### Se Dimas **não** vier

A **mesma rampa** vale: Onda C/D ficam com Lucio + Cursor + docs TSK. “Transição suave” = **não pular** G-M5/G-M6; imposto Dimas vira **dívida técnica documentada** em [`dimas-tsk-rastreio-m.md`](dimas-tsk-rastreio-m.md) §4, não surpresa no cutover.

### Hábito semanal (1 linha no fechamento de sessão)

Ao fechar marco ou PR relevante, responder: **“Isso aproxima qual onda (A–D) e qual gate?”** — se nenhuma, marcar TSK §4 vigilância ou recusar escopo.

---

## Links

| Doc | Uso |
|-----|-----|
| [`dimas-tsk-rastreio-m.md`](dimas-tsk-rastreio-m.md) | Snapshot TSK × M* |
| [`m0-duvidas-dimas-solucoes.md`](../m0-duvidas-dimas-solucoes.md) | BFF + cookie (Solução A) |
| [`comparativo-dimas-v20260818.md`](../estudos-lucio-apps-plano-migracao-core/comparativo-dimas-v20260818.md) | TSK completa |
