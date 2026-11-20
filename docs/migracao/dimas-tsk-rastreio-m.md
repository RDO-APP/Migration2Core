# Rastreio Dimas (TSK) × marcos M* — execução homolog

**Trilha:** docs / orquestrador · **Atualizado:** 2026-11-20  
 
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

## Por que “~40% Dimas” parecia parado (esclarecimento 2026-11-15)

Havia **três números misturados** no orquestrador antigo:

| Número | O que media | out/26 | **agora (15/nov)** |
|--------|-------------|--------|---------------------|
| **% por marco M\*** | Fatia **daquele** marco (M4, M7…) | M4 ~88 · M7 ~90 | M4 **90** · M7 **92** · M5 web **94** |
| **Clusters Dimas já iniciados** | Obra/etapa/tarefa · RDO/Chart · gestor P6a · P4 | ~40% “visível” (só P1–P3+RDO+Chart) | **~75–80%** |
| **PDF Dimas total** | TSK-01…56 incl. fundação limpa + mobile⏸ + ETL Onda 6 | ~40% | **~45–50%** |

**Conclusão:** você tinha razão — o que **já começamos** (web operador) subiu para a faixa **80%**. O “~40%” ficou **stale**: media só a fatia antiga **ou** diluía com mobile/ETL/Clean Arch que **ainda não abrimos**. Caminho homolog até **M9 D1** ≈ **~65–70%**.

---

## Snapshot — etapas M* × Dimas (2026-11-15)

Espelha [`ORQUESTRADOR-MIGRACAO.md`](../ORQUESTRADOR-MIGRACAO.md) § *Pendências por marco*. Tip app: **`5f747b5`**.

**Posição vs PDF Dimas:** execução **M\*** + strangler. **À frente** no operador web (P1–P7 fatia). **Atrás / diferente:** fundação “completa” TSK-01…10, OpenAPI/ETL 40…45, mobile greenfield 46…56 (**⏸**). **Encaixe Dimas:** paralelo **M6** — [`dimas-entrada-paralela-pos-m4.md`](dimas-entrada-paralela-pos-m4.md).

Legenda coluna **Dimas:** **◐** parcial · **☐** não coberto · **⏸** adiado · **—** fora escopo / trilha **F**

| Marco | Feito | Ainda pendente | **Dimas** (cluster / TSK) |
|-------|--------|----------------|---------------------------|
| **M0** | A1–A5, Vite, v0 API, E2E, docs | Branding; E2 localhost | **◐** Fundação TSK-01…10 — fatia host/SPA |
| **M0′** | Matriz, manual ①–⑥, Fase A PASS | HAR opcional | **◐** Onda 0 doc |
| **M1** | Cenário A, v1 endpoints, tipos TS | Pacote npm; EQ-M | **◐** Contrato · **☐** npm formal |
| **W0.5 / E2E** | Cards React; **M3 PASS** | — | **◐** TSK-17…23 leitura |
| **M2** | **FECHADO** | — | leitura Cards ☑ |
| **M3** | **FECHADO** | E2E 6–7 opcional | **—** gate Lucio |
| **M4** | M4.1–M4.8 ☑ · P3 filtros/stubs `5f747b5` | G5/G6; UI-M1/M2c | **◐** Front + RBAC shell |
| **M5 web** | RDO + Chart C1–C8 + Dashboard | DOC-FICHAS | **◐** TSK-31…36 · U-56/57 **~88%** |
| **M5 EQ-M** | — | **⏸** | **⏸** TSK-46…56 |
| **M6** | **Fase 0 OK** · JWT login/me **código** (`/api/mobile/auth/*`) | SigningKey+smoke · OpenAPI YAML · LoginObra Bearer | **◐** TSK-07 · 40…41 |
| **M7+** | 7a–7d · Obra · P6a · Paralizações · P4 · colab/equip/tarefa · Efetivo/Medição PDF OK · Excel logo fix | CAT-PARALIZ · G5 · 3.1 · Terceirizado dropdown · ClosedXML Excel | **◐** escrita 17…23 · gestor 14…16 · medição 24…30 **~48%** · RBAC |
| **M8** | Branch CI, roteiro | Runway &lt;2 min | **◐** deploy · **☐** ETL 43 |
| **M9** | Fatia operador no Git | D1–D7 · smoke `5f747b5` | **◐** release fatia |
| **M10** | — | L1 · P6b | **☐** cutover |

**Paralelo:** **I0** B1/B2 OK · B3 pendente. **TSK-32** → trilha **F**.

