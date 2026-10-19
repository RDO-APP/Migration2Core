# Roteiro — deploy homolog Core (operador Lucio)

**Trilha:** **I0** · **Quem executa:** Lucio (PowerShell + browser). **Agente:** não roda SSM/deploy (só código/docs no Git).  
**Plano técnico:** [`../homolog-core-deploy-rapido-plano.md`](../homolog-core-deploy-rapido-plano.md)  
**Atualizado:** 2026-10-19 (lições login AWS, path clone, um passo por vez)

---

## 1. Mapa mental (não repetir confusão)

| Você pensa | Realidade |
|------------|-----------|
| “Abri AWS Session Manager na EC2” | Isso é **o servidor** (`hostname` tipo `EC2AMAZ-…`, usuário `ssm-user`). **Não** tem OneDrive, **não** tem clone `C:\Dev`. **Publish/build** é no **notebook/PC local**; EC2 só **recebe** o zip via SSM. |
| “Já estou logado no Console AWS” | Console **≠** AWS CLI no PC. Deploy usa **CLI** (`aws s3`, `aws ssm`). |
| “Copio a URL do `aws login` e abro depois” | Callback em `127.0.0.1:porta` **só funciona** enquanto o PowerShell **ainda espera** o login. Senão: **ERR_CONNECTION_REFUSED**. |
| “Código está no Cursor Equipamentos” | Workspace **Equipamentos** = legado prod + **cópia de docs**. Core homolog = repo **`RDO-APP/Migration2Core`** clonado no disco. |
| “Path `C:\Dev\Migration2Core`” | **Canônico nos docs** — só vale se o clone existir. Sempre: `Test-Path C:\Dev\Migration2Core` → `True` antes de publish. |

**Homolog:** `https://homolog.sistema.rdoapp.com.br` · EC2 `i-05cb0003c031a26da` · bucket `s3rdoapp` · região `us-east-2`

---

## 2. Pré-requisitos (one-time)

| Item | Como verificar |
|------|----------------|
| Git | `git --version` |
| .NET SDK (build Core) | `dotnet --version` |
| AWS CLI v2 (≥ 2.32 para `aws login`) | `aws --version` |
| Clone **Migration2Core** | `Test-Path C:\Dev\Migration2Core` → **True** |
| Scripts de deploy | `Test-Path C:\Dev\Migration2Core\RDO-CleanMigration-2026\scripts\publish-homolog-ec2.ps1` → **True** |

Se `Test-Path` do clone = **False** → **Passo A** abaixo (clone). Não pule.

---

## 3. Onde colar comando (duas janelas no mesmo laptop)

| Nome neste roteiro | Como abrir | Como saber que é **esta** janela (cole `hostname; whoami`) | Comandos que vão **aqui** |
|--------------------|------------|--------------------------------------------------------------|---------------------------|
| **PowerShell local** | Tecla Windows → digite **PowerShell** → Enter (app azul no **seu** Windows) | `DESKTOP-…` · usuário `…\lucio` · pasta costuma ser `C:\Users\LUCIO` ou `C:\Dev\…` | `aws login`, `publish-homolog-ec2.ps1`, `deploy-homolog-ec2-ssm.ps1`, `aws ssm get-command-invocation`, `aws ssm cancel-command` |
| **Terminal Session Manager** | Site **AWS Console** → EC2 → instância → **Connect** → aba **Session Manager** (PowerShell **dentro do navegador**, no servidor) | `EC2AMAZ-…` · `…\ssm-user` · prompt quase sempre `PS C:\Windows\system32>` | Só diagnóstico no **servidor** (logs, `127.0.0.1:5081`) — **não** publish, **não** deploy, **não** colar saída JSON de log |

**Regra de colar:** uma **linha** por vez — **sem** `PS C:\...>`, **sem** JSON `{ "CommandId": ... }` (isso é **resposta**, não comando).

**Antes de cada passo:** na dúvida, `hostname; whoami` na janela onde vai colar.

## 4. Passo a passo — um comando por vez

Cada bloco: **Onde [PC|SSM]** → **comando** → **para que serve** → **resultado esperado**. Só avance quando bater o esperado.

### Passo A — Clone (se `Test-Path C:\Dev\Migration2Core` = False) · **[PC]**

```powershell
New-Item -ItemType Directory -Force -Path C:\Dev | Out-Null; git clone --branch ci/homolog-ec2-s3-ssm https://github.com/RDO-APP/Migration2Core.git C:\Dev\Migration2Core
```

**Serve:** baixar código + scripts de deploy.  
**Esperado:** pasta `C:\Dev\Migration2Core` criada; `git` termina sem erro.  
Se branch falhar: troque por `main` ou branch que o GitHub mostrar.

Confirme:

```powershell
Test-Path C:\Dev\Migration2Core\RDO-CleanMigration-2026\scripts\publish-homolog-ec2.ps1
```

**Esperado:** `True`.

---

### Passo B — Login CLI (sempre que credencial expirar) · **[PC]**

```powershell
aws login --remote
```

**Serve:** autorizar **este PowerShell** a usar sua conta AWS (S3 + SSM).  
**Esperado:**

1. Terminal mostra **URL** + pede **código**.
2. Abra a URL → **Continue with active session** (LucioNeto).
3. Copie o **código curto** da tela AWS (não é URL longa) → cole no PowerShell → Enter.
4. Mensagem: `Updated profile default to use arn:aws:iam::...:user/LucioNeto`.

**Não use** `aws login` sem `--remote` se o callback `127.0.0.1` já falhou antes.  
**Não feche** o PowerShell entre abrir URL e colar código.

---

