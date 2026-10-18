# Plano — deploy homolog RdoApp.Core rápido (SSM + CI)

**Repo:** `RDO-APP/Migration2Core` · **Trilha:** I + EQ-W0.5  
**URL:** `https://homolog.sistema.rdoapp.com.br` · **EC2:** `i-05cb0003c031a26da` · **Porta:** 5081  
**Pasta:** `C:\inetpub\wwwroot\homologacao\rdoapp_core`  
**Banco:** `homol_rdoapp` (connection string **só** em `appsettings.Staging.json` na EC2)

**Objetivo:** parar de enviar zip **self-contained ~57 MB** a cada correção; passar a **hotfix SSM** (segundos–1 min) + **build no GitHub Actions** (como a Loja), com **serviço Windows** para restart limpo.

---

## Visão das fases

| Fase | O quê | Frequência | Tempo típico |
|------|--------|------------|--------------|
| **0** | Commit/push fix `Selecionar` + 1 deploy | Uma vez | ~7 min (último full) |
| **1** | Instalar .NET **Hosting Bundle** na EC2 | One-time | ~15 min |
| **2** | Publish **framework-dependent** + script | Por release maior | ~1 min publish local/CI |
| **3** | **Hotfix SSM** (dll + `wwwroot/app`) | Dia a dia | ~30 s–2 min |
| **4** | **GitHub Actions** + workflow dispatch | Push ou botão | ~3–5 min (build na nuvem) |
| **5** | **Serviço Windows** `RdoAppCoreHomolog` | One-time + rare | Restart ~5 s |

Ordem recomendada: **0 → 1 → 5 → 2 → 4 → 3** (serviço antes de hotfix evita DLL presa).

---

## Fase 0 — Desbloquear `POST /Obra/Selecionar` (agora)

### 0.1 Commit (Lucio ou agente, branch `ci/homolog-ec2-s3-ssm` ou `main`)

Incluir no commit (já existente local em `C:\Dev\Migration2Core`):

- `RdoApp.Core/Services/LoginObraService.cs` — decrypt seguro + fallback RBAC  
- `RdoApp.Core/Services/RbacRouteService.cs` — URLs/menu nulos  
- `RdoApp.Core/Controllers/ObraController.cs` — try/catch + `LoginSessionJson`  
- `RdoApp.Core/Controllers/AccountController.cs` — sessão unificada  
- `RdoApp.Core/Infrastructure/LoginSessionJson.cs` — novo  
- `RDO-CleanMigration-2026/scripts/deploy-homolog-ec2-ssm.ps1` — BOM JSON + presigned URL  
- `RDO-CleanMigration-2026/scripts/ec2-apply-rdoapp-core.ps1` — TLS 1.2, taskkill, presigned, start Kestrel  

Opcional no mesmo commit: `client/` build → `wwwroot/app` (se mudou React).

```powershell
cd C:\Dev\Migration2Core
git status
git add <arquivos acima>
git commit -m "fix(homolog): Selecionar + scripts SSM deploy"
git push origin <branch>
```

### 0.2 Build React (se Cards M2)

```powershell
cd C:\Dev\Migration2Core\RDO-CleanMigration-2026\client
npm ci
npm run build
```

### 0.3 Último deploy **full** (self-contained atual)

Enquanto Fase 1–2 não estiver pronta:

```powershell
$env:Path = "$env:ProgramFiles\Amazon\AWSCLIV2;" + $env:Path
aws sts get-caller-identity   # deve funcionar após aws login
cd C:\Dev\Migration2Core\RDO-CleanMigration-2026\scripts
.\publish-homolog-ec2.ps1
.\deploy-homolog-ec2-ssm.ps1 -S3Bucket "s3rdoapp" -InstanceId "i-05cb0003c031a26da"
```

Anotar `CommandId` e conferir:

```powershell
aws ssm get-command-invocation --command-id <CommandId> --instance-id i-05cb0003c031a26da --region us-east-2
```

### 0.4 Teste E2E

1. `https://homolog.sistema.rdoapp.com.br/Account/Login`  
2. Escolher obra → **sem** 500 em `/Obra/Selecionar`  
3. `/Tarefa/Cards` (React ou placeholder)

---

## Fase 1 — Runtime .NET na EC2 (one-time)

Hoje o homolog usa **`RdoApp.Core.exe` self-contained**. Para hotfix pequeno, a EC2 precisa do **ASP.NET Core Runtime 10 (Windows x64)** ou **Hosting Bundle** (recomendado se no futuro usar IIS in-process).

