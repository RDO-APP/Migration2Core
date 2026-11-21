# Docs — Migração Equipamentos (fonte única)

**Canônico:** repositório **`RDO-APP/Migration2Core`** · pasta `docs/`.

| O quê | Onde |
|-------|------|
| Orquestrador (ler primeiro) | [`ORQUESTRADOR-MIGRACAO.md`](ORQUESTRADOR-MIGRACAO.md) |
| Dimas TSK × marcos M* (rastreio) | [`migracao/dimas-tsk-rastreio-m.md`](migracao/dimas-tsk-rastreio-m.md) |
| Manual front ①–⑤ + **paridade P1–P4 (§10)** · stack **§10.7** · **§ Apps** | [`manual-frontend-rdo-equipamentos-prod-core-mobile.md`](manual-frontend-rdo-equipamentos-prod-core-mobile.md) |
| Pendências stack UI (tabela **por página** · BS5×legado · *Quando mudar* · UI-M3 adiado) | [`migracao/pendencias-melhorias-ui-stack.md`](migracao/pendencias-melhorias-ui-stack.md) |
| Fontello + FA legado → Core (marcos M4.7 vs UI-M3) | [`migracao/fontello-fa-legado-marcos-ui.md`](migracao/fontello-fa-legado-marcos-ui.md) |
| Marcos M0–M3 · M0′ · I0 | `m0-*`, `m1-*`, [`matriz-4-paginas-prod-kiro-mobile.md`](matriz-4-paginas-prod-kiro-mobile.md), [`homolog-core-deploy-rapido-plano.md`](homolog-core-deploy-rapido-plano.md), [`migracao/m2-execucao-checklist.md`](migracao/m2-execucao-checklist.md), [`migracao/m3-execucao-runbook.md`](migracao/m3-execucao-runbook.md) |
| Estudos E0–E6 | arquivos `migracao-*.md`, `plano-execucao-migracao-v1.md`, `estudo-ci-homolog-readiness-e6.md` |
| API compartilhada EQ-R/EQ-M | [`api-client-equipamentos-v1.md`](api-client-equipamentos-v1.md) · [`api-client/`](api-client/) |
| **M6** Apontador (Fase 0→JWT) | [`migracao/plano-m6-mobile-jwt.md`](migracao/plano-m6-mobile-jwt.md) · checklist [`migracao/m6-fase0-baseline-apk-prod.md`](migracao/m6-fase0-baseline-apk-prod.md) |
| Ops RDS / Dimas (referência) | [`ops/README.md`](ops/README.md) |
| Governança catálogos RDS | [`rds-equipamentos-governanca-catalogos.md`](rds-equipamentos-governanca-catalogos.md) · diff ①×② [`scripts/homol-vs-prod-schema-diff.sql`](scripts/homol-vs-prod-schema-diff.sql) |
| Infra nuvem AWS (EC2/ALB/RDS/S3/…) | [`migracao/infraestrutura-nuvem-aws-rdo.md`](migracao/infraestrutura-nuvem-aws-rdo.md) · manual §14 |
| **L1 Linux homolog** (2026-11-19) | [`migracao/plano-dia2-l1-linux.md`](migracao/plano-dia2-l1-linux.md) · [`../RDO-CleanMigration-2026/DEPLOY-HOMOLOG-LINUX-EC2.md`](../RDO-CleanMigration-2026/DEPLOY-HOMOLOG-LINUX-EC2.md) · EC2 `i-0776acb09b8438f22` |
| Git push (agente) | [`migracao/git-push-checklist.md`](migracao/git-push-checklist.md) |
| CI homolog (código) | [`../RDO-CleanMigration-2026/PLANO-CI-HOMOLOG-EC2.md`](../RDO-CleanMigration-2026/PLANO-CI-HOMOLOG-EC2.md) |
| Trilha F (FAPESC) | [`estudos-lucio-apps-plano-migracao-core/`](estudos-lucio-apps-plano-migracao-core/) · chat **FAPESC Execução** · stub [`editais-fapesc/README.md`](editais-fapesc/README.md) |
| Regra Cursor (cópia) | [`cursor-rules/orquestrador-migracao-impacto.mdc`](cursor-rules/orquestrador-migracao-impacto.mdc) |

**OneDrive ↔ Git:** espelho Cursor em `…/Equipamentos/docs/` deve ficar **100% alinhado** ao clone `C:\Dev\Migration2Core` após cada push/pull — script [`migracao/sync-docs-onedrive-from-git.ps1`](migracao/sync-docs-onedrive-from-git.ps1). **Commit/push só Migration2Core**; repo legado `Equipamentos` **não** recebe docs M* / orquestrador.
