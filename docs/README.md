# Docs — Migração Equipamentos (fonte única)

**Canônico:** repositório **`RDO-APP/Migration2Core`** · pasta `docs/`.

| O quê | Onde |
|-------|------|
| Orquestrador (ler primeiro) | [`ORQUESTRADOR-MIGRACAO.md`](ORQUESTRADOR-MIGRACAO.md) |
| Manual front ①–⑤ + **paridade P1–P4 (§10)** · stack **§10.7** | [`manual-frontend-rdo-equipamentos-prod-core-mobile.md`](manual-frontend-rdo-equipamentos-prod-core-mobile.md) |
| Pendências melhorias UI (P1–P4 stack · UI-M3 adiado) | [`migracao/pendencias-melhorias-ui-stack.md`](migracao/pendencias-melhorias-ui-stack.md) |
| Marcos M0–M3 · M0′ · I0 | `m0-*`, `m1-*`, [`matriz-4-paginas-prod-kiro-mobile.md`](matriz-4-paginas-prod-kiro-mobile.md), [`homolog-core-deploy-rapido-plano.md`](homolog-core-deploy-rapido-plano.md), [`migracao/m2-execucao-checklist.md`](migracao/m2-execucao-checklist.md), [`migracao/m3-execucao-runbook.md`](migracao/m3-execucao-runbook.md) |
| Estudos E0–E6 | arquivos `migracao-*.md`, `plano-execucao-migracao-v1.md`, `estudo-ci-homolog-readiness-e6.md` |
| API compartilhada EQ-R/EQ-M | [`api-client-equipamentos-v1.md`](api-client-equipamentos-v1.md) · [`api-client/`](api-client/) |
| Ops RDS / Dimas (referência) | [`ops/README.md`](ops/README.md) |
| Git push (agente) | [`migracao/git-push-checklist.md`](migracao/git-push-checklist.md) |
| CI homolog (código) | [`../RDO-CleanMigration-2026/PLANO-CI-HOMOLOG-EC2.md`](../RDO-CleanMigration-2026/PLANO-CI-HOMOLOG-EC2.md) |
| Trilha F (FAPESC) | [`estudos-lucio-apps-plano-migracao-core/`](estudos-lucio-apps-plano-migracao-core/) · chat **FAPESC Execução** · stub [`editais-fapesc/README.md`](editais-fapesc/README.md) |
| Regra Cursor (cópia) | [`cursor-rules/orquestrador-migracao-impacto.mdc`](cursor-rules/orquestrador-migracao-impacto.mdc) |

**OneDrive ↔ Git:** espelho Cursor em `…/Equipamentos/docs/` deve ficar **100% alinhado** ao clone `C:\Dev\Migration2Core` após cada push/pull — script [`migracao/sync-docs-onedrive-from-git.ps1`](migracao/sync-docs-onedrive-from-git.ps1). **Commit/push só Migration2Core**; repo legado `Equipamentos` **não** recebe docs M* / orquestrador.