### 1.1 SSM na EC2 (Session Manager ou Run Command)

1. Baixar e instalar **.NET 10 Hosting Bundle** (Windows x64) — mesma major do `net10.0` do projeto.  
2. Reiniciar IIS **somente** se for usar IIS; para Kestrel standalone basta o runtime.  
3. Validar:

```powershell
dotnet --list-runtimes
# Deve listar Microsoft.AspNetCore.App 10.x e Microsoft.NETCore.App 10.x
```

### 1.2 Decisão de execução

| Modo | Comando / serviço | Notas |
|------|-------------------|--------|
| **A — Kestrel + serviço (recomendado agora)** | `dotnet RdoApp.Core.dll` ou exe framework-dependent | Porta 5081, `ASPNETCORE_ENVIRONMENT=Staging` |
| **B — IIS + Hosting Bundle** | Site :5081, pool No Managed Code | Alinha com doc `DEPLOY-HOMOLOG-EC2.md` |

Plano assume **A + Fase 5 (serviço)**.

---

## Fase 2 — Publish framework-dependent

### 2.1 Novo script (a criar no repo)

`RDO-CleanMigration-2026/scripts/publish-homolog-ec2-fdd.ps1`:

- `dotnet publish -c Release -r win-x64 --self-contained false -o publish/homolog-ec2-fdd`
- Saída típica: **~5–15 MB** (app + deps), sem runtime completo embarcado.

### 2.2 Primeiro deploy FDD na EC2

1. Publicar FDD local ou no CI.  
2. **Uma** cópia full para `C:\inetpub\wwwroot\homologacao\rdoapp_core` (substituir self-contained).  
3. Preservar **`appsettings.Staging.json`** (nunca vem do zip).  
4. Entrypoint passa a ser **`dotnet RdoApp.Core.dll`** (serviço Windows — Fase 5).

### 2.3 Checklist pós-migração FDD

- [ ] `dotnet RdoApp.Core.dll` sobe na 5081  
- [ ] Smoke `http://127.0.0.1:5081/Account/Login` → 200  
- [ ] ALB `https://homolog.sistema.rdoapp.com.br` → login OK  

---

## Fase 3 — Hotfix SSM (dll + SPA)

### 3.1 Novo script (a criar)

`RDO-CleanMigration-2026/scripts/publish-homolog-hotfix.ps1`:

- `dotnet publish ... --self-contained false` para pasta staging  
- Montar zip **só** com:
  - `RdoApp.Core.dll` (+ `.pdb` opcional homolog)
  - Dependências **alteradas** (ou lista fixa mínima: `RdoApp.Core.dll`, `*.deps.json`, assemblies do projeto)
  - `wwwroot/app/**` (build Vite)
- **Não** incluir `appsettings.Staging.json`

### 3.2 Novo apply na EC2 (a criar)

`ec2-apply-rdoapp-core-hotfix.ps1`:

1. Presigned URL → baixar zip pequeno  
2. **`Stop-Service RdoAppCoreHomolog`** (Fase 5) ou `taskkill`  
3. Copiar só arquivos do zip por cima  
4. **`Start-Service RdoAppCoreHomolog`**  
5. Smoke Login 200  

### 3.3 Deploy hotfix (Lucio)

```powershell
cd C:\Dev\Migration2Core\RDO-CleanMigration-2026\scripts
.\publish-homolog-hotfix.ps1
.\deploy-homolog-hotfix-ssm.ps1 -S3Bucket "s3rdoapp" -InstanceId "i-05cb0003c031a26da"
```

Tempo esperado: **~30 s–2 min** (SSM + cópia + restart serviço).

---

## Fase 4 — GitHub Actions + workflow dispatch

Base: `.github/workflows/homolog-core-ec2.yml` (já existe; hoje publica **self-contained**).

### 4.1 Ajustes no workflow (próximo commit)

| Item | Ação |
|------|------|
| Publish | Trocar para `--self-contained false` (FDD) ou job separado **hotfix** |
| Client | Step `npm ci && npm run build` em `RDO-CleanMigration-2026/client` |
| Deploy | Manter SSM; alinhar com `ec2-apply` presigned + **serviço** |
| Branch | Permitir `workflow_dispatch` em `ci/homolog-ec2-s3-ssm` até merge em `main` |

### 4.2 Variáveis GitHub (repo Migration2Core)

Conforme `PLANO-CI-HOMOLOG-EC2.md`:

