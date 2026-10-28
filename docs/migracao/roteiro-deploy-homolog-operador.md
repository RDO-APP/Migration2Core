# Roteiro — deploy homolog Core (operador Lucio)

**Trilha:** **I0** · **Quem executa:** Lucio (PowerShell + browser). **Agente:** não roda SSM/deploy (só código/docs no Git).  
**Plano técnico:** [`../homolog-core-deploy-rapido-plano.md`](../homolog-core-deploy-rapido-plano.md)  
**Atualizado:** 2026-10-28 · **M7 7a** cadastro RDO · branch `ci/homolog-ec2-s3-ssm` · ref Git **`498ebc4+`** (sempre **A2 pull** → **D publish** → **E deploy** — nunca E sem D)

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

**Como copiar no PowerShell:** abra este `.md` no Cursor (preview ou editor), clique no **ícone copiar** no canto superior direito de cada bloco `powershell` (ou selecione só o texto **dentro** do bloco). Cole **uma colagem por vez** na janela **[PC]** — **não** cole o prompt `PS C:\...>` nem JSON de resposta.

---

## 3b. Ciclo deploy normal — 4 colagens (fluxo de sempre)

Use isto **99% das vezes**. Credencial AWS OK recente → pule colagem **2** (login).

**Colagem 1 — atualizar Git**

```powershell
git -C C:\Dev\Migration2Core fetch origin ci/homolog-ec2-s3-ssm; git -C C:\Dev\Migration2Core pull origin ci/homolog-ec2-s3-ssm
```

**Colagem 2 — só se `aws sts get-caller-identity` falhar (credencial expirada)**

```powershell
aws login --remote
```

```powershell
aws sts get-caller-identity --region us-east-2
```

**Colagem 3 — publish (vários minutos)**

```powershell
cd C:\Dev\Migration2Core\RDO-CleanMigration-2026\scripts
```

```powershell
.\publish-homolog-ec2.ps1
```

**Colagem 4 — deploy (mesma pasta `scripts`; não feche o PowerShell)**

```powershell
.\deploy-homolog-ec2-ssm.ps1 -S3Bucket s3rdoapp -InstanceId i-05cb0003c031a26da
```

**O que acontece na colagem 4 (importante):**

| Você vê | Significa |
|---------|-----------|
| `CommandId: xxxxxxxx-…` | SSM aceitou o job na EC2 (só informativo) |
| Linhas `[HH:mm:ss] Status: InProgress` | **Normal** — o script **já está esperando** sozinho (poll 15 s) |
| `Deploy SSM OK.` | Pode ir ao browser — **Passo G** |
| `Failed` | Copie **toda** a saída para o chat Migração |

**Você não precisa** rodar `wait-ssm-homolog-command.ps1` nem **substituir** nenhum UUID no fluxo normal. Isso só existia para quem usava `-NoWait` ou fechava o terminal no meio — ver **Passo F (recuperação)** abaixo.

---

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

### Passo A2 — Atualizar clone (se `Test-Path` = True, **antes de cada deploy**) · **[PC]**

```powershell
git -C C:\Dev\Migration2Core fetch origin ci/homolog-ec2-s3-ssm; git -C C:\Dev\Migration2Core pull origin ci/homolog-ec2-s3-ssm
```

**Serve:** garantir publish com o mesmo commit que está no GitHub (ex. `4c4bb5b`).  
**Esperado:** `Already up to date` ou fast-forward sem conflito.

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

**Serve:** `npm run build` (SPA em `wwwroot/app`) + `dotnet publish` self-contained + `rdoapp_core.zip` local.  
**Esperado:** build Vite OK · `Publish OK` · `Zip: ...\publish\rdoapp_core.zip` (vários minutos).  
**Smoke bundle (pós-`fe0713f`):** `index-Dte8_yr6.js` · `index-D5QSC4UY.css` — hash muda a cada build; conferir em DevTools → Network após deploy. **M4.7g** exige **Core DLL** (BFF `showEditarObra`) **e** SPA — publish completo (Passo D), não só hotfix DLL.

---

### Passo E — Enviar S3 + comando na EC2 · **[PC]** (dispara deploy **remoto** na EC2)

Mesma pasta que o Passo D (`...\RDO-CleanMigration-2026\scripts`):

