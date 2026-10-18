# Governança RDS — catálogos MySQL (instância Equipamentos)

**Instância:** `equipamentos.cslrikufb7hm.us-east-2.rds.amazonaws.com:3306`  
**Conta/região:** RDOApp · us-east-2  
**Atualizado:** 2026-10-17  
**Relacionado:** [`aws-route53-rdoapp-dns-homolog-tecnico.md`](aws-route53-rdoapp-dns-homolog-tecnico.md) §8

Objetivo: classificar cada **catálogo (schema)** em **manter / reformar / investigar / candidato a apagar**, antes de qualquer `DROP DATABASE`.

---

## 1. Legenda de status

| Status | Significado |
|--------|-------------|
| **MANTER** | Produção ou homolog ativo; não apagar |
| **REFORMAR** | Catálogo escolhido para evoluir (schema/dados) — ex. homolog Equipamentos .NET 8 |
| **INVESTIGAR** | Existe no RDS; sem referência clara em EC2/git ou conteúdo desconhecido |
| **ARQUIVAR→APAGAR** | Só após backup + zero referência + Lucio OK — não executar DROP neste doc |

Schemas **mysql / information_schema / performance_schema / sys / innodb** → **MANTER** (sistema; não listar em limpeza).

---

## 2. Matriz proposta (pré-inventário DBeaver)

Evidência EC2 `Web.config` (2026-10-17): `rdoapp` → `novo_rdoapp`; `piscinas` → `piscinas_rdoapp`; `piscinas_hm` → `piscinas_rdoapp_homologa`.

| Catálogo | Status proposto | Produto / função | Evidência hoje | Notas |
|----------|-----------------|------------------|----------------|-------|
| **`novo_rdoapp`** | **MANTER** | Equipamentos **produção** obras | `C:\inetpub\wwwroot\rdoapp\Web.config` | Nunca homolog Core |
| **`piscinas_rdoapp`** | **MANTER** | Piscinas **produção** | `piscinas\Web.config` | Vertical separado |
| **`piscinas_rdoapp_homologa`** | **MANTER** | Piscinas **homolog** | `homologacao\piscinas_hm\Web.config` | Dados CETI/escolas; **não** Equipamentos Core |
| **`rdoapp_loja`** | **MANTER** | Loja produção | Naming padrão | Fora Migration2Core Equipamentos |
| **`rdoapp_loja_homologa`** | **MANTER** | Loja homolog | Naming padrão | Idem |
| **`homol_rdoapp`** | **REFORMAR → MANTER (homolog Core)** | Homolog **Equipamentos** .NET 8 | EC2 `appsettings.Staging.json`; **47** tabelas (pós-DDL 2026-10-17) | **43 obras** subset prod; gêmeo schema de `rdoapp_homologa` (43 tbl) |
| **`rdoapp_homologa`** | **INVESTIGAR** (ou redundante) | Idem `homol_rdoapp` | Só RDS; lista de tabelas **idêntica** a `homol_rdoapp` | Após validação: **fundir** uso em um nome só |
| **`rdoapp_net8_test`** | **INVESTIGAR** | Spike .NET 8? | Citado só em `HOMOLOGACAO_LOCAL.md` como *alternativa* | **Autor/data criação desconhecidos** no git; poucas tabelas — ver inventário §3 |
| **`rdoapp`** | **INVESTIGAR → ARQUIVAR→APAGAR?** | Legado pré-`novo_rdoapp` | `rdoapp_bkp\Web.config` | Só apagar se backup + nenhum job apontando |
| **`RDOApp`** | **INVESTIGAR** | Legado (capitalização) | Só RDS | Comparar tamanho/schema com `rdoapp` |
| **`GilbertoLegacy`** | **INVESTIGAR → ARQUIVAR→APAGAR?** | Cópia pontual Gilberto | Nome explícito | Backup S3/mysqldump antes de qualquer DROP |
| **`Piscinas_Homologa`** | **INVESTIGAR** | Homolog Piscinas alternativo? | Só RDS | Comparar com `piscinas_rdoapp_homologa` (duplicata?) |
| **`tmp`** | **INVESTIGAR → ARQUIVAR→APAGAR?** | Utilitário | Nome | Confirmar vazio / descartável |

