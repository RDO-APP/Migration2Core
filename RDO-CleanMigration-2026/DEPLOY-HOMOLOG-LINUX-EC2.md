# Deploy homolog EC2 Linux — RdoApp.Core (L1)

**URL (não muda):** `https://homolog.sistema.rdoapp.com.br`  
**Plano:** [`docs/migracao/plano-dia2-l1-linux.md`](../docs/migracao/plano-dia2-l1-linux.md)  
**W1 (rollback):** [`DEPLOY-HOMOLOG-EC2.md`](DEPLOY-HOMOLOG-EC2.md) · EC2 Windows `i-05cb0003c031a26da`  
**Banco:** `homol_rdoapp` — connection string **só na EC2**, nunca no Git.

**Status doc:** L1 **cutover feito** (2026-11-19) — TG aponta Linux `i-0776acb09b8438f22` **healthy** · Windows fora da 5081 · falta smoke browser Lucio + commit Git.

---

## Inventário AWS (verificado 2026-11-19 · us-east-2 · conta `775387704919`)

| Item | Valor |
|------|--------|
| ALB | `Sistema-RDO` · ARN `…/app/Sistema-RDO/f52257982e76a385` |
| Listener HTTPS | `:443` · rule **Priority 4** Host `homolog.sistema.rdoapp.com.br` → TG abaixo |
| Host irmão (mesmo TG) | Priority **3** · `homologacao.piscinas.rdoapp.com.br` (não alterar regra no cutover L1) |
| TG | `tg-equipamentos-homolog-5081` · ARN `…/targetgroup/tg-equipamentos-homolog-5081/23dd68b7de53942f` |
| TG porta / protocolo | **HTTP : 5081** |
| Health check | Path `/` · Matcher **200** · interval 30s · healthy≥5 · unhealthy≥2 |
| VPC | `vpc-ea507a82` |
| Subnet Windows (referência) | `subnet-c1a2ffa9` · **us-east-2a** · `172.31.0.0/20` · MapPublicIpOnLaunch |
| EC2 Windows (W1) | `i-05cb0003c031a26da` · Name `Equipamentos` · IP privado **`172.31.2.89`** · running |
| SG instância | `sg-0949364ef36d38331` (`sg_Equipamentos`) |
| SG ALB → 5081 | Origem `sg-00356b50f53dbbeee` (`sg- alb-sistema-rdo`) TCP **5081** (também 80/82/443) |
| Egress SG | `0.0.0.0/0` (RDS via VPC OK) |
| Instance profile | `NewInstanceRole` (SSM) |
| Bucket publish | `s3rdoapp` (mesmo W1) |

**Health TG no inventário:** target Windows `i-05cb…:5081` = **unhealthy** (`Target.ResponseCodeMismatch` — códigos **[302]**). Matcher exige **200** em `/`. Browser pode ainda servir via ALB; para L1 preferir **antes do cutover**:
- health path `/Account/Login` (espera 200), **ou**
- matcher `200,302`.

Não mudar regra Host Priority 4 — só **destinos** do TG.

---

## Staging (modelo Windows → copiar à Linux)

| | Windows (W1) | Linux (L1) |
|--|--------------|------------|
| App root | `C:\inetpub\wwwroot\homologacao\rdoapp_core` | `/var/www/rdoapp_core` |
| Secrets | `appsettings.Staging.json` (não no zip) | idem — **não** sobrescrever no apply |
| Env | `ASPNETCORE_ENVIRONMENT=Staging` | unit systemd |
| URLs | `ASPNETCORE_URLS=http://0.0.0.0:5081` | idem |
| Conteúdo mínimo Staging | `ConnectionStrings:DefaultConnection` → `Database=homol_rdoapp` · `Smtp:*` (mesmo Esqueci senha) | copiar do Windows (SSM/RDP) **sem** colar senha no Git |

Prod `C:\inetpub\wwwroot\rdoapp` / `:80` — **intocado**.

---

## Decisões L1 (fixas)

1. **Nova** EC2 Amazon Linux 2023 na mesma VPC/SG (`sg_Equipamentos`) — preferir subnet `subnet-c1a2ffa9` (us-east-2a) ou outra AZ da VPC com rota ao ALB.
2. **Não** co-hospedar na EC2 Loja `i-0af4ef47531a19acb` (Name **PHP**, `t2.micro`, ALB **Loja-RDO**) — inventário [`docs/migracao/infraestrutura-nuvem-aws-rdo.md`](../docs/migracao/infraestrutura-nuvem-aws-rdo.md).
3. Publish: `dotnet publish -c Release -r linux-x64 --self-contained true` (paridade com W1 `win-x64`).
4. Runtime: **Kestrel** direto na 5081 + **systemd** (`rdoapp-core-homolog.service`) — sem nginx (ALB termina TLS).
5. Deploy: S3 zip + SSM `AWS-RunShellScript` (scripts Fase 2).
6. Cutover: registrar Linux no TG → healthy → desregistrar Windows **só** da 5081.
7. Rollback: re-registrar `i-05cb0003c031a26da:5081`; `systemctl stop` na Linux se preciso.

