# Plano M6 — Mobile (Apontador) · JWT / contrato homolog

**Trilha:** EQ-M (+ Core contrato) · **Repos:** `EquipamentosMobile` + `Migration2Core`  
**Atualizado:** 2026-11-20  
**Não confundir:** M6 **migração** (este doc) ≠ M6 de editais RHAE/FAPESC.

**Decisão Lucio (20/11):** **sim** — confirmar que o **APK atual converge para produção** **antes** de abrir o trabalho JWT/homolog. Sem baseline prod, M6 vira chute.

---

## Onde estamos

| Hoje | Alvo M6 |
|------|---------|
| APK Apontador → **EQ-L** `sistema.rdoapp.com.br` `/api/*` · `novo_rdoapp` · **cenário A** | Mesmo produto de campo, com **contrato documentado** + caminho para **homolog Core** (JWT / OpenAPI) **sem** greenfield do app |
| Web homolog → Core cookie + BFF · `homol_rdoapp` · L1 Linux | Web e app **compartilham tipos/contrato** (não o mesmo bundle UI) |
| **M5 EQ-M** ⏸ adiado | Reabre **junto** com M6 (orquestrador) — obrigatório antes **M9 D4** / cutover Onda 6 |

Canônico: [`ORQUESTRADOR-MIGRACAO.md`](../ORQUESTRADOR-MIGRACAO.md) · [`api-client-equipamentos-v1.md`](../api-client-equipamentos-v1.md) · [`dimas-entrada-paralela-pos-m4.md`](dimas-entrada-paralela-pos-m4.md) · Fase 1 detalhe: [`m6-fase1-jwt-openapi.md`](m6-fase1-jwt-openapi.md).

---

## Fase 0 — Baseline APK → produção (**pré-M6 · fazer primeiro**)

**Objetivo:** provar que o build/loja atual ainda fala com **prod legado** e que a jornada crítica de campo está viva.

**Checklist executável (evidências):** [`m6-fase0-baseline-apk-prod.md`](m6-fase0-baseline-apk-prod.md)

| # | Passo | Status 20/11 |
|---|--------|:------------:|
| 0.1 | Identificar APK / branch / URL | ☑ repo + APK EAS `@rdo-app` |
| 0.2 | Smoke **prod** Login→obra→medição | ☑ **PASS** 20/11 · salvar + relógio · BD prod |
| 0.3 | Inventário endpoints | ☑ no doc Fase 0 |
| 0.4 | Decisão branch merge vs plano | ☑ **A** · `main` @ `8e7eb5e` |
| 0.5 | **Baseline OK** → Fase 1 | ☑ **2026-11-20** |

**Fora da Fase 0:** apontar APK para homolog · JWT · alterar prod `:80`.  

---

## Fase 1 — Contrato (Core · M6 núcleo)

| # | Entrega | Aceite | Status 20/11 |
|---|---------|--------|:------------:|
| 1.1 | OpenAPI / mapa **API mobile v1** (login + obra + medição mínima) alinhado ao que o APK já usa | Diff documentado legado ↔ Core | **stub** mapa em [`m6-fase1-jwt-openapi.md`](m6-fase1-jwt-openapi.md) |
| 1.2 | **JWT** (ou bearer documentado) no Core homolog — cookie web **permanece** para SPA | Token emitido + endpoint protegido smoke | **código landed** · smoke **após publish** |
| 1.3 | Pacote tipos TS compartilhado (fechar residual **M1**) | Consumível por web e mobile | **pending** |
| 1.4 | CORS / audience / expiração / refresh (mínimo seguro) | Nota de segurança no doc | **parcial** (sem refresh) |

Detalhe rotas / curl / security: [`m6-fase1-jwt-openapi.md`](m6-fase1-jwt-openapi.md).

---

## Fase 2 — Apontador homolog (retoma **M5 EQ-M**)

| # | Entrega | Aceite |
|---|---------|--------|
| 2.1 | Build/flavor **homolog** (base URL `homolog.sistema…` + JWT) | APK ou Expo apontando homolog |
| 2.2 | Smoke mesma jornada da Fase 0, mas em **`homol_rdoapp`** (obra/CPF de teste web) | Paridade funcional mínima |
| 2.3 | Gaps listados (o que falta vs prod API) | Backlog priorizado — não big-bang |

---

## Fase 3 — Gates antes do cutover (M9 D4 / M10)

| Gate | Significado |
|------|-------------|
| **G-M6** | Contrato + JWT homolog + smoke app Fase 2 OK |
| **M9 D4** | Mobile no aceite de release (orquestrador) |
| **M10** | Cutover prod Core + `novo_rdoapp` — app **já** sabe o contrato (não inventar no dia) |

---

## Ordem sugerida na prática (após smoke web L1 / O4)

1. ~~Fase 0 baseline APK→prod~~ **☑**  
2. **Agora:** Fase 1.2 smoke após publish homolog · fechar 1.1/1.3/1.4.  
3. **Em paralelo web:** O4 convite + residual M7+ que não dependem de mobile.  
4. **Depois:** Fase 2 APK homolog.  
5. **Não** misturar M6 com cutover URL/banco (**M10**).

---

## O que M6 **não** é

- Reescrever o Apontador do zero (TSK mobile greenfield ⏸).  
- Trocar `sistema.rdoapp.com.br` (continua a URL de prod).  
- Exigir Dimas no time (encaixe paralelo se vier).  
- Bloquear melhorias web pós-L1 (3.1/CAT) — podem seguir **em paralelo**.

---

## Próxima ação imediata (EQ-M · Lucio + agente)

1. **Publish + deploy** homolog Core (Linux L1) com o slice JWT 1.2.  
2. Setar **`Jwt:SigningKey`** no EC2 Staging (não usar placeholder do Git).  
3. **Smoke 1.2** — curl `POST /api/mobile/auth/login` + `GET /api/mobile/auth/me` (ver [`m6-fase1-jwt-openapi.md`](m6-fase1-jwt-openapi.md)).  
4. Seguinte: 1.3 tipos TS · 1.4 fechar nota (refresh decision) · depois Fase 2 APK homolog.
