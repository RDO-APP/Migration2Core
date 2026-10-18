# Trilha Core homolog — clique a clique (3 etapas)

**Decisão (2026-10-17):** publicar **`RdoApp.Core`** primeiro na **EC2 Windows atual** `(Equipamentos)` · porta **5081** · URL **`https://homolog.sistema.rdoapp.com.br`**.  
**Depois (gatilho L1):** migrar homolog app para **EC2 Linux dedicada** — mesma URL/TG; ver [`plano-preparacao-migracao-homolog.md`](plano-preparacao-migracao-homolog.md) **§11**.

**Canônico deploy:** `C:\Dev\Migration2Core\RDO-CleanMigration-2026\DEPLOY-HOMOLOG-EC2.md`

---

## Mapa das 3 etapas (Windows — agora)

| Etapa | Onde | Resultado |
|-------|------|-----------|
| **1** | **Seu PC** | Pasta `publish\homolog-ec2` gerada |
| **2** | **EC2** (SSM/RDP) | Arquivos em `C:\inetpub\wwwroot\homologacao\rdoapp_core` + secrets |
| **3** | **EC2** (IIS) + browser | Site **5081** = Core · login Equipamentos · TG **Healthy** |

**Infra AWS (Fases 1–4):** já feita — [`plano-homolog-sistema-clique-a-clique.md`](plano-homolog-sistema-clique-a-clique.md).

---

## Etapa 1 — Publish no seu PC {#etapa-1}

**Tempo:** ~5–15 min (primeira vez pode baixar runtime no publish self-contained).

### 1.1 Abrir PowerShell

1. Tecla Windows → digite **`PowerShell`**.
2. Abra **Windows PowerShell** (não precisa “Executar como administrador”).

### 1.2 Ir para a pasta de scripts

Cole e Enter:

```powershell
cd C:\Dev\Migration2Core\RDO-CleanMigration-2026\scripts
```

| Se der erro “caminho não encontrado” | Ação |
|--------------------------------------|------|
| Pasta não existe | Clone/atualize o repo: `git pull` em `C:\Dev\Migration2Core` |
| Repo em outro disco | Ajuste o `cd` para o caminho real dos `scripts` |

### 1.3 (Opcional) Conferir SDK

```powershell
dotnet --version
```

Precisa de SDK compatível com **`net10.0`** (projeto `RdoApp.Core`). Se falhar, instale [.NET SDK](https://dotnet.microsoft.com/download).

### 1.4 Rodar o publish

```powershell
.\publish-homolog-ec2.ps1
```

| Mensagem | Significado |
|----------|-------------|
| **`Publish OK.`** (verde) | Etapa 1 concluída → **Etapa 2** |
| Erro de build | Copie o erro e pare — corrigir antes de copiar para EC2 |
| “scripts desabilitados” | Rode uma vez: `Set-ExecutionPolicy -Scope Process Bypass` e repita 1.4 |

### 1.5 Conferir pasta de saída

```powershell
Get-ChildItem C:\Dev\Migration2Core\publish\homolog-ec2 | Select-Object -First 8 Name
```

Deve listar arquivos como **`RdoApp.Core.exe`**, **`web.config`**, DLLs.

**Pare aqui.** Avise **“Etapa 1 OK”** ou envie o erro — só então seguimos **Etapa 2** (copiar para EC2).

---

## Etapa 2 — Copiar para EC2 (resumo — detalhar na sessão)

**Destino:** `C:\inetpub\wwwroot\homologacao\rdoapp_core`  
**Secrets:** `appsettings.Production.json` **só na EC2** (connection string homolog).

Métodos: RDP, zip + S3, ou SSM — escolher na hora da Etapa 2.

---

## Etapa 3 — IIS + teste (resumo — detalhar na sessão)

1. Parar site **`piscinas_hm`** (5081).
2. Site/pool apontando para **`rdoapp_core`** · `ASPNETCORE_ENVIRONMENT=Staging`.
3. Browser: `https://homolog.sistema.rdoapp.com.br/Account/Login`.
4. Checklist: [`e2e-fase0-checklist.md`](e2e-fase0-checklist.md).

---

## Lembrete Linux (gatilho L1 — não executar antes)

Migrar homolog **app** para **EC2 Linux nova** quando **todos** ocorrerem:

- [ ] **H2** — Core homolog na AWS com smoke test OK  
- [ ] **E2E Fase 0** assinado na URL `homolog.sistema`  
- [ ] (Recomendado) Primeiro teste de **outra pessoa** ou mobile homolog no Core  

**Entrega L1:** doc `DEPLOY-HOMOLOG-LINUX-EC2.md` (a criar) + TG `homolog-5081` registrando instância Linux + desregistrar Windows na 5081.

**Não** migrar Linux antes do gatilho — evita duas frentes (app + infra) ao mesmo tempo.
