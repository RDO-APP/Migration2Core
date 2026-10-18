# E2E Fase 0 — Checklist (Migration2Core)

**Homolog Equipamentos (Core / `homol_rdoapp`):** autorizado 2026-10-17  
**Schema RDS:** **47** tabelas (= prod) desde DDL 2026-10-17 — validar login grava `historico_login` após redeploy Core.  
**Fluxo:** Login → Escolher obra → POST Selecionar → `/Tarefa/Cards`

### Usuários de teste homolog RDS (Lucio — só homolog)

| Vertical | CPF | Senha | Catálogo esperado |
|----------|-----|-------|-------------------|
| **Piscinas** | `567.065.455-20` | `1234` | `piscinas_rdoapp_homologa` |
| **Equipamentos** | `538.219.635-49` | `1234` | `homol_rdoapp` (Core `homolog.sistema`) |

Não commitar connection strings com senha de produção.

---

## Pré-voo

| # | Item | OK | Falha | Notas |
|---|------|:--:|:-----:|-------|
| P1 | `dotnet build` no `RdoApp.Core` | | | |
| P2 | Connection string homolog configurada (User Secrets ou local) | | | |
| P3 | Teste TCP/host RDS a partir do PC (VPN se usar) | | | Ver §Conectividade abaixo |
| P4 | Fontes em `wwwroot/fonts` (opcional visual) | | | README Kiro — copiar do legado se header quebrado |

---

## Checklist E2E

**Homolog EC2 (M0):** `https://homolog.sistema.rdoapp.com.br/Account/Login` — CPF Equipamentos § acima.

**Local dev:** `https://localhost:7176/Account/Login`

| # | Passo | OK | Falha | Data | Notas |
|---|--------|:--:|:-----:|------|-------|
| 1 | Abrir URL Login homolog **ou** localhost — página carrega | | | | |
| 2 | Login com usuário homolog | | | | CPF/senha seus de teste |
| 3 | Redireciona para `/Obra/Escolher` | | | | |
| 4 | Lista exibe obras (>0 ou esperado) | | | | |
| 5 | Selecionar obra → `/Tarefa/Cards` | | | | |
| 6 | `/` (Home) respeita sessão (Cards ou Escolher) | | | | |
| 7 | Logout e novo login repetem fluxo | | | | opcional |

**Resultado geral:** ☐ PASS · ☐ FAIL — responsável: ___________

---

## Conectividade (se `Connect Timeout expired`)

1. Confirmar **VPN** ou rede que já funciona para legado homolog / MySQL Workbench.  
2. PowerShell (só teste de rede — **não** expõe senha):

```powershell
Test-NetConnection equipamentos.cslrikufb7hm.us-east-2.rds.amazonaws.com -Port 3306
```

`TcpTestSucceeded : True` → app deve conectar se user/senha/catálogo corretos.  
`False` → security group RDS, IP residencial, ou firewall — ajuste AWS/ops antes do E2E.

3. Security group do RDS: seu IP público (ou VPN) liberado na porta **3306**.

---

## Subir o app

```powershell
cd C:\Dev\Migration2Core\RDO-CleanMigration-2026\RDO-CleanMigration-2026\RdoApp.Core
dotnet run --launch-profile https
```

---

## Registro automático (Cursor agent 2026-10-17)

- Build local: **OK**
- App listening: `https://localhost:7176`
- Login via agent: **Falha** — `MySqlException: Connect Timeout expired` (agente sem rota ao RDS; **não** invalida teste na sua máquina)

---

## Links

- `docs/plano-preparacao-migracao-homolog.md` — política A, riscos  
- `Migration2Core/.../HOMOLOGACAO_LOCAL.md` — guia local  
