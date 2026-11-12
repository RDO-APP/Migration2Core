# CMS — Grupo, Menu, Página (RBAC = DNA do RDO App)

**Trilha:** EQ-L (catálogo) · ponte Loja × Sistema · **não** é tela operador P1–P5.  
**Atualizado:** 2026-11-01 · prints prod + DBeaver `homol_rdoapp` / `novo_rdoapp`.  
**Orquestrador:** [`../ORQUESTRADOR-MIGRACAO.md`](../ORQUESTRADOR-MIGRACAO.md) § DNA · **Manual:** [`../manual-frontend-rdo-equipamentos-prod-core-mobile.md`](../manual-frontend-rdo-equipamentos-prod-core-mobile.md) §5 / §12.  
**Ponte:** skill `ponte-loja-sistema-rdo`.

Quem vê o CMS: `colaborador.col_st_admin == true` → `LoginModel.ObterMenuDefault` injeta Grupo, Menu, Página, Histórico **no login** (não depende da obra).

**Não** passar este CMS ao dono da assinatura: `grupo` + `grupo_pagina_acao` são **templates globais** (todos os tenants da mesma `licenca`). Dono só **atribui** um dos 5 papéis da **licença comprada** (#29).

---

## 0. DNA — três eixos (nunca misturar)

O acesso **não** é “admin vs usuário”. É o produto:

```
Loja (plano) → licenca → 5 templates de grupo
                    ↘
Obra: Contratante (t)  |  Contratada (d)
         Diretor · Engenheiro          Diretor · Engenheiro · Operador
                    ↘
grupo_pagina_acao  →  Routes[]  →  o que o colaborador vê e faz
menu               →  drawer (9 itens iguais para todos os clientes)
```

| Eixo | Onde | O que decide |
|------|------|----------------|
| **1. Plano Loja** | `tipoLicenca` → `licenca.lic_ds_licenca` → `grupo.gru_id_licenca` | **Qual conjunto** de 5 templates existe para aquele tenant |
| **2. Lado da obra** | `gru_st_contratante` 1=`t` Contratante · 2=`d` Contratada · `oco_st_contratante_contratada` | Quem assina de cada lado; filtro ao vincular colaborador |
| **3. Subperfil** | nome do `grupo` + `gru_st_diretor` + GPA | Diretor / Engenheiro / **Operador (só Contratada)** — **Assinar/Editar** e o resto das páginas |

**Não existe** Operador Contratante.

Homolog Core lê **`homol_rdoapp`**. Prod EQ-L lê **`novo_rdoapp`**. **Não** copiar matriz de um catálogo para o outro.

### 0.1 Loja → `licenca` → rótulo no grupo

`ServicoLoja` manda `tipoLicenca` igual a `lic_ds_licenca` (não usar `gratuita`/`basica` no payload). O **nome** do grupo ainda diz Gratuita/Básica.

| Plano Loja (slug) | `tipoLicenca` / `lic_ds_licenca` | Rótulo nos 5 grupos |
|-------------------|----------------------------------|---------------------|
| `plano-gratuito` | **BASIC2** | **Gratuita** |
| `plano-basico` | **FULL** | **Básica** |
| `plano-equipamentos` | **Equipamentos** | **Equipamentos** (`gru_id_licenca = 18` no prod) |

Limites de quantidade (obras, tarefas, fotos, logo PDF) vêm da row `licenca`. **Páginas e ações** vêm do **grupo**. Vertical Equipamentos vs Piscinas no runtime ainda nasce do **grupo na obra**, não de um SKU separado no checkout (SKU Equipamentos na Loja existe; ACL continua no grupo).

Campo legado `statusBasicaGratuita` = **string do `gru_nm_nome`**. Mobile ainda roteia por essa string (ignora `Routes[]`).

### 0.2 Os 15 templates (5 papéis × 3 planos)

Todos usam **Menu Colaborador**. Criador da obra recebe o grupo `gru_st_diretor = 1` do **mesmo lado** e da **mesma licença**.

| Papel | Lado | Diretor? | Gratuita (BASIC2) | Básica (FULL) | Equipamentos (18) |
|-------|------|:--------:|-------------------|---------------|-------------------|
| Diretor Contratante | `t` | sim | Diretor Contratante (Gratuita) | Diretor Contratante (Básica) | Diretor Contratante (Equipamentos) · prod **35** |
| Engenheiro Contratante | `t` | não | Engenheiro Contratante (Gratuita) | Engenheiro Contratante (Básica) | Engenheiro Contratante (Equipamentos) · prod **36** |
| Diretor Contratada | `d` | sim | Diretor Contratada (Gratuita) | Diretor Contratada (Básica) | Diretor Contratada (Equipamentos) · prod **37** |
| Engenheiro Contratada | `d` | não | Engenheiro Contratada (Gratuita) · homol **26** | Engenheiro Contratada (Básica) · homol **31** | Engenheiro Contratada (Equipamentos) · prod **38** |
| Operador Contratada | `d` | não | Operador Contratada (Gratuita) | Operador Contratada (Básica) | Operador Contratada (Equipamentos) · prod **39** |

**Extras** (não são os 5 papéis da obra): `Colaborador` (duas linhas na lista prod) · `Terceirizado`.

**Assinar / Editar RDO** = **(A)** GPA `assinarRdo`/`editar` em `/rdo/index` no grupo da sessão **e** **(B)** `t`/`d` × status do RDO. Homolog (`homol_rdoapp`): Engenheiro Contratada **tem** (A); Operador Contratada **não tem** (A) → cinza mesmo sendo `d`. Prod Equipamentos (`novo_rdoapp` 35–39): os 5 tinham (A) no CSV — **não** usar isso para homolog.

---

## 1. Três tabelas (o que cada tela edita)

| Tela prod | URL | Tabela | Papel |
|-----------|-----|--------|--------|
| **Grupo** | `#/grupo/index` · `#/grupo/cadastro` | `grupo` + `grupo_pagina_acao` | Perfil: nome, menu, licença, Diretor, Contratante/Contratada, **checkboxes** página×ação |
| **Menu** | `#/menu/index` · `#/menu/cadastro` | `menu` + páginas do menu | Quais **itens o drawer** lista |
| **Página** | `#/pagina/index` · `#/pagina/cadastro` | `pagina` + `pagina_acao` / `acao` | Catálogo de rotas (`/rdo/index`, …) e ações possíveis (`visualizar`, `assinarRdo`, …) |

Fluxo: **Página** define o que existe → **Menu** escolhe o que aparece no hamburger → **Grupo** marca o que aquele perfil pode **fazer** em cada página.

O Core homolog (`PermissionHelper`) lê só o 3º passo (`Routes[]` pós-`LoginObra` = `grupo_pagina_acao`). O drawer homolog mapeia `LoginData.Menu` ([`m4-7-menu-nav-stubs.md`](m4-7-menu-nav-stubs.md)).

---

## 2. Menus (print `#/menu/index`)

Só **dois** menus no prod:

| Título | Alias | Quem usa |
|--------|-------|----------|
| **Menu Admin** | `admin` | Só `col_st_admin` (CMS) |
| **Menu Colaborador** | `MenuColaborador` | **Todos** os grupos de cliente (Gratuita / Básica / Equipamentos / Colaborador / Terceirizado) |

### 2.1 Menu Colaborador (print cadastro) — 9 itens do drawer

Ordem na tela:

| Título | URL (prod) | Homolog EQ-R (06/11 · tip `1bb526c`) |
|--------|------------|--------------------------------------|
| Equipamentos | `/equipamentos/index` | SPA `EquipamentoIndexPage` + BFF (lista obra) · cadastro ainda EmMigracao |
| Colaboradores | `/colaborador/index` | SPA `ColaboradorIndexPage` + BFF (lista obra) · cadastro ainda EmMigracao |
| Efetivo Diário | `/efetivo/index` | 🟡 SPA+BFF `/Efetivo/Index` (sem Copiar/Novo colab) |
| Card de Tarefas | `/tarefa/cards` | ✅ SPA `/Tarefa/Cards` |
| RDOs | `/rdo/index` | ✅ SPA `/Rdo/Index` |
| Obras | `/obra/index` | stub EmMigracao `/obra/index` |
| Empresas | `/empresa/index` | SPA `EmpresaIndexPage` + BFF (lista obra) · cadastro ainda EmMigracao |
| Etapas | `/etapa/index` | stub EmMigracao `/etapa/index` (+ cadastro SPA `/Etapa/Cadastro`) |
| Códigos de Paralizações | `/tarefa/paralizacoes/index` | stub EmMigracao · **CAT-PARALIZ-01** antes de CRUD real |

Chart, Dashboard, Grupo, Menu, Página **não** estão neste menu. Chart/Dashboard entram por **header** + `ObterRotasDefault` / `grupo_pagina_acao` (`/chart`, `/dashboard/index`) — ver [`m4-7g-rbac-shell-p1-p3.md`](m4-7g-rbac-shell-p1-p3.md).

---


### 2.2 Header (fora do drawer) — botões/ícones prod

| Controle | URL prod | Homolog | Gate RBAC shell |
|----------|----------|---------|-----------------|
| Gráfico geral (chart) | `/chart` | ✅ SPA `/Chart/Index` | `showChart` ← `visualizar` `/chart` |
| Dashboard da obra | `/dashboard/index` | ✅ SPA `/Dashboard/Index` | `showDashboardObra` ← `acessarDashboard` |
| Nova obra (se perfil) | `/obra/cadastro` | 🟡 SPA editar obra selecionada `/Obra/Cadastro` (não “nova” full) | `showNovaObra` ← `visualizar` `/obra/cadastro` |
| Trocar senha (user menu) | `/colaborador/alterarsenha` | `/Account/ChangePassword` | sempre no menu usuário |
| Logo | — | `/Obra/Escolher` | — |

**Smoke G5 (menu ☰):** logado + obra → abrir cada item do drawer → **200** (SPA ou EmMigracao), **sem 404**. Admin (`grupo`/`menu`/`pagina`) só se `col_st_admin`.

## 3. Grupos (prints `#/grupo/index` páginas 1–2)

**5 papéis × 3 licenças** + dois genéricos. Todos com **Menu Colaborador**.

| Papel | Gratuita | Básica | Equipamentos |
|-------|:--------:|:------:|:------------:|
| Diretor Contratante | ✓ | ✓ | ✓ |
| Engenheiro Contratante | ✓ | ✓ | ✓ |
| Diretor Contratada | ✓ | ✓ | ✓ |
| Engenheiro Contratada | ✓ | ✓ | ✓ |
| Operador Contratada | ✓ | ✓ | ✓ |

**Não existe** Operador Contratante.  
**Extra:** `Colaborador` (duas linhas na lista) · `Terceirizado`.

Campos do cadastro de grupo: Descrição · Menu · **Licenca** · **Status Diretor** (Comum / Diretor) · **Contratante/Contratada** (`gru_st_contratante` 1=`t` / 2=`d`) · grade `grupo_pagina_acao`.

Criar obra: o logado recebe o grupo com `gru_st_diretor == 1` + mesmo lado + mesma `licenca` (`ObraModel.SalvarColaboradorLogado`).

Assinar/Editar RDO: **(A)** ações `assinarRdo` / `editar` em `/rdo/index` no **grupo da obra** **e** **(B)** `t`/`d` × status.

**UI 01/nov (Lucio — mandatório):** **Operador Contratada = ícones cinza**; **Engenheiro Contratada = azuis**. Os dois são lado `d`. Logo **não** é só (B). É **(A) no grupo**.

`/rdo/index` tem **duas** `pagina_acao` com alias `assinarRdo` (linhas duplicadas). Em **prod Equipamentos** as duas estão nos 5 grupos. Em **homol** só no Engenheiro Contratada (Gratuita/Básica).

### 3.1 Equipamentos — RDS `novo_rdoapp` (DBeaver 01/nov/2026)

Licença **`gru_id_licenca = 18`** · `lic_ds_licenca = Equipamentos`. `gru_st_contratante`: 1 = contratante (`t`), 2 = contratada (`d`).

| gru_id | Nome | Diretor | Cte/Cta |
|--------|------|:-------:|:-------:|
| 35 | Diretor Contratante (Equipamentos) | 1 | 1 |
| 37 | Diretor Contratada (Equipamentos) | 1 | 2 |
| 36 | Engenheiro Contratante (Equipamentos) | — | 1 |
| 38 | Engenheiro Contratada (Equipamentos) | — | 2 |
| 39 | Operador Contratada (Equipamentos) | — | 2 |

Matriz **marcada** (CSV recorte `/rdo/*` `/tarefa/cards` `/obra/lista` `/obra/cadastro` `/colaborador/index`). ✓ = linha em `grupo_pagina_acao`. Dir Cta ≈ Dir Cte neste recorte.

| Ação | url | Dir Cta | Dir Cte | Eng Cta | Eng Cte | Op Cta |
|------|-----|:-------:|:-------:|:-------:|:-------:|:------:|
| `assinarRdo` | `/rdo/index` | ✓ | ✓ | ✓ | ✓ | ✓ |
| `editar` | `/rdo/index` | ✓ | ✓ | ✓ | ✓ | ✓ |
| `visualizar` `criarNovo` `gerarRdo` | `/rdo/index` | ✓ | ✓ | ✓ | ✓ | ✓ |
| `deletar` | `/rdo/index` | ✓ | ✓ | — | — | — |
| `editar` `visualizar` | `/rdo/cadastro` | ✓ | ✓ | ✓ | ✓ | ✓ |
| `gerarRdo` `visualizar` `editar` `visualizarRegistro` `acessarDashboard` | `/tarefa/cards` | ✓ | ✓ | ✓ | ✓ | ✓ |
| `criarNovo` | `/tarefa/cards` | ✓ | ✓ | ✓ | — | ✓ |
| `editarObra` | `/tarefa/cards` | ✓ | ✓ | ✓ | ✓ | — |
| `aterarStatusEmMassa` | `/tarefa/cards` | ✓ | ✓ | ✓ | ✓ | — |
| `deletar` | `/tarefa/cards` | ✓ | ✓ | — | — | — |
| `visualizar` | `/obra/lista` `/obra/cadastro` | ✓ | ✓ | ✓ | ✓ | ✓ |
| `editar` | `/obra/cadastro` | ✓ | ✓ | ✓ | ✓ | — |
| `criarNovo` `enviarConvite` `editar` | `/obra/lista` | ✓ | ✓ | ✓ | ✓ | — |
| `copiarObra` | `/obra/lista` | ✓ | ✓ | — | ✓ | — |
| `visualizar` `acessarDashboard` `gerarRdo` | `/colaborador/index` | ✓ | ✓ | ✓ | ✓ | ✓ |
| `editar` `criarNovo` | `/colaborador/index` | ✓ | ✓ | ✓ | ✓ | — |
| `deletar` | `/colaborador/index` | ✓ | ✓ | — | — | — |

CSV prod (`novo_rdoapp` licença 18): grupo 39 tinha linhas `assinarRdo`/`editar` em `/rdo/index`. **Não usar para homolog.**

### 3.2 Homolog — RDS `homol_rdoapp` (DBeaver 01/nov/2026)

`JOIN` em `assinarRdo`/`editar` em `/rdo/index` — **só Engenheiro Contratada**. Nenhuma linha Operador Contratada.

| gru_id | Nome | licença | ações |
|--------|------|---------|--------|
| 26 | Engenheiro Contratada (Gratuita) | BASIC2 | `assinarRdo` (2×) · `editar` |
| 31 | Engenheiro Contratada (Básica) | FULL | `assinarRdo` (2×) · `editar` |

Dois `assinarRdo` = duas `pagina_acao` com o mesmo alias (igual ao CSV prod). O Core homolog está certo: Operador sem GPA → `showAssinarRdo`/`showEditarRdo` false → ícones cinza. Engenheiro com GPA → azuis (lock B ainda aplica `t`/`d` × status).

Fonte CSV: Desktop `*_202611011216.csv` · **não** versionar.

---

## 4. Catálogo Página (prints `#/pagina/index` 1–4)

Inventário **títulos visíveis** (prod, status Ativo). Cadastro de cada página (quais `acao` existem) **não** fotografado.

| Título | Alias | URL |
|--------|-------|-----|
| Grupo | grupo | `/grupo/index` |
| Menu | menu | `/menu/index` |
| Grupo Cadastro | cadastroGrupo | `/grupo/cadastro` |
| Pagina | pagina | `/pagina/index` |
| Pagina Cadastro | paginaCadastro | `/pagina/cadastro` |
| Menu Cadastro | cadastroMenu | `/menu/cadastro` |
| Obra Escolher | obraescolher | `/obra/escolher` |
| Obra Cadastro | obracadastro | `/obra/cadastro` |
| Equipamentos | equipamentos | `/equipamentos/index` |
| Equipamentos Cadastro | equipamentosCatastro | `/equipamentos/cadastro` |
| Colaboradores | colaborador | `/colaborador/index` |
| Colaborador Cadastro | colaboradorCadastro | `/colaborador/cadastro` |
| Tarefa | tarefa | `/tarefa/index` |
| Tarefa Cadastro | tarefaCadastro | `/tarefa/cadastro` |
| Card de Tarefas | tarefacards | `/tarefa/cards` |
| Obra Lista (excluir) | obra | `/obra/lista` |
| RDOs | rdo | `/rdo/index` |
| Rdo Cadastro | rdoCadastro | `/rdo/cadastro` |
| Obras | obra | `/obra/index` |
| Empresas | empresa | `/empresa/index` |
| Empresa Cadastro | empresaCadastro | `/empresa/cadastro` |
| Alterar Senha | alterarsenha | `/colaborador/alterarsenha` |
| Dashboard | dashboard | `/dashboard/index` |
| Relatório de Produtividade | relatorioProdutividade | `/relatorioprodutividade/index` |
| Etapa Cadastro | etapacadastro | `/etapa/cadastro` |
| Etapas | etapa | `/etapa/index` |
| Relatório de Medição | RelatorioMedicao | `/relatoriomedicao/index` |
| Gráfico Geral | GraficoGeral | `/chart` |
| Gráfico RDOs | GraficoRdos | `/chart/rdos` |
| Gráfico RDOs Atrasado | GraficoRdosAtrasados | `/chart/atrasado` |
| Gráfico Dia Improdutivo | GraficoDiaImprodutivo | `/chart/diaimprodutivo` |
| Gráfico Tarefas | GraficoTarefas | `/chart/tarefa` |
| Gráfico Comentários | GraficoComentarios | `/chart/comentario` |
| Efetivo Diário | efetivo | `/efetivo/index` |
| Relatório efetivo diário | relatorioefetivodiario | `/relatorioefetivodiario/index` |
| Histórico de Acessos | historicoacesso | `/historicoacesso/index` |
| Códigos de Paralizações | CodigosParalizacoes | `/tarefa/paralizacoes/index` |

Alias `obra` aparece em **Obra Lista** e **Obras** (URLs diferentes `/obra/lista` vs `/obra/index`) — não unificar sem olhar `pag_id_pagina`.

---

## 5. Manual / orquestrador — o que já tinha vs o que faltava

| Item | Já estava | Faltava (fechado 01/nov neste doc + §12 do manual) |
|------|-----------|-----------------------------------------------------|
| `Permission.check` / `PermissionHelper` por `path` + ação | [`m4-7g-rbac-shell-p1-p3.md`](m4-7g-rbac-shell-p1-p3.md) | Ligar **shell** `showAssinarRdo` / `showEditarRdo` (`assinarRdo`/`editar` em `/rdo/index`) na tabela do 7g |
| Rotas mudam no **Selecionar obra** (`oco_id_grupo`) | m4-7g § P1→P3 | — |
| Drawer homolog mapeia `menuPaginas` | [`m4-7-menu-nav-stubs.md`](m4-7-menu-nav-stubs.md) | Distinguir **Menu Colaborador** (9 itens) vs **Menu Admin** |
| P6 “grupo/colaborador em migração” | manual §10.8 | **Separar P6a** colaborador/empresa/obra (gestor tenant) **P6b** Grupo/Menu/Página (`col_st_admin`) |
| Dono ≠ admin CMS | proposta §10.3 · ponte | Prints: 5×3 grupos; só 2 menus; catálogo Página; **não** copiar CMS ao dono |
| Assinar/Editar cinza | `habilitarAssinarRdo` + W3 | **Homolog:** Operador sem (A); Engenheiro com (A). **Prod Equipamentos CSV:** os 5 têm (A) — outro catálogo |
| Matriz 5 Equipamentos | — | **Fechado** 01/nov DBeaver §3.1 (`licenca` 18) `novo_rdoapp` |
| DNA Loja × 15 grupos | proposta §10 | **§0 deste doc** + orquestrador § DNA |
| Cadastro Página (lista de `acao`) | print Diretor Cte Gratuita + CSV aliases | Suficiente para #29 |
| `gru_id_licenca` Equipamentos | — | **18** · `lic_ds_licenca=Equipamentos`. Gratuita vs rótulo BASIC na UI = outro grupo |
| Painel Dono (atribui template) | proposta §4.2 futuro | **Não** implementar neste ciclo M7 |
| Homolog SPA `#/grupo` `#/menu` `#/pagina` | stub “Em migração” | **Marco M10** (cutover). Até lá canônico = **EQ-L prod**. **Não** M5/M7. **≠** #29 |

---

## 6. Plano Dono (não é M7)

**Backlog:** Melhorias 1.0 **#29** (ponte Loja × Sistema) · orquestrador § *Melhorias produto*.

1. **Fase 1:** dono da `empresa` **atribui** um dos 5 templates da **licença da assinatura** ao colaborador na obra. Sem tela de checkboxes.  
2. **Fase 2 (opcional):** clone por empresa + `features[]`.  
3. **Nunca:** `col_st_admin` no cliente; editar Página/Menu; alterar template global.

Export útil (em vez de 15 prints): `grupo` ⋈ `grupo_pagina_acao` ⋈ `pagina` ⋈ `acao` filtrado pela `licenca` da assinatura.

---

## 7. Dump DBeaver (completar IDs Gratuita/Básica)

Rodar **duas vezes**: `USE homol_rdoapp;` e `USE novo_rdoapp;` — colunas iguais, **ids diferentes**.

```sql
-- grupos
SELECT g.gru_id_grupo, g.gru_nm_nome, l.lic_ds_licenca, g.gru_id_licenca,
       g.gru_st_diretor, g.gru_st_contratante, m.men_ds_alias
FROM grupo g
LEFT JOIN licenca l ON l.lic_id_licenca = g.gru_id_licenca
LEFT JOIN menu m ON m.men_id_menu = g.gru_id_menu
ORDER BY l.lic_ds_licenca, g.gru_nm_nome;

-- menus + páginas do drawer
SELECT m.men_id_menu, m.men_nm_titulo, m.men_ds_alias,
       p.pag_nm_titulo, p.pag_ds_url, mp.mpa_vl_ordem
FROM menu m
JOIN menu_pagina mp ON mp.mpa_id_menu = m.men_id_menu
JOIN pagina p ON p.pag_id_pagina = mp.mpa_id_pagina
ORDER BY m.men_ds_alias, mp.mpa_vl_ordem;

-- catálogo página
SELECT pag_id_pagina, pag_nm_titulo, pag_ds_alias, pag_ds_url, pag_st_status
FROM pagina
ORDER BY pag_id_pagina;
```