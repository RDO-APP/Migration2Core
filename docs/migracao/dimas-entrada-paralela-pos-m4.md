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

## Links

| Doc | Uso |
|-----|-----|
| [`dimas-tsk-rastreio-m.md`](dimas-tsk-rastreio-m.md) | Snapshot TSK × M* |
| [`m0-duvidas-dimas-solucoes.md`](../m0-duvidas-dimas-solucoes.md) | BFF + cookie (Solução A) |
| [`comparativo-dimas-v20260818.md`](../estudos-lucio-apps-plano-migracao-core/comparativo-dimas-v20260818.md) | TSK completa |
