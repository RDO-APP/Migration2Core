# M9 — Roteiro de aceite D1–D7 (release homolog → GO cutover)

**Trilha:** EQ-R + EQ-M · **Atualizado:** 2026-11-23 21:55 BRT  
**Host:** `https://homolog.sistema.rdoapp.com.br` · RDS **`homol_rdoapp`** · L1 `i-0776acb09b8438f22`  
**Critério:** paridade **operável** (fluxo + dados) — não pixel-perfect.  
## D8 — Ordem do histórico (fora do D1–D7 · 23/11)

Regra prod: data DESC → hora_inicial DESC (NULL = 00:00) → ultima_atualizacao DESC.  
Após editar horas: reabrir relógio / cadastro (GET já reordena). Tip Core: COALESCE na query.  
**Não** reindexar a cada tecla — só na leitura do histórico.

---

**Próximo após GO:** [`m10-cutover-checklist.md`](m10-cutover-checklist.md).

Marcar cada linha: ☐ / ☑ PASS / ✗ FAIL + data BRT.

---

## 0. Pré (obrigatório antes de D1)

| # | Item | Status 23/11 16:10 |
|---|------|-------------------|
| 1 | Core tip com **clone Copiar** | ☑ HEAD Git `d04e727` · `CloneListasFromOrigemAsync` |
| 2 | **Publish + deploy** L1 Linux tip `d04e727`+ | ☐ Lucio — blocos abaixo |
| 3 | Smoke mínimo pós-deploy: Login 200 + Copiar → colab/equip | ☐ após deploy |
| 4 | APK Homolog | ☑ EAS Finished `42bd2e66` · commit **`a319ce69`** · profile `appApontadorHomolog` |
| 5 | Tip App local vs APK | ⚠ local `72aeaa9` (hora/horímetro) **à frente** do APK `a319ce69` — D4 OK no tip APK; se precisar V5/V6 no mobile → novo EAS |

### Publish / deploy (Lucio · PC)

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

Esperado: `Deploy homolog Core Linux OK` · smoke Login 200.

### EAS (só se D4 exigir tip `72aeaa9`+)

No repo `C:\Dev\EquipamentosMobile` (branch homolog), profile `appApontadorHomolog` — Lucio dispara; agente não publica EAS sem pedido.

---

## D1 — Login → Escolher → Cards

| # | Passo | Esperado | ☐ |
|---|--------|----------|:-:|
| 1 | Login CPF homolog | 200 · sem loop | |
| 2 | Escolher obra | Lista obras do colaborador | |
| 3 | Selecionar obra | Vai a `/Tarefa/Cards` com etapas/tarefas | |
| 4 | Shell (nome obra / menu) | Operável | |

**PASS D1:** ☐ ____/____ ____:____

---

## D2 — Cards operador (web)

| # | Passo | Esperado | ☐ |
|---|--------|----------|:-:|
| 1 | Toolbar FILTRO / + tarefa / etapa | Abre / salva sem 500 | |
| 2 | ⋮ status rápido | Grava linha no histórico (Pausada **sem** exigir código = prod) | |
| 3 | Relógio (histórico) | Lista medições | |
| 4 | Olho / lápis | Cadastro carrega | |

**PASS D2:** ☐ ____/____ ____:____

---

## D3 — Nova medição + impressora (web)

| # | Passo | Esperado | ☐ |
|---|--------|----------|:-:|
| 1 | **+** Nova medição | Status default = atual da tarefa | |
| 2 | Hora ini > fim | Bloqueia com mensagem | |
| 3 | Horímetro Final inicia **0**; Final &lt; Inicial | Bloqueia | |
| 4 | Status Pausada | Qtd desabilitada; código obrigatório no **salvar** | |
| 5 | Foto(s) + salvar | Persiste / toast OK | |
| 6 | Impressora PDF | Páginas &gt; 0 | |
| 7 | Impressora Excel | Abre (aviso formato HTML.xls = aceito até pós-M10) | |

**PASS D3:** ☐ ____/____ ____:____

---

## D4 — Apontador (mobile Homolog → Core)

| # | Passo | Esperado | ☐ |
|---|--------|----------|:-:|
| 1 | APK `appApontadorHomolog` tip atual | Login JWT homolog | |
| 2 | Obras / etapas / card | Mesma obra do D1 | |
| 3 | + / EDITAR medição | Mesmas regras D3 (hora/horímetro/qtd) | |
| 4 | PDF / Excel | Igual web (Excel aviso OK) | |

**PASS D4:** ☐ ____/____ ____:____ · tip APK: `a319ce69` (EAS `42bd2e66`) · se tip novo: ________