```powershell
.\deploy-homolog-ec2-ssm.ps1 -S3Bucket s3rdoapp -InstanceId i-05cb0003c031a26da
```

**Serve:** upload zip + script na EC2 (para processo, preserva `appsettings.Staging.json`).  
**Esperado:** `CommandId: …` (informativo) → o **mesmo script** chama `wait-ssm-homolog-command.ps1` **automaticamente** → termina com **`Deploy SSM OK.`** (full deploy na EC2 costuma **3–8 min**; `InProgress` nesse intervalo é normal).

**Não faça nada extra** após colar o comando — deixe o PowerShell aberto até `Deploy SSM OK.` ou `Failed`.

---

### Passo F — Esperar SSM (**só recuperação** — fluxo normal **não** usa)

**Quando usar (raro):**

| Situação | O que fazer |
|----------|-------------|
| Deploy com **`-NoWait`** | O PowerShell imprime **uma linha pronta** com o UUID **já preenchido** — copie **essa linha inteira** (não invente `COMMAND_ID`) |
| Fechou o PowerShell com SSM ainda `InProgress` | Na saída antiga ou no Console AWS → Run Command, copie o UUID de `CommandId:` e use a colagem abaixo trocando **só** o UUID |
| `wait` deu timeout mas o deploy pode ainda estar rodando | Reexecutar wait com o **mesmo** `CommandId` (script é idempotente enquanto `InProgress`) |

**Onde:** **[PC]** · `C:\Dev\Migration2Core\RDO-CleanMigration-2026\scripts`

Troque `COLE-AQUI-O-UUID-DO-COMMANDID` pelo valor verde `CommandId: …` (ex.: `46901ecd-1234-5678-abcd-0123456789ab`):

```powershell
.\wait-ssm-homolog-command.ps1 -CommandId "COLE-AQUI-O-UUID-DO-COMMANDID" -InstanceId i-05cb0003c031a26da
```

**Esperado:** linhas `[HH:mm:ss] Status: InProgress` … depois **`Deploy SSM OK.`**  
Se `Failed`: copie a saída completa para o chat Migração.

**Exemplo com `-NoWait`:** o deploy **já imprime** o comando completo — use **só** essa linha, sem editar manualmente.

---

### Passo G — Teste produto (E2E + **M4.7b/c/d**)

Use **Ctrl+F5** (hard refresh) após SSM Success.