### 2.1 `rdoapp_net8_test` — quem criou?

| Fonte | Achado |
|-------|--------|
| Git `Migration2Core` | **Nenhum** script `CREATE DATABASE rdoapp_net8_test` encontrado |
| `HOMOLOGACAO_LOCAL.md` (Kiro/fev/2026) | Menciona **`rdoapp_net8_test`** como exemplo de catálogo experimental — **não** documenta criação |
| EC2 `Web.config` scan | **Nenhuma** referência |
| Conclusão | Provável **`CREATE DATABASE` manual** (dev/Kiro/Gilberto/DBA) ou ferramenta (DBeaver/EF) **sem registro no repo**. Confirmar com quem tinha acesso RDS em 2025–2026; no MySQL **não há** “created by” por schema. |

---

## 3. Inventário técnico (rodar no DBeaver)

### Passo A — tamanho e contagem de tabelas (todos os catálogos app)

```sql
SELECT
  table_schema AS catalogo,
  COUNT(*) AS qtd_tabelas,
  ROUND(SUM(data_length + index_length) / 1024 / 1024, 1) AS mb_aprox
FROM information_schema.tables
WHERE table_type = 'BASE TABLE'
  AND table_schema NOT IN (
    'information_schema', 'mysql', 'performance_schema', 'sys', 'innodb'
  )
GROUP BY table_schema
ORDER BY mb_aprox DESC, catalogo;
```

Inventário **2026-10-17** (query §3 passo A):

| catalogo | qtd_tabelas | mb_aprox | Status proposto | Comentário |
|----------|-------------|----------|-----------------|------------|
| **novo_rdoapp** | 47 | 65.6 | **MANTER** | Prod Equipamentos |
| **Piscinas_Homologa** | 47 | 26.0 | **INVESTIGAR → ARQUIVAR→APAGAR?** | **318 obras** vs **106** em `piscinas_rdoapp` / `piscinas_rdoapp_homologa`; **26 MB**, sem EC2 — homolog Piscinas **antigo/ampliado**, não ligado ao IIS |
| **piscinas_rdoapp_homologa** | 49 | 2.9 | **MANTER** | **106 obras** (= `piscinas_rdoapp` prod); homolog Piscinas ativo (`piscinas_hm`) |
| **rdoapp_loja** | 22 | 12.1 | **MANTER** | Loja prod |
| **homol_rdoapp** | **47** | ~5.0 | **MANTER (homolog Core)** | Schema = prod (47 tbl); **43 obras** vs **284** prod; lookups `efetivo_status` (4) + `tarefa_codigo_paralizacao` (22) copiados de prod |
| **rdoapp_loja_homologa** | 23 | 4.7 | **MANTER** | Loja homolog |
| **piscinas_rdoapp** | 48 | 3.1 | **MANTER** | Piscinas prod; **106 obras** |
| **rdoapp** | 38 | 2.2 | **INVESTIGAR → ARQUIVAR→APAGAR?** | Legado; só `rdoapp_bkp` na EC2 |
| **rdoapp_homologa** | 43 | 2.0 | **INVESTIGAR → ARQUIVAR→APAGAR?** | Só **8 obras** — sandbox mínimo; após adotar `homol_rdoapp`, redundante |
| **rdoapp_net8_test** | 15 | 0.5 | **INVESTIGAR → ARQUIVAR→APAGAR?** | Schema **parcial** (15/47); sem ref EC2/git de criação |
| **GilbertoLegacy** | 2 | 0.0 | **INVESTIGAR → ARQUIVAR→APAGAR?** | 2 tabelas só — snapshot mínimo |

**Não listados** na query (zero tabelas base ou catálogo vazio): conferir na árvore DBeaver se ainda existem `RDOApp`, `tmp` (não entraram no GROUP BY).

| catalogo | qtd_tabelas | mb_aprox | Status revisado (Lucio) |
|----------|-------------|----------|-------------------------|
| *(preencher após decisão)* | | | |

