# M6 Fase 0 — Baseline APK → produção

**Trilha:** EQ-M · **Repo mobile:** `C:\Dev\EquipamentosMobile` · `RDO-APP/EquipamentosMobile`  
**Atualizado:** 2026-11-20  
**Plano pai:** [`plano-m6-mobile-jwt.md`](plano-m6-mobile-jwt.md)  
**Gate:** sem **Baseline OK** (0.5) → **não** abrir JWT/Fase 1

---

## 0.1 Identidade do build (repo)

| Campo | Valor |
|-------|--------|
| Clone | `C:\Dev\EquipamentosMobile` |
| Branch checkout | **`feature/alteracoes_apontador`** (tracking `origin/…`) |
| Tip | **`8fe3c2f`** — *fix null horímetro nova medição* (base layout `14cf5d3`) |
| `main` | `034ea13…` · merge-base com tip: `4b401ff…` |
| Ahead de `main` | 4 commits (layout · paralização/horímetro · PDF/Excel · Gerar Apontamento) |
| Variant default | **`appApontador`** · package `com.dimasduarta.rdoapp.apontador` |
| Expo version (app) | `1.0.0` (`app.config` / expo) |
| **URL prod (default)** | **`https://sistema.rdoapp.com.br`** (`EXPO_PUBLIC_API_ENV=prod`) |
| URL “homolog” no app hoje | `http://192.168.0.8:58951` — **LAN legado**, **≠** `homolog.sistema` Core L1 |
| EAS / scripts | `eas.json` + `package.json` → Apontador com **`API_ENV=prod`** nos profiles principais |

**Lucio preenche (loja / celular):**

| Campo | Valor |
|-------|--------|
| Origem do APK em uso | APK interno Dimas · `…\Dimas\Rdo_Apontador_11082026.apk` |
| Versão embutida | Expo `1.0.0` · package `com.dimasduarta.rdoapp.apontador` · `apiEnv=prod` |
| SHA256 | `A65482F87A82A81674AC23D6A116D32DACE4D5204A1AFFBEDF5EC5F033F74F39` |
| Tamanho / mtime disco | ~113 MB · `2026-09-01` (cópia); nome arquivo **11/08/2026** |
| GitHub | **APK não versionado** no repo · tip `14cf5d3` (10/08) · identidade bate com branch; **sem** prova binária bit-a-bit |
| Confirma base URL prod? | Bundle contém `sistema.rdoapp.com.br` (+ string LAN `192.168.0.8` no código) · ☐ smoke celular |

---

## 0.2 Smoke prod (cenário A) — **você no celular**

CPF/obra de teste **prod** (não Georges homolog, salvo se existir no prod).

| # | Passo | ☐ |
|---|--------|:-:|
| 1 | Abrir **RDO Apontador** (build de produção) | ☑ |
| 2 | Login CPF + senha | ☑ `824.351.035-49` (Georges) · **2026-11-20 ~10:52** |
| 3 | Lista de obras / escolher obra (`ObterObras` + `LoginObra`) | ☑ 2 obras Feira de Santana · Diretor Contratada (Básica) |
| 4 | Cards/etapas carregam | ☑ `COMPLEXO EDUCACIONAL` → Etapas (Canteiro · Serviços · Estrutura · Pavimentação) |
| 5 | Abrir tarefa / medição mínima (horímetro ou status) | ☐ **FAIL** — ver notas |
| 6 | Foto se for o fluxo habitual | ☐ bloqueado por 5 |
| 7 | Salvar apontamento (`/api/tarefa/Salvar` ou equivalente) | ☐ bloqueado por 5 |

**Resultado:** ☐ PASS · ☑ **FAIL** (parcial) — data: **2026-11-20**

