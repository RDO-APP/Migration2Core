# Storytelling unificado — Migração Core + Apps + FAPESC

**Para:** Dimas Duarte · **De:** Lucio Felix Neto (RDO APP SC)  
**Data:** set/2026  
**Base:** Backlog `v20260909` (56 TSK · 346 h) · Plano Ondas U · FAPESC 031/2026  
**Uso:** 1 reunião de alinhamento · anexo a proposta · base do roadmap compartilhado

---

## 1. Tese em uma frase

> **Não reescrevemos do zero.** Evoluímos o que já funciona (Apps mobile, APIs Framework, domínio validado em obra), usamos as **56 TSK** como inventário técnico da solução alvo, e entregamos em **ondas** — com **FAPESC** em trilha paralela e fronteira clara.

---

## 2. O que já temos (evidência)

| Ativo | Estado | Não jogar fora |
|-------|--------|----------------|
| **Apps Expo** (Piscineiro + Apontador) | ~94% código compartilhado · APK em produção/homolog | Sprint 7–8 “RN do zero” |
| **Branch `feature/alteracoes_apontador`** | 8/9 ajustes UI (ago/2026) | Rebuild antes de merge |
| **Backend Framework** | Equipamentos + Piscinas em operação | Big bang ETL mês 4 |
| **Homolog CI** | GitHub + Expo RDO App · build APK automático | — |
| **Estudos Lucio** | Ondas 0–6 · spec Apontamentos · comparativos | — |

---

## 3. Duas trilhas — uma arquitetura

```
                    ┌─────────────────────────────────────┐
                    │     SOLUÇÃO ALVO (.NET 8 + React)    │
                    │  Clean Arch · MySQL · S3 · OpenAPI   │
                    └─────────────────────────────────────┘
                                      ▲
          ┌───────────────────────────┼───────────────────────────┐
          │                           │                           │
   TRILHA A — PRODUTO          STRANGLER                 TRILHA B — FAPESC
   (Backlog Dimas TSK)         (convivência)              (A1–A16 · 9 meses)
          │                           │                           │
   Onda 0: Apps + API mínima    Framework → Core            Imutabilidade PoC
   Onda 1–5: Core + React web   endpoint a endpoint       hash · testnet · API verify
   Onda 6: ETL + cutover        AngularJS desliga           módulo separado
```

**Regra de ouro:** TSK-32 (assinatura comercial) **dispara evento** → módulo FAPESC. **Não misturar** entregáveis de edital.

---

## 4. Ordem de entrega (Ondas U — proposta Lucio)

| Onda | Objetivo | TSK Dimas relacionadas | Prazo indicativo |
|------|----------|------------------------|------------------|
| **0** | **Fechar Apps** — impressora Piscineiro, Apontamentos Apontador, homolog | — (antes TSK-01) | **Agora** |
| **1** | Fundação Core + Auth + scaffold React | TSK-01…12 | Meses 1–2 |
| **2** | Strangler web operador + integrar mobile na API nova | TSK-40 + U-25 | Meses 2–4 |
| **3** | Paridade operador (cards, medição, histórico) | TSK-24…30 | Meses 3–5 |
| **4** | Domínio obra/etapa/tarefa Core | TSK-17…23 | Meses 4–6 |
| **5** | Gestor — relatórios, PDF, Excel | TSK-37…38 | Meses 6–8 |
| **6** | ETL + cutover + desligar legado | TSK-41…45 | **Por último** |

> **Mobile (TSK-46…56):** integrar RN **existente** nas Ondas 0–2 — **não** aguardar Sprint 7–8.

---

## 5. Piscinas × Equipamentos — 2 produtos, 1 core

| Camada | Piscinas (Piscineiro) | Equipamentos (Apontador) |
|--------|----------------------|---------------------------|
| **APK** | `appPiscinas` | `appApontador` |
| **API** | `piscinas.rdoapp.com.br` | `sistema.rdoapp.com.br` |
| **Medição** | `piscinas.tsx` (química, PH…) | `equipamentos.tsx` (horímetro, paralisação…) |
| **Dashboard** | Piscineiro cards (LIMPEZA) | NormalDashboard (obras → etapas) |
| **Compartilhado** | auth, obra, cards, history shell, laudo/apontamento, PDF | idem |

