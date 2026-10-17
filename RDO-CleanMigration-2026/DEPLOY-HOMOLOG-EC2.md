# Deploy homolog EC2 — RdoApp.Core

**URL:** `https://homolog.sistema.rdoapp.com.br`  
**Fase W1 (atual):** EC2 **Windows** `(Equipamentos)` · IIS porta **5081** · TG `tg-equipamentos-homolog-5081`  
**Fase L1 (depois):** EC2 **Linux** dedicada — **mesma URL/TG** após gatilho G1–G2 em `Equipamentos/docs/plano-preparacao-migracao-homolog.md` **§11**.  
**Banco:** catálogo homolog compartilhado (política A) — connection string **só na EC2**, nunca no Git.

**Clique a clique (3 etapas):** `Equipamentos/docs/trilha-core-homolog-clique-a-clique.md`  
Infra AWS: `Equipamentos/docs/plano-homolog-sistema-clique-a-clique.md`.

---

## Visão

```text
Browser → ALB (HTTPS) → EC2:5081 (IIS + RdoApp.Core) → RDS homolog
```

Substitui o site legado **`piscinas_hm`** na mesma porta (Piscinas deixa de ser a home).

---

## Etapa 1 — Publish na sua máquina (Lucio)

PowerShell:

```powershell
cd C:\Dev\Migration2Core\RDO-CleanMigration-2026\scripts
.\publish-homolog-ec2.ps1
```

Saída: `C:\Dev\Migration2Core\publish\homolog-ec2\` (inclui `RdoApp.Core.exe`, `web.config`, etc.).

Requisito: [.NET SDK](https://dotnet.microsoft.com/download) compatível com o projeto (`net10.0` no `.csproj`).

---

## Etapa 2 — Copiar arquivos para a EC2

Escolha **uma** forma:

| Método | Quando usar |
|--------|-------------|
| **SSM** + pasta zipada no S3 | Sem RDP |
| **RDP** + rede compartilhada / pen drive | Mais simples para 1º deploy |
| **`git pull` na EC2** + publish no servidor | Depois que Git/dotnet estiver na EC2 |

**Pasta destino na EC2 (criar se não existir):**

`C:\inetpub\wwwroot\homologacao\rdoapp_core`

**Não** sobrescrever `C:\inetpub\wwwroot\rdoapp` (produção).

---

## Etapa 3 — Connection string na EC2 (sem Git)

Na EC2, crie **somente no servidor**:

`C:\inetpub\wwwroot\homologacao\rdoapp_core\appsettings.Production.json`

Modelo (preencha com o mesmo host/catálogo homolog do legado — copie do `Web.config` homolog ou Parameter Store):

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=SEU_RDS;Database=piscinas_rdoapp_homologa;User=...;Password=...;SslMode=None;"
  }
}
```

Alternativa: variáveis de ambiente no **Application Pool** do IIS (`ConnectionStrings__DefaultConnection`).

---

## Etapa 4 — IIS (uma vez)

Objetivo: porta **5081** serve **RdoApp.Core**, não Piscinas.

1. **IIS Manager** → site **`piscinas_hm`** → **Stop** (ou renomear depois).
2. Criar site **`homolog_sistema`** (ou reutilizar `piscinas_hm` trocando só o caminho):
   - **Physical path:** `C:\inetpub\wwwroot\homologacao\rdoapp_core`
   - **Binding:** `http`, port **5081**, IP **All Unassigned**, host name **vazio** (ALB já filtra Host).
3. **Application pool** dedicado (ex. `RdoAppCoreHomolog`):
   - **.NET CLR version:** **No Managed Code**
   - **Start Mode:** AlwaysRunning (opcional)
4. Variável de ambiente do pool:
   - `ASPNETCORE_ENVIRONMENT` = **`Staging`**
5. **Start** o site.

Self-contained publish não exige Hosting Bundle; se usar publish framework-dependent, instale **ASP.NET Core Runtime** correspondente ao `TargetFramework`.

---

## Etapa 5 — Testes

| Onde | URL / ação |
|------|------------|
| EC2 (SSM) | `(Invoke-WebRequest http://127.0.0.1:5081/Account/Login -UseBasicParsing).StatusCode` → **200** |
| AWS | TG **homolog-5081** → **Healthy** |
| Browser | `https://homolog.sistema.rdoapp.com.br/Account/Login` (certificado pode avisar até ACM — Fase 3) |

Checklist E2E: repo Equipamentos `docs/e2e-fase0-checklist.md` (base URL = homolog.sistema).

---

## Etapa 6 — HTTPS (ACM)

Incluir **`homolog.sistema.rdoapp.com.br`** no certificado do listener **Sistema-RDO** (ou wildcard). Ver `docs/plano-homolog-sistema-clique-a-clique.md` Fase 3.

---

## Segurança

- **Não** commitar `appsettings.json` / `Production.json` com senha.
- **Não** alterar site **`rdo`** (prod :80).
- Homolog compartilhado: sem `dotnet ef database drop` / migrations destrutivas.

---

## Problemas comuns

| Sintoma | Causa provável |
|---------|----------------|
| 502 / Unhealthy | Site parado, pool errado, pasta vazia |
| Login não grava cookie | App atrás do ALB — usar build com `UseForwardedHeaders` (Program.cs) |
| Redirect estranho | `UseHttpsRedirection` + ALB — forwarded headers |
| Piscinas na tela | IIS ainda aponta para `piscinas_hm` |

---

## Próximo (automação)

- Workflow GitHub: build + artefato  
- Deploy SSM (pull + publish na EC2)  
- `DisableAssinaturaCheck: false` quando testar Loja (Onda 2)