**Notas 0.2 (Georges · Complexo / 1ª Etapa · Canteiro):**
- Tela **Nova medição** abre com erro vermelho **`Empty response from backend`**.
- Status → **Pausada**: códigos de paralisação **não** aparecem.
- **Causa (código):** `handleResponse` em `src/services/index.ts` rejeita JSON `null`. Na abertura, `Promise.all` chama `CarregarHorimetroFinalUltimoHistoricoTarefa` (`float?` no legado — **null** sem horímetro anterior) + `GetCodigosParalizacoes`. O null do horímetro derruba o `all` → erro na UI **e** `pausedCodes` nunca popula.
- **Fix Git:** `8fe3c2f` — `tarefaService` aceita `null` + `allSettled` (códigos Pausada). **APK instalado ainda sem o fix** até rebuild.
- **Não** é falha do Core L1 / homolog — cenário A → `sistema.rdoapp.com.br`.

---

## 0.3 Inventário de calls (código atual · Apontador)

Base: `src/services/*` na branch `feature/alteracoes_apontador`.

### Auth / sessão

| Método | Path |
|--------|------|
| POST | `/api/login/LoginUser` |
| POST | `/api/colaborador/RecuperarSenha` |
| POST | `/api/Usuario/LoginObra` |

### Obra

| Método | Path |
|--------|------|
| POST | `/api/obra/ObterObras` |
| POST | `/api/obra/ObterColaboradoresObra/` |
| POST | `/api/obra/ObterEquipamentosObra/` |
| GET | `/api/obra/quantidadeMaximaFotos?id=` |

### Etapa / tarefa / medição (núcleo campo)

| Método | Path |
|--------|------|
| GET | `/api/etapa/Get/?idObra=` |
| GET | `/api/etapa/ObterEtapaTarefa/?…` |
| POST | `/api/tarefa/CarregarHistoricoTarefa/` |
| POST | `/api/tarefa/ObterTarefa/` |
| POST | `/api/tarefa/ObterImagensTarefa/` |
| POST | `/api/statusTarefa/ListaStatusTarefaPermitidos/` |
| POST | `/api/tarefa/AtualizarStatus` |
| GET/POST | `/api/tarefa/paralizacoes/GetCodigosParalizacoes` |
| POST | `/api/tarefa/CarregarHorimetroFinalUltimoHistoricoTarefa` |
| POST | `/api/tarefa/Salvar` |
| POST | `/api/tarefa/GerarRelatorioControleHorasEquipamentoTarefa/` |

### Piscinas (mesmo repo · variant `appPiscinas` — **fora** do baseline Apontador)

Laudo: `/api/laudo/*` — não é critério da Fase 0 Equipamentos.

### Vs api-client M1

P0 documentados (`LoginUser`, `ObterObras`, `LoginObra`, `etapa/Get`, …) **estão** no app.  
App usa **mais** endpoints de tarefa/medição/foto — Fase 1 M6 deve cobrir o **mínimo crítico** da tabela acima (não só P0 Cards).

---

## 0.4 Decisão de branch

| Opção | Significado |
|-------|-------------|
| **A — Merge** `feature/alteracoes_apontador` → `main` | Baseline = tip `14cf5d3` vira linha oficial |
| **B — Plano escrito** | Listar o que entra/fica de fora antes do merge; baseline smoke pode ser loja **ou** build da feature |

**Decisão Lucio:** ☐ A · ☐ B — data: ___ · notas: ___

*(Orquestrador já citava esta decisão aberta desde M0 @ `14cf5d3`.)*

---

## 0.5 Gate Baseline OK

| Critério | Status |
|----------|:------:|
| 0.1 preenchido (repo ☑ + loja/celular) | ☐ |
| 0.2 smoke prod PASS | ☐ |
| 0.3 inventário aceito como contrato mínimo | ☑ repo |
| 0.4 decisão A ou B registrada | ☐ |
| **Baseline OK → liberar M6 Fase 1** | ☐ Lucio |

---

## Fora da Fase 0

- Apontar app para `homolog.sistema` / Core L1  
- JWT  
- Trocar URL prod  
- Commit Migration2Core de JWT