| Nome | Exemplo |
|------|---------|
| Secret `AWS_ROLE_ARN` | role OIDC GitHub → S3 + SSM |
| Variable `HOMOLOG_CORE_S3_BUCKET` | `s3rdoapp` ou bucket dedicado |
| Variable `HOMOLOG_EC2_INSTANCE_ID` | `i-05cb0003c031a26da` |
| Variable `HOMOLOG_IIS_APP_POOL` | vazio se usar só serviço Kestrel |

### 4.3 Uso (como Loja)

1. Push na branch monitorada **ou**  
2. Actions → **Homolog Core EC2 (build + deploy)** → **Run workflow** → `deploy_to_ec2: true`  
3. Acompanhar job **deploy** (poll SSM no workflow, ~6 min max).

Lucio **não** precisa `dotnet publish` local no dia a dia.

---

## Fase 5 — Serviço Windows (restart rápido)

Evita DLL presa (problema visto no deploy full) e restart em **segundos**.

### 5.1 Opção recomendada: **NSSM** ou script + `sc.exe`

**Nome sugerido:** `RdoAppCoreHomolog`  
**Diretório:** `C:\inetpub\wwwroot\homologacao\rdoapp_core`  
**Binário (após FDD):** `C:\Program Files\dotnet\dotnet.exe`  
**Argumentos:** `RdoApp.Core.dll`  
**Variáveis de ambiente (serviço):**

- `ASPNETCORE_ENVIRONMENT=Staging`  
- `ASPNETCORE_URLS=http://*:5081`  

### 5.2 One-time via SSM (esboço)

Script `scripts/ec2-install-rdoapp-core-service.ps1` (a criar):

1. Verificar dotnet no PATH  
2. Instalar/registrar serviço  
3. `Set-Service -StartupType Automatic`  
4. Start + smoke 5081  

### 5.3 Operacional

```powershell
Restart-Service RdoAppCoreHomolog
Get-Service RdoAppCoreHomolog
```

Hotfix SSM passa a usar **Stop/Start-Service** em vez de copiar com exe rodando.

---

## Ordem de execução (checklist único)

```
[ ] 0. Commit/push fix Selecionar + scripts SSM atuais
[ ] 0. npm run build (client) se necessário
[ ] 0. Um deploy full final (self-contained) OU pular se for direto para FDD na 1ª carga
[ ] 1. Instalar .NET 10 Runtime/Hosting Bundle na EC2 (SSM/RDP)
[ ] 5. Criar serviço Windows RdoAppCoreHomolog (apontando para dotnet + dll)
[ ] 2. publish-homolog-ec2-fdd.ps1 + deploy full FDD uma vez
[ ] 4. Configurar vars/secrets GitHub + testar workflow_dispatch
[ ] 3. Implementar publish-homolog-hotfix.ps1 + deploy-homolog-hotfix-ssm.ps1
[ ] 3. Teste hotfix: mudar 1 linha → workflow ou hotfix local → Selecionar/Cards OK
[ ] Atualizar ORQUESTRADOR / M2.5 E2E assinado
```

---

## Artefatos a implementar no repo (próximo commit conjunto)

| Arquivo | Função |
|---------|--------|
| `scripts/publish-homolog-ec2-fdd.ps1` | Publish framework-dependent |
| `scripts/publish-homolog-hotfix.ps1` | Zip mínimo dll + wwwroot/app |
| `scripts/deploy-homolog-hotfix-ssm.ps1` | S3 + SSM hotfix |
| `scripts/ec2-apply-rdoapp-core-hotfix.ps1` | Apply na EC2 + serviço |
| `scripts/ec2-install-rdoapp-core-service.ps1` | One-time serviço |
| `.github/workflows/homolog-core-ec2.yml` | FDD + npm build + serviço |
| `DEPLOY-HOMOLOG-EC2.md` | Link para este plano |

---

## Referências

- `RDO-CleanMigration-2026/DEPLOY-HOMOLOG-EC2.md`  
- `RDO-CleanMigration-2026/PLANO-CI-HOMOLOG-EC2.md`  
- `docs/ORQUESTRADOR-MIGRACAO.md` — EQ-W0.5, M2.5  
- Loja homolog: push `homolog` → Actions + SSM (padrão a espelhar)

---

**Próxima ação sugerida:** executar **Fase 0** (commit/push + um deploy) para corrigir `Selecionar`; em seguida **Fase 1 + 5** na EC2; depois commit com scripts FDD/hotfix + workflow (Fases 2–4).
