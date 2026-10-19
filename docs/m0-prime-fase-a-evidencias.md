# M0′ — Fase A (evidências e OK documental)

**Data:** 2026-10-19 · **Marco:** M0′ · **Trilha:** docs (EQ referência prod ①)

---

## A1 — RDS e hosts (manual §10)

| Catálogo / host | Valor canônico | Fonte |
|-----------------|----------------|--------|
| Equipamentos prod | `novo_rdoapp` | [`rds-equipamentos-governanca-catalogos.md`](rds-equipamentos-governanca-catalogos.md) |
| Core homolog obras | `homol_rdoapp` | idem · Core `appsettings.Staging.json` |
| Piscinas prod | `piscinas_rdoapp` | idem |
| Piscinas homolog legado | `piscinas_rdoapp_homologa` | IIS `homologacao\piscinas_hm` |
| Host homolog Piscinas (legado) | `https://homologacao.piscinas.rdoapp.com.br` | [`aws-route53-rdoapp-dns-homolog-tecnico.md`](aws-route53-rdoapp-dns-homolog-tecnico.md) |
| Host homolog obras Core | `https://homolog.sistema.rdoapp.com.br` | orquestrador |

**Regra:** Core Equipamentos **não** usa `piscinas_rdoapp_homologa` (2026-10-17).

---

## A2 — Smoke HTTP prod (4 telas obras · templates)

**Host:** `https://sistema.rdoapp.com.br` · **2026-10-19**

| # | Tela | Recurso verificado | HTTP |
|---|------|-------------------|------|
| 1 | Login | `/` · `Client/Views/Login/index.html` | 200 |
| 2 | Escolher | `Client/Views/Obra/escolher.html` | 200 |
| 3 | Cards | `Client/Views/Tarefa/cards.html` | 200 |
| 4 | Shell SPA | `Client/app.js` | 200 |

**Complemento Lucio (opcional, recomendado para M0′ fechado):** no browser logado, DevTools **Network** — exportar ou anotar **1 request** por fluxo:

| Passo | API esperada (prod) |
|-------|---------------------|
| Login | `POST /api/login/LoginUser` |
| Escolher | `POST /api/obra/ObterObras` ou fluxo pós-login |
| Selecionar obra | `POST /api/Usuario/LoginObra` |
| Cards | `GET /api/etapa/ObterEtapaTarefa/` (ou `etapa/Get`) |

Obra referência comparativa homolog: **42** (FACHADA OESTE SHOPPING BARRA).

---

## A3 — Aceite M0′

| Item | Status | Quem |
|------|--------|------|
| Manual §10 RDS/hosts | ☑ doc | agente 2026-10-19 |
| Manual §10 colunas ④⑤ | ☑ conteúdo manual | agente |
| EquipoToPiscina repo | ☑ | Lucio 2026-10-19 |
| Vetor ⑥ rdo-blockchain | ☑ | agente |
| Smoke HTTP A2 | ☑ | agente |
| HAR/Network API A2 | ○ opcional | Lucio |

**M0′ documental:** **PASS** com ressalva — HAR API prod opcional antes de declarar M0′ **FECHADO** no orquestrador.

Próximo marco operacional: **Fase B (I0)** · [`homolog-core-deploy-rapido-plano.md`](homolog-core-deploy-rapido-plano.md).