### Passo B — referência em produção/homolog (EC2)

```powershell
Get-ChildItem C:\inetpub\wwwroot -Recurse -Include Web.config,appsettings*.json -ErrorAction SilentlyContinue |
  Select-String -Pattern 'database=' |
  ForEach-Object { "$($_.Path): $($_.Line.Trim())" }
```

Catálogo **sem linha** no passo B → mais provável **INVESTIGAR** ou **ARQUIVAR→APAGAR**.

**Resultado passo B — EC2 `C:\inetpub\wwwroot` (2026-10-17):**

| Catálogo | Site / arquivo (ativo ou template) |
|----------|-------------------------------------|
| **`novo_rdoapp`** | **`rdoapp\Web.config`** (prod Equipamentos :80) · `rdoapp_bkp\Web.config` (cópia ativa AWS) |
| **`piscinas_rdoapp`** | **`piscinas\Web.config`** · `piscinas_backup_20260227` · **`EquipoToPiscinas_hm\Web.config`** |
| **`piscinas_rdoapp_homologa`** | **`homologacao\piscinas_hm\Web.config`** (RDS ativo) · **`homologacao\rdoapp_core\appsettings.Staging.json`** · templates `appsettings.json` / `example` em `rdoapp_core*` |
| **`rdoapp`** | Só **`rdoapp_bkp`** (legado comentado + refs antigas `devbd01` / GoDaddy) |

**Órfãos RDS (nenhuma linha `database=` no scan legado IIS):** `rdoapp_homologa`, `Piscinas_Homologa`, `rdoapp_net8_test`, `GilbertoLegacy`, `rdoapp_loja`, `rdoapp_loja_homologa` — Loja pode usar `Database=` (D maiúsculo); repetir scan se necessário.

**Core homolog (2026-10-17):** `homologacao\rdoapp_core\appsettings.Staging.json` → **`database=homol_rdoapp`** (não `piscinas_rdoapp_homologa`).

**Obs. `piscinas_hm`:** existe trecho com `127.0.0.1` + `piscinas_rdoapp_homologa` (MySQL local) **e** entrada **ativa** para RDS `piscinas_rdoapp_homologa` — conferir qual o app legado usa em runtime.

**Ação Migration2Core:** trocar **`appsettings.Staging.json`** (e templates no publish) de `piscinas_rdoapp_homologa` → catálogo Equipamentos escolhido (§4) **antes** do próximo E2E.

### Passo C — paridade schema com `novo_rdoapp` (homolog candidatos)

**Status 2026-10-17:** **concluído** — `homol_rdoapp` **47** tabelas (= `novo_rdoapp`).

Script versionado (copiar/colar no DBeaver, **um `CREATE` por vez** se Ctrl+Enter só rodar uma linha):  
[`scripts/homol_rdoapp-sync-tables-from-prod.sql`](scripts/homol_rdoapp-sync-tables-from-prod.sql)

Tabelas criadas (estrutura `LIKE` prod): `efetivo`, `efetivo_status`, `historico_login`, `tarefa_codigo_paralizacao`.  
Dados copiados de prod: `efetivo_status` (4 linhas), `tarefa_codigo_paralizacao` (22). `efetivo` e `historico_login` **vazias** (OK homolog).

Conferência só Equipamentos (ignora Piscinas na mesma instância):

```sql
SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_schema IN ('homol_rdoapp', 'novo_rdoapp')
  AND table_name IN ('efetivo', 'efetivo_status', 'historico_login', 'tarefa_codigo_paralizacao')
  AND table_type = 'BASE TABLE'
ORDER BY table_schema, table_name;
```

---

## 4. Decisões pendentes (Equipamentos / Migration2Core)

1. **Catálogo alvo homolog Equipamentos .NET 8:** **`homol_rdoapp`** — **fechado** (schema 47 tbl + E2E login 2026-10-17). Manter EC2: `appsettings.Staging.json` → `database=homol_rdoapp`.
2. **Duplicatas:** `homol_rdoapp` × `rdoapp_homologa`; `Piscinas_Homologa` × `piscinas_rdoapp_homologa`.
3. **`rdoapp_net8_test`:** se inventário §3 mostrar schema incompleto e zero uso → **ARQUIVAR→APAGAR**; se quiser sandbox limpo, **renomear política** ou recriar do zero com nome acordado.
4. **Política de DROP:** mysqldump para S3 → registrar neste doc → DROP só com checklist §5.

