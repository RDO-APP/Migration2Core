# Homolog na nuvem — RdoApp.Core (2026-10-17)

**URL:** `https://homolog.sistema.rdoapp.com.br`  
**Infra:** Route 53 + ALB **Sistema-RDO** → TG `tg-equipamentos-homolog-5081` → EC2 **(Equipamentos)** porta **5081**.

## O que foi feito

1. Publish Windows self-contained (`scripts/publish-homolog-ec2.ps1`).
2. Artefato enviado via **S3** (`s3rdoapp/rdoapp_core.zip`) e extraído em `C:\inetpub\wwwroot\homologacao\rdoapp_core`.
3. App executado com **Kestrel** (`RdoApp.Core.exe`, `ASPNETCORE_ENVIRONMENT=Staging`, `ASPNETCORE_URLS=http://*:5081`) — IIS site legado `piscinas_hm` **parado** na 5081 (Hosting Bundle pendente para IIS nativo).
4. Smoke: `http://127.0.0.1:5081/Account/Login` → **200**; browser em `homolog.sistema` → login Core.

## Trilha

- **W1 (agora):** EC2 Windows atual — ver doc Equipamentos `plano-preparacao-migracao-homolog.md` §11.
- **L1 (depois):** EC2 Linux dedicada após H2 + E2E Fase 0.

## Operacional

- **Reinício EC2:** subir de novo o Core na 5081 (ou serviço Windows — TODO).
- **Republicar:** publish local → S3 → `aws s3 cp` na EC2 → reiniciar processo.
- **Secrets:** connection string só na EC2 (`appsettings.Production.json`), não no Git.

Guia: [`DEPLOY-HOMOLOG-EC2.md`](DEPLOY-HOMOLOG-EC2.md).