| # | O quê | Esperado |
|---|--------|----------|
| G1 | `https://homolog.sistema.rdoapp.com.br/Account/Login` → CPF homolog | Login OK |
| G2 | **P2** `/Obra/Escolher` · selecionar obra (ex. **42**) | Cards obra · Selecionar → **P3** |
| G3 | **P3** `/Tarefa/Cards` | Accordion com etapas/tarefas (BFF) |
| G4 | Header | Logo · **nome da obra** · usuário + dropdown · ícones chart/+ (RBAC) |
| G5 | **Menu hambúrguer** (M4.7d/**i**) | Drawer **opaco**, links **brancos**, accordion **não** aparece por cima do menu · itens de `GET /api/bff/shell` · Trocar senha / Sair |
| G6 | Toolbar linha título | **RDO · Efetivo** (2 ícones se perfil **sem** `editarObra` — paridade prod **M4.7g**) · DevTools → `GET /api/bff/shell` → matriz [`m4-7g-rbac-shell-p1-p3.md`](m4-7g-rbac-shell-p1-p3.md) |
| G7 | Toolbar faixa | LISTA · FILTRO · ADICIONAR TAREFA · ADICIONAR ETAPA |
| G8 | **P5a / M7 7a** RDO | `/Rdo/Index` listagem · **NOVO** → `/Rdo/Cadastro` SPA · salvar · voltar listagem · Chart → `/Chart` (stub se ainda não entregue) |
| G9 | DevTools Network | `GET /api/bff/etapas` **200** · SPA JS carregado (hash atual, ex. `index-DzoPbagL.js`) |

Erro → banner vermelho ou tela em branco; anotar `CommandId` se SSM falhou → chat Migração.

Após PASS: marcar **M4.7c/d** smoke em [`m4-execucao-checklist.md`](m4-execucao-checklist.md) · botões: [`p3-botoes-habilitacao-m7.md`](p3-botoes-habilitacao-m7.md).

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
| Agente “faz deploy” | Regra de sessão | **Lucio** roda colagens **3–4** (D–E); agente só documenta/codifica |
| Doc pedia `wait-ssm` + `COMMAND_ID` | Confusão com fluxo antigo / `-NoWait` | Fluxo normal: **só** `deploy-homolog-ec2-ssm.ps1` até `Deploy SSM OK.` |
| Deploy OK mas **UI igual** | Publish **sem** `git pull` · **SSM sem publish** (re-upload zip velho) · cache browser | **Um ciclo só:** `git pull` → `git log -1` → **publish** → **deploy** → Ctrl+F5 · Network: hash JS/CSS **≠** deploy anterior |
| Menu **transparente** / etapas **atrás** do drawer | `header.css` sidebar `z-index:2` dentro de `.topo` | **M4.7i** (`operador-menu-open`) — precisa bundle novo pós-fix |
| **3 ícones** toolbar (RDO+edit+efetivo) vs prod **2** | `GET /api/bff/shell` → `showEditarObra:true` (permissão homolog) ou Core **sem** campos RBAC | Comparar JSON com prod (mesmo CPF) · não é bug de deploy se BFF devolve `true` |
| **Deploy SSM OK** + browser **`502 Bad Gateway`** | **Regressão de hospedagem** (desde ~commit `6056bc9`): `ec2-apply` faz `taskkill` + **`Start-Process` Kestrel** mas **não** parava site IIS na **5081**; smoke só **`127.0.0.1:5081`** → falso positivo. ALB fala com **IP privado:5081** (mesmo caminho do browser). | Redeploy com `ec2-apply` atual (para IIS na 5081 + Kestrel `0.0.0.0:5081` + **ALB smoke obrigatório**). **Ou** modo IIS: deploy com `-AppPoolName '…'` e **sem** Kestrel solto — ver [`DEPLOY-HOMOLOG-EC2.md`](../../RDO-CleanMigration-2026/DEPLOY-HOMOLOG-EC2.md). |
| SSM **Failed** + **Unable to connect** `127.0.0.1:5081` | Build **`ceab653`**: `[HttpGet]` + `[HttpGet("/Chart")]` no mesmo action → exe **morre na subida** | Publish com fix M4.7k (só rotas por atributo no `Index` de Chart/Rdo/Dashboard) |

### Por que “antes não acontecia”

| Época | Como homolog subia | Por que ALB + browser funcionavam |
|--------|-------------------|-----------------------------------|
| **Setup manual (W1)** | IIS site na **5081** apontando para `homologacao\rdoapp_core` (doc Etapa 4) | Um único listener na 5081; ALB e localhost = mesmo caminho |
| **SSM `6056bc9` / `d18cf8f`** | Script passou a subir **segundo** host: exe Kestrel + smoke **só localhost** | IIS **continuou** na 5081 em muitos deploys; ALB pode ver **502** enquanto SSM imprime **200** |
| **Out/2026 `ceab653`** | Mesmo script + **bug de rotas** no publish | 502 **e** SSM Failed (exe não escuta) |

**Regra operacional (evitar repetir):** na EC2 existe **um** dono da porta **5081** — **IIS** *ou* **Kestrel/serviço `RdoAppCoreHomolog`**, nunca os dois. O script `ec2-apply-rdoapp-core.ps1` hoje: para sites IIS na 5081 (modo Kestrel padrão), sobe Core em **`http://0.0.0.0:5081`**, e **falha o deploy** se o smoke no **IP privado** não for **200**.

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

## 7. Checklist rápido (colar no chat antes/depois de deploy)

- [ ] `Test-Path C:\Dev\Migration2Core` = True  
- [ ] `git pull` branch `ci/homolog-ec2-s3-ssm` (commit alvo anotado, ex. `4c4bb5b`)  
- [ ] `publish-homolog-ec2.ps1` existe  
- [ ] `aws sts get-caller-identity` OK  
- [ ] Publish gerou zip (+ `npm run build` no log)  
- [ ] Colagem 4 terminou com **`Deploy SSM OK.`** (sem passo extra de wait)  
- [ ] G1–G3 login → Escolher → Cards com dados  
- [ ] G5 hambúrguer + G6 ícones toolbar título  
- [ ] G8 pelo menos um clique → Em migração
