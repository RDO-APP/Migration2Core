# Homolog — Obras `/Obra/Index` ações (convite / copiar)

**Trilha:** EQ-R · **Página:** menu ☰ Obras · SPA `ObraIndexPage` · BFF `GET /api/bff/obras/index/bootstrap`  
**Usuário smoke:** CPF `538.219.635-49` · Diretor Contratada · Georges `824.351.035-49`  
**Prod ref:** `Client/Views/Obra/index.html` — `fa-send` · `fa-copy` · `fa-edit` · `fa-trash-o`  
**Host L1:** `i-0776acb09b8438f22` · `homolog.sistema.rdoapp.com.br`

---

## Tentativas (data/hora Brasília)

| # | Data/hora | Sintoma / hipótese | Solução | Resultado |
|---|-----------|--------------------|---------|-----------|
| **O1** | 2026-11 (pré-L1) | Ações faltavam — GPA só `/obra/index` | `PermissionHelper` + `/obra/index` | Só editar + excluir |
| **O2** | 2026-11 | GPA canônico `/obra/lista` | `CanObraLista` index∪lista + BFF | Botões no DOM; ícones invisíveis |
| **O3** | 2026-11-11 | FA sem `fa-send`/`fa-copy` | Glifos em `escolher.css` | **Smoke OK** — 4 ícones |
| **O4** | 2026-11-19 | Erro 500 ao enviar convite | try/catch BFF + `SmtpMailService` + Guid hífens | Código ☑ — smoke adiado L1 |
| **O5** | **2026-11-20 ~09:08** | Copiar obra | `BuildCopiaAsync` + SPA `?copiar=` | **Smoke OK** (L1) |
| **O4b** | **2026-11-20 ~09:10** | `Unable to cast DBNull → String` no Convite (obra Feira de Santana) | Select parcial + `ExecuteUpdateAsync` `ObrCdConvite` | Deploy SSM **Success** `e97e6e39…` ~**09:19–09:24** |
| **O4c** | **2026-11-20 ~09:26** | `Smtp:Host não configurado` | — | Sintoma |
| **O4d** | **2026-11-20 ~09:32** | Staging Windows **sem** seção `Smtp` | SMTP nunca no Staging — igual **E1** | Fonte `Web.config` → adicionar `Smtp` na Linux |
| **O4e** | **2026-11-20 ~09:41** | Staging edit + restart → **active**; grep Host OK | — | Arquivo tem Smtp |
| **O4f** | **2026-11-20 ~09:43** | Ainda `Smtp:Host não configurado` | `Smtp` estava **dentro** de `Migration` (grep achava Host; root sem chave Smtp) | — |
| **O4g** | **2026-11-20 ~09:47** | JSON root com **Smtp** OK · Host `smtp.rdoapp.com.br` | restart active | — |
| **O4h** | **2026-11-20 ~09:49** | Browser `ERR_TOO_MANY_REDIRECTS` Login↔`/Home/Error` | **Não** é publish | — |
| **O4i** | **2026-11-20 ~09:56** | `Access denied` rdoadmin @ Linux | Senha RDS Staging errada ao editar Smtp | — |
| **O4j** | **2026-11-20 ~10:01** | Senha RDS corrigida · Login `curl` **200** | Site de volta | ☑ |
| **O4k** | **2026-11-20 ~10:02** | `Failure sending mail.` | Porta **25** refused; **587** OK | Trocar Staging Port 587 + EnableSsl true |
| **O4l** | **2026-11-20 ~10:07** | Crash JSON (`truee` / `'e' invalid`) · Login **000** | Typo no `EnableSsl` | — |
| **O4m** | **2026-11-20 ~10:09** | JSON_OK · Smtp `587`/`true` · Login **200** · service active | Staging OK (porta 587) | — |
| **O4n** | **2026-11-20 ~10:11** | Ainda `Failure sending mail.` (TCP 587 OK) | Auth/TLS pós-connect · toast sem InnerException | — |
| **O4o** | **2026-11-20 ~10:15** | `journalctl` sem SmtpException (só Login/Obras) | BFF engole erro no toast | — |
| **O4p** | **2026-11-20 ~10:17** | smtplib `535 authentication failed` · User/From/PassSet OK · 587+SSL | Locaweb rejeitou AUTH | — |
| **O4q** | **2026-11-20 ~10:20** | Lucio: Staging Password “ok” (visual) | Staging len**13** ≠ Web.config len**10** (sha ≠) | — |
| **O4r** | **2026-11-20 ~10:28** | Staging = Web.config (`len 10` / `a070…`) | smtplib ainda **535** | Web.config senha **rejeitada** pela Locaweb |
| **O4s** | **2026-11-20 ~10:29** | 535 com senha canônica do repo | Caixa desatualizada / senha só no IIS prod | — |
| **O4t** | **2026-11-20 ~10:31** | user `convite` (sem @) também **535** | Senha Web.config morta na Locaweb | — |
| **O4u** | **2026-11-20 ~10:40** | Locaweb: senha `convite@` realinhada ao Web.config | smtplib **SMTP_AUTH_OK** 587+STARTTLS | ☑ restart · Login **200** |
| **O4v** | **2026-11-20 ~10:43** | Browser ainda `Failure sending mail.` (AUTH Python OK) | Deploy ainda **sem** unwrap InnerException / `UseDefaultCredentials=false` | ☑ publish unwrap |
| **O4w** | **2026-11-20 ~11:09** | Toast: `RemoteCertificateNameMismatch` · Ssl=True :587 | Cert TLS = **`*.email-ssl.com.br`** (Locaweb) | ☑ Host→`email-ssl.com.br` |
| **O4x** | **2026-11-20 ~11:20** | Enviar Convite + e-mail Gmail OK · link `/convidada?o=` | Host SMTP Locaweb OK | ☑ **SMTP fechado** |
| **O4y** | **2026-11-20 ~15:25** | Aceite `/convidada` C4 | Contratante → Escolher · Diretor Contratante MIGRAÇÃO 15/11 | ☑ **C4 PASS** |

