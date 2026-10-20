# E2E Fase 0 — Checklist (Migration2Core)

**Marco:** **M3** · Runbook: [`migracao/m3-execucao-runbook.md`](migracao/m3-execucao-runbook.md)  
**Homolog Equipamentos (Core / `homol_rdoapp`):** autorizado 2026-10-17  
**Schema RDS:** **47** tabelas (= prod) desde DDL 2026-10-17 — validar login grava `historico_login` após redeploy Core.  
**Fluxo:** Login → Escolher obra → POST Selecionar → `/Tarefa/Cards` (**React** + `/api/bff/etapas`)

**Smoke informal (2026-10-19, pré-M3 formal):** obra 42 · 3 etapas · 13 cards — repetir e assinar tabela abaixo para **M3 FECHADO**.

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
| 1 | Abrir URL Login homolog **ou** localhost — página carrega | ☑ | | 2026-10-19 | `homolog.sistema…/Account/Login` (HTTP homolog) |
| 2 | Login com usuário homolog | ☑ | | 2026-10-19 | CPF Equipamentos § acima |
| 3 | Redireciona para `/Obra/Escolher` | ☑ | | 2026-10-19 | |
| 4 | Lista exibe obras (>0 ou esperado) | ☑ | | 2026-10-19 | 7 obras em grid |
| 5 | Selecionar obra → `/Tarefa/Cards` | ☑ | | 2026-10-19 | Obra **42** · React C3 · 3 etapas · 13 tarefas · BFF OK |
| 6 | `/` (Home) respeita sessão (Cards ou Escolher) | | | | não testado nesta rodada |
| 7 | Logout e novo login repetem fluxo | | | | opcional |

**Resultado geral:** ☑ **PASS** (gate M3: passos 1–5) · ☐ FAIL — responsável: **Lucio Félix** · 2026-10-19

**Ressalva (não reprova M3):** paridade **gráfica** (header unificado, layout prod) e **página 4 Nova medição** ficam **fora** deste gate — ver orquestrador gap #1 · M4 · M7+.

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
