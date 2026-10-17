# Homologação local — RdoApp.Core (Migration2Core)

Teste na sua máquina **antes** de commit/push no GitHub. Não há site “Migration2Core” em produção.

## RDS vs banco (nome confuso)

| Conceito | O que é na prática hoje |
|----------|-------------------------|
| **Instância RDS** | Um servidor MySQL na AWS (hostname no legado costuma ser `equipamentos….us-east-2.rds.amazonaws.com`). **Não** existe um RDS só para `Migration2Core`. |
| **Database (catálogo MySQL)** | Um “banco” *dentro* desse servidor — ex.: homolog vs produção são **nomes diferentes**, no **mesmo** RDS ou em instâncias distintas, conforme a operação. |
| **`piscinas_rdoapp_homologa`** | Nome **legado** do catálogo de **homologação** (histórico “piscinas”, mas o schema é o do RDO obras/equipamentos: `colaborador`, `obra`, `tarefa`, …). O spike .NET 8 foi alinhado ao `Web.config` de homolog do legado — **reutiliza** esse catálogo, não cria outro automaticamente. |

**Produção** (`sistema.rdoapp.com.br`, repo `Equipamentos`) aponta para **outro** catálogo (não homolog). **Teste local .NET** hoje = app novo + **mesmo homolog compartilhado** que o legado usa para testes — qualquer escrita afeta o mesmo ambiente de homolog.

**Alternativas** (se quiser isolar a migração): MySQL local/Docker com dump; outro catálogo no mesmo RDS (ex. experimentos citados no repo como `rdoapp_net8_test`); ou RDS dedicado — exige decisão sua + backup. Nada disso está ligado por padrão no `appsettings` atual.

## Pré-requisitos

- [.NET 8 SDK](https://dotnet.microsoft.com/download)
- Rede até o RDS AWS (VPN/firewall corporativo, se aplicável)
- Visual Studio 2022 **ou** CLI (`dotnet`)

## Caminho do projeto

```
C:\Dev\Migration2Core\RDO-CleanMigration-2026\RDO-CleanMigration-2026\RdoApp.Core
```

Solução: `RDO-CleanMigration-2026.sln` (pasta pai).

## Subir o app (CLI)

```powershell
cd C:\Dev\Migration2Core\RDO-CleanMigration-2026\RDO-CleanMigration-2026\RdoApp.Core
dotnet restore
dotnet build
dotnet run --launch-profile https
```

URLs (ver `Properties/launchSettings.json`):

| Perfil | URL |
|--------|-----|
| https | https://localhost:7176 |
| http | http://localhost:5229 |

Entrada sugerida: `/Account/Login`

Visual Studio: projeto **RdoApp.Core** como startup, perfil **https**, F5. Detalhes: `HOW-TO-RUN-IN-VISUAL-STUDIO.md`.

## Connection string (local)

O app lê `ConnectionStrings:DefaultConnection` (ordem usual: User Secrets → `appsettings.{Environment}.json` → `appsettings.json`).

### Opção A — rápida (só na sua máquina)

Manter a string em `appsettings.json` **não versionada** ou em arquivo local ignorado pelo git. **Não** fazer push com senha no repositório.

### Opção B — recomendada antes do GitHub (User Secrets)

`UserSecretsId` já está no `.csproj`. Defina a connection string uma vez:

```powershell
cd C:\Dev\Migration2Core\RDO-CleanMigration-2026\RDO-CleanMigration-2026\RdoApp.Core

dotnet user-secrets set "ConnectionStrings:DefaultConnection" "Server=SEU_HOST;Database=piscinas_rdoapp_homologa;User=...;Password=...;SslMode=None;"
```

Modelo de chaves (sem segredos): `appsettings.example.json`.

Depois, em `appsettings.json` commitável, use placeholder ou remova `Password=` — o override dos User Secrets prevalece localmente.

Listar (sem imprimir valor completo no terminal compartilhado):

```powershell
dotnet user-secrets list
```

## Flags de desenvolvimento

Em `appsettings.Development.json`:

```json
"Migration": {
  "DisableAssinaturaCheck": true
}
```

Isso evita bloqueio por assinatura Loja durante a migração. **Não** use em produção.

## Checklist manual — Fase 0 (seleção de obra)

1. Abrir `/Account/Login` — página carrega (CSS/fontes: se header quebrado, copiar assets do legado conforme plano Kiro).
2. Login com usuário de **homolog** (CPF/senha que você já usa no ambiente de testes).
3. Redirecionamento para **Escolher obra** (`/Obra/Escolher`).
4. Selecionar uma obra → POST `Obra/Selecionar` → sessão preenchida (LoginObra).
5. Destino esperado: **`/Tarefa/Cards`** (placeholder da Fase 0).
6. `/` (Home) deve respeitar obra na sessão (ir para Cards ou Escolher).

Erros de permissão/obra: mensagens via `TempData` na view Escolher.

## Script auxiliar

```powershell
.\scripts\test-local.ps1
```

Faz `restore` + `build` e imprime URLs + checklist. Não inicia o servidor em background (use `dotnet run` em outro terminal).

## Antes do push (GitHub)

1. Connection string só em **User Secrets** ou CI (GitHub Actions secrets) — ver `appsettings.example.json`.
2. Revisar `git diff` — nenhum `Password=` real em arquivos tracked.
3. Branch sugerida: `migracao-retomada-2026` (não `main` direto até revisão).
4. Repositório: `https://github.com/RDO-APP/Migration2Core` (não confundir com `RDO-APP/Equipamentos` / `sistema.rdoapp.com.br`).

## O que este teste **não** cobre

- Deploy EC2 / IIS / Docker
- Mobile Apontador
- Integração Loja pós-compra (assinatura real com `DisableAssinaturaCheck: false`)

Esses passos entram em ondas posteriores da migração.