---

## 5. Próximos passos (homolog Core na EC2)

Ordem sugerida após DDL RDS:

| # | Ação | Detalhe |
|---|------|---------|
| 1 | **Publish local** | `Migration2Core` → `publish-homolog-ec2.ps1` / zip `rdoapp_core` |
| 2 | **Deploy EC2** | Pasta `C:\inetpub\wwwroot\homologacao\rdoapp_core` — **preservar** `appsettings.Staging.json` (`homol_rdoapp` + credenciais; não sobrescrever do zip) |
| 3 | **Runtime** | `ASPNETCORE_ENVIRONMENT=Staging`, `ASPNETCORE_URLS=http://0.0.0.0:5081` (502 se cair em 5000) |
| 4 | **E2E pós-deploy** | [`e2e-fase0-checklist.md`](e2e-fase0-checklist.md) · URL `https://homolog.sistema.rdoapp.com.br` · CPF `53821963549` / `1234` · UI Equipamentos · login grava `historico_login` |
| 5 | **Git** | Docs `Equipamentos/docs` + repo `Migration2Core` (appsettings example, branding) — push na branch acordada |
| 6 | **Serviço persistente** | Windows Service ou IIS reverse proxy para Core não morrer ao fechar RDP |
| 7 | **HTTPS homolog** | ACM / cert existente no vhost (se ainda HTTP-only) |
| 8 | **Governança RDS** | Duplicatas `rdoapp_homologa`, `Piscinas_Homologa`, `rdoapp_net8_test` — só após backup §7 checklist DROP |

Guia deploy: [`homolog-ec2-migration2core-proximo.md`](homolog-ec2-migration2core-proximo.md) · canônico Migration2Core: `DEPLOY-HOMOLOG-EC2.md`.

---

## 6. Checklist antes de `DROP DATABASE`

- [ ] Backup mysqldump (schema + dados) datado
- [ ] Passo B EC2: zero referências
- [ ] Passo A: MB e tabelas documentados
- [ ] Loja / Piscinas / prod confirmados intactos
- [ ] Lucio aprova status **ARQUIVAR→APAGAR**
- [ ] Janela fora de horário comercial (se prod compartilha instância)

---

## 7. Histórico

| Data | Evento |
|------|--------|
| 2026-10-17 | Inventário DBeaver 18 entradas; confirmado `piscinas_rdoapp_homologa` = dados Piscinas |
| 2026-10-17 | Criado este doc de governança; autoria `rdoapp_net8_test` indefinida no git |
| 2026-10-17 | Passo A: 11 catálogos — `rdoapp_net8_test` 15 tabelas / 0,5 MB; `Piscinas_Homologa` 26 MB |
| 2026-10-17 | Contagem `obra`: homolog/prod Piscinas **106**; `Piscinas_Homologa` **318** (órfão) |
| 2026-10-17 | Passo B EC2: só `novo_rdoapp`, `piscinas_rdoapp*`, Core→`piscinas_rdoapp_homologa`; homol/rdoapp_homologa/net8/Gilberto sem IIS |
| 2026-10-17 | Obras: **novo_rdoapp 284** · **homol_rdoapp 43** · **rdoapp_homologa 8** |
| 2026-10-17 | `homol_rdoapp`: **0** obras com `obr_id_obra` 233–235 (CETI Piscinas homolog) — OK para homolog Equipamentos |
| 2026-10-17 | **E2E OK:** Core `homolog.sistema` + `homol_rdoapp` · CPF `53821963549` · 7 obras = DBeaver = browser |
| 2026-10-17 | **DDL homol:** 4 tabelas + lookups; **47/47** tbl vs `novo_rdoapp`; script em `docs/scripts/homol_rdoapp-sync-tables-from-prod.sql` |
