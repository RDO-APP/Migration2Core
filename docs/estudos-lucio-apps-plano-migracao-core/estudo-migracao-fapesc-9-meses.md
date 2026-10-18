# Estudo — Migração Core (Dimas) × FAPESC em 9 meses

**Autor:** Lucio Felix de Souza Neto (RDO APP SC)  
**Atualizado:** 2026-08-19 (cronograma itemizado § 3)  
**Base:** Backlog Dimas v20260818 (346 h) · Proposta FAPESC 031/2026 (A1–A16 · R$ 79.990)  
**Relacionados:** [comparativo-dimas-v20260818.md](./comparativo-dimas-v20260818.md) · [docs/editais-fapesc/](../editais-fapesc/README.md) · [10_PONTE_MIGRACAO_TIME.md](../editais-fapesc/10_PONTE_MIGRACAO_TIME.md) · [docs/imutabilidade/](../imutabilidade/README.md)

---

## 1. Objetivo

Compilar em um único cronograma de **9 meses** o que pode ser entregue em paralelo:

1. **Migração Core** — backlog Dimas (TSK-01…56, PDF ago/2026)  
2. **FAPESC Imutabilidade** — atividades A1–A16 aprovadas na proposta enviada

Inclui horas por mês, marcos de pagamento PJ e o que fica **fora** do período FAPESC (Fase 2 / pós-venda).

---

## 2. Premissas

| Item | Valor |
|------|-------|
| Início do termo | **set/2026** (se contemplação confirmada) |
| Duração contrato FAPESC | **9 meses** (set/2026 → mai/2027) |
| Capacidade referência | **20 h/semana** (~**87 h/mês** = 20 × 4,33 sem/mês) · 1 dev sênior |
| Coluna **Migração** | Horas do PDF Dimas (TSK) — **já incluem IA** (ver § 2.1) |
| Coluna **FAPESC** | Atividades A1–A16; horas **estimadas** por Lucio (FAPESC aprovou **R$**, não h) |
| TSK-32 ≠ FAPESC | Assinatura comercial (Dimas) dispara evento → módulo `RdoApp.Imutabilidade` (FAPESC) |
| PoC FAPESC | Backend/homolog; **sem** front comercial como objeto do fomento |
| **Dimas** | **PJ externo** — **fora** da equipe executora SIGFAPESC (§ 8.3.3 atendido) |

### 2.1 Ferramentas de IA — posição Dimas (ago/2026)

> *“Uso Gemini, Claude e Copilot. Já trabalho com Cursor — **essa estimativa já conta com ele como IDE**.”*  
> — Dimas Duarte, sobre o PDF v20260818 (346 h)

**Implicação para este estudo:**

| Escopo | As 346 h do Dimas | Horas FAPESC (~352 h, estimativa Lucio) |
|--------|-------------------|----------------------------------------|
| Já desconta Cursor + IA? | **Sim** | **Parcialmente** — se Dimas executar A5b–A9 com o mesmo stack |
| Dá para “comprimir de novo” só trocando IDE? | **Não** — seria **double counting** | Ganho marginal (~0–10% em código; **0%** em A1 normativo, testnet, stress) |
| Dimas considera 346 h realista? | **Autodeclarado otimista**; difícil sozinho | PoC FAPESC **adiciona** carga paralela |

**O que ainda pode ajudar (não é “mais IA”):** segundo dev/parceiro, Lúcio/Carlos na Onda 0, `.cursor/rules` + docs no repo (contexto compartilhado), corte de escopo (mobile greenfield, ETL prod).

### Pagamentos PJ (conta FAPESC → NF Dimas/parceiros)

| Mês projeto | Mês calendário | Rubrica | Valor |
|-------------|----------------|---------|-------|
| 3 | nov/2026 | Consultoria / assessoria | R$ 15.998 |
| 6 | fev/2027 | Desenvolvimento de software | R$ 31.996 |
| 8 | abr/2027 | Serviços técnicos especializados | R$ 23.980 |

