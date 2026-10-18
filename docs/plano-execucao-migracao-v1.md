# Plano de execução migração v2 (marcos)

**Data:** 2026-10-17  
**Horizonte:** ~12 semanas (marcos **não** rígidos em calendário)  
**Homolog-only** Core · prod **EQ-L** intocado até Onda 6  

**Canônico:** [`ORQUESTRADOR-MIGRACAO.md`](ORQUESTRADOR-MIGRACAO.md) · mapa de impacto · regra `.cursor/rules/orquestrador-migracao-impacto.mdc`  
**Pré-requisitos:** estudos E0–E6 concluídos.

---

## 1. Como executar

1. Ler orquestrador + declarar **sub-trilha** e **impacto cruzado** antes de codar.
2. **Uma sub-trilha principal por sessão** (EQ-R, EQ-M, EQ-W bugfix, EQ-L, F, I).
3. Cada marco **M*** fecha entregável verificável; atualizar orquestrador (**Próxima ação** = próximo M*).
4. **EQ-R + EQ-M** evoluem em paralelo quando o marco exige — nunca duplicar regra de negócio em EQ-W.

---

## 2. Trilhas (resumo)

| Trilha | Papel |
|--------|--------|
| **EQ-R** | Web React — UI alvo homolog |
| **EQ-M** | Apontador RN — par API/TS com EQ-R |
| **EQ-W** | Ponte Razor W1 — bugfix até M4 |
| **EQ-L** | Legado prod — referência e `api/*` |
| **F** | FAPESC — cronograma (chat Execução) |
| **I** | CI homolog EC2 |

---

## 3. Marcos (sequência)

| Marco | Nome | Objetivo | Trilhas | Entregável / critério de done | Impacto (revisar) |
|:-----:|------|----------|---------|------------------------------|-------------------|
| **M0** | Arranque | Alinhar stack React+RN e validar ponte | EQ-R, EQ-M, EQ-W | [`m0-duvidas-dimas-solucoes.md`](m0-duvidas-dimas-solucoes.md); SPA greenfield `client/`; inventário branch `feature/alteracoes_apontador`; E2E EQ-W | `Migration2Core`, E3, E2 |
| **M1** | Contrato compartilhado | Uma fonte de verdade API/types web+app | EQ-R, EQ-M | Doc ou pacote **`api-client`** (endpoints, DTOs, env homolog/prod); cenário E3 escolhido (A/B/C/D) | EQ-L `api/*` hoje; auth cookie vs JWT anotado |
| **M2** | Cards homolog | Operador vê tarefas após obra — **React** | EQ-R | Cards com **dados** em `homolog.sistema` (paridade mínima `cards.html`); CPF teste Equipamentos | EQ-W placeholder; **homol_rdoapp**; E2 rotas |
| **M3** | E2E Fase 0 assinado | Lucio aceita fluxo homolog produto | EQ-R, EQ-W | Checklist [`e2e-fase0-checklist.md`](e2e-fase0-checklist.md) assinado no fluxo **EQ-R**; `historico_login` OK | Trilha **I** desbloqueada (gate E6) |
| **M4** | Encerramento ponte EQ-W | Parar investimento Razor | EQ-W, EQ-R | Critério ORQ: M2+M3 OK → EQ-W **congelada** (só bugfix crítico); Cards Razor não evolui | Deploy :5081; CI publica host Core |
| **M5** | Apontador alinhado | Mobile no plano homolog/API | EQ-M | Merge **ou** plano explícito `feature/alteracoes_apontador`; APK homolog testado; doc URL API | EQ-L prod; pacote M1; RDS se cenário D |
| **M6** | Auth/API unificada | JWT/OpenAPI spike | EQ-R, EQ-M, EQ-L | U-05 spike documentado; rota homolog consumível por EQ-M (mesmo contrato M1) | Não quebrar Apontador prod |
| **M7** | RBAC + próxima tela | Strangler avança além de Cards | EQ-R | RBAC web (Escolher/header); 1 tela seguinte (etapa/lista **ou** escopo Equipamentos acordado) | Matriz E2; EQ-M se mesma permissão |
| **M8** | CI homolog | Deploy repetível EC2 | **I** | Merge `ci/homolog-ec2-s3-ssm`; passos PLANO-CI; workflow smoke :5081; Staging preservado | S3/IAM/OIDC; **não** prod `:80` |
| **M9** | Pacote homolog v1 | Fechar critérios D1–D7 | EQ-R, EQ-M, I | Todos D* abaixo ✅; orquestrador atualizado | Hub B2G evidências se pedido |
| **M10** | Onda 2 / L1 prep | Preparar expansão pós-v1 | EQ-R, EQ-M, docs | Backlog telas Onda 2; doc trilha Linux L1; **sem** cutover prod | FAPESC marcos (F) paralelos |

**Marco atual:** **M2** — [`migracao/m2-execucao-checklist.md`](migracao/m2-execucao-checklist.md). **M1:** FECHADO · **M0:** PARCIAL PASS — [`m0-registro-encerramento.md`](m0-registro-encerramento.md).

---

## 4. Critérios D* (pacote M9)

| ID | Critério |
|----|----------|
| D1 | login → Escolher → Cards **com dados** via **EQ-R** |
| D2 | CPF `53821963549` · branding Equipamentos |
| D3 | `historico_login` em homolog |
| D4 | EQ-M prod estável; homolog mobile documentado; API alinhada M1/M6 |
| D5 | Core **não** em `inetpub\rdoapp` prod |
| D6 | Orquestrador + marco M* registrados |
| D7 | **api-client** (M1) usado ou referenciado por EQ-R e EQ-M |

---

## 5. Vista semanal sugerida (marcos)

| Sem | Foco marco |
|:---:|------------|
| 1 | **M0** |
| 2 | **M1** + início **M2** |
| 3 | **M2** |
| 4 | **M3**, **M4** |
| 5 | **M5** |
| 6 | **M6** |
| 7 | **M7** |
| 8 | **M8** |
| 9–10 | **M9** buffer |
| 11–12 | **M10** |

Semanas são guia; **done = critério do marco**, não data.

---

## 6. Fora de escopo v2

- Cutover produção (Onda 6) · React SPA em `:80` prod  
- ETL `novo_rdoapp` · token/EDI · DROP RDS  
- Features novas **EQ-W** (salvo fallback Lucio entre M0–M3)  
- PoC FAPESC blockchain (chat Execução)  
- Trilha **PQ** Piscinas  

---

## 7. Riscos

| Risco | Mitigação |
|-------|-----------|
| M2 atrasa | M3/M8/I esperam; EQ-W fallback só com OK Lucio |
| EQ-M preso em EQ-L API | M1 cenário E3; M6 spike |
| Horas Dimas FAPESC+TSK | Trilha F; priorização explícita |
| Mudança sem mapa de impacto | Regra orquestrador |

---

## 8. Estudos vinculados

E1 · E2 · E3 · E4 · E6 — pasta `docs/`.

---

## 9. Próxima ação

Fechar **M0** (workshop Dimas + inventário EQ-M + E2E EQ-W).