---



## O4c — SMTP na Linux (ops · Lucio)

Convite e Esqueci senha usam as mesmas chaves:

```text
Smtp:Host
Smtp:Port          (default 587)
Smtp:EnableSsl     (default true)
Smtp:FromEmail / Smtp:FromName
Smtp:User
Smtp:Password
```

Arquivo **só na EC2:** `/var/www/rdoapp_core/appsettings.Staging.json`  
Modelo: Windows `C:\inetpub\wwwroot\homologacao\rdoapp_core\appsettings.Staging.json` (se ainda tiver Smtp).

**Conferir sem vazar senha** (SSM):

```powershell
aws ssm send-command --region us-east-2 --instance-ids i-0776acb09b8438f22 --document-name AWS-RunShellScript --parameters "commands=[\"test -f /var/www/rdoapp_core/appsettings.Staging.json && echo STAGING_OK || echo STAGING_MISSING\",\"grep -E '\\\"Host\\\"|\\\"Smtp\\\"' /var/www/rdoapp_core/appsettings.Staging.json | sed 's/\\\"Password\\\"[^,}]*/\\\"Password\\\":\\\"***\\\"/g' | head -20\"]" --output text --query Command.CommandId
```

Depois (troque `COMMAND_ID`):

```powershell
aws ssm get-command-invocation --region us-east-2 --command-id COMMAND_ID --instance-id i-0776acb09b8438f22 --query StandardOutputContent --output text
```

Se `Host` vazio/ausente: copiar bloco `Smtp` do Windows Staging → Linux Staging → `sudo systemctl restart rdoapp-core-homolog` → retestar Convite (~mesmo horário do smoke).

**Não** commitar `appsettings.Staging.json`.

---

## Smoke pós-O4 / O5

### Convite (O4)

1. Obra com só contratante **ou** só contratada → Enviar Convite → toast sucesso **ou** SMTP claro.  
2. Obra com **ambas** → *Já existe empresa…*  
3. E-mail inválido → validação sem 500.  
4. `/convidada` → stub (**esperado**).

### Copiar (O5) — ☑ 20/11 ~09:08 · clone listas ☑ código 23/11

**Clone listas (23/11):** `CreateAsync` + `IdObraOrigemCopia` → `obra_colaborador` (exceto criador) + `obra_equipamento` da origem. Smoke: Copiar → Salvar → Index/cadastro da nova obra com time/frota.  

**Fora O4 SMTP:** aceite `/convidada` — [`homolog-convidada-aceite.md`](homolog-convidada-aceite.md).
