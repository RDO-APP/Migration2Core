# Estudo E4 — FAPESC × Migração × Mobile (anexo out/2026)

**Data:** 2026-10-17  
**Base:** `estudo-migracao-fapesc-9-meses.md` (set/2026–mai/2027) · `storytelling-unificado-dimas-migracao-fapesc.md`

**Chat FAPESC Execução:** `6a7186f9-e813-4d8e-9720-f096c7eae369` — PoC/imutabilidade; **não** codar Termo neste chat Migração.

---

## 1. Onde estamos no calendário (out/2026)

| Marco | Planejado (9 meses) | Realidade estudo out/2026 |
|-------|---------------------|---------------------------|
| Mês 1 set/2026 | Onda 0 mobile + TSK-01…02 + A1/A2 FAPESC | Termo/contemplação — **validar** com chat FAPESC |
| Mês 2 out/2026 | TSK-03…07 + A1/A2/A5a | **Paralelo:** homolog Core (`homol_rdoapp`), CI pausado, Apontador branch feature |
| Mês 3 nov/2026 | ★ PJ consultoria + TSK-08…12 + A3/A4 | Gate doc + DDA FAPESC |

Este anexo **não** altera o PDF 9 meses — registra **tensões** visíveis em out/2026.

---

## 2. Três frentes competindo por capacidade

| Frente | Entregável típico | Repo / chat |
|--------|-------------------|-------------|
| **FAPESC** | A1 normativo, A3 DDA, A5a DER, PoC verify | FAPESC Execução · `docs/imutabilidade/` |
| **Migração Core web** | Razor homolog, Cards, JWT futuro | Migration2Core · Migração chat |
| **Mobile Onda 0** | Apontador APK, U-05 API, homolog | EquipamentosMobile · coord. Migração |

**Dimas (20 h/sem referência):** PDF já inclui IA; **FAPESC soma** ~352 h estimadas Lucio — picos **>22 h/sem** em meses 4–6 do estudo original.

---

## 3. Dependências cruzadas (matriz)

| Migração / Mobile | Depende de FAPESC? | FAPESC depende de Migração? |
|-------------------|--------------------|-----------------------------|
| Homolog Core Equipamentos | **Não** | **Não** para PoC backend |
| TSK-32 assinatura → evento imutabilidade | **Sim** (módulo pós-assinatura) | **Sim** — evento do produto |
| JWT API mobile | **Não** direto | **Não** |
| Demonstração órgão (web) | Narrativa A1 requisitos | **Parcial** — demo pode ser legado + PoC API |
| OpenAPI U-08 | **Não** | Facilita auditoria A4 diagramas |

**Regra ponte:** PoC blockchain **≠** homologação TCE/MP em prod municipal (chat FAPESC).

---

## 4. O que FAPESC **não** deve puxar prematuramente

- Cutover `novo_rdoapp` → Core (Onda 6).
- Troca API mobile para Core homolog sem contrato.
- Deploy prod Equipamentos via Migration2Core.

---

## 5. O que Migração **deve** entregar para aliviar FAPESC (narrativa)

| Entrega migração | Uso FAPESC / comercial |
|------------------|------------------------|
| Homolog URL estável + E2E login | Demo B2G “sistema moderno em validação” |
| `historico_login` homolog | Evidência trilha acesso (sem blockchain) |
| Documentação arquitetura Equipamentos-only | Anexo A4 (diagrama) **referência**, não copy PoC |

---

## 6. Sincronização sugerida (processo, não código)

| Cadência | Participantes | Pauta |
|----------|---------------|-------|
| Quinzenal 30 min | Lucio + chat FAPESC lead | Marcos M*, dependências TSK-32 |
| Mensal | Lucio + Dimas | Razor vs React, mobile vs Cards |
| Por marco | Lucio | Atualizar `ORQUESTRADOR-MIGRACAO.md` + ponte FAPESC 3 bullets |

Arquivo ponte time (se existir no workspace): `docs/editais-fapesc/10_PONTE_MIGRACAO_TIME.md` — recriar/atualizar se ausente no clone.

---

## 7. Out/2026 — foco recomendado pós-estudo

1. **Fechar E2E Fase 0** homolog Core (Cards MVP mínimo).
2. **Merge ou decisão** branch `feature/alteracoes_apontador`.
3. **Chat FAPESC:** confirmar marco M1 real vs plano set/2026.
4. **Não** iniciar TSK-10 React até gate §3 `migracao-frontend-razor-react-decisao.md`.

---

## 8. Referências

- `estudos-lucio-apps-plano-migracao-core/estudo-migracao-fapesc-9-meses.md`
- `estudos-lucio-apps-plano-migracao-core/storytelling-unificado-dimas-migracao-fapesc.md`
- `docs/imutabilidade/README.md`
