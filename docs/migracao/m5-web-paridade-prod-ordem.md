# M5 web (Onda B) — ordem para sintonizar homolog com produção

**Trilha:** EQ-R · **Decisão 2026-10-26:** **M5 EQ-M (Apontador)** **adiado** — foco **100% web** até **G-M5** + avanço **M7**.  
**Gate:** [`dimas-entrada-paralela-pos-m4.md`](dimas-entrada-paralela-pos-m4.md) **G-M5** — RDO/Chart/Dashboard **não** só EmMigracao.

**Nota:** marco **M5** no [`plano-execucao-migracao-v1.md`](../plano-execucao-migracao-v1.md) = mobile; aqui **M5 web** = Onda B (telas listagem/gráfico). Evitar confusão com **M5-nav** (menu drawer).

---

## Já ≈ produção (homolog)

| P | Tela | Observação |
|---|------|------------|
| P1 | Login | Funcional Razor · **M4.8** = SPA, mesma regra |
| P2 | Escolher | React + BFF |
| P3 | Cards (lista tarefas) | React + BFF · cadastros/modais = **M7** |

---

## Fila web — uma frente por PR/deploy

| Ordem | Destino stub hoje | Referência prod | Marco |
|:-----:|-------------------|-----------------|-------|
| **0** | — | **M4.8** ☑ · M4.7 smoke ☑ (fontello = backlog UI-M1) | Pré-M5 web |
| **1** | `/Rdo/Index` | `#/rdo/index` | **M5 web** ☑ listagem BFF + React (ações M7+) |
| **2** | `/Chart/Index` + `/chart/*` | `#/chart` | **M5 web** |
| **3** | `/Dashboard/Index` | `#/dashboard/index` | **M5 web** |
| **4** | `/Rdo/Cadastro` | `#/rdo/cadastro` · toolbar Gerar RDO | **M7** |
| **5** | `/Obra/Cadastro` | `#/obra/cadastro` | **M7** |
| **6** | `/Efetivo/Index` | `#/efetivo/index` | **M7** |
| **7** | `/Tarefa/Index`, `/Tarefa/Cadastro`, `/Etapa/Cadastro` | toolbar + card | **M7** |
| **8** | Menu admin (colaborador, equipamento, relatórios…) | drawer | **M7+** |
| **9** | Nova medição | modal cards | **P4 · M7+** |

Critério “sintonizado”: mesma **informação e ações principais** que prod para aquela rota (não exige pixel-perfect — **UI-M3** adiado).

---

## Apontador (EQ-M) — adiado até quando

| Pode adiar sem bloquear web | Reabrir Apontador quando |
|-----------------------------|---------------------------|
| Todo **M5 web** + grande parte de **M7** web | **Antes de G-M6** se mobile homolog Core for obrigatório |
| Prod mobile segue **EQ-L** + cenário **A** | **Obrigatório antes de M9 D4** (pacote homolog v1) |
| | **Obrigatório antes de cutover Onda 6** (campo na API/Core nova) |

**Revisão da decisão:** ao fechar **G-M5** (listagens/gráficos web reais) ou se **M6** (OpenAPI/JWT) for priorizado — o que vier **primeiro**.
