# Comparativo — Backlog Dimas v20260909 × v20260818 × Ondas U

**Autor PDF:** Dimas Duarte  
**Arquivo novo:** `Dimas Migração Core Apps Piscinas Apontador Backlog_RDO v20260909.pdf` (09/set/2026)  
**Arquivo anterior:** `Backlog_RDO v20260818.pdf` (18/ago/2026)  
**Cruzamento com:** [comparativo-e-plano-unificado.md](./comparativo-e-plano-unificado.md) · [comparativo-dimas-v20260818.md](./comparativo-dimas-v20260818.md)  
**Atualizado:** 2026-09-18

---

## 1. Diff v20260909 vs v20260818

| Item | v20260818 | v20260909 | Mudou? |
|------|-----------|-----------|--------|
| Título | Plano de Reescrita RDO & App Mobile | Idem | Não |
| Tarefas | 56 (TSK-01…56) | 56 (TSK-01…56) | Não |
| Esforço | 346 h | 346 h | Não |
| Capacidade | 20 h/sem · 4 h/dia · 1 dev | Idem | Não |
| Prazo | 86,5 d · 17,3 sem (~4 meses) | Idem | Não |
| Stack | .NET 8 · React 19 · RN/Expo · MySQL 8.4 · S3 | Idem | Não |
| Sprints 1–8 | Mesma distribuição | Idem | Não |
| Lista TSK | Mesmas descrições e dependências | Idem | Não |

**Conclusão:** o PDF de **09/set/2026** é **reemissão** do backlog de **18/ago/2026** — **sem alteração material** de escopo, horas ou ordem. O cruzamento TSK → Ondas U permanece válido; ver [comparativo-dimas-v20260818.md](./comparativo-dimas-v20260818.md) §4 (tabela completa).

---

## 2. Resumo executivo (v20260909)

| Métrica | Valor |
|---------|--------|
| Abordagem | **Greenfield** — Core + Web + ETL + mobile **reescrito no fim** (Sprints 7–8) |
| Mobile | TSK-46…56 — setup RN do zero, offline SQLite, EAS |
| RBAC | TSK-12 — `usePermission` + Protected Routes |
| Apontamento | TSK-24…30 — modelo desacoplado, horas, horímetro, química piscina |
| Assinatura | TSK-32/35 — canvas + SHA-256 + PDF laudo |
| ETL | TSK-41…45 — Sprint 6 (~48 h) |

---

## 3. Veredicto (inalterado vs ago/2026)

| Aspecto | Dimas v20260909 | Plano unificado (Ondas U) | Ação |
|---------|-----------------|---------------------------|------|
| Inventário técnico TSK | ✅ Completo | Usar como backlog | Adotar |
| Ordem de entrega | Web → ETL → mobile | **Onda 0** mobile → Strangler → ETL por último | **Reordenar** |
| Prazo 4 meses @ 20 h | 346 h declaradas | Realista: **7–11 meses** (1 dev) ou 2 devs | **Ajustar** |
| Rebuild mobile | 70 h Sprint 7–8 | Evoluir Expo existente (~94% pronto) | **Rejeitar rebuild** |
| Trancar etapa | Implícito no domínio web | **Não** trancar etapa Apontador (decisão ago/2026) | **Perfil/RBAC** |
| FAPESC | TSK-32 SHA-256 | Módulo **Imutabilidade** separado (A1–A16) | **Fronteira** §5 |

**Storytelling recomendado:** *“Não reescrevemos do zero — usamos as 56 TSK como mapa técnico, com ordem Ondas U e apps mobile como Onda 0.”*

---

## 4. Mapa Sprint → Onda (referência rápida)

| Sprint Dimas | Onda unificada | Nota |
|--------------|----------------|------|
| — | **Onda 0** | Apps + API Framework Apontamento **antes** Sprint 1 |
| 1–2 | Onda 1 | Fundação Core + Identity |
| 3–4 | Onda 4 | Obras, etapas, apontamento |
| 5 | Onda 4 + FAPESC* | RDO/Laudo · *TSK-32 ≠ entregável FAPESC |
| 6 (relatórios) | Onda 5 | Dapper, Excel, PDF gestor |
| 6 (ETL) | **Onda 6** | Só após validação campo |
| 7–8 (mobile) | **Onda 0 + U-25** | Integrar RN existente |

Detalhe TSK → U: [comparativo-dimas-v20260818.md](./comparativo-dimas-v20260818.md) §4.

---

## 5. Fronteira FAPESC × Dimas

| | Dimas (TSK) | FAPESC (A1–A16) |
|---|-------------|-----------------|
| Objeto | Produto comercial Core + Apps | PoC imutabilidade documental |
| Assinatura | TSK-32 canvas + SHA-256 comercial | Hash snapshot determinístico + ancoragem |
| Prazo | 346 h (~4 meses declarados) | 9 meses contrato |
| Integração | Evento: RDO assinado → fila imutabilidade | Módulo `RdoApp.Imutabilidade` |

Cronograma paralelo 9 meses: [estudo-migracao-fapesc-9-meses.md](./estudo-migracao-fapesc-9-meses.md).

---

## 6. Decisões pendentes com Dimas (set/2026)

1. Confirmar que v20260909 **não** altera escopo vs ago — apenas reemissão.  
2. Aceitar **Onda 0** (mobile primeiro) vs Sprint 7–8 greenfield.  
3. Matriz **Plano × Papel × Feature** (RBAC) — substitui “trancar etapa”.  
4. Merge `feature/alteracoes_apontador` antes de rebuild.  
5. **Avisar antes de push** em `main` / `homolog` (pipeline CI ativo).  
6. TSK-32 **dispara** FAPESC — não **é** FAPESC.

---

## Referências

| Arquivo | Descrição |
|---------|-----------|
| [storytelling-unificado-dimas-migracao-fapesc.md](./storytelling-unificado-dimas-migracao-fapesc.md) | **1 página** para alinhar Dimas |
| [comparativo-dimas-v20260818.md](./comparativo-dimas-v20260818.md) | Tabela TSK-01…56 completa |
| [estudo-migracao-fapesc-9-meses.md](./estudo-migracao-fapesc-9-meses.md) | Migração × FAPESC paralelo |
