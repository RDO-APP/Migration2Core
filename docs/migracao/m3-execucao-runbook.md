# M3 — E2E Fase 0 (runbook operador)

**Marco:** M3 · **Trilhas:** EQ-R + EQ-W (host) · **Gate:** fecha **M2** formal · **Pré:** C1–C3 + C5 homolog OK (`d18cf8f`)  
**Checklist canônico:** [`../e2e-fase0-checklist.md`](../e2e-fase0-checklist.md)

---

## Critério de done M3

Lucio assina **PASS** no checklist E2E com:

| Gate M3 (mínimo) | Passo checklist | Evidência |
|------------------|-----------------|-----------|
| Login homolog | 1–2 | `/Account/Login` carrega; CPF Equipamentos homolog |
| Escolher | 3–4 | `/Obra/Escolher`; lista com obras |
| Selecionar | 5 (parte 1) | POST obra; redirect `/Tarefa/Cards` |
| Cards **React com dados** | 5 (parte 2) | ≥1 etapa accordion; cards com %/status (BFF agrupador) |

Passos **6–7** recomendados; **não** bloqueiam M3 se 1–5 PASS.

**Smoke informal 2026-10-19:** obra **42** · 3 etapas · 13 tarefas — usar mesma obra para assinatura formal se ainda válida.

---

## Roteiro (homolog EC2 — preferido)

1. Abrir `https://homolog.sistema.rdoapp.com.br/Account/Login`
2. CPF `538.219.635-49` · senha homolog (§ checklist — não commitar)
3. Escolher obra (ex. **42** ou qualquer com tarefas)
4. Clicar obra → **Cards**
5. Confirmar UI **React** (accordion azul, grid cards) — **não** placeholder Razor vazio
6. DevTools → Network: `GET /api/bff/etapas` **200** com payload etapas
7. Preencher colunas OK/Data/Notas em [`e2e-fase0-checklist.md`](../e2e-fase0-checklist.md) · resultado **PASS**

Deploy recente: zip `rdoapp_core-20261019-175555` · SSM Success ~1,4 min.

---

## Se falhar

| Sintoma | Ação |
|---------|------|
| Timeout RDS local | Testar só **homolog EC2** (não invalida M3) |
| Cards vazio / 401 BFF | Sessão obra: repetir Selecionar; ver `SessionKeys.ObraId` |
| Placeholder Razor | Redeploy com `client` build em `wwwroot/app` — [`roteiro-deploy-homolog-operador.md`](roteiro-deploy-homolog-operador.md) |
| Selecionar 500 | EQ-W bugfix — registrar; **não** pular para M4 |

---

## Após PASS

1. Atualizar [`m2-execucao-checklist.md`](m2-execucao-checklist.md) — critério fechamento M2 ☑  
2. Orquestrador: marco **M2 FECHADO** · **M3 FECHADO** · próxima ação **M4**  
3. Commit/push **`Migration2Core`** (docs + checklist assinado) — branch `ci/homolog-ec2-s3-ssm`

**Não** iniciar shell/Escolher React (M4) antes do PASS documentado — critério de congelamento EQ-W.

---

## Fora do gate M3 (não reprovar M3)

- Toolbar Cards (filtro RDO, nova tarefa) — **M4 / gap #1**
- Filtros Escolher Obra+Município — **M4**
- Nova medição modal — **M7+**
- Branding/fonts P4 — opcional
