# Estudo E1 — Front-end: o que o Kiro quebrou e Razor vs React

**Data:** 2026-10-17 · **Somente estudo** (sem implementação nesta fase).

> **Decisão orquestrador (2026-10-17):** UI web de produto = **EQ-R (React)**; **EQ-M (Apontador)** compartilha API/pacotes TS; **EQ-W (Razor Kiro)** = ponte W1 sem features novas. Canônico: [`ORQUESTRADOR-MIGRACAO.md`](ORQUESTRADOR-MIGRACAO.md).

Fontes: `Migration2Core/RDO-CleanMigration-2026/4-CRITICAL-PAGES-IMPLEMENTATION-PLAN.md`, README Kiro, código `RdoApp.Core`, `migracao-kiro-mapa-estudo.md`.

---

## 1. Três gerações de UI (contexto)

| Geração | Stack | Onde vive hoje |
|---------|--------|----------------|
| **Legado prod** | ASP.NET + **AngularJS 1.x** (SPA `Client/app.js`) | `RDO-APP/Equipamentos` → `sistema.rdoapp.com.br` |
| **Kiro Clean 2026** | **ASP.NET Core MVC + Razor** + CSS/JS externos | `RDO-APP/Migration2Core` → homolog Core |
| **Backlog Dimas** | **React 19 + Vite** strangler | TSK-10+ · ainda **não** no Core homolog |

Mobile (**Apontador**): **Expo/RN** — consome **Web API legado** (`api/...` no Equipamentos), não Razor.

---

## 2. O que “quebrou” no trabalho Kiro (documentado + código atual)

### 2.1 Projeto 1 abandonado (`EquipoToPiscina-1`)

| Problema | Efeito |
|----------|--------|
| **JS inline dentro de `.cshtml`** | Syntax inválida → **página em branco** (crise ~1 semana) |
| Mistura Blazor / legado | Abandonado em favor do Clean 2026 |

**Lição adotada no Projeto 2:** zero inline script; JS em arquivos separados (`4-CRITICAL-PAGES`).

### 2.2 Clean Migration — falhas conhecidas (jan–fev/2026)

| # | Sintoma | Causa raiz (doc Kiro) | Estado out/2026 |
|---|---------|------------------------|-----------------|
| 1 | Login branco incognito | CDN Bootstrap bloqueado | Revisar `Login.cshtml` — preferir assets locais |
| 2 | Escolher em branco | Arquivo view corrompido (0 KB) ou inline JS | View existe; validar em homolog |
| 3 | Nova Medição modal | Bootstrap/scope JS | **Não portado** — escopo Piscinas/laudo |
| 4 | Etapa/Tarefa vazia | Filtro `ColaboradorId` agressivo | Legado; Core **Cards** ainda placeholder |
| 5 | Header / botões RBAC | Rotas legado vs MVC | 🟡 partials `_HeaderEscolher` |
| 6 | Branding “Piscinas” | Copy homolog Piscinas | 🟡 parcialmente corrigido no código recente |
| 7 | README desatualizado | Diz “pending Selecionar” | **Código já tem** `POST Obra/Selecionar` + redirect Cards |

### 2.3 Gap atual de produto (homolog Core)

| Peça | Legado | Core homolog |
|------|--------|--------------|
| Login | `/login` Angular | `/Account/Login` Razor ✅ |
| Escolher | `/obra/escolher` | `/Obra/Escolher` ✅ |
| Selecionar obra | API + localStorage | `POST /Obra/Selecionar` ✅ |
| **Cards tarefa** | `/tarefa/cards` rico | `/Tarefa/Cards` **placeholder** ⬜ |
| Accordion etapas | `Tarefa/index` + cards.html | **Inexistente** ⬜ |

Arquivo: `Views/Tarefa/Cards.cshtml` — texto “Placeholder Fase 1”.

---

## 3. Razor vs React — decisão provisória (estudo)

### 3.1 Por que Kiro escolheu Razor

- Operador web **depois** de mobile (RESUMPTION-PLAN).
- Paridade com **fluxo cookie + sessão** do legado (sem JWT ainda).
- Entrega rápida Escolher/header sem montar SPA.

### 3.2 Por que Dimas prevê React

- TSK-10 scaffold Vite; strangler AngularJS → React.
- RBAC `usePermission` no front moderno.
- Alinhamento com stack declarada no PDF (React 19).

### 3.3 Proposta de convivência (para plano execução E5)

| Camada | W1 homolog (Windows EC2) | Onda 2+ |
|--------|---------------------------|---------|
| **Auth + Escolher + Cards MVP** | **Razor** até paridade mínima E2E Fase 0–1 | Manter até strangler pronto |
| **Painéis densos / Dono / relatórios** | Legado Angular **ou** Razor mínimo | **React** strangler |
| **Mobile Apontador** | **Inalterado** — API legado | JWT/API Core quando **contrato** estável |

**Não decidir React vs Razor no mobile** — RN permanece; decisão é **qual API** (legado vs Core).

### 3.4 Critérios EQ-R (React alvo) — pós-decisão

1. TSK-10 scaffold **ou** SPA no host homolog — **início semana 1** (não gate s9).
2. E2E assinado Lucio no fluxo **React** (login → Escolher → Cards com dados).
3. Matriz RBAC Loja×perfis fechada antes de telas sensíveis.
4. **EQ-W:** encerrar quando (1) ou (2) em [`ORQUESTRADOR-MIGRACAO.md`](ORQUESTRADOR-MIGRACAO.md) § Encerramento ponte.

---

## 4. Anti-padrões (manter)

- ❌ JS inline em `.cshtml`
- ❌ CDN-only CSS crítico (login)
- ❌ Copiar homolog Piscinas (`piscinas_rdoapp_homologa`) para Equipamentos Core
- ❌ Blazor misturado ao MVC deste spike

---

## 5. Próximo → implementação (fora deste doc)

1. **EQ-R:** Cards React (escopo reduzido) + pacotes TS com **EQ-M**.
2. **EQ-W:** só bugfix ponte; auditar `Escolher.cshtml` se bloquear E2E.
3. Reconciliar README Kiro com `ObraController.Selecionar`.
4. Remover strings “Piscinas” remanescentes no Core Razor.

---

## 6. Referências

- `Migration2Core/.../4-CRITICAL-PAGES-IMPLEMENTATION-PLAN.md`
- `Migration2Core/.../ESCOLHER-OBRA-TECHNICAL-BLUEPRINT.md`
- `docs/migracao-matriz-rotas-legado-core.md` (E2)