---

## Etapa A — Provisionar EC2 (Lucio · Fase 1)

Checklist console / CLI:

1. Launch **Amazon Linux 2023** · VPC `vpc-ea507a82` · SG `sg-0949364ef36d38331` · IAM `NewInstanceRole`.
2. Confirmar **SSM Agent Online** (Systems Manager → Fleet Manager).
3. Criar `/var/www/rdoapp_core` · dono adequado ao serviço.
4. Copiar `appsettings.Staging.json` do Windows (não versionar).
5. Unit systemd (rascunho — ajustar paths na Fase 2):

```ini
[Unit]
Description=RdoApp.Core homolog (Kestrel 5081)
After=network.target

[Service]
WorkingDirectory=/var/www/rdoapp_core
ExecStart=/var/www/rdoapp_core/RdoApp.Core
Restart=always
RestartSec=5
Environment=ASPNETCORE_ENVIRONMENT=Staging
Environment=ASPNETCORE_URLS=http://0.0.0.0:5081
# User=… (definir na Fase 1)

[Install]
WantedBy=multi-user.target
```

6. **Ainda não** registrar no TG.
7. Anotar **InstanceId** Linux → colar abaixo e no `roteiro-deploy-homolog-operador.md`.

| Campo | Valor |
|-------|--------|
| InstanceId Linux | **`i-0776acb09b8438f22`** |
| Private IP Linux | **`172.31.2.111`** |
| AMI / tipo | AL2023 `ami-0e3ea3dc6b356c29a` · **t3.small** · Name `rdoapp-core-homolog-linux` |
| Subnet / SG | `subnet-c1a2ffa9` · `sg-0949364ef36d38331` |
| TG | **ainda não** registrado (só após smoke deploy) |

---

## Etapa B — Publish + deploy (Fase 2)

| Artefato | Função |
|----------|--------|
| `scripts/launch-homolog-linux-ec2.ps1` | Provisiona AL2023 (já usado → `i-0776acb09b8438f22`) |
| `scripts/publish-homolog-linux.ps1` | npm build client + `dotnet publish -r linux-x64` → `publish/rdoapp_core_linux.zip` |
| `scripts/ec2-apply-rdoapp-core-linux.sh` | Extrai zip · preserva Staging · `systemctl restart` · smoke localhost **e** IP privado |
| `scripts/deploy-homolog-linux-ssm.ps1` | Upload S3 + SSM `AWS-RunShellScript` |

**Pré:** `appsettings.Staging.json` em `/var/www/rdoapp_core/` (copiar do Windows; apply **não** cria secrets).

**AWS**

```powershell
aws login --remote
```

```powershell
aws sts get-caller-identity --region us-east-2
```

**Scripts**

```powershell
cd C:\Dev\Migration2Core\RDO-CleanMigration-2026\scripts; .\publish-homolog-linux.ps1
```

```powershell
cd C:\Dev\Migration2Core\RDO-CleanMigration-2026\scripts; .\deploy-homolog-linux-ssm.ps1 -S3Bucket s3rdoapp -InstanceId i-0776acb09b8438f22
```

---

## Etapa C — Cutover TG (Fase 3)

1. Smoke SSM Linux: Login **200** em `127.0.0.1:5081` e `http://<IP-privado>:5081/Account/Login`.
2. Ajustar health check do TG se ainda unhealthy por 302 (ver inventário).
3. Register target Linux `:5081` → aguardar **healthy**.
4. Deregister Windows `i-05cb0003c031a26da:5081`.
5. Browser: `https://homolog.sistema.rdoapp.com.br/Account/Login` → Escolher → Cards · O4/O5 rápido.

**Rollback:** register Windows de novo no TG; stop unit Linux.

---

## Segurança

- Não commitar `appsettings.Staging.json` / senhas SMTP.
- Não alterar site prod `:80` / pasta `rdoapp`.
- Não dropar `homol_rdoapp`.
- Um único listener na **5081** na instância Linux (só Kestrel).

---

## Próximo após este rascunho

1. Fase 1 — Lucio provisiona EC2 + preenche InstanceId nesta tabela.  
2. Fase 2 — agente cria os 3 scripts + endurece este doc.  
3. Fase 3 — piloto + cutover.