**Síntese:** clusters **web iniciados** ≈ **75–80%**; PDF **total** ≈ **45–50%** (mobile/ETL/fundação limpa puxam a média para baixo).

---

## Snapshot — clusters TSK × M* (homolog 15/nov/2026)

| Cluster Dimas | TSK | Marco | Status | **~% cluster** | Gap TSK restante |
|---------------|-----|-------|--------|:--------------:|------------------|
| Fundação Core | 01…10 | M0, M1, I0 | ◐ | **35** | MediatR/Clean Arch, Serilog, S3, Argon2, JWT — **M6** |
| Identity + RBAC web | 11…13 | M6, M7 | ◐ | **55** | `usePermission` formal · CRUD fino |
| Cadastros gestor | 14…16 | M7+ | ◐ | **80** | Relatórios EmMigracao · polish · **CAT-PARALIZ-01** |
| Obra · etapa · tarefa | 17…23 | M2, M7 | ◐ | **85** | gaps lista/filtro fino · polish 1.5a |
| Apontamento · medição | 24…30 | M7+, P4 | ◐ | **45** | U-05 Framework pleno · foto persist |
| RDO · laudo web | 31…36 | M5, M7 | ◐ | **88** | polish Chart tiles · DOC-FICHAS |
| Relatórios · S3 | 37…39 | M7+ | ☐ | **8** | produtividade / efetivo / medição SPA |
| OpenAPI · ETL · cutover | 40…45 | M6, M8, M10 | ☐ | **5** | ETL Onda 6 only |
| Mobile greenfield | 46…56 | M5, M6 | ⏸ | **0** | Integrar RN — **não** rebuild |
| Onda 0 (Lucio) | U-01…08 | M1, M5 | ◐ | **40** | shared / OpenAPI cedo |
| Imutabilidade | TSK-32 | **F** | — | — | FAPESC |
| Front BS3/fontello | — | M4.7, UI-M3 | ◐ | **60** | UI-M1/M2c · UI-M3 pós-M7 |

**Marco ativo:** **M4** fechamento (G5/G6) **+ M5 web** **+ M7+** polish · tip **`5f747b5`** · **M5 EQ-M ⏸**.

---

## Lacunas U / TSK sem marco M* explícito (vigilância)

| ID | Tema | Sugestão M* / Onda |
|----|------|-------------------|
| U-26 | Licença Operador vs Diretor | M7 ou Onda 2 comercial |
| U-33 | Lista Apontamentos web | M7+ / Onda 3 |
| U-56, U-57 | Gráficos, efetivo diário | M5/M7 (efetivo já rota) |
| TSK-01…09 “completo” | Infra fundação | Backlog pós-M4 ou com Dimas |
| TSK-43 | ETL apontamentos | **Onda 6 only** |

---

## Se Dimas entrar agora (20/11)

**Ready (não reinventar):**
- Homolog operador web SPA+BFF · L1 Linux · `/convidada` **C4 PASS**
- M6 Fase 0 Baseline APK→prod OK (`main` `8e7eb5e`)
- Slice JWT Core: `POST /api/mobile/auth/login` · `GET /api/mobile/auth/me` (código; cookie SPA intacto)
- Docs: [`plano-m6-mobile-jwt.md`](plano-m6-mobile-jwt.md) · [`m6-fase1-jwt-openapi.md`](m6-fase1-jwt-openapi.md) · orquestrador

**Missing (encaixe paralelo):**
- `Jwt:SigningKey` Staging + smoke curl login/me
- OpenAPI YAML formal / Swagger (1.1 além do mapa markdown)
- `LoginObra` + obras/etapas/medição com **Bearer** (paridade APK)
- Pacote tipos TS (1.3) · refresh token (1.4) · Fase 2 APK→homolog

---

## Links

| Doc | Uso |
|-----|-----|
| [comparativo-dimas-v20260818.md](../estudos-lucio-apps-plano-migracao-core/comparativo-dimas-v20260818.md) | Tabela TSK ↔ U completa |
| [comparativo-e-plano-unificado.md](../estudos-lucio-apps-plano-migracao-core/comparativo-e-plano-unificado.md) | Filosofia strangler × reescrita |
| [migracao-kiro-mapa-estudo.md](../migracao-kiro-mapa-estudo.md) | Kiro × TSK Onda 1 |
| [plano-execucao-migracao-v1.md](../plano-execucao-migracao-v1.md) | Sequência M0…M10 |