Pagamento ao prestador: **após entrega + NF** (edital § 8.2). Entre set/2026 e fev/2027 o dev trabalha **sem** o desembolso principal de código.

---

## 3. Cronograma 9 meses — Migração (Dimas) × FAPESC (aprovado)

**Premissas:** termo **set/2026** · **20 h/semana** (~**87 h/mês** = 20 × 4,33) · coluna **Migração** = backlog PDF Dimas (**346 h**, já com Cursor/Gemini/Claude/Copilot · itens **fora** marcados) · coluna **FAPESC** = atividades **A1–A16** (horas **estimadas** — FAPESC aprovou **R$**, não h).

**Pagamentos PJ Dimas (conta FAPESC):** consultoria **mês 3** · dev **mês 6** · serviços **mês 8**.

**Formato:** cada linha = um item · **h** = horas no mês · **h/sem** = h ÷ 4,33 (ritmo se espalhado no mês). Linha em branco entre itens. **Σ** = soma Migração + FAPESC no mês.

**Legenda:** ✓ ≤ 20 h/sem · ⚠️ 20–22 · ❌ > 22 (1 pessoa, 100% das duas colunas).

---

### Mês 1 · set/2026 · Σ **48 h** · **11,1 h/sem** · ✓

| Mês | Migração / Dimas | FAPESC / Aprovado |
|-----|------------------|-------------------|
| 1 | Onda 0 — U-05 API Apontamento Framework, U-08 OpenAPI **(Lucio/Carlos)** · **16 h** · **3,7 h/sem** | |
| | | |
| 1 | TSK-01 — Solution .NET 8 Clean Arch · **4 h** · **0,9 h/sem** | A1 — Requisitos normativos TCE/MP/CREA/14.133 **(início)** · **12 h** · **2,8 h/sem** |
| | | |
| 1 | TSK-02 — DbContext EF Core, MySQL · **8 h** · **1,8 h/sem** | A2 — Matriz redes registro externo **(início)** · **8 h** · **1,8 h/sem** |
| | | |

---

### Mês 2 · out/2026 · Σ **60 h** · **13,9 h/sem** · ✓

| Mês | Migração / Dimas | FAPESC / Aprovado |
|-----|------------------|-------------------|
| 2 | TSK-03 — Domain Obras/Apontamento/Identity · **12 h** · **2,8 h/sem** | A1 — Requisitos normativos **(cont.)** · **8 h** · **1,8 h/sem** |
| | | |
| 2 | TSK-04 — Serilog, CorrelationId, ProblemDetails · **2 h** · **0,5 h/sem** | A2 — Matriz redes **(cont.)** · **8 h** · **1,8 h/sem** |
| | | |
| 2 | TSK-05 — Interceptor auditoria EF · **4 h** · **0,9 h/sem** | A5a — Auditoria DER, dataset ancoragem **(início)** · **16 h** · **3,7 h/sem** |
| | | |
| 2 | TSK-06 — Hardening CORS, rate limit, Argon2 · **2 h** · **0,5 h/sem** | |
| | | |
| 2 | TSK-07 — JWT Bearer, Auth endpoints · **8 h** · **1,8 h/sem** | |
| | | |

---

### Mês 3 · nov/2026 · Σ **80 h** · **18,5 h/sem** · ✓ · ★ PJ consultoria **R$ 15.998**

