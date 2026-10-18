# M0 — Dúvidas (workshop Dimas) × soluções sem reunião

**Data:** 2026-10-17  
**Contexto:** [`ORQUESTRADOR-MIGRACAO.md`](ORQUESTRADOR-MIGRACAO.md) · marcos M0–M1  
**Evidência Git (out/2026):** `Migration2Core` — só `main`, `ci/homolog-ec2-s3-ssm`, `homolog/homol-rdoapp-paridade` (sem React). `EquipamentosMobile` — `feature/alteracoes_apontador` @ `14cf5d3`; `homolog` @ `525ccfa` (diverge).

Para cada linha: **Solução A** = preferida sem Dimas · **B/C** = alternativas · **Async Dimas** = mensagem mínima se quiser validação dele depois.

---

| # | Dúvida (era para o Dimas) | Solução A (executável agora) | Solução B / C | Async Dimas (opcional) |
|---|---------------------------|------------------------------|---------------|-------------------------|
| **1** | Scaffold **TSK-10** (React/Vite) já existe? Onde? | **A:** Confirmado **não** no `Migration2Core` GitHub — criar SPA greenfield em `RDO-CleanMigration-2026/client/` (Vite+React+TS), alinhado PDF TSK-10. | **B:** Scaffold mínimo só Cards+Login depois do host. **C:** Buscar outro repo org RDO-APP (só se aparecer repo privado listado na conta). | “Existe branch React fora Migration2Core?” |
| **2** | Quem implementa **EQ-R** nas próximas semanas? | **A:** **Lucio + Cursor** homolog; Dimas mantém **EQ-L** prod IIS + mobile até aviso. Registrar no orquestrador. | **B:** Dimas só revisa PR EQ-R quando disponível. | Confirmar se ele quer ser reviewer obrigatório. |
| **3** | **Onde** hospedar React no homolog? | **A:** Build estático servido pelo **RdoApp.Core** (`wwwroot/app` ou fallback SPA) em `:5081` / `homolog.sistema`. | **B:** Subdomínio ou path `/app/*` no mesmo certificado. **C:** CDN S3 só após M8 CI. | Preferência Clean Arch / repo SPA separado. |
| **4** | **JWT vs cookie** web + mobile? | **A:** **Fase 1 (M2–M5):** web EQ-R pode usar **BFF no Core** (cookie sessão homolog) + mobile continua **token/API legado** prod (cenário A). | **B:** EQ-R consome mesmos endpoints `api/*` que Apontador (EQ-L) com auth existente até M6. **C:** M6 — spike JWT (TSK-07) documentado; não bloquear Cards. | Quando implementa U-05/OpenAPI. |
| **5** | Cenário homolog mobile **A/B/C/D** (E3)? | **A:** **Cenário A** — Apontador **prod** API estável; homolog = operador web Core/React + RDS `homol_rdoapp`. | **B:** **D** só se subir **site legado** homolog apontando `homol_rdoapp`. **C:** **C** parcial — API mínima no Core (login/obras/tarefas) após M2. | Validar cenário D se ele já tem IIS homolog legado. |
| **6** | Merge **`feature/alteracoes_apontador`**? | **A:** **Inventário sem merge:** `git fetch` + checkout branch + mapear `src/services/*` → M1 api-client (Lucio/Cursor). | **B:** Merge local em branch **`homolog`** de teste (não `main`) para APK EAS. **C:** PR Lucio→`main` se você for maintainer. | OK merge oficial ou rebase em `homolog`? |
| **7** | **Cards** — React vs fallback Razor? | **A:** **EQ-R only** (orquestrador); Cards React homolog M2. | **B:** Fallback **EQ-W** Razor **só** se M2 estourar prazo — decisão explícita Lucio, 1 sprint max. | N/A se Lucio já decidiu EQ-R. |
| **8** | **FAPESC** rouba TSK / U-05? | **A:** Trilha **F** paralela; marcos M* no chat FAPESC — **M2 Cards não depende** PoC blockchain. | **B:** Priorização escrita: semana X = EQ-R, semana Y = TSK-32 (E4). **C:** Dimas 20h/sem cap — cortar escopo M7 não M2. | Qual marco FAPESC nas próximas 2 semanas. |
| **9** | **api-client** compartilhado EQ-R + EQ-M? | **A:** Doc **`api-client-equipamentos-v0.md`** + tipos TS gerados do inventário mobile (branch `feature/alteracoes_apontador`) + rotas E2 legado. | **B:** Pasta `packages/api-client` no monorepo Migration2Core importada pelo mobile depois. **C:** OpenAPI manual dos 5 endpoints críticos (login, obras, tarefas, cards, apontamento). | Revisar contrato antes de publicar pacote npm interno. |
| **10** | E2E **EQ-W** (ponte Razor)? | **A:** Executar [`e2e-fase0-checklist.md`](e2e-fase0-checklist.md) homolog CPF `53821963549`; anexar pass/fail — **M0 done** independente Dimas. | **B:** Se fail, trilha **EQ-W** bugfix only antes de M2. | Só se bug for publish IIS prod (EQ-L). |

---

## Branch mobile — decisão recomendada (pós-Git)

| Situação | Solução |
|----------|---------|
| Quer **UI 9 ajustes** Lucio (ago/2026) | Trabalhar a partir de **`feature/alteracoes_apontador`** |
| Quer **build EAS homolog** (set/2026) | Partir de **`homolog`**, depois **cherry-pick** ou merge da feature |
| Quer **main** limpa | Merge feature → main **M5**; até lá inventário na feature |

---

## Mensagem async única (copiar se quiser)

```text
Lucio aqui — homolog Equipamentos: Cards em React no Migration2Core (não achei branch TSK-10 no repo). Apontador: vou mapear API a partir da feature/alteracoes_apontador; prod API segue por enquanto. Quando puder: (1) React em client/ no Core ok? (2) merge feature→main ou homolog? (3) conflito FAPESC x U-05 nas próximas 2 semanas? Não te bloqueio.
```

---

## Fechamento M0 sem workshop

| Entregável M0 | Como fechar |
|---------------|-------------|
| Stack React+RN alinhada | Decisão Lucio: EQ-R greenfield + EQ-M inventário branch |
| TSK-10 scaffold | **Solução 1A** — criar `client/` |
| Inventário mobile | Checkout `feature/alteracoes_apontador` + M1 doc |
| E2E EQ-W | Solução 10A |

Atualizar orquestrador **Próxima ação** → **M1** após E2E + inventário iniciado.