### Passo C — Confirmar login · **[PC]**

```powershell
aws sts get-caller-identity --region us-east-2
```

**Esperado:** JSON com `"Account": "775387704919"` e `"Arn": ".../LucioNeto"`.

---

### Passo D — Gerar zip (~57 MB, self-contained) · **[PC]**

```powershell
cd C:\Dev\Migration2Core\RDO-CleanMigration-2026\scripts; .\publish-homolog-ec2.ps1
```

**Serve:** `dotnet publish` + `rdoapp_core.zip` local.  
**Esperado:** `Publish OK` e `Zip: ...\publish\rdoapp_core.zip` (vários minutos).

---

### Passo E — Enviar S3 + comando na EC2 · **[PC]** (dispara deploy **remoto** na EC2)

```powershell
.\deploy-homolog-ec2-ssm.ps1 -S3Bucket "s3rdoapp" -InstanceId "i-05cb0003c031a26da"
```

**Serve:** upload zip + script na EC2 (para processo, preserva `appsettings.Staging.json`).  
**Esperado:** `CommandId` + **poll automático** a cada 15 s até `Success` ou erro (full deploy na EC2 costuma **3–8 min** — `InProgress` nesse intervalo é normal).

**Só se usou** `-NoWait` no deploy, ou perdeu a janela — **Passo F** (mesma pasta `scripts`):

```powershell
.\wait-ssm-homolog-command.ps1 -CommandId "COMMAND_ID"
```

Substitua `COMMAND_ID` pelo UUID anotado.

---

### Passo F — Esperar SSM (manual / recuperação)

**Onde:** **[PC]** · `C:\Dev\Migration2Core\RDO-CleanMigration-2026\scripts`

```powershell
.\wait-ssm-homolog-command.ps1 -CommandId "COMMAND_ID"
```

**Esperado:** linhas `[HH:mm:ss] Status: InProgress` … depois **`Deploy SSM OK.`**  
Se `Failed`: copie a saída completa para o chat Migração.

Alternativa legada (uma consulta, sem loop): `aws ssm get-command-invocation ...` — evitar; preferir `wait-ssm-homolog-command.ps1`.

---

### Passo G — Teste produto

1. `https://homolog.sistema.rdoapp.com.br/Account/Login`  
2. CPF teste homolog · Escolher obra · clicar obra.  
3. OK → `/Tarefa/Cards`. Erro → **texto completo** do banner vermelho (Staging mostra `ex.Message` após deploy com código novo).

---

## 4. Erros que já aconteceram (atalho)

| Sintoma | Causa | O que fazer |
|---------|--------|-------------|
| `Cannot find path C:\Dev\Migration2Core\...` | Clone **não existe** no PC | **Passo A** |
| `ERR_CONNECTION_REFUSED` em `127.0.0.1:52xxx` | URL/callback de sessão **morta** ou PowerShell fechado | `aws login --remote` de novo; **não** copiar URL antiga |
| `aws s3` / `AccessDenied` | CLI sem login | Passo B + C |
| SSM `InProgress` 10–20 min, stdout vazio | **Normal** — zip self-contained: download + `Expand-Archive` + `Copy-Item` na EC2; SSM **nao** mostra log ate `Success`/`Failed` | Deixe `wait-ssm-homolog-command.ps1` rodar; teste `https://homolog.sistema.rdoapp.com.br/Account/Login` (pode ser build anterior ate acabar) |
| SSM `InProgress` 20+ min (timeout do wait) | Deploy anterior / DLL presa / download travado | Console SSM → cancelar; Session Manager: processos `RdoApp.Core`; redeploy |
| SSM **`Failed`** mas stdout tem **`Deploy homolog Core OK`** + **`Smoke status: 200`** | **Falso negativo** — Core escreveu log no console SSM (`invalid argument`) | Tratar como **Success**; testar browser; proximo deploy usa `ec2-apply` com start detached |
| Agente “faz deploy” | Regra de sessão | **Lucio** roda Passos D–F; agente só documenta/codifica |

---

## 5. Hotfix (depois de I0 / runtime na EC2)

Só quando [`homolog-core-deploy-rapido-plano.md`](../homolog-core-deploy-rapido-plano.md) Fase 1+5 OK:

```powershell
cd C:\Dev\Migration2Core\RDO-CleanMigration-2026\scripts
.\publish-homolog-hotfix.ps1 -SkipClientBuild
.\deploy-homolog-hotfix-ssm.ps1 -S3Bucket "s3rdoapp" -InstanceId "i-05cb0003c031a26da"
```

Enquanto EC2 usa **só** `RdoApp.Core.exe` self-contained **sem** .NET instalado → preferir **Passo D + E** (full).

---

## 6. Para o agente (próximas sessões)

1. **Primeiro:** perguntar ou pedir `Test-Path C:\Dev\Migration2Core` — **não assumir** clone.  
2. **Deploy:** nunca enfileirar 10 comandos; **um passo + resultado esperado**.  
3. **Login:** recomendar **`aws login --remote`** (Lucio no Windows).  
4. **Docs/commits:** Migration2Core; espelho `.md` no workspace Equipamentos **não** substitui clone.  
5. **Alternativa sem AWS:** debug local `dotnet run` + RDS homolog (outro roteiro).

---

## 7. Checklist rápido (colar no chat antes de deploy)

- [ ] `Test-Path C:\Dev\Migration2Core` = True  
- [ ] `publish-homolog-ec2.ps1` existe  
- [ ] `aws sts get-caller-identity` OK  
- [ ] Publish gerou zip  
- [ ] SSM Success  
- [ ] E2E login → Escolher → Selecionar