| Mês | Migração / Dimas | FAPESC / Aprovado |
|-----|------------------|-------------------|
| 3 | TSK-08 — IEmailSender SMTP · **2 h** · **0,5 h/sem** | A1 — Requisitos normativos **(conclusão)** · **8 h** · **1,8 h/sem** |
| | | |
| 3 | TSK-09 — IFileStorage AWS S3 · **8 h** · **1,8 h/sem** | A2 — Matriz redes **(conclusão)** · **8 h** · **1,8 h/sem** |
| | | |
| 3 | TSK-10 — Scaffold SPA React Vite TS · **6 h** · **1,4 h/sem** | A3 — DDA arquitetura imutabilidade · **16 h** · **3,7 h/sem** |
| | | |
| 3 | TSK-11 — React recuperação/troca senha · **4 h** · **0,9 h/sem** | A4 — Diagramas componentes, fluxo, API · **16 h** · **3,7 h/sem** |
| | | |
| 3 | TSK-12 — RBAC usePermission **(início)** · **4 h** · **0,9 h/sem** | A5a — Auditoria DER **(cont.)** · **8 h** · **1,8 h/sem** |
| | | |
| 3 | | ★ *Entregáveis M3:* Relatório Requisitos + DDA + mapeamento DER |
| | | |

---

### Mês 4 · dez/2026 · Σ **76 h** · **17,6 h/sem** · ✓

| Mês | Migração / Dimas | FAPESC / Aprovado |
|-----|------------------|-------------------|
| 4 | TSK-12 — RBAC **(conclusão)** · **4 h** · **0,9 h/sem** | A5a — Auditoria DER **(conclusão)** · **8 h** · **1,8 h/sem** |
| | | |
| 4 | TSK-13 — Histórico auditoria login · **2 h** · **0,5 h/sem** | A5b — Serialização determinística **(início)** · **24 h** · **5,5 h/sem** |
| | | |
| 4 | TSK-17 — CRUD Obra + logo S3 · **4 h** · **0,9 h/sem** | A6 — Módulo hash integridade **(início)** · **8 h** · **1,8 h/sem** |
| | | |
| 4 | TSK-18 — Vínculos colaborador/equipamento à obra · **4 h** · **0,9 h/sem** | |
| | | |
| 4 | TSK-19 — Contexto Obra Ativa React · **8 h** · **1,8 h/sem** | |
| | | |
| 4 | TSK-20 — Convite acesso obra e-mail · **2 h** · **0,5 h/sem** | |
| | | |
| 4 | TSK-21 — CRUD Etapas drag-and-drop · **4 h** · **0,9 h/sem** | |
| | | |
| 4 | TSK-22 — Auxiliares Status, Unidades, P99 · **2 h** · **0,5 h/sem** | |
| | | |
| 4 | TSK-23 — CRUD Planejamento Tarefas **(início)** · **6 h** · **1,4 h/sem** | |
| | | |

---

### Mês 5 · jan/2027 · Σ **92 h** · **21,2 h/sem** · ⚠️

| Mês | Migração / Dimas | FAPESC / Aprovado |
|-----|------------------|-------------------|
| 5 | TSK-23 — Planejamento Tarefas **(conclusão)** · **6 h** · **1,4 h/sem** | A5b — Serialização determinística **(cont.)** · **16 h** · **3,7 h/sem** |
| | | |
| 5 | TSK-15 — CRUD Colaborador · **4 h** · **0,9 h/sem** | A6 — Módulo hash **(cont.)** · **16 h** · **3,7 h/sem** |
| | | |
| 5 | TSK-16 — CRUD Equipamentos · **4 h** · **0,9 h/sem** | A7 — Conector registro externo **(início)** · **12 h** · **2,8 h/sem** |
| | | |
| 5 | TSK-24 — Modelo normalizado Apontamento · **12 h** · **2,8 h/sem** | |
| | | |
| 5 | TSK-25 — Cálculo horas normais/extras · **12 h** · **2,8 h/sem** | |
| | | |
| 5 | TSK-26 — Horas/horímetro equipamentos · **4 h** · **0,9 h/sem** | |
| | | |
| 5 | TSK-27 — Testes unitários cálculo horas · **8 h** · **1,8 h/sem** | |
| | | |
| 5 | TSK-28 — Medição avanço físico **(início)** · **2 h** · **0,5 h/sem** | |
| | | |

