# Estudo E6 — Prontidão CI homolog (sem executar AWS)

**Data:** 2026-10-17  
**Escopo:** Avaliar se o pipeline **pode** rodar — **não** criar bucket, **não** Run workflow.

Canônico técnico: `Migration2Core/RDO-CleanMigration-2026/PLANO-CI-HOMOLOG-EC2.md`  
Branch código: `RDO-APP/Migration2Core` → `ci/homolog-ec2-s3-ssm` (merge pendente em `main`).

---

## 1. Artefatos prontos (repo)

| Item | Status |
|------|--------|
| `publish-homolog-ec2.ps1` | ✅ testado local (~59 MB zip) |
| `ec2-apply-rdoapp-core.ps1` | ✅ escrito |
| `deploy-homolog-ec2-ssm.ps1` | ✅ escrito |
| `.github/workflows/homolog-core-ec2.yml` | ✅ branch CI |
| `.gitignore` Staging secrets | ✅ |
| RDS `homol_rdoapp` 47 tbl | ✅ |
| IIS/Staging EC2 | 🟡 one-time Lucio (passo 5 PLANO-CI) |

---

## 2. Pré-requisitos AWS (ainda não verificados neste estudo)

| # | Item | Verificado? |
|---|------|-------------|
| 1 | Bucket S3 homolog dedicado | ⬜ |
| 2 | IAM EC2 `s3:GetObject` | ⬜ |
| 3 | IAM OIDC GitHub → role | ⬜ |
| 4 | GitHub vars/secrets | ⬜ |
| 5 | SSM Agent Online | ⬜ |

---

## 3. Gate recomendado (ordem)

```text
E2E Fase 0 assinado (Cards com dados — **EQ-R** alvo; EQ-W placeholder não conta)
    → merge branch ci/homolog-ec2-s3-ssm
    → passos 0–5 PLANO-CI (Lucio AWS)
    → Run workflow deploy_to_ec2=true
    → smoke 200 :5081
```

**Motivo:** CI sem Cards úteis só repete homolog “login OK”.

---

## 4. Alternativa manual

PC com AWS CLI:

```powershell
cd C:\Dev\Migration2Core\RDO-CleanMigration-2026\scripts
.\publish-homolog-ec2.ps1
.\deploy-homolog-ec2-ssm.ps1 -S3Bucket "<bucket>" -InstanceId "i-05cb0003c031a26da"
```

Mesmos pré-requisitos S3/IAM/SSM.

---

## 5. O que CI **nunca** deve fazer (checklist review)

- [ ] Path `inetpub\rdoapp`
- [ ] Sobrescrever `appsettings.Staging.json` com secret do Git
- [ ] Catálogo `novo_rdoapp`

Workflow atual: **OK** por desenho (preserva Staging no script EC2).

---

## 6. Conclusão E6

**Prontidão código:** alta.  
**Prontidão operacional:** baixa — depende Lucio AWS + merge + E2E.  
**Ação:** manter CI **pausado** até gate §3.

---

## 7. Pós-L1 (Linux)

Reutilizar bucket/role pattern; trocar `AWS-RunPowerShellScript` por systemd/Docker — doc futuro `DEPLOY-HOMOLOG-LINUX-EC2.md`.
