# Pacote execução P2 + P3 (EQ-R) — 2026-10-21

**Trilha:** EQ-R · **Repo código:** `C:\Dev\Migration2Core` · branch `ci/homolog-ec2-s3-ssm`  
**Homolog:** https://homolog.sistema.rdoapp.com.br · S3 `s3rdoapp` · EC2 `i-05cb0003c031a26da`  
**Fora do pacote:** EQ-M/PQ-M código · P1 Login SPA · P4 medição · commit (só se Lucio pedir)

### Registro execução 2026-10-21

| Passo | Status | Evidência |
|-------|--------|-----------|
| Código P2/P3 | ✅ | `Migration2Core` client — ver lista abaixo |
| `npm run build` | ✅ | `index-Cu858CxQ.js` · `index-CgO3haO5.css` |
| `publish-homolog-ec2.ps1` | ✅ local | `publish\rdoapp_core.zip` |
| Upload S3 + SSM | ⏸ | **AWS session expired** — rodar `aws login` e repetir `deploy-homolog-ec2-ssm.ps1` (zip já gerado: `rdoapp_core-20261021-115126.zip` tentativa falhou no upload) |

---

## Pré-requisitos

- [ ] `Test-Path C:\Dev\Migration2Core` OK
- [ ] AWS CLI logada (`aws sts get-caller-identity`)
- [ ] Node + .NET SDK na máquina do Lucio
- [ ] Smoke ref.: CPF `538.219.635-49` / `1234` · obra teste (ex. FACHADA…)

---

## Fase A — P2 Escolher (polish)

| # | Tarefa | Arquivo(s) |
|---|--------|------------|
| A1 | Remover `<h2>Selecione uma das obras…</h2>` | `EscolherPage.tsx` |
| A2 | 0 obras: sem filtros; mensagem *Clique no botão "+" no cabeçalho…* | `EscolherPage.tsx` |
| A3 | Header: dropdown `<a class="dropdown-toggle">`; ícones + usuário na mesma linha | `OperadorShell.tsx`, `header.css` |
| A4 | Reduzir reserva abaixo do `.topo` (conteúdo mais alto) | `header.css` / `escolher.css` host |

**Aceite P2:** grid cards + legenda; filtros só com obras; header ≈ prod `nav.html` (Escolher).

---

## Fase B — P3 Cards (bugs + paridade)

| # | Tarefa | Arquivo(s) |
|---|--------|------------|
| B1 | Accordion: remover `.collapse.in` (BS5); corpo controlado por React | `CardsPage.tsx`, `cards-page.css` |
| B2 | Estado inicial: etapas **fechadas** (+), como prod | `CardsPage.tsx` |
| B3 | Remover meta `N etapa(s) · M tarefa(s)` | `CardsPage.tsx` |
| B4 | Toolbar: Gerar RDO, Editar Obra, Efetivo Diário no `panel-heading` | `CardsToolbar.tsx` |
| B5 | Linha FILTRO / ADICIONAR horizontal (flex, não grid BS3) | `CardsToolbar.tsx`, `cards-page.css` |
| B6 | Ícone `icon-rdo-gerar-novo` (fontello) se ausente no host | `cards-page.css` / wwwroot |

**Aceite P3:** accordion abre cards; toolbar com RDO + efetivo visíveis; sem contagem etapas/tarefas.

---

## Fase C — Build + deploy

```powershell
cd C:\Dev\Migration2Core\RDO-CleanMigration-2026\client
npm ci
npm run build

cd C:\Dev\Migration2Core\RDO-CleanMigration-2026\scripts
.\publish-homolog-ec2.ps1
.\deploy-homolog-ec2-ssm.ps1 -S3Bucket "s3rdoapp" -InstanceId "i-05cb0003c031a26da"
```

| # | Verificação |
|---|-------------|
| C1 | Homolog serve novo hash JS/CSS (`curl -s …/app/index.html`) |
| C2 | E2E: Login → Escolher → Selecionar → Cards |
| C3 | Ctrl+F5 nos prints P2/P3 |

---

## Fase D — Docs (espelho workspace)

- Atualizar **Próxima ação** em `docs/ORQUESTRADOR-MIGRACAO.md` se marco fechado
- Não commitar em `Equipamentos` legado (EQ-L)

---

## Contrato compartilhado (pós-pacote, M6+)

Ver análise no chat 2026-10-21: BFF `/api/bff/obras` + `/api/bff/etapas` alinhados a `equipamentos-api.types.ts`; mobile continua cenário **A** até API espelhada no Core.
