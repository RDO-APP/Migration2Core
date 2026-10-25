# Rastreio Dimas (TSK) × marcos M* — execução homolog

**Trilha:** docs / orquestrador · **Atualizado:** 2026-10-25  
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
2. Ler **esta página** — coluna **Gap TSK** do cluster em que a sessão atua.
3. Ao **fechar marco** ou entrega grande: atualizar snapshot §3 e, se novo gap, §4.

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
| RDO · laudo web | 31…36 | M5, M7+ | ◐ | Listagem/chart stub; cadastro RDO real — **M5/M7** |
| Relatórios · S3 worker | 37…39 | Onda 5 / M7+ | ☐ | Dapper/Excel/PDF gestor |
| OpenAPI · ETL · cutover | 40…45 | M6, M8, M10, Onda 6 | ☐ | ETL **adiado** vs PDF mês 4 — **correto** no plano M* |
| Mobile greenfield | 46…56 | M5, M6 | ⏸ | **Não rebuild** — integrar RN existente |
| Onda 0 (só Lucio) | U-01…08 | M5, M1 | ◐ | Apontamento Framework, `@rdoapp/shared`, OpenAPI cedo |
| Imutabilidade | TSK-32 | **F** | — | Chat **FAPESC Execução** · `rdo-blockchain` |
| Front legado BS3/CSS/fontello | — | M4.7 (**UI-M2c**), UI-M3 | ◐ | Fase A copiar glifos: [`fontello-fa-legado-marcos-ui.md`](fontello-fa-legado-marcos-ui.md) · Fase B **UI-M3** pós-M7 |

**Marco ativo:** **M4** (M4.7 paridade ícones/menu · doc fontello marcos) → **M4.8** → **M5…M7**.

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

**Ação do agente:** se a sessão implementar algo que **fecha** uma linha acima, atualizar §3 e registrar commit/marco no orquestrador **Próxima ação**.

---

## Links

| Doc | Uso |
|-----|-----|
| [comparativo-dimas-v20260818.md](../estudos-lucio-apps-plano-migracao-core/comparativo-dimas-v20260818.md) | Tabela TSK ↔ U completa |
| [comparativo-e-plano-unificado.md](../estudos-lucio-apps-plano-migracao-core/comparativo-e-plano-unificado.md) | Filosofia strangler × reescrita |
| [migracao-kiro-mapa-estudo.md](../migracao-kiro-mapa-estudo.md) | Kiro × TSK Onda 1 |
| [plano-execucao-migracao-v1.md](../plano-execucao-migracao-v1.md) | Sequência M0…M10 |
