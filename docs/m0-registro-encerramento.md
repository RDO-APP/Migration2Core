# M0 — Registro de encerramento (PARCIAL PASS)

**Data encerramento:** 2026-10-17  
**Responsável E2E homolog:** Lucio Félix  
**Marco seguinte:** **M1** — [`m1-execucao-checklist.md`](m1-execucao-checklist.md)

Checklist operacional: [`m0-execucao-checklist.md`](m0-execucao-checklist.md)

---

## 1. Objetivo M0 (recordar)

Alinhar trilhas **EQ-R + EQ-M** sem workshop Dimas; inventário API mobile; scaffold React; validar ponte **EQ-W** (login → Escolher → Selecionar).

---

## 2. Entregáveis concluídos

| # | Entregável | Evidência |
|---|------------|-----------|
| 1 | Decisões Lucio (A1–A5) | [`m0-execucao-checklist.md`](m0-execucao-checklist.md) § A |
| 2 | Dúvidas Dimas × soluções async | [`m0-duvidas-dimas-solucoes.md`](m0-duvidas-dimas-solucoes.md) |
| 3 | Trilhas EQ/F/I + impacto (regra Cursor) | [`ORQUESTRADOR-MIGRACAO.md`](ORQUESTRADOR-MIGRACAO.md) · `.cursor/rules/orquestrador-migracao-impacto.mdc` |
| 4 | Plano execução v2 (marcos M0–M10) | [`plano-execucao-migracao-v1.md`](plano-execucao-migracao-v1.md) |
| 5 | Estudos E0–E6 (docs) | Índice orquestrador |
| 6 | Git mobile: branch `feature/alteracoes_apontador` @ `14cf5d3` | `C:\Dev\EquipamentosMobile` |
| 7 | Inventário endpoints v0 | [`api-client-equipamentos-v0.md`](api-client-equipamentos-v0.md) |
| 8 | Migration2Core: **sem** branch React no GitHub (3 branches) | fetch 2026-10-17 |
| 9 | Scaffold **EQ-R**: Vite `client/` + build OK | `Migration2Core/RDO-CleanMigration-2026/client` · [`eq-r-scaffold-m0.md`](eq-r-scaffold-m0.md) |
| 10 | `dotnet build` RdoApp.Core | 2026-10-17 (warnings) |

---

## 3. E2E homolog Lucio (2026-10-17)

**URL:** `https://homolog.sistema.rdoapp.com.br/Obra/Escolher`  
**Usuário:** CPF `53821963549` / senha `1234` · RDS `homol_rdoapp`

| Passo | Resultado | Notas |
|-------|-----------|--------|
| Login | OK | |
| Escolher — lista obras | OK | 7 obras Equipamentos visíveis |
| Branding | **FAIL** | Header/footer ainda **Piscinas** (EC2 ≠ Git recente + strings residuais) |
| UI cards obras | **Parcial** | Layout flex + col Bootstrap desalinhado; sem paridade legado |
| Clicar obra → Cards | **FAIL** | Erro ao selecionar (investigar `POST /Obra/Selecionar`; dívida **EQ-W0.5**) |
| Cards placeholder | N/A | Não alcançado de forma estável |

**Classificação M0 E2E:** **PARCIAL PASS** — suficiente para **fechar M0** e iniciar **M1**; **M3** exige EQ-W0.5 + clique OK.

---

## 4. Análise técnica (sessão 2026-10-17)

- **Blazor:** fora do stack atual (`RdoApp.Core` = MVC Razor). Crise histórica = Projeto 1 abandonado (JS inline).
- **Código Git local:** `_HeaderEscolher` já **Equipamentos**; homolog mostra **Piscinas** → **redeploy** pendente.
- **Cards:** `Tarefa/Cards.cshtml` usa `_Layout` template (não operador) — contribui choque pós-clique.
- **Produto alvo UI:** **EQ-R** (React); **EQ-W** = ponte — não investir polish total em Escolher Razor.

---

## 5. Dívidas explícitas (não bloqueiam M1)

| ID | Dívida | Trilha | Alvo |
|----|--------|--------|------|
| D1 | Redeploy homolog + branding Equipamentos | EQ-W + I | EQ-W0.5 |
| D2 | Fix clique obra / Selecionar | EQ-W | EQ-W0.5 |
| D3 | Escolher grid/CSS mínimo | EQ-W | opcional antes M2 |
| D4 | Cards layout operador | EQ-W | até EQ-R M2 |

---

## 6. Orquestrador

Atualizado para **marco M1** em [`ORQUESTRADOR-MIGRACAO.md`](ORQUESTRADOR-MIGRACAO.md) (fase atual, próxima ação, histórico M0).
