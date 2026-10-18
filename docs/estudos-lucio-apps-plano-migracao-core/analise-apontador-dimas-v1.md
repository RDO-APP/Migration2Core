# Estudo — App Apontador v1 (Dimas): APK, repositórios e comparação com PiscinasMobile

**Autor:** Lucio + Cursor (jul/2026)  
**Atualização:** set/2026 — APK **11/08/2026** verificado vs **9 ajustes UI** (msg 08/08). Decisão ago/2026: **não trancar etapa Equipamentos** (accordion/todas etapas permitidas).

**Artefatos analisados:**
- APK jul/2026: `Dimas/Rdo_ApontadorJulho2026.apk` (220 MB)
- APK ago/2026: `Dimas/appApontador_v20260805.apk` (118 MB) — **antes** dos 9 ajustes
- APK ago/2026: `Dimas/Rdo_Apontador_11082026.apk` (118 MB) — **nova versão** (semana passada)
- Screenshots: `Dimas/Telas App do Apontador/` (jun e ago/2026)
- Repo ativo: [RDO-APP/EquipamentosMobile](https://github.com/RDO-APP/EquipamentosMobile) — branch **`feature/alteracoes_apontador`** → `14cf5d3` (10/ago/2026)
- Repo referência Carlos: [RDO-APP/PiscinasMobile](https://github.com/RDO-APP/PiscinasMobile) / [RDO-APP/RDOAppPiscinasMobile](https://github.com/RDO-APP/RDOAppPiscinasMobile) — HEAD `744cea9` (**sem** commits Dimas)
- Spec: [especificacao-app-apontador-dimas.md](./especificacao-app-apontador-dimas.md) (branch `docs/especificacao-apontador-dimas` no Equipamentos)

---

## 1. Acesso aos repositórios

Clone confirmado via `git` no ambiente local (credenciais do usuário).

| Repositório | HEAD / branch | Última alteração | Autor |
|---|---|---|---|
| **EquipamentosMobile** | `main` → `4b401ff` (14/jul) · **`feature/alteracoes_apontador` → `14cf5d3`** (10/ago) | Jul–ago/2026 | Dimas Duarte |
| PiscinasMobile / RDOAppPiscinasMobile | `744cea9` | 22/06/2026 | Carlos Gabriel Campo |

**Importante:** o trabalho recente do Dimas está na branch **`feature/alteracoes_apontador`**, **não mergeada** na `main`. O repo unificado `RDOAppPiscinasMobile` **não contém** esses commits — APKs vêm de **EquipamentosMobile**.

---

## 2. Histórico recente — EquipamentosMobile

| Data | Autor | Commit / PR | Descrição |
|---|---|---|---|
| 14/07/2026 21:58 | Dimas Torres | PR #3 merge | Merge correção modal |
| 14/07/2026 21:57 | Dimas Duarte | `729f635` | Corrige fechar modal de tarefa ao salvar + `refetch` etapas |
| 06/07/2026 22:14 | Dimas Torres | PR #2 merge | Merge projeto inicial |
| 06/07/2026 21:40 | Dimas Duarte | `5845e65` | **Projeto Inicial do APK Apontador** — 108 arquivos, ~117k linhas |
| 04/08/2026 | Dimas Duarte | `d10d618`…`b8cc7c9` | Impressora PDF/Excel, Gerar Apontamento, cálculo horas, remove gráfico |
| **10/08/2026** | Dimas Duarte | **`14cf5d3`** | **Ajustes layout solicitados 08-08-2026** (9 itens UI Lucio) |
| 01/07/2026 09:08 | Lucio Felix Neto | `1707905` | Initial commit (repo vazio) |

**Autores:** 5 commits Dimas Duarte, 3 merges Dimas Torres, 1 Lucio.

---

## 3. Histórico recente — PiscinasMobile

| Data | Autor | Descrição |
|---|---|---|
| 22/06/2026 | Carlos Gabriel Campo | `dateTime`, API env, logging em `handleCall` |
| 26/03/2026 | Carlos Gabriel Campo | `pausedCodes`, URLs homolog, `EditRegisterScreen` |
| 19/03/2026 | Carlos Gabriel Campo | `add-register-screen`, modais no `NormalDashboard` |
| 12/03/2026 | Carlos Gabriel Campo | `WorkCard`, `NormalWorkDetails` com filtros |
| fev–mar/2026 | Carlos Gabriel Campo | Laudos, impressora, histórico, gráficos, login, services |

**30 commits** — todos de Carlos Gabriel Campo. Base estável **8 dias antes** do fork do Dimas.

---

## 4. Comparação de código: EquipamentosMobile × PiscinasMobile

### 4.1 Panorama

| Métrica | Valor |
|---|---|
| Arquivos em `src/` | 72 em cada repo |
| Arquivos **idênticos** (hash MD5) | **68 (94%)** |
| Arquivos **diferentes** | **4** |
| Arquivos exclusivos de um repo | 0 |

**Conclusão:** EquipamentosMobile é um **fork do PiscinasMobile** (estado de jun/2026) com ajustes pontuais para Apontador.

### 4.2 Os 4 arquivos alterados pelo Dimas

#### `src/config/appVariant.ts`
- Default da variante: `appPiscinas` → **`appApontador`**
- Nova função **`matchesDefaultEtapa(titulo)`**:
  - Apontador: `"EQUIPAMENTO"` ou `"EQUIPAMENTOS"`
  - Piscinas: `"LIMPEZA"`
- API env default: `__DEV__ ? homolog : prod` → sempre **`prod`**

#### `src/contexts/PiscineiroCardsContext.tsx`
- Filtro hardcoded `e.titulo === "LIMPEZA"` → **`matchesDefaultEtapa()`**
- Mantém o nome do contexto (não criou `ApontadorCardsContext`)

#### `src/components/screens/normal-work-details.tsx`
- Adiciona `.filter(matchesDefaultEtapa)` em `filteredEtapas` — **só etapa EQUIPAMENTOS** dentro da obra
- Adiciona `refetch()` ao fechar modal de medição (commit 14/jul)

#### `src/components/screens/add_modify_register/add-register-screen.tsx`
- Após salvar equipamento com sucesso, **fecha o modal** (`setOpen(null)`)

### 4.3 Configuração de projeto (novo/alterado)

| Arquivo | Alteração Dimas |
|---|---|
| `app.config.ts` | `com.dimasduarta.rdoapp.apontador`, slug `rdo-app-apontador`, EAS projectId |
| `.env` | `EXPO_PUBLIC_APP_VARIANT=appApontador`, `EXPO_PUBLIC_API_ENV=prod` |
| `package.json` | Nome `rdo-app-apontador`, scripts Windows via `run-with-env.js` |
| `eas.json` | Profiles `appApontadorPreview`, `development`, `preview` |
| `README.md` | Documentação dedicada ao Apontador |

---

## 5. O que o Dimas fez vs o que aproveitou

### 5.1 Trabalho próprio do Dimas

| # | Item |
|---|---|
| 1 | Criou repo separado **EquipamentosMobile** (não evoluiu PiscinasMobile compartilhado) |
| 2 | Configurou build EAS/APK Apontador (`com.dimasduarta.rdoapp.apontador`) |
| 3 | Função `matchesDefaultEtapa()` — abstração etapa por variante |
| 4 | Filtro parcial de etapa em `normal-work-details` (só EQUIPAMENTOS na obra) |
| 5 | Correção UX: modal fecha ao salvar + refetch da lista |
| 6 | Defaults Apontador + produção (`sistema.rdoapp.com.br`) |

### 5.2 Reaproveitado do PiscinasMobile (Carlos) — ~94%

| Módulo | Arquivos / componentes |
|---|---|
| Autenticação | `login-screen`, `AuthContext`, `authService` |
| Dashboard gestor | `NormalDashboard`, `WorkCard` |
| Dashboard Piscineiro | `piscineiro-screen`, `PiscineiroCardsContext` |
| Detalhe obra | `normal-work-details` (base + filtro Dimas) |
| Cards | `taskCard`, `normalTaskCard`, `workCard` |
| Medição | `add-register-screen`, `equipamentos.tsx`, `edit-register-screen` |
| Histórico | `history-screen`, `TarefaModal` |
| Laudos | `laudo-list-screen`, `laudoService` |
| Impressora | `report-print-screen`, `report.tsx` (não no card) |
| Gráficos | `dashboard-history-screen` |
| Services | `tarefaService`, `obraService`, `formService`, validações, mocks |
| UI / Nav | `AppHeader`, `AppFooter`, themed, hooks |

---

## 6. Análise do APK e telas (15/jun/2026)

### 6.1 Metadados do APK

| Campo | Valor |
|---|---|
| Pacote | `com.dimasduarta.rdoapp.apontador` |
| Nome | RDO Apontador |
| Variante | `appApontador` |
| API | `prod` → `sistema.rdoapp.com.br` |
| Stack | Expo SDK 54, React Compiler, New Architecture, Hermes |

Bundle JS compilado (sem `index.android.bundle` legível) — análise funcional via screenshots e código-fonte.

### 6.2 Checklist vs especificação

| Requisito | Spec | Entrega v1 | Status |
|---|---|---|---|
| Variante Apontador | `appApontador` → Equipamentos API | Confirmado no `app.config` | ✅ |
| Repo compartilhado | `PiscinasMobile` com variant | Repo separado `EquipamentosMobile` | ⚠️ |
| Roteamento operador | Perfil Operador vs Diretor (sem exigir dashboard plano) | `NormalDashboard` + `WorkCard` (capacete) | ⚠️ |
| ~~Trancar etapa Equipamentos~~ | **Cancelado (ago/2026)** — operador vê todas etapas | Accordion OBRA/TESTE/EQUIPAMENTOS | ✅ alinhado à nova regra |
| Filtro etapa na obra (`matchesDefaultEtapa`) | Opcional — pode remover se accordion completo for desejado | Branch `main` filtra EQUIPAMENTOS | ⚠️ revisar com Dimas |
| Título card | Nome do equipamento | Cards com nome do equipamento na seção EQUIPAMENTOS | ✅ |
| N cards por obra | Vários equipamentos | Vários cards na etapa EQUIPAMENTOS | ✅ |
| Botões card | Pasta, Relógio, Impressora, + | Pasta, Gráfico, Relógio, + (sem impressora) | ⚠️ |
| Pasta → Apontamentos | Lista + assinatura (espelho Laudos) | Abre medições / laudo | ⚠️ |
| Terminologia | Apontamento (não Laudo) | Checkbox "GERAR LAUDO" | ❌ |
| Impressora no card | PDF diário `tipo: Equipamento` | Não visível nos cards | ❌ |
| `unit-dashboard` | Rota `"Apontador (Básica)"` | Ainda só `"Piscineiro (Básica)"` | ❌ |

### 6.3 Observação APK vs código Git

Screenshots de **15/jun** mostram accordion com OBRA, TESTE e EQUIPAMENTOS. O código no GitHub (commit **06/jul**) já filtra só EQUIPAMENTOS em `normal-work-details`. O APK entregue provavelmente é de **build anterior** ao push — recomenda-se novo build do commit `4b401ff` (14/jul) para validar o filtro.

### 6.4 Bugs observados nas telas

- **Total Horas = 0** com horímetro 0→100 (cálculo incorreto)
- Confusão entre lista de **medições** e lista de **apontamentos** assináveis

---

## 7. Gaps prioritários (próxima sprint)

| Prioridade | Item | Ação |
|---|---|---|
| **Alta** | **Ícone Card Obra (item 4)** | Trocar HardHat por ícone web por `contratanteContratada` — ver §10.4 |
| Alta | Roteamento operador vs gestor | Definir o que muda por `statusBasicaGratuita` **sem** trancar etapa |
| ~~Alta~~ | ~~Trancar etapa Equipamentos~~ | **Cancelado** |
| Média | Remover `matchesDefaultEtapa` no Apontador? | Se accordion completo for o padrão, retirar filtro em `normal-work-details` |
| Média | Botões do card | Impressora + sem gráfico — **entregue** na branch `feature/alteracoes_apontador` (04/ago) |
| Média | Pasta Apontamentos | Criar `apontamento-list-screen` (espelho Laudos) |
| Média | Terminologia | Trocar "Laudo" por "Apontamento" |
| Estratégica | Repo único | Avaliar merge em `PiscinasMobile` com variant `appApontador` |
| Backend | API | `ApontamentoController` mínimo para pasta + impressora |

---

## 8. Veredicto

A v1 do Dimas demonstra domínio da base Carlos (medição, cards, API Equipamentos) e entrega um APK funcional. O fork reaproveita **94% do código** com **4 arquivos alterados** e configuração EAS dedicada.

Com a decisão de **não trancar etapa Equipamentos**, o accordion com todas etapas (OBRA, TESTE, EQUIPAMENTOS, etc.) **deixa de ser gap**. Pendências principais: **ícone Card Obra** (item 4 dos 9 ajustes — ver §10), pasta **Apontamentos** (substituir Laudo de ponta a ponta), merge da branch `feature/alteracoes_apontador` na `main`, e `ApontamentoController` no backend.

---

## 10. APK 11/08/2026 — verificação dos 9 ajustes (msg 08/08/2026)

### 10.1 Mensagem de referência (Lucio → Dimas, 08/08/2026)

Pedido de **9 ajustes de UI/UX** para alinhar App Apontador ao **Sistema Equipamentos web** (`sistema.rdoapp.com.br`), comparando branch `feature/alteracoes_apontador` × web AngularJS.

| # | Pedido | Arquivo principal |
|---|--------|-------------------|
| 1 | Card de **Obra** menor (sem `width: 300`, menos padding) | `workCard.tsx` |
| 2 | Filtro **"Unidade escolar" → "Obra"** | `normal-dasboard.tsx` |
| 3 | Legenda **depois** da lista de obras | `normal-dasboard.tsx` |
| 4 | **Ícone dinâmico** por `obra.contratanteContratada` (web: `icon-{{obra.contratanteContratada}}`) | `workCard.tsx` |
| 5 | Card de **Tarefa** menor | `taskCard.tsx` |
| 6 | **Sem cidade** no card de tarefa | `normal-work-details.tsx` + `taskCard.tsx` |
| 7 | **Datas em uma linha** | `taskCard.tsx` |
| 8 | Nova medição **vertical** (um campo por linha) | `equipamentos.tsx` |
| 9 | Remover **+ Etapa / + Tarefa** | `normal-work-details.tsx` |

### 10.2 APKs na pasta `Dimas/`

| Arquivo | Tamanho | Observação |
|---------|---------|------------|
| `Rdo_ApontadorJulho2026.apk` | 220 MB | v1 antiga (16/jul) |
| `appApontador_v20260805.apk` | 118 MB | Build **06/ago** — **antes** do commit `14cf5d3` |
| **`Rdo_Apontador_11082026.apk`** | 118 MB | Build **11/ago** — inclui `14cf5d3` |

**Evidência bundle JS** (strings no `index.android.bundle`):

| String | APK 05/08 | APK 11/08 |
|--------|-----------|-----------|
| `getObraIconColor` | ❌ | ✅ |
| `fieldsColumn` / `fieldFull` | ❌ | ✅ |
| `Unidade escolar` | ✅ | ✅ (string ainda presente no bundle compartilhado) |

Hashes SHA256 distintos entre 05/08 e 11/08 — builds diferentes; tamanho quase igual (~118 MB).

### 10.3 Checklist: commit `14cf5d3` × APK 11/08

| # | Pedido | Status | Evidência no código (`14cf5d3`) |
|---|--------|--------|----------------------------------|
| 1 | Card Obra menor | ✅ | `width: '100%'`, padding reduzido, barra progresso 8px, ícone 36px |
| 2 | "Obra" no filtro | ✅ | Label alterado em `normal-dasboard.tsx` |
| 3 | Legenda no rodapé | ✅ | `grid` antes, `legend` depois |
| **4** | **Ícone web contratada** | **❌ parcial** | Continua **`HardHat` (lucide)**; só mudou **cor** (`getObraIconColor`) e tamanho — **não** implementou glifo equivalente ao web `icon-contratada` / `icon-contratante` |
| 5 | Card Tarefa menor | ✅ | `flexBasis: 240`, header 48px, paddings reduzidos |
| 6 | Sem cidade no card | ✅ | `subtitle` removido em `normal-work-details.tsx` |
| 7 | Datas em 1 linha | ✅ | Texto único `{dataInicio} À {dataPrevisaoFim}` |
| 8 | Medição vertical | ✅ | `fieldsColumn` + `fieldFull` em `equipamentos.tsx` |
| 9 | Remover +Etapa/+Tarefa | ✅ | Blocos removidos de `normal-work-details.tsx` |

### 10.4 Item 4 — detalhe (ícone Contratada)

**Web** (`escolher.html`):

```html
<i class="icon-{{obra.contratanteContratada}}"></i>
```

**App após `14cf5d3`** (`workCard.tsx`):

```tsx
const iconColor = getObraIconColor(card?.obra?.contratanteContratada)
<HardHat size={36} color={iconColor} />
```

**Conclusão:** operador contratada vê o **mesmo capacete** (HardHat), apenas **azul** vs **cinza** para contratante. **Não** replica o ícone CSS do web (`icon-contratada`, etc.). Confirmação visual do usuário (set/2026): ícone contratada **igual ao anterior**, diferente da versão web.

**Ação pendente:** mapear sprites/CSS web (`icon-contratada`, `icon-contratante`, …) para ícones RN (SVG/asset ou `@expo/vector-icons` custom) usando `card.obra.contratanteContratada` da API (`obraTypes.ts`).

### 10.5 Veredicto APK 11/08

**8 de 9** ajustes entregues. **Falta item 4** (ícone por perfil, não só cor no HardHat). Branch **`feature/alteracoes_apontador`** ainda **não mergeada** na `main` do GitHub.

### 10.6 Mensagem sugerida ao Dimas (pendência ícone)

> Dimas, testei o APK 11/08 (`Rdo_Apontador_11082026`). Os 9 ajustes de 08/08: a maioria entrou (card obra/tarefa, legenda, Obra no filtro, datas, medição vertical, sem +Etapa/+Tarefa). Falta o **item 4 — ícone do Card de Obra**: hoje continua HardHat lucide só com cor diferente. No Sistema web é `icon-{{obra.contratanteContratada}}`. Preciso do ícone equivalente ao web, não só azul/cinza no mesmo capacete. Pode corrigir na `feature/alteracoes_apontador` e mandar novo build?

---

## 11. Parágrafo para o Dimas (atualizado set/2026)

> Dimas, testamos o APK **11/08** (`Rdo_Apontador_11082026`): **8 de 9** ajustes de UI de 08/08 entraram — obrigado. **Falta o item 4** (ícone do Card de Obra igual ao web `icon-contratanteContratada`, não só HardHat com cor). Spec atualizada: **não trancar etapa Equipamentos** (accordion OK). Próximos focos: corrigir ícone, pasta **Apontamentos** com API própria, merge `feature/alteracoes_apontador` → `main`.
