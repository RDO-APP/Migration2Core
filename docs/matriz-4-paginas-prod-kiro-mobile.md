# Matriz — 4 páginas críticas (Prod × Kiro × Core × Mobile)

**Data:** 2026-10-18  
**Repos:**  
- **Prod web (EQ-L):** `RDO-APP/Equipamentos` → `rdoappProject/` · `https://sistema.rdoapp.com.br`  
- **Kiro / Core homolog (EQ-W/R):** `RDO-APP/Migration2Core` → `RDO-CleanMigration-2026/RDO-CleanMigration-2026/RdoApp.Core/` · `https://homolog.sistema.rdoapp.com.br`  
- **Mobile (EQ-M):** `RDO-APP/EquipamentosMobile` · branch ref. `feature/alteracoes_apontador` @ `14cf5d3`  

**Objetivo:** Fonte única de aceite por **página operador**, alinhada ao estudo Kiro (jan–fev/2026) e à comparação **página a página** com produção Equipamentos — não Piscinas/Gilberto como referência de produto.

**Manual gráfico ampliado (5 vetores):** [`manual-frontend-rdo-equipamentos-prod-core-mobile.md`](manual-frontend-rdo-equipamentos-prod-core-mobile.md) — inclui **Piscinas web (PQ-L)** e **Piscineiro (PQ-M)** + tabela **GitHub / RDS** no topo.

**M0′ Fase A (evidências):** [`m0-prime-fase-a-evidencias.md`](m0-prime-fase-a-evidencias.md)

**Docs Kiro relacionados:**  
`RDO-CleanMigration-2026/4-CRITICAL-PAGES-IMPLEMENTATION-PLAN.md` · `FEBRUARY-2026-COMPLETE-SUMMARY-AND-NEXT-PLAN.md` · `ESCOLHER-OBRA-TECHNICAL-BLUEPRINT.md` · `STRATEGY-2-OBRA-CARDS-IMPLEMENTATION-PLAN.md` · `docs/migracao-kiro-mapa-estudo.md`

---

## Legenda de status

| Símbolo | Significado |
|---------|-------------|
| ✅ | Paridade mínima operador ou equivalente intencional |
| 🟡 | Parcial — fluxo ou UI incompleta |
| ⬜ | Não migrado / placeholder |
| 🔀 | Decisão diferente do legado (documentada) |
| ❌ | Quebrado em homolog (dívida ativa) |

**Dono trilha:** EQ-L = só referência · EQ-W = ponte Razor · EQ-R = React alvo · EQ-M = Apontador

---

## Página 1 — Login

| Dimensão | Detalhe |
|----------|---------|
| **Prod (AngularJS)** | Rota UI `#/login` · `Client/Views/Login/index.html` · `Client/Controllers/LoginController.js` · API `POST api/login/LoginUser` (`LoginController.cs` / `LoginModel`) |
| **Regras prod** | CPF normalizado; senha TripleDES; monta `LoginViewModel` (rotas/menu default); cookie/sessão; redirect **`/obra/escolher`** |
| **Kiro** | ✅ `AccountController` POST/GET · `Views/Account/Login.cshtml` · `Utils/Seguranca.cs` · lições CDN/incognito (`4-CRITICAL-PAGES`) |
| **Core homolog hoje** | ✅ Login MVC funciona em homolog · strings ainda misturam Piscinas/Equipamentos em views antigas |
| **Mobile** | Login nativo → **`POST /api/login/LoginUser`** (prod API — cenário **A** M1) · não usa Razor |
| **Gap** | Branding homolog = Equipamentos; alinhar copy/logo · não reabrir CDN externo no login Razor |
| **Dono** | EQ-W (ponte) até M4 · critério E2E em [`e2e-fase0-checklist.md`](e2e-fase0-checklist.md) passo 1 |

---

## Página 2 — Card de obras (Escolher)

| Dimensão | Detalhe |
|----------|---------|
| **Prod (AngularJS)** | Rota `#/obra/escolher` · `Client/Views/Obra/escolher.html` · `ObraController.js` · após clique: **`POST api/Usuario/LoginObra`** (também `api/login/LoginObra` em fluxos legados) |
| **Regras prod** | Lista obras do colaborador; **LoginObra** preenche sessão (`LoginViewModel`: rotas RBAC, menu, `ObraColaborador`, obra); navega **`/tarefa/cards`** · filtros cliente (unidade/município) no template |
| **Kiro** | 🟡 Escolher MVC · `ObraController` GET Escolher + POST Selecionar · `LoginObraService` + `RbacRouteService` · header `_HeaderEscolher` + `PermissionHelper` · **STRATEGY-2:** filtros/progresso cards **não** migrados |
| **Core homolog hoje** | 🟡 Lista obras OK · ❌ **Selecionar** (LoginObra web) falha com exceção / banner genérico · branding Escolher |
| **Mobile** | Lista obras + **`LoginObra`** via API prod · **referência de payload** para M1 types · não replica grid web |
| **Gap #1** | **`POST /Obra/Selecionar`** = port LoginObra — sessão + RBAC + redirect Cards (EQ-W0.5) |
| **Gap #2** | Filtros/paridade visual obra cards (opcional EQ-W; Kiro STRATEGY-2) |
| **Dono** | EQ-W até Selecionar OK · EQ-R não reinventa Escolher (só cookie/session herdada) |

---

## Página 3 — Card de tarefas (Etapas / Cards)

