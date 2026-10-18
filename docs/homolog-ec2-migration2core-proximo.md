# Homolog EC2 — Migration2Core (próximo passo)

**Objetivo:** URL na nuvem (EC2) para você **ver e dar OK** no fluxo Fase 0 — não localhost como homolog oficial.

**Política de banco:** A fechado (catálogo homolog compartilhado). Na EC2 do SaaS a conexão RDS homolog costuma funcionar **dentro da VPC** (sem depender do IP da sua casa).

---

## O que muda na cabeça

| Camada | Papel |
|--------|--------|
| **Dev local** | Cursor/`dotnet run` — opcional, para codar |
| **Homolog (seu OK)** | Site `RdoApp.Core` na **EC2** + URL |
| **Produção** | Legado `Equipamentos` / `sistema.rdoapp.com.br` — intocado |

---

## Pré-requisitos (decidir com você)

| # | Decisão | Opções |
|---|---------|--------|
| 1 | **Onde hospedar** | **Decidido (2026-10-17): mesma EC2 do sistema** — subdomínio ou path (nome URL pendente) |
| 2 | **URL** | **Confirmar nome existente** (Lucio: provável subdomínio já criado) — ver §Inventário DNS abaixo; senão path ou novo vhost só para `RdoApp.Core` |
| 3 | **Runtime** | Kestrel + Nginx/Caddy na EC2, ou IIS se já existir |
| 4 | **Secrets** | Connection string homolog + `ASPNETCORE_ENVIRONMENT=Staging` no servidor (não no Git) |
| 5 | **Deploy** | SSM + `git pull` + `dotnet publish` (padrão similar Loja) ou pipeline GitHub |

---

## Inventário DNS / docs (2026-10-17)

| Host | Evidência no repo | DNS (checagem externa) |
|------|-------------------|-------------------------|
| `sistema.rdoapp.com.br` | Produção Equipamentos | **Ativo** (A → EC2 us-east-2) |
| `homolog.loja.rdoapp.com.br` | ALB `loja-rdo-*` | Ativo (referência DNS) |
| **`homologacao.piscinas.rdoapp.com.br`** | ALB **`sistema-rdo-67414…`** | **Homolog web sistema/obras hoje** |
| `homolog.sistema.rdoapp.com.br` | — | **Ausente** na Route 53 — criar opcional; doc [`aws-route53-rdoapp-dns-homolog-tecnico.md`](aws-route53-rdoapp-dns-homolog-tecnico.md) |
| Subdomínios flat (`sistema-homolog`, etc.) | Docs antigos | Não usados neste padrão |
| Homolog **dados** (`piscinas_rdoapp_homologa`) | Vários `Web.config` / Kiro | RDS (não é URL) |

**Conclusão:** é plausível existir vhost ou subdomínio **só na EC2/Registro.br** sem estar versionado no Git — ou homolog legado era **mesmo host + banco homolog** sem DNS separado. **Próximo passo:** você confirma a URL que lembra (favorito, certificado, painel Registro.br) **ou**, com autorização SSM, listar sites Nginx/IIS na EC2 do sistema.

**Migration2Core:** pode **reutilizar** subdomínio/vhost existente (outro path/porta) ou **criar** entrada nova (ex. `core-homolog…`) sem mexer em `sistema.rdoapp.com.br`.

---

## Entrega mínima (MVP homolog EC2)

1. `dotnet publish` Release → pasta no servidor  
2. Serviço systemd (Linux) ou site IIS apontando para Kestrel  
3. HTTPS (cert existente ou Let's Encrypt no subdomínio)  
4. Smoke: `/Account/Login` → Escolher → Cards  
5. Você marca **OK** no checklist (mesmo fluxo E2E, URL cloud)

---

## Checklist E2E (mesmo fluxo, URL EC2)

Usar [`e2e-fase0-checklist.md`](e2e-fase0-checklist.md) trocando a base URL de `localhost:7176` pela **URL homolog EC2**.

---

## Ordem sugerida — “e agora?” (atualizado 2026-10-17)

**RDS fechado:** `homol_rdoapp` com **47** tabelas (= `novo_rdoapp`). E2E login já validado com catálogo + URL homolog; falta **publish/deploy** alinhado ao schema novo (`historico_login`, etc.).

1. **Publish** na máquina dev: `DEPLOY-HOMOLOG-EC2.md` + `scripts/publish-homolog-ec2.ps1` → zip/pasta `homolog-ec2`.  
2. **EC2** (`homologacao\rdoapp_core`): extrair publish; **não** sobrescrever `appsettings.Staging.json` (manter `database=homol_rdoapp`).  
3. **Reiniciar Core** com `Staging` + porta **5081**.  
4. **E2E:** [`e2e-fase0-checklist.md`](e2e-fase0-checklist.md) — CPF `53821963549` / `1234`; confirmar UI Equipamentos e gravação em `historico_login`.  
5. **GitHub / CI:** repo **Migration2Core** — [`PLANO-CI-HOMOLOG-EC2.md`](https://github.com/RDO-APP/Migration2Core/blob/main/RDO-CleanMigration-2026/PLANO-CI-HOMOLOG-EC2.md) (OIDC + S3 + SSM; homolog only). Docs RDS: [`rds-equipamentos-governanca-catalogos.md`](rds-equipamentos-governanca-catalogos.md) §5.  
6. **Serviço persistente + HTTPS** homolog (não depender de processo manual).  
7. **OK registrado** → CI homolog + Onda 1.

---

## Localhost até lá

Não bloqueia homolog EC2. Se quiser dev local, ainda depende de **3306** do seu IP ao RDS; na EC2 esse passo muitas vezes **não existe** (app e RDS na mesma nuvem).