---

### Mês 6 · fev/2027 · Σ **114 h** · **26,3 h/sem** · ❌ · ★ PJ dev **R$ 31.996**

| Mês | Migração / Dimas | FAPESC / Aprovado |
|-----|------------------|-------------------|
| 6 | TSK-28 — Medição avanço físico **(conclusão)** · **2 h** · **0,5 h/sem** | A5b — Serialização **(conclusão)** · **8 h** · **1,8 h/sem** |
| | | |
| 6 | TSK-29 — Upload fotos medição S3 · **4 h** · **0,9 h/sem** | A6 — Módulo hash **(conclusão)** · **8 h** · **1,8 h/sem** |
| | | |
| 6 | TSK-30 — Indicadores químicos piscina · **2 h** · **0,5 h/sem** | A7 — Conector registro externo **(cont.)** · **16 h** · **3,7 h/sem** |
| | | |
| 6 | TSK-31 — Agrupador diário RDO · **12 h** · **2,8 h/sem** | A8 — API verificação integridade · **20 h** · **4,6 h/sem** |
| | | |
| 6 | TSK-32 — Assinatura canvas + evento pós-assinatura · **8 h** · **1,8 h/sem** | A9 — Integração homolog/testnet **(início)** · **12 h** · **2,8 h/sem** |
| | | |
| 6 | ★ *Marco:* RDO + assinatura (hospedeiro PoC) | ★ *Entregável M6:* protótipo **50–100 registros** verificáveis |
| | | |

---

### Mês 7 · mar/2027 · Σ **55 h** · **12,7 h/sem** · ✓

| Mês | Migração / Dimas | FAPESC / Aprovado |
|-----|------------------|-------------------|
| 7 | TSK-33 — PDF RDO QuestPDF · **12 h** · **2,8 h/sem** | A9 — Integração homolog/testnet **(conclusão)** · **16 h** · **3,7 h/sem** |
| | | |
| 7 | TSK-34 — CRUD Laudo + sugestão indicadores · **4 h** · **0,9 h/sem** | A8 — Refinamento + doc API preliminar · **8 h** · **1,8 h/sem** |
| | | |
| 7 | TSK-35 — Assinatura laudo, fotos, PDF · **12 h** · **2,8 h/sem** | |
| | | |
| 7 | TSK-36 — Painel listagem laudos React · **2 h** · **0,5 h/sem** | |
| | | |
| 7 | TSK-37 — Queries analíticas Dapper **(início)** · **1 h** · **0,2 h/sem** | |
| | | |

---

### Mês 8 · abr/2027 · Σ **79 h** · **18,2 h/sem** · ✓ · ★ PJ serviços **R$ 23.980**

| Mês | Migração / Dimas | FAPESC / Aprovado |
|-----|------------------|-------------------|
| 8 | TSK-37 — Dapper relatórios **(conclusão)** · **7 h** · **1,6 h/sem** | A10 — Testes carga/stress · **16 h** · **3,7 h/sem** |
| | | |
| 8 | TSK-38 — Export Excel e PDF · **4 h** · **0,9 h/sem** | A11 — Auditoria segurança + LGPD · **12 h** · **2,8 h/sem** |
| | | |
| 8 | TSK-39 — Worker migração arquivos → S3 · **12 h** · **2,8 h/sem** | A12 — Simulação adulteração pós-ancoragem · **12 h** · **2,8 h/sem** |
| | | |
| 8 | TSK-40 — Swagger/OpenAPI v1 · **2 h** · **0,5 h/sem** | A13 — Custo operacional por registro · **8 h** · **1,8 h/sem** |
| | | |
| 8 | TSK-41 — Mapeamento DDL legado → MySQL · **6 h** · **1,4 h/sem** | ★ *Entregável M8:* Relatório Validação **TRL 5** |
| | | |

---