---

## D5 — RDO

| # | Passo | Esperado | ☐ |
|---|--------|----------|:-:|
| 1 | Lista RDOs | Abre | |
| 2 | Novo RDO + salvar | Sem 500 | |
| 3 | PDF RDO (fotográfico se marcado) | Gera | |
| 4 | Assinar (se papel permitir) | Fluxo operável | |

**PASS D5:** ☐ ____/____ ____:____

---

## D6 — Obra Index + cadastros P6a

| # | Passo | Esperado | ☐ |
|---|--------|----------|:-:|
| 1 | `/Obra/Index` | Lista | |
| 2 | **Copiar obra** → Salvar | Nova obra com **colabs + equips** da origem | |
| 3 | Enviar convite (se SMTP OK) | Toast / sem 500 | |
| 4 | Colaborador / Equipamento / Empresa / Paralizações | Index+cadastro SPA | |

**PASS D6:** ☐ ____/____ ____:____

---

## D7 — Relatórios leves + GO

### D7.1 — Chart (`/Chart`)

| Tile | Filtro de datas? | O que o número significa (paridade prod) |
|------|------------------|----------------------------------------|
| RDO´s Atrasados | Sim (`rdo_dt_rdo`) | Contagens de RDO sem assinatura no período |
| Dias Improdutivos | Sim | Dias no período |
| **Comentários** | **Sim** | Só RDO com `rdo_tp_comentario_geracao` = P/N (👍/👎 na assinatura). **0 em todas as obras = sem esse dado no `homol_rdoapp`** (não é bug de filtro). Tile mostra **negativos** contratante/contratada (= prod). |
| **Tarefas com Início em Atraso** | **Não** (prod também ignora o período) | **Qtd de cards ainda Planejada** cuja `tar_dt_inicio` ≤ hoje — **não** é “dias de atraso desde 2020”. Obra de 2020 com 73 = 73 tarefas Planejada atrasadas para começar, não 73 dias. |

Smoke: Filtrar com período curto vs longo — Comentários/RDO/Improdutivos mudam; Início em Atraso **não** muda (esperado).

### D7.2 — Efetivo

Já validado (Copiar dia / relatório) — marcar PASS.

### D7.3 — Stubs EmMigracao (simplificado)

**Com o seu ☰ (print 23/11):** Card de Tarefas · Colaboradores · Códigos · Efetivo · Empresas · Equipamentos · Etapas · Obras · RDOs — **todos já são telas reais**. **D7.3 = PASS** para o menu do operador.

**O que era “Relatórios/CMS”:** itens que **não aparecem** nesse ☰ (só admin / ainda placeholder no Core). **Você não precisa procurar isso agora.** Ignore D7.3 se o ☰ abrir tudo sem tela cinza “Em migração”.

### D7.4 — GO / NO-GO em português

Pergunta única: **posso começar a preparar o cutover M10 (Core em produção com `novo_rdoapp`)?**

| Você diz | Significa |
|----------|-----------|
| **GO** | “Sim, homolog está bom o bastante para planejar o cutover.” |
| **NO-GO** | “Não — ainda tem problema grave; listar o motivo.” |

**Exemplos de NO-GO:** Login/Cards/RDO com erro 500 · Copiar obra **depois do deploy** ainda sem colaboradores · medição deixa salvar hora inicial > final · APK Homolog sem login JWT.

**Não é NO-GO:** Comentários do Chart em 0 · Excel aviso antigo · item de menu admin que você nem vê · melhorias 3.1/CAT.

**PASS D7 / GO cutover:** ☑ 23/11 · decisão: **GO M10**

---

## Resumo

| Gate | Status | Data |
|------|--------|------|
| Pré §0 | clone Git ☑ · **deploy Lucio agora** · APK ☑ | 23/11 21:20 |
| D1 | ☑ PASS Lucio | 23/11 |
| D2 | ☑ PASS Lucio | 23/11 |
| D3 | ◐ Excel .xls no host (aviso) · horas norma/extra · republish | 23/11 |
| D4 | | |
| D5 | ☑ PASS Lucio | 23/11 |
| D6 | ✗ colabs sem clone no host · smoke após deploy `d04e727` | 23/11 |
| D7 | ☑ GO Lucio 23/11 · Comentários Chart fix código (smoke pós-deploy) | 23/11 |

**NO-GO se:** 500 em jornada crítica · medição sem bloqueio hora/horímetro · Copiar sem listas · mobile sem JWT homolog.

**Estado plano (23/11):** Lucio em teste M9 · agente fechou pré tip/APK + blocos publish · GO só no D7.4.