**Core (TSK):** um domínio Apontamento + extensões por módulo (TSK-30 piscina · TSK-26 equipamentos).

---

## 6. Como “trancar” o app — decisão de produto

| Mecanismo | Piscineiro | Apontador | Adotar? |
|-----------|------------|-----------|---------|
| Trancar **etapa fixa** (só LIMPEZA / só EQUIPAMENTOS) | Opcional | **Não** (decisão ago/2026) | Parcial |
| **Perfil/plano** (`statusBasicaGratuita`) | Cards vs lista | Dashboard por perfil | **Sim — principal** |
| **RBAC** (TSK-12) | API devolve `features[]` | Mobile obedece | **Sim — implementar** |
| **Dono/licença** (`idLicenca` 1/2) | Assinatura laudo/apontamento | Ordem contratada → contratante | **Só assinatura** |

**Dono da assinatura** = plano comercial + admin da conta — **não** tranca layout inteiro. Operador: medição + consulta. Gestor: criar obra/etapa (web). Assinatura: quem tem `idLicenca` certo.

---

## 7. Capacidade e prazos — expectativa realista

| Cenário | Dimas PDF v20260909 | Estimativa Lucio |
|---------|---------------------|------------------|
| 1 dev · 20 h/sem · **só** migração | 346 h · **~4 meses** | **7–11 meses** |
| 1 dev · migração **+** FAPESC | Não previsto no PDF | **Sobrecarga** — ver §8 |
| 346 h inclui Cursor/IA? | **Sim** (Dimas, ago/2026) | Não comprimir de novo só com IDE |

---

## 8. FAPESC em paralelo (9 meses)

| Dimas (produto) | FAPESC (PoC) |
|---------------|--------------|
| TSK-01…45 Core + Web | A1–A4 arquitetura + normativo |
| TSK-32 assinatura comercial | A5b–A9 hash + testnet + API |
| Apps homolog/prod | Backend homolog PoC |
| ETL produção (Onda 6) | A14–A16 encerramento |

**Risco:** 1 pessoa @ 20 h/sem **não** fecha migração **e** FAPESC no mesmo prazo sem **segundo recurso** ou **sequenciamento**.

Detalhe mês a mês: [estudo-migracao-fapesc-9-meses.md](./estudo-migracao-fapesc-9-meses.md).

---

## 9. O que pedimos ao Dimas

1. **Validar** este storytelling e a ordem Ondas U (vs Sprint 1→8 linear).  
2. **Confirmar** v20260909 = reemissão do ago (sem mudança de escopo).  
3. **Combinar** antes de push em `main` / `homolog` (CI + Expo ativos).  
4. **Merge** `feature/alteracoes_apontador` → homolog → teste APK.  
5. **Separar** TSK-32 (produto) de entregáveis FAPESC (edital).  
6. **Exportar** TSK para issues com tags `onda-0`…`onda-6`.

---

## 10. Próximo marco (90 dias)

| Entrega | Responsável | Critério de done |
|---------|-------------|------------------|
| Onda 0 — Apps fechados | Dimas + Lucio | Apontamentos + impressora · APK homolog no celular |
| TSK-01…07 fundação | Dimas | Solution Core + Auth + S3 scaffold |
| RBAC mínimo API | Dimas | LoginObra retorna `perfil` + `features[]` |
| FAPESC A1–A2 | Equipe FAPESC | Normativo + matriz redes |

---

## Referências rápidas

| Doc | Link |
|-----|------|
| Diff v20260909 vs ago | [comparativo-dimas-v20260909.md](./comparativo-dimas-v20260909.md) |
| TSK → Ondas (tabela completa) | [comparativo-dimas-v20260818.md](./comparativo-dimas-v20260818.md) |
| Plano 6 ondas | [comparativo-e-plano-unificado.md](./comparativo-e-plano-unificado.md) |
| Cronograma 9 meses | [estudo-migracao-fapesc-9-meses.md](./estudo-migracao-fapesc-9-meses.md) |
| Chat Migração | `ee6f7379-dfb3-4995-a6cd-1c691007e9b0` |
| Chat FAPESC | `7bd737a8-9e2c-4022-a549-24c06dd8c5f5` |