| Dimensão | Detalhe |
|----------|---------|
| **Prod (AngularJS)** | Rota `#/tarefa/cards` · **`Client/Views/Tarefa/cards.html`** · `TarefaController.js` · APIs: `GET api/etapa/Get/?idObra=` · `GET api/etapa/ObterEtapaTarefa/` · `POST api/tarefa/ObterTarefa/` |
| **Regras prod** | Accordion etapas; cards tarefa; permissões por rota; toolbar/header operador; depende **LoginObra** prévio |
| **Kiro** | ⬜ Razor placeholder `Tarefa/Cards` · lição **Etapa vazia** (filtro ColaboradorId errado) — **não** repetir Razor · pausa 35% antes de SPA |
| **Core homolog hoje** | 🟡 `TarefaController.Cards` serve **`wwwroot/app/index.html`** (React M2) se existir · BFF **`GET /api/bff/etapas`** (EF `homol_rdoapp`) · bloqueado se Selecionar ❌ |
| **Mobile** | Fluxo tarefas pós-LoginObra · mesmos endpoints P0 em [`api-client-equipamentos-v1.md`](api-client-equipamentos-v1.md) · **usar como spec de dados**, não layout web |
| **Gap #1** | Checklist paridade mínima `cards.html` (etapas visíveis, ≥1 tarefa) em homolog |
| **Gap #2** | M2: React + BFF homolog **ou** proxy documentado — decisão M2 já = BFF `homol_rdoapp` |
| **Dono** | **EQ-R (M2)** · EQ-W só fallback Razor |

---

## Página 4 — Nova medição (modal / cadastro rápido)

| Dimensão | Detalhe |
|----------|---------|
| **Prod (AngularJS)** | Modal **`#nova-medicao-botao-rapido`** em `cards.html` · abertura `TarefaController.js` (~`$('#nova-medicao-botao-rapido').modal('show')`) · validações `.data-medicao` · cadastro em `cadastro.html` / POST tarefa-medição |
| **Regras prod** | Status, datas medição, horímetro, paralisações; integração Bootstrap/Angular Material; **depende Cards** |
| **Kiro** | ⬜ **Não concluído** · anti-padrões documentados (modal não abre, scope JS, Bootstrap init) em `4-CRITICAL-PAGES-IMPLEMENTATION-PLAN.md` |
| **Core homolog hoje** | ⬜ Fora de escopo M2 atual |
| **Mobile** | Medição/tarefa em telas Apontador — **vetor de regras de negócio** para Onda 2 / pós-M3 (não substituir modal web admin) |
| **Gap** | Só após **M3** assinado; escopo EQ-R tela ou manter prod para medição até Onda 2 |
| **Dono** | Backlog **M7+** / Onda 2 · referência prod + mobile |

---

## Cruzamento resumido (Kiro × prod)

| # | Página | Prod Equipamentos | Kiro entregou | Kiro não entregou (por quê) |
|---|--------|-------------------|---------------|-----------------------------|
| 1 | Login | Angular + API LoginUser | MVC + TripleDES | Branding homolog; lições CDN |
| 2 | Obras | escolher.html + LoginObra API | Escolher + Selecionar (em progresso) | Filtros/cards ricos; LoginObra web instável em homolog |
| 3 | Tarefas | cards.html + APIs etapa/tarefa | Entidades + placeholder | Pausa mobile; Angular complexo → decisão React |
| 4 | Nova medição | Modal cards.html | Tentativas falhas | JS/modal; dependência Cards |

---

## O que aproveitar do Mobile (EQ-M)

| Artefato | Uso na migração web |
|----------|---------------------|
| [`api-client-equipamentos-v1.md`](api-client-equipamentos-v1.md) + `equipamentos-api.types.ts` | Contrato **LoginUser / ObterObras / LoginObra / etapa/Get** — M2 Cards |
| Cenário **A** (mobile → prod API) | Web homolog **não** assume mesma URL — BFF homolog ou cookie MVC |
| Branch `feature/alteracoes_apontador` | Homologação APK; validar mesma obra CPF teste que web |
| Fluxo campo operador | Prioridade UX **Cards** antes de Nova Medição web |

---

## Gates E2E (homolog) — ordem correta

1. Login (200)  
2. Escolher — N obras  
3. **Selecionar** — sem 500; sessão obra  
4. **Cards** — React ou placeholder com **dados** (`/api/bff/etapas` 200)  
5. Nova medição — **fora** gate M3  

Checklist: [`e2e-fase0-checklist.md`](e2e-fase0-checklist.md)

---

## Dívidas ativas (2026-10-18)

| ID | Item | Trilha |
|----|------|--------|
| W0.5 | Selecionar + deploy confiável | EQ-W + **I0** |
| R2.0 | Cards React + BFF homolog | EQ-R |
| I0 | Deploy rápido (FDD, serviço, hotfix, CI) — ver [`homolog-core-deploy-rapido-plano.md`](homolog-core-deploy-rapido-plano.md) | I |
| DOC | Lucio: captura Network prod (4 telas) + revisão desta matriz | — |

---

## Próximo passo documental

1. Lucio validar coluna **Prod** (screenshot + 1 request por tela).  
2. Atualizar orquestrador: marco **M0′** (esta matriz) antes de declarar M2 “em execução”.  
3. Implementação: **Selecionar** (EQ-W) local/RDS → **I0** → **M2** Cards com checklist página 3.
