# M10 — Checklist cutover Core → produção (`novo_rdoapp`)

**Trilha:** I + EQ-R/M · **Atualizado:** 2026-11-23 16:10 BRT  
**Pré:** [`m9-aceite-d1-d7.md`](m9-aceite-d1-d7.md) **GO** · L1 homolog ≠ este cutover  
**Regra:** **proibido** `ALTER`/`DROP` em `novo_rdoapp` sem Lucio explícito neste chat.  
**Canônico RDS:** [`rds-equipamentos-governanca-catalogos.md`](../rds-equipamentos-governanca-catalogos.md) §0 · diff [`../scripts/homol-vs-prod-schema-diff.sql`](../scripts/homol-vs-prod-schema-diff.sql).

---

## 1. Banco — o que fizemos em `homol_rdoapp` × o que falta em `novo_rdoapp`

### 1.1 Leitura certa

Os DDL em **homolog** foram para **alcançar** o schema que **produção já tinha** (homol atrasado).  
Cutover M10 = Core passa a apontar para **`novo_rdoapp`** — **não** é "aplicar o ALTER do homol no prod".

| Data | Onde | Ação | Motivo | Em `novo_rdoapp`? |
|------|------|------|--------|-------------------|
| 2026-10-17 | `homol_rdoapp` | `CREATE` LIKE prod: `efetivo`, `efetivo_status`, `historico_login`, `tarefa_codigo_paralizacao` + lookups | Homol sem 4 tabelas | **Já existiam** em prod |
| 2026-10-17 | `homol_rdoapp` | DML: `efetivo_status` (4) · `tarefa_codigo_paralizacao` (22) de prod | Lookups | **Já em prod** |
| 2026-11-03 11:54 | `homol_rdoapp.tarefa` | `ALTER` +4 colunas: `tar_codigo_paralizacao` varchar(3) · 3× horímetro float | Homol &lt; prod (L11/O0) | **Já em prod** (origem do gap) |
| 2026-11-03 12:22–12:25 | `homol_rdoapp` | `MODIFY` varchar `tarefa` / `rdo` (alargar) | Alinhar tipos a prod | **Já em prod** (referência) |
| 2026-11-03 ~12:27 | ambos | Diff Q1–Q4 **limpo** | Schema gêmeo | — |
| 2026-11-16 | `homol_rdoapp.grupo` | `INSERT` id **34** Terceirizado | Homol sem row; **prod já tinha 34** | **Nada a fazer** em prod |

Script sync tabelas: [`../scripts/homol_rdoapp-sync-tables-from-prod.sql`](../scripts/homol_rdoapp-sync-tables-from-prod.sql) · colunas tarefa: [`../scripts/homol-vs-prod-tarefa-colunas.sql`](../scripts/homol-vs-prod-tarefa-colunas.sql).

### 1.2 O que **falta** no BD `novo_rdoapp` (para cutover Core)

| Item | Status | Ação M10 |
|------|--------|----------|
| DDL das 4 colunas `tarefa` / varchar | **Não falta** — prod era a referência | Só **revalidar** Q1–Q4 no DBeaver antes do GO |
| Tabelas efetivo / historico_login / códigos | **Não falta** | Idem |
| `grupo` 34 Terceirizado | **Não falta** | Conferir `SELECT` id 34 (já deve existir) |
| Conteúdo (43 vs 284 obras) | Divergência **ok** | **Não** clonar obras demo homol → prod |
| DDL **novo** pós-03/nov só no Core | Nenhum DDL de produto aplicado só em homol até 23/11 | Se surgir: script em `homol` → Lucio OK → **mesmo** script em `novo_rdoapp` |
| CAT-PARALIZ / foto-geo / schema `imagem` extra | Melhoria **pós**-produção | **Fora** M10 cutover |

### 1.3 Gate schema (obrigatório no dia do GO — só leitura)

**DBeaver** → RDS equipamentos → abrir script [`../scripts/homol-vs-prod-schema-diff.sql`](../scripts/homol-vs-prod-schema-diff.sql).

| Query | Esperado |
|-------|----------|
| Q1 | `delta_colunas` = 0 em todas as tabelas |
| Q2 | **0 linhas** (nada só de um lado) |
| Q3 | **0 linhas** (tipos iguais) |
| Q4 | **0 linhas** (conforme script) |

Sanidade `grupo` 34 (prod):

```sql
SELECT gru_id, gru_nome FROM novo_rdoapp.grupo WHERE gru_id = 34;
-- esperado: 34 · Terceirizado (ou nome equivalente)
```

☐ Q1–Q4 limpo em ____/____ ____:____ · evidência (print/chat): ________  
☐ `grupo` 34 OK em ____/____ ____:____

**Decisão schema (23/11 plano):** nenhum ALTER preparado para `novo_rdoapp` neste cutover — só revalidar.

---

## 2. Pré-cutover (app / infra)