### Mês 9 · mai/2027 · Σ **36 h** · **8,3 h/sem** · ✓ · ★ Encerramento FAPESC

| Mês | Migração / Dimas | FAPESC / Aprovado |
|-----|------------------|-------------------|
| 9 | TSK-42 — ETL cadastros essenciais **(conclusão)** · **8 h** · **1,8 h/sem** | A14 — Documentação técnica final + viabilidade econômica · **16 h** · **3,7 h/sem** |
| | | |
| 9 | TSK-43 — ETL apontamentos **(início)** · **2 h** · **0,5 h/sem** | A16 — Relatório final FAPESC · **8 h** · **1,8 h/sem** |
| | | |
| 9 | TSK-44 — ETL usuários → Identity **(início)** · **1 h** · **0,2 h/sem** | *(A15 INPI = recurso próprio)* |
| | | |
| 9 | TSK-45 — Validação staging/cutover **(início)** · **1 h** · **0,2 h/sem** | |
| | | |
| 9 | 🚫 **FORA (Fase 2):** TSK-46…56 mobile greenfield · **~70 h** | |
| | | |
| 9 | 🚫 **FORA (Fase 2):** restante TSK-43…45 ETL/cutover prod · **~40–60 h** | |
| | | |

---

### 3.1 Resumo mensal

| Mês | Migração h | FAPESC h | Σ | h/sem | Cap. |
|-----|------------|----------|---|-------|------|
| 1 | 28 | 20 | 48 | 11,1 | ✓ |
| 2 | 28 | 32 | 60 | 13,9 | ✓ |
| 3 | 24 | 56 | 80 | 18,5 | ✓ |
| 4 | 36 | 40 | 76 | 17,6 | ✓ |
| 5 | 48 | 44 | 92 | 21,2 | ⚠️ |
| 6 | 50 | 64 | 114 | 26,3 | ❌ |
| 7 | 31 | 24 | 55 | 12,7 | ✓ |
| 8 | 31 | 48 | 79 | 18,2 | ✓ |
| 9 | 12 | 24 | 36 | 8,3 | ✓ |
| **Σ** | **288** | **352** | **640** | **méd. 16,4** | |

\* Migração **288 h** na tabela + **~58 h** fora (mobile + ETL prod) ≈ **346 h** PDF. FAPESC **352 h** estimadas Lucio.

### 3.2 Carga só Dimas (cenário ajustado)

Se **Onda 0** (16 h, mês 1) = Lucio/Carlos e **A1** (~28 h, meses 1–3) = consultor PJ:

| Mês | Σ tabela | − Onda 0 | − A1 | **Σ Dimas** | **h/sem** | Cap. |
|-----|----------|----------|------|-------------|-----------|------|
| 1 | 48 | 16 | 12 | 20 | 4,6 | ✓ |
| 2 | 60 | — | 8 | 52 | 12,0 | ✓ |
| 3 | 80 | — | 8 | 72 | 16,6 | ✓ |
| 4 | 76 | — | — | 76 | 17,6 | ✓ |
| 5 | 92 | — | — | 92 | 21,2 | ⚠️ |
| 6 | 114 | — | — | 114 | 26,3 | ❌ |
| 7 | 55 | — | — | 55 | 12,7 | ✓ |
| 8 | 79 | — | — | 79 | 18,2 | ✓ |
| 9 | 36 | — | — | 36 | 8,3 | ✓ |
| **Total 9 meses** | **640** | **16** | **28** | **596** | **méd. 15,3** | |

**Nota:** a linha antiga **“7–9 · 170 h”** era a **soma dos meses 7 + 8 + 9** (55 + 79 + 36 = **170 h**), **não** o acumulado do projeto inteiro. O total Dimas no cenário ajustado é **596 h** em 9 meses.

Meses **5–6** estouram mesmo ajustado — mitigar com parceiro ou deslocar **A9** parcial para mês 7.

