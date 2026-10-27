# Rastreio Dimas (TSK) × marcos M* — execução homolog

**Trilha:** docs / orquestrador · **Atualizado:** 2026-10-27  
**Dono da execução:** plano **M\*** ([`plano-execucao-migracao-v1.md`](../plano-execucao-migracao-v1.md) + [`ORQUESTRADOR-MIGRACAO.md`](../ORQUESTRADOR-MIGRACAO.md))  
**Referência Dimas:** PDF **Backlog_RDO v20260818** → [`../estudos-lucio-apps-plano-migracao-core/comparativo-dimas-v20260818.md`](../estudos-lucio-apps-plano-migracao-core/comparativo-dimas-v20260818.md) (TSK-01…56 × Ondas U)

---

## Decisão de governança (2026-10-25)

| Regra | Texto |
|-------|--------|
| **Quem manda na ordem** | **Marcos M\*** + Ondas U (strangler). **Não** seguir Sprint 1→8 linear do PDF como cronograma. |
| **Papel do Dimas** | **TSK = inventário técnico** da solução alvo. Reordenação e cutover = plano unificado (ver comparativo §2). |
| **Time Dimas** | **Incerto** — execução continua **Lucio + Cursor** até (se) Dimas entrar; **possível concluir homolog v1 sem Dimas**. |
| **Decisão Lucio (2026-10-25)** | **Seguir plano M\*** sem Dimas **por enquanto**. Entrada futura = **paralelo**, aproveitando BFF/React/homolog existentes — **não** reiniciar Sprint 1 PDF. Marco de encaixe: **M5/M6** + doc [`dimas-entrada-paralela-pos-m4.md`](dimas-entrada-paralela-pos-m4.md). |
| **Transição suave Dimas** | Rampa Ondas **A→D** + gates **G-M4…G-M8** — **obrigatória** mesmo sem Dimas no time; ver § *Transição suave* no doc acima. |
| **Quando Dimas entrar** | Revalidar estimativas; exportar TSK→issues; **não** inverter M4→M8 sem gate. Storytelling: [`storytelling-unificado-dimas-migracao-fapesc.md`](../estudos-lucio-apps-plano-migracao-core/storytelling-unificado-dimas-migracao-fapesc.md). |
| **Conflito explícito** | Strangler (M\*) **vence** big-bang Sprint 6 do PDF; mobile **evoluir** (M5) **vence** TSK-46…48 greenfield. |

---

## Ritual — início de sessão (chat Migração)

1. Ler [`ORQUESTRADOR-MIGRACAO.md`](../ORQUESTRADOR-MIGRACAO.md) — **Próxima ação (1)** e marco ativo.
2. Ler **esta página** — §2 **Etapas M\*** (coluna **Dimas**) e §3 **clusters TSK** (coluna **Gap TSK**) do cluster da sessão.
3. Ao **fechar marco** ou entrega grande: atualizar §2 e §3; se novo gap U/TSK, §4.

---

## Snapshot — etapas M* × Dimas (2026-10-27)

Espelha [`ORQUESTRADOR-MIGRACAO.md`](../ORQUESTRADOR-MIGRACAO.md) § *Pendências por marco* + leitura vs PDF **Backlog_RDO v20260818**. Git app homolog: **`fd8a144`** · docs orquestrador **`9f68a4f`**.

**Posição vs PDF Dimas:** execução **M\*** + strangler (não Sprint 1→8 linear). **À frente** do PDF no operador web homolog (P1–P3, RDO listagem). **Atrás / diferente:** fundação “completa” TSK-01…10, gestor TSK-14…16, apontamento TSK-24…30, relatórios TSK-37…39, OpenAPI/ETL TSK-40…45, mobile greenfield TSK-46…56 (**⏸** — evoluir RN). **Encaixe Dimas:** paralelo **M5/M6** — [`dimas-entrada-paralela-pos-m4.md`](dimas-entrada-paralela-pos-m4.md).

Legenda coluna **Dimas:** **◐** parcial vs backlog · **☐** alvo Dimas ainda não coberto pelo M\* · **⏸** adiado de propósito · **—** fora escopo homolog Equipamentos / trilha **F**