| # | Item | Detalhe concreto | ☐ |
|---|------|------------------|:-:|
| 1 | M9 D1–D7 **GO** | Assinatura em [`m9-aceite-d1-d7.md`](m9-aceite-d1-d7.md) D7.4 | |
| 2 | Tip Core acordado | Homolog estável pós-M9 (mín. `d04e727`+ clone) | |
| 3 | CS Production | `ConnectionStrings:DefaultConnection` → **`Database=novo_rdoapp`** (nunca `homol_rdoapp`) · fora do Git (SSM/arquivo EC2) | |
| 4 | JWT prod | `SigningKey` / `Issuer` / `Audience` **distintos** do Staging (`Issuer` ≠ `https://homolog.sistema.rdoapp.com.br`) | |
| 5 | Uploads | `FileStorage:UploadsRoot` path EC2 / volume prod | |
| 6 | SMTP prod | Locaweb · smoke e-mail Esqueci/Convite | |
| 7 | Tráfego | DNS/ALB `sistema.rdoapp.com.br` · plano troca legado IIS ↔ Core (TG prod acordado no dia) | |
| 8 | Rollback | IIS EQ-L **`i-05cb0003c031a26da`** · re-registrar no TG anterior se FAIL · CS legado intacta | |
| 9 | Backup RDS | Snapshot `novo_rdoapp` + janela Lucio anunciada | |
| 10 | Apontador | Dia D: **A** legado `api/*` em `sistema.rdoapp.com.br` **ou** **B** Core JWT — decisão escrita abaixo | |

**Decisão Apontador (§2.10) — 27/11 Lucio:** **A** (login legado `POST /api/login/LoginUser` + cookie). Código Core `39ff033` (deploy L1 no mesmo dia). Smoke desse login no homolog ainda aberto. **B** (JWT no APK de produção) fica em **APONTADOR-B**, depois do corte.

APK que os usuários usam hoje: Dimas `Rdo_Apontador_11082026` · pacote `com.dimasduarta.rdoapp.apontador` · `sistema.rdoapp.com.br`. Rotas de campo conferidas iguais ao app atual. APK de produção novo — **build EAS disparado 27/11** (`rdo-app` / `rdo-app-apontador`, [build `3d55464d`](https://expo.dev/accounts/rdo-app/projects/rdo-app-apontador/builds/3d55464d-2f6e-41ed-b1f6-079912c04256)): pacote `com.rdoapp.apontador` · arquivo `Rdo_Apontador_Producao_*.apk` · instala ao lado do Dimas · código EquipamentosMobile `main` `0391a88` (Excel `.xls`/`.xlsx` por conteúdo já incluído). Homolog: `com.rdoapp.apontador.homolog` · `Rdo_Apontador_Homolog_*.apk`. **Keystore:** gerado pelo EAS na nuvem (conta `rdo-app`); manter o mesmo nas próximas versões e guardar cópia fora do Git. Laudo fora do Apontador. **Antes de distribuir:** teste em obra de teste (login, apontamento, Excel abre no celular).

Homolog L1 (`i-0776acb09b8438f22` · TG `tg-equipamentos-homolog-5081`) **não** é o host deste cutover.

---

## 3. Dia do cutover (ordem)

| # | Passo | ☐ |
|---|--------|:-:|
| 1 | Snapshot RDS + anunciar janela | |
| 2 | Deploy Core **Production** (host acordado) com CS `novo_rdoapp` | |
| 3 | Health `/Account/Login` 200 (localhost + URL pública) | |
| 4 | Troca tráfego DNS/TG (legado IIS → Core) | |
| 5 | Smoke prod mínimo = **D1 + D3 + D5** (web) | |
| 6 | Se FAIL → rollback TG/IIS · CS intacta no legado | |
| 7 | Se PASS → monitor 24–48h · Apontador conforme §2.10 | |

**Não** rodar publish/deploy prod pelo agente sem pedido explícito do Lucio.

---

## 4. Pós-cutover (não bloqueia GO M9 / cutover)

Backlog canônico pós-M10 — **fora** do caminho crítico do cutover:

| ID | Item | Dono | Ref |
|----|------|------|-----|
| **M7-REL-HORAS-XLS** | ClosedXML Excel horas (logo + aviso formato ≠ HTML.xls) | EQ-R | [`pendencias-melhorias-ui-stack.md`](pendencias-melhorias-ui-stack.md) · impressora |
| **P6b** | CMS `#/grupo` `#/menu` `#/pagina` (+ Histórico) | EQ-R | [`cms-grupo-menu-pagina-prod.md`](cms-grupo-menu-pagina-prod.md) |
| **CAT-PARALIZ-01** | Códigos paralização por empresa | EQ-R | Cards ⋮ / Paralizações |
| **V10** | Limite fotos por licença (App) | EQ-M | [`m6-apk-botoes-campos-paridade-core.md`](m6-apk-botoes-campos-paridade-core.md) |
| **3.1** | Pausada + código no ⋮ (além da prod) | EQ-R | melhoria pós-Core10 |
| **CI-B3** | Actions Linux runway homolog | I | paralelo ops |
| **ES-OBRA-DEMO** | Traduzir etapas/tarefas de obra copiada para espanhol (Paraguai) — SQL DBeaver via chat Migração; só **depois** de 100% espelhado + prod | EQ-R / dados | [`pendencias-melhorias-ui-stack.md`](pendencias-melhorias-ui-stack.md) · I18N-ES-01 |
| **APONTADOR-B** | Apontador na API Core JWT (opção B) após monitoramento do cutover com A | EQ-M | §2.10 |

**Regra Lucio (26/11):** melhorias só após **100% espelhado** e **em produção**.

---

## 5. Assinatura

| | Nome | Data |
|--|------|------|
| Schema Q1–Q4 | | |
| M9 GO | | |
| Cutover executado | | |
| Rollback testado (simulado ou real) | | |

**Estado plano (27/11):** runbook M10 pronto · dia D ainda bloqueado até smoke deste deploy + assinatura M9 · schema = só revalidar (sem ALTER) · Apontador dia D = **A**.