### 3.3 Conta anual (20 h/semana × 9 meses)

| Métrica | Valor |
|---------|-------|
| Semanas | 9 × 4,33 ≈ **39 sem** |
| Capacidade | 39 × 20 h ≈ **780 h** |
| Carga Σ tabela | 640 ÷ 39 ≈ **16,4 h/sem** (média) |
| Carga PDF + FAPESC | 698 ÷ 39 ≈ **17,9 h/sem** |
| Conta rápida | 698 ÷ 9 ÷ 4 ≈ **19,4 h/sem** ✓ |
| Folga vs 698 h | ≈ **82 h** |

**Conclusão:** a **média anual** cabe em 20 h/sem; o risco são os **picos** (meses **5–6**).

---

## 4. Totais e capacidade

### 4.1 Horas consolidadas

| Bloco | Horas | Observação |
|-------|-------|------------|
| Migração meses 1–9 | **346 h** | PDF Dimas — **já com Cursor + Gemini + Claude + Copilot** |
| FAPESC A1–A16 | **~352 h** | Estimativa Lucio; **não** estava no PDF Dimas |
| **Soma paralela (Σ tabela § 3)** | **640 h** | Meses 1–9; mobile ~70 h fora |
| **Soma PDF + FAPESC** | **~698 h** | 346 + ~352 |
| Capacidade 9 meses @ 20 h/sem | **~780 h** | 39 sem × 20 h |
| **Média** | **16,4–17,9 h/sem** | Cabe em 20 h/sem |
| **Picos** | M5 **21,2** · M6 **26,3 h/sem** | Ver § 3 — estouram se 1 pessoa faz tudo |
| **Folga** (vs 698 h) | **~82 h** | ~1 mês — consumida se picos não forem nivelados |

### 4.2 Por que não dá para enxugar só com IDE

| Expectativa | Realidade (posição Dimas) |
|-------------|---------------------------|
| “Cursor/Kiro reduz 346 h para ~245 h” | **Inválido** — 346 h **já nasceram** com Cursor |
| “9 meses viram 6–7 só com IA” | **Inválido** para migração; FAPESC continua 9 meses fixos |
| O PDF é conservador? | Dimas disse ser **otimista** — risco de **estourar**, não de sobrar |
| O que comprime de verdade | **Parceiro dev**, Onda 0 fora do Dimas, **cortar** mobile greenfield/ETL prod |

### 4.3 Cenários realistas (pós-esclarecimento Dimas)

| Cenário | Descrição | Folga / risco |
|---------|-----------|---------------|
| **Base** | PoC FAPESC + TSK 1–6 parcial; ETL/mobile fora | **~85 h** — apertado |
| **+ Parceiro** | Dimas indica dev (DBA A5a) ou 2º dev 10 h/sem | FAPESC + migração **viável** sem Fase 2 grande |
| **+ Lúcio/Carlos Onda 0** | Apps fora do Dimas | Libera **~16–40 h/mês** início |
| **Estourar escopo** | Dimas faz Onda 0 + React gestor + ETL | **−140 h** folga → atraso mês 6/8 ou qualidade |

**Removido:** “Cenário IA” com −164 h — **retirado** após confirmação Dimas (ago/2026).

---

## 5. O que fica fora dos 9 meses (Fase 2)

| Item | TSK / U | Horas ref. | Fonte sugerida |
|------|---------|------------|----------------|
| Mobile greenfield RN/Expo | TSK-46…56 | **~70 h** | Evoluir RN existente; contrato pós-venda |
| ETL apontamentos + cutover **produção** | TSK-43, 45 | **~40–60 h** | Recurso próprio / MRR |
| React **gestor** + strangler Angular completo | U-36, U-51…55 | **~140 h** | Contrapartida + Fase 2 |
| EDI fase 2 (TCE/CREA/MP) | — | — | Pós-FAPESC |
| Integração ART CREA (convênio) | — | — | Pós-FAPESC |

