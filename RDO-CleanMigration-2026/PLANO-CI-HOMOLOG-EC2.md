# Plano CI/CD — homolog `RdoApp.Core` (EC2 Windows W1)

**Repo:** `RDO-APP/Migration2Core` — **somente homolog** até EC2 Linux (L1) e cutover futuro.  
**Não deploya** produção (`inetpub\rdoapp`, site `rdo` :80, `novo_rdoapp`).

**URL:** `https://homolog.sistema.rdoapp.com.br` · porta **5081** · catálogo **`homol_rdoapp`**.

Espelho operacional da Loja: **GitHub Actions (OIDC) → S3 artefato → SSM na EC2** — sem RDP. Docker fica para **dev local** ou **L1 Linux** (fase 2).

---

## Visão

```text
push main / workflow_dispatch (Migration2Core)
    → GitHub Actions: dotnet publish → rdoapp_core.zip
    → S3 (bucket homolog dedicado)
    → SSM Run Command (PowerShell na EC2 Windows)
    → expand em C:\inetpub\wwwroot\homologacao\rdoapp_core
    → preserva appsettings.Staging.json
    → smoke http://127.0.0.1:5081/Account/Login
```

---

## Passo 0 — Decisões (Lucio)

| # | Decisão | Valor sugerido |
|---|---------|----------------|
| 0.1 | Bucket S3 **só homolog Core** | ex. `rdoapp-homolog-core-artifacts` (us-east-2) |
| 0.2 | Instância EC2 W1 | `i-05cb0003c031a26da` |
| 0.3 | Pasta deploy | `C:\inetpub\wwwroot\homologacao\rdoapp_core` |
| 0.4 | App pool IIS (se usar) | `RdoAppCoreHomolog` (ajustar no script se nome diferente) |
| 0.5 | Secrets RDS | **Só** `appsettings.Staging.json` na EC2 (fora do zip) |

---

## Passo 1 — AWS: bucket S3

1. Console AWS **us-east-2** → S3 → **Create bucket**.
2. Nome: ex. `rdoapp-homolog-core-artifacts`.
3. Block public access: **on**.
4. Lifecycle (opcional): expirar objetos `rdoapp_core/*.zip` após 30 dias.

---

## Passo 2 — AWS: IAM role EC2 (instância Equipamentos)

A instância precisa ler o zip no S3 (SSM executa como role da EC2).

Anexe ou complemente a role da EC2 com policy mínima:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:GetObject"],
      "Resource": "arn:aws:s3:::rdoapp-homolog-core-artifacts/rdoapp_core/*"
    }
  ]
}
```

(Ajuste o nome do bucket.)

---

## Passo 3 — AWS: IAM OIDC para GitHub Actions

1. IAM → Identity providers → **GitHub** (`token.actions.githubusercontent.com`) se ainda não existir.
2. Crie role ex. `github-migration2core-homolog-deploy` com trust policy (substituir `RDO-APP/Migration2Core`):

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::CONTA_ID:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:RDO-APP/Migration2Core:*"
        }
      }
    }
  ]
}
```

3. Policy da role (ajuste bucket e instância):

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:PutObject", "s3:GetObject"],
      "Resource": "arn:aws:s3:::rdoapp-homolog-core-artifacts/rdoapp_core/*"
    },
    {
      "Effect": "Allow",
      "Action": ["ssm:SendCommand", "ssm:GetCommandInvocation"],
      "Resource": [
        "arn:aws:ec2:us-east-2:CONTA_ID:instance/i-05cb0003c031a26da",
        "arn:aws:ssm:us-east-2:*:document/AWS-RunPowerShellScript"
      ]
    },
    {
      "Effect": "Allow",
      "Action": "ssm:SendCommand",
      "Resource": "arn:aws:ssm:us-east-2:CONTA_ID:*"
    }
  ]
}
```

Refinar `ssm:SendCommand` conforme auditoria interna.

---

## Passo 4 — GitHub: variáveis e secrets

Repositório **Migration2Core** → Settings → Secrets and variables → Actions:

| Tipo | Nome | Exemplo |
|------|------|---------|
| Secret | `AWS_ROLE_ARN` | `arn:aws:iam::CONTA:role/github-migration2core-homolog-deploy` |
| Variable | `HOMOLOG_CORE_S3_BUCKET` | `rdoapp-homolog-core-artifacts` |
| Variable | `HOMOLOG_EC2_INSTANCE_ID` | `i-05cb0003c031a26da` |
| Variable | `HOMOLOG_IIS_APP_POOL` | `RdoAppCoreHomolog` (vazio = não reinicia pool) |

**Não** cadastrar senha RDS no GitHub.

---

## Passo 5 — EC2: one-time (IIS + Staging)

1. Pasta `C:\inetpub\wwwroot\homologacao\rdoapp_core` criada.
2. **`appsettings.Staging.json`** na pasta com `Database=homol_rdoapp` + credenciais RDS.
3. Site IIS porta **5081** → physical path acima · pool **No Managed Code** · `ASPNETCORE_ENVIRONMENT=Staging`.
4. SSM Agent **Online** na instância.

Guia manual: `DEPLOY-HOMOLOG-EC2.md`.

---

## Passo 6 — Primeiro deploy automatizado

1. Merge do workflow em `main` (`.github/workflows/homolog-core-ec2.yml`).
2. Actions → **Homolog Core EC2 (build + deploy)** → **Run workflow**.
3. Marque **deploy_to_ec2** = true (default).
4. Acompanhar job: upload S3 → SSM → smoke **200**.

---

## Passo 7 — E2E humano

Checklist: repo Equipamentos `docs/e2e-fase0-checklist.md`  
Login: CPF `53821963549` / `1234` · UI Equipamentos · `historico_login` após login.

---

## Passo 8 — Deploy manual (sem Actions)

Na máquina com AWS CLI configurado:

```powershell
cd C:\Dev\Migration2Core\RDO-CleanMigration-2026\scripts
.\publish-homolog-ec2.ps1
.\deploy-homolog-ec2-ssm.ps1 `
  -S3Bucket "rdoapp-homolog-core-artifacts" `
  -InstanceId "i-05cb0003c031a26da"
```

---

## Fase L1 (depois) — Linux + Docker

Quando EC2 Linux homolog existir:

- Trocar `AWS-RunPowerShellScript` por script bash/systemd ou **GHCR** + `docker compose`.
- Manter **mesmo bucket/role pattern**; alterar só target TG/instance.
- Doc a criar: `DEPLOY-HOMOLOG-LINUX-EC2.md`.

---

## O que este pipeline **nunca** faz

- Publicar em `C:\inetpub\wwwroot\rdoapp` ou site **`rdo`** (:80).
- Commitar ou sobrescrever `appsettings.Staging.json` com secrets do Git.
- Apontar homolog Core para `novo_rdoapp` (prod).

---

## Arquivos no repo

| Arquivo | Função |
|---------|--------|
| `.github/workflows/homolog-core-ec2.yml` | Build + deploy opcional |
| `scripts/publish-homolog-ec2.ps1` | Publish local/CI |
| `scripts/ec2-apply-rdoapp-core.ps1` | Roda **na EC2** via SSM |
| `scripts/deploy-homolog-ec2-ssm.ps1` | Upload S3 + dispara SSM (PC local) |
| `DEPLOY-HOMOLOG-EC2.md` | IIS + troubleshooting |

---

## Histórico

| Data | Evento |
|------|--------|
| 2026-10-17 | Plano CI homolog W1 (Windows S3+SSM) |