| Marco | Feito | Ainda pendente | **Dimas** (cluster / TSK · relação ao PDF) |
|-------|--------|----------------|---------------------------------------------|
| **M0** | A1–A5, Vite, v0 API, E2E login→Escolher, docs E0–E6 | Branding homolog; E2 localhost | **◐ Fundação** TSK-01…10 · Sprint 1 “arranque” — só **fatia** (host + SPA + build); falta stack “completa” Dimas |
| **M0′** | Matriz, manual ①–⑥, Fase A PASS | HAR API prod (opcional) | **◐ Onda 0 / doc** U-01…08 · alinha prod×Core×mobile; **não** substitui TSK de implementação |
| **M1** | Cenário **A**, v1 endpoints, tipos TS, mapa Core×legado | Pacote npm; EQ-M não consome | **◐ Contrato** · antecipa OpenAPI/U-05 (**TSK-40…41** cedo no espírito, **☐** pacote npm formal) |
| **W0.5 / E2E** | Selecionar + Cards React; **M3 PASS** | Itens históricos toolbar (já avançaram em M4) | **◐ TSK-17…23 leitura** · operador vê obra/tarefas; **☐** cadastro/lista/filtro escrita |
| **M2** | **FECHADO** | — | **◐ Obra·etapa·tarefa** TSK-17…23 · **leitura Cards** ≈ early Sprint operador; **☐** use cases escrita |
| **M3** | **FECHADO** | E2E passos 6–7 opcional | **—** gate produto Lucio · **não** é marco nomeado no PDF; equivalente a homolog aceito antes de cortar Razor |
| **M4** | M4.1–M4.7g ☑, **M4.8** Login SPA ☑ | G5/G6; **UI-M1/M2c**; congela EQ-W formal | **◐ Front** (fontello/BS3) + **◐ Identity/RBAC** TSK-11…13 (shell/menu/stubs) · **☐** `usePermission`/CRUD · strangler **≠** app React gestor Sprint 2–3 |
| **M5 web** (Onda B) | RDO listagem **T5 E**; W1/W2 **`fd8a144`** | T6 smoke; W3; M7 ações; Chart; Dashboard | **◐ RDO·laudo** TSK-31…36 · listagem BFF+React; **☐** cadastro/laudo/PDF/assinar · **◐** gráficos U-56/U-57 (Chart **#2** stub) |
| **M5 EQ-M** (plano v1) | — | **⏸ adiado** | **⏸ Mobile** TSK-46…56 · PDF = greenfield RN · **M\*** vence: integrar **EquipamentosMobile**, não rebuild |
| **M6** | — | JWT/OpenAPI spike; mobile homolog API | **☐ Fundação auth** TSK-07 · **☐ OpenAPI** TSK-40…41 · ponto natural **entrada Dimas** (Application/API v1) |
| **M7+** | Stubs P3, RBAC shell | CRUD, **P4** medição, PDF/assinar RDO | **☐** TSK-14…16 gestor · **☐** TSK-24…30 apontamento/medição · **☐** TSK-31…36 ações RDO · **◐** RBAC fino 11…13 |
| **M8** | Branch CI, roteiro D→E | Runway &lt;2 min; gate workflow | **◐ Infra deploy** (parte TSK-01…05) · **☐** pipeline “produto Dimas” · **☐** ETL TSK-43 (**Onda 6 only**, adiado ✓) |
| **M9** | — | D1–D7 pacote homolog v1 | **◐** “release homolog v1” · cobre **fatia** operador web+doc · **☐** D4 mobile homolog · **☐** D7 pacote M1 pleno |
| **M10** | — | Onda 2 / prep Linux L1 | **☐** expansão telas + **☐** cutover Onda 6 TSK-43…45 · prep pós-v1, não Sprint linear |

**Paralelo (gate Dimas-adjacente):** **I0** B1/B2 OK — **◐** TSK-01 deploy/runway; B3 pendente.

**Fora comparativo homolog Equipamentos:** **TSK-32** imutabilidade → trilha **F** / FAPESC (**—**).

**Síntese:** strangler homolog operador (**M4 + M5 web**) alinhado ao plano unificado; **~30–40%** do “valor Dimas” visível na web (P1–P3 + RDO listagem); **~70%+** fundação/gestor/mobile/ETL no backlog TSK, **de forma intencional** até **M6/M7** (mobile **⏸** vs TSK-46…56).

---

## Snapshot — clusters TSK × M* (homolog out/2026)

Legenda: **☑** coberto pelo M* em curso/fechado · **◐** parcial · **☐** no plano M*, não feito · **⏸** adiado de propósito (≠ esquecido) · **—** Dimas only / Onda 6 / FAPESC

| Cluster Dimas (Sprint ref.) | TSK (ex.) | Marco M* | Status homolog | Gap TSK (o que Dimas prevê e M* ainda não entregou) |
|----------------------------|-----------|----------|----------------|-----------------------------------------------------|
| Fundação Core | 01…10 | M0, M1, I0 | ◐ | MediatR/Clean Arch completa, Serilog, S3, Argon2, JWT (TSK-07) — **M6** |
| Identity + RBAC web | 11…13, 12 | M6, M7 | ◐ | `usePermission` / CRUD protegido — shell BFF hoje · **M7+** |
| Cadastros gestor cedo | 14…16 | Onda 5 / M7+ | ☐ | Empresa/Colaborador/Equip CRUD React — **fora M4** |
| Obra · etapa · tarefa | 17…23 | M2, M7 | ◐ | **Leitura** Cards (M2☑); **escrita** cadastro/lista/filtro — **M7+** |
| Apontamento · medição | 24…30 | M7+, P4 | ☐ | Domínio + API; U-05 Framework antes — **Onda 0/4** |
| RDO · laudo web | 31…36 | M5 web, M7+ | ◐ | **P5a** listagem BFF **T5 E** · shell W1/W2 **`fd8a144`**; Chart stub; PDF/assinar **M7** |
| Relatórios · S3 worker | 37…39 | Onda 5 / M7+ | ☐ | Dapper/Excel/PDF gestor |
| OpenAPI · ETL · cutover | 40…45 | M6, M8, M10, Onda 6 | ☐ | ETL **adiado** vs PDF mês 4 — **correto** no plano M* |
| Mobile greenfield | 46…56 | M5, M6 | ⏸ | **Não rebuild** — integrar RN existente |
| Onda 0 (só Lucio) | U-01…08 | M5, M1 | ◐ | Apontamento Framework, `@rdoapp/shared`, OpenAPI cedo |
| Imutabilidade | TSK-32 | **F** | — | Chat **FAPESC Execução** · `rdo-blockchain` |
| Front legado BS3/CSS/fontello | — | M4.7 (**UI-M2c**), UI-M3 | ◐ | Fase A copiar glifos: [`fontello-fa-legado-marcos-ui.md`](fontello-fa-legado-marcos-ui.md) · Fase B **UI-M3** pós-M7 |

**Marco ativo:** **M4** fechamento (G5/G6 · UI-M1) **+ M5 web Onda B** (P5a RDO → Chart → Dashboard) · **M5 EQ-M ⏸** · **M6/M7** backlog.

---

## Lacunas U / TSK sem marco M* explícito (vigilância)

Fonte detalhada: comparativo Dimas §5 (**U sem TSK**). Ao planejar **M5+**, checar se algum item precisa **novo sub-marco** ou linha no [`m4-execucao-checklist.md`](m4-execucao-checklist.md) / checklist M5 quando existir.

| ID | Tema | Sugestão M* / Onda |
|----|------|-------------------|
| U-26 | Licença Operador vs Diretor | M7 ou Onda 2 comercial |
| U-33 | Lista Apontamentos web | M7+ / Onda 3 |
| U-56, U-57 | Gráficos, efetivo diário | M5/M7 (efetivo já rota stub P3) |
| TSK-01…09 “completo” | Infra fundação | Backlog pós-M4 ou com Dimas |
| TSK-43 | ETL apontamentos | **Onda 6 only** — não antecipar |

**Ação do agente:** se a sessão implementar algo que **fecha** uma linha acima, atualizar §2/§3 e registrar commit/marco no orquestrador **Próxima ação**.

---

## Links

| Doc | Uso |
|-----|-----|
| [comparativo-dimas-v20260818.md](../estudos-lucio-apps-plano-migracao-core/comparativo-dimas-v20260818.md) | Tabela TSK ↔ U completa |
| [comparativo-e-plano-unificado.md](../estudos-lucio-apps-plano-migracao-core/comparativo-e-plano-unificado.md) | Filosofia strangler × reescrita |
| [migracao-kiro-mapa-estudo.md](../migracao-kiro-mapa-estudo.md) | Kiro × TSK Onda 1 |
| [plano-execucao-migracao-v1.md](../plano-execucao-migracao-v1.md) | Sequência M0…M10 |