*Horas Fase 2 também assumem stack IA do Dimas — **não** aplicar desconto adicional.*

---

## 6. Atores legais (CREA / TCE / MP) × cronograma

| Quando | Atividade | Quem |
|--------|-----------|------|
| Mês 3 | **A1** — matriz ator × assina × ART × acesso | Consultor GovTech (PJ consultoria) — **sem ganho IA** |
| Mês 4–6 | RBAC mínimo amarrado à A1 | Dimas (**TSK-12** parcial) |
| Mês 6 | Gatilho âncora **pós-2 assinaturas** | **TSK-32** + **A5b–A9** |
| Pós-9 meses | PNCP, pacote ART CREA | EDI fase 2 |

Ver: [`docs/imutabilidade/05_ATORES_ASSINATURA.md`](../imutabilidade/05_ATORES_ASSINATURA.md).

---

## 7. Pagamento Dimas — FAPESC × Fase 2

### Via FAPESC (~R$ 55–60k para Dimas)

| Data ref. | Marco | Valor |
|-----------|-------|-------|
| nov/2026 | A1–A4 + DDA (consultoria) | até **R$ 15.998** |
| fev/2027 | Protótipo A5b–A9 + Core/RDO (**TSK-31/32**) | **R$ 31.996** |
| abr/2027 | Homolog, stress, TRL 5 | até **R$ 23.980** |

### Fase 2 — fora FAPESC (pós-venda)

| Tranche | Gatilho | Escopo | Valor ref. |
|---------|---------|--------|------------|
| T1 | Homolog FAPESC OK | React operador + domínio apontamento | R$ 25–35k |
| T2 | MRR ≥ X | React gestor + relatórios | R$ 25–35k |
| T3 | 3 clientes / staging OK | ETL prod + desligar Angular | R$ 20–30k |

---

## 8. Diagrama — três trilhas

```
  M1────M3────M6────M8────M9
  │     │     │     │     │
  FAPESC PoC (A1→A16) ─────────────────────────────► TRL 5
        │           ▲           ▲
        │      R$15k       R$32k      R$24k
        │
  Migração (TSK) ──► Core ──► RDO ──► relatórios ──► ETL (Fase 2)
        │              ↑
        │         346 h já c/ Cursor+IA (Dimas)
        │
  Onda 0 apps ──► Lucio/Carlos (paralelo, reduz carga Dimas)
```

---

## 9. Decisões registradas

1. **TSK-32** = assinatura comercial; **`RdoApp.Imutabilidade`** = objeto FAPESC (A5b–A9).  
2. **R$ 31.996** = PoC + hospedeiro Core/RDO — não migração inteira.  
3. **346 h Dimas** = **já incluem** Cursor, Gemini, Claude, Copilot — **não** descontar de novo.  
4. **Mobile greenfield** (TSK-46…56) **cancelado**; evoluir RN existente.  
5. **Dimas = PJ externo** — não consta na equipe executora SIGFAPESC; contratação via rubricas PJ (§ 8.3.3 OK).  
6. ETL **produção** = Fase 2; **média** cabe em 20 h/sem — **meses 5–6 estouram** se Dimas fizer 100% das duas colunas (§ 3).  

---

## Referências

| Documento | Conteúdo |
|-----------|----------|
| [comparativo-dimas-v20260818.md](./comparativo-dimas-v20260818.md) | TSK × Ondas U · §9 FAPESC × Dimas |
| [comparativo-e-plano-unificado.md](./comparativo-e-plano-unificado.md) | Plano Strangler Ondas 0–6 |
| [docs/editais-fapesc/03_ORCAMENTO.md](../editais-fapesc/03_ORCAMENTO.md) | Rubricas e desembolsos |
| Backlog Dimas | `Backlog_RDO v20260818.pdf` — 346 h **com IA** |
