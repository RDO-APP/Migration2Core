# Comparativo — Backlog Dimas v20260818 × Plano unificado (Ondas U)

**Autor PDF:** Dimas Duarte  
**Arquivo:** `Backlog_RDO v20260818.pdf` (18/ago/2026)  
**Cruzamento com:** [comparativo-e-plano-unificado.md](./comparativo-e-plano-unificado.md) (jul/2026)  
**Atualizado:** 2026-08-19

---

## 1. Resumo do PDF Dimas (ago/2026)

| Métrica | Valor |
|---------|--------|
| Título | Plano de Reescrita / Modernização RDO & App Mobile |
| Tarefas | **56** (TSK-01…TSK-56) · 27 marcadas complexas (~48%) |
| Esforço declarado | **346 h** líquidas |
| Capacidade | **20 h/semana** · 1 Dev FullStack Sênior/Arquiteto · **4 h/dia** |
| Prazo declarado | **86,5 dias úteis** · **17,3 semanas** (~4 meses comerciais) |
| Stack | .NET 8 Clean Arch · React 19 · React Native/Expo · MySQL 8.4 · AWS S3 |
| Abordagem | **Greenfield** — web + Core + ETL + **mobile reescrito no fim** (Sprints 7–8) |

### Sprints Dimas × horas

| Sprint | Módulo | Tarefas | Horas | Semanas @ 20h |
|--------|--------|---------|-------|---------------|
| 1 | Fundação & identidade mínima | 10 | 56h | 2,8 |
| 2 | RBAC & cadastros base | 6 | 24h | 1,2 |
| 3 | Obras, etapas & tarefas | 7 | 36h | 1,8 |
| 4 | Apontamentos & medições | 7 | 48h | 2,4 |
| 5 | RDO & laudo (web) | 6 | 50h | 2,5 |
| 6 | Relatórios, S3, ETL, go-live web | 9 | 62h | 3,1 |
| 7–8 | App mobile híbrido (RN/Expo) | 11 | 70h | 3,5 |
| **Total** | | **56** | **346h** | **17,3** |

---

## 2. Veredicto do cruzamento

| Aspecto | Dimas v20260818 | Plano unificado (U-01…U-66) | Ação |
|---------|-----------------|-----------------------------|------|
| Stack destino | .NET 8, React, RN, S3 | Igual | ✅ Adotar TSK como inventário técnico |
| Apontamento desacoplado | TSK-24…30 | U-44…U-50 + U-05 (Framework) | ✅ Mesma direção |
| Mobile | Rebuild Sprint 7–8 (70h) | **Onda 0** — evoluir RN existente | ❌ **Reordenar** — não rebuild |
| ETL / cutover | Sprint 6 (mês 4) | **Onda 6** — último | ❌ **Adiar** ETL |
| Web “100%” mês 3 | Marco M3 | Paridade **operador** Onda 3; gestor Onda 5 | ❌ Ajustar expectativa |
| Transição | Big bang implícito | Strangler Fig | ❌ Framework → Core por endpoint |
| Prazo 4 meses @ 20h/sem | 346h | Estimativa jul/2020: 240–448 **dias** (1 dev pleno) | ⚠️ PDF ago **5× mais agressivo** que jul |
| Itens só no plano Lucio | — | U-01…U-08, U-26, U-36, licença, 2 produtos | ⚠️ Incluir no MVP |

**Conclusão:** usar TSK como **backlog técnico**; usar Ondas U como **ordem de entrega** e **escopo de transição**.

---

## 3. Mapa Sprint Dimas → Onda unificada (recomendado)

| Sprint Dimas (PDF) | Onda unificada | Observação |
|--------------------|----------------|------------|
| — | **Onda 0** | **Antes** do Sprint 1 — apps + API Framework Apontamento |
| Sprint 1 | Onda 1 (U-10…U-19) | Fundação Core + scaffold React |
| Sprint 2 | Onda 1 + Onda 2 | Identity parcial + cadastros base |
| Sprint 3 | Onda 4 (U-40…U-42) + Onda 2 (U-23) | Obras/etapas/tarefas Core |
| Sprint 4 | Onda 4 (U-44…U-50) | Domínio apontamento |
| Sprint 5 | Onda 4 (U-48…U-49) + FAPESC* | RDO/Laudo/PDF · *SHA-256 = projeto FAPESC separado |
| Sprint 6 (relatórios) | Onda 5 (U-54…U-55) | Dapper/Excel/PDF gestor |
| Sprint 6 (ETL/go-live) | **Onda 6** (U-60…U-66) | **Só após** Onda 0 + U-44 validados |
| Sprint 7–8 (mobile) | **Onda 0 + Onda 2 (U-25)** | Integrar RN existente; offline = incremento posterior |

---

## 4. Cruzamento TSK → U (tabela completa)

Legenda **Status:** ✅ alinhado · 🔄 reordenar · ⚠️ gap/ajuste · 🚫 conflito com plano unificado · ➕ só no plano Lucio

| TSK | Descrição (PDF) | h | Sprint | Onda U | Ref U | Status | Nota |
|-----|-----------------|---|--------|--------|-------|--------|------|
| TSK-01 | Solution .NET 8 Clean Arch, MediatR, FluentValidation | 4 | 1 | 1 | U-10 | ✅ | = FND-01 |
| TSK-02 | DbContext EF Core, MySQL 8.4, migrations, Dapper | 8 | 1 | 1 | U-11 | ✅ | = FND-02 |
| TSK-03 | Mapeamento Domain (Obras, Apontamento, Identity) | 12 | 1 | 1 | U-12 | ✅ | = FND-03 |
| TSK-04 | Serilog, CorrelationId, ProblemDetails | 2 | 1 | 1 | U-14 | ✅ | FND-05…07 |
| TSK-05 | Interceptor EF auditoria CreatedBy/UpdatedBy | 4 | 1 | 1 | U-14 | ✅ | |
| TSK-06 | Hardening CORS, Rate Limit, Argon2/BCrypt | 2 | 1 | 1 | U-16 | ✅ | FND-14 |
| TSK-07 | JWT Bearer Access/Refresh, Auth endpoints | 8 | 1 | 2 | U-16, U-21 | ✅ | |
| TSK-08 | IEmailSender SMTP | 2 | 1 | 1 | U-17 | ✅ | FND-10 |
| TSK-09 | IFileStorage AWS S3 multipart/presigned | 8 | 1 | 1 | U-17 | ✅ | FND-11 |
| TSK-10 | Scaffold SPA React Vite TS Query Auth | 6 | 1 | 1 | U-19 | ✅ | FND-12 adaptado |
| TSK-11 | React recuperação e troca de senha | 4 | 2 | 2 | U-22 | ✅ | USR-03/04 |
| TSK-12 | RBAC usePermission + Protected Routes | 8 | 2 | 2 | U-24 | ✅ | USR-05 |
| TSK-13 | Histórico auditoria login IP/UA | 2 | 2 | 2 | — | ✅ | Detalhe infra |
| TSK-14 | CRUD Empresas (API + React) | 2 | 2 | 5 | U-53 | 🔄 | PDF cedo; unificado = gestor Onda 5 |
| TSK-15 | CRUD Colaborador sem login (API + React) | 4 | 2 | 4 | U-43 | 🔄 | PDF Sprint 2; unificado Onda 4 |
| TSK-16 | CRUD Equipamentos marcas/modelos | 4 | 2 | 4 | U-43 | 🔄 | idem |
| TSK-17 | CRUD Obra + logo S3 | 4 | 3 | 4 | U-40 | ✅ | OBR |
| TSK-18 | Vínculos colaborador/equipamento à obra | 4 | 3 | 4 | U-40 | ✅ | |
| TSK-19 | Contexto Obra Ativa React (X-Obra-Id) | 8 | 3 | 2–3 | U-23, U-30 | ✅ | OBR-04 + strangler |
| TSK-20 | Convite acesso obra por e-mail | 2 | 3 | 5 | U-53 | 🔄 | Gestor; legado Angular hoje |
| TSK-21 | CRUD Etapas drag-and-drop | 4 | 3 | 4 | U-41 | ✅ | ETP |
| TSK-22 | Auxiliares Status, Unidades, P99 | 2 | 3 | 4 | U-42 | ✅ | |
| TSK-23 | CRUD Planejamento Tarefas na etapa | 12 | 3 | 4 | U-42 | ✅ | TRF |
| TSK-24 | Modelo normalizado Apontamento | 12 | 4 | 0+4 | U-05, U-44 | 🔄 | **Framework API antes (U-05)** |
| TSK-25 | Cálculo horas normais/extras/finais | 12 | 4 | 4 | U-45 | ✅ | APT-02 |
| TSK-26 | Horas/horímetro equipamentos | 4 | 4 | 4 | U-45 | ✅ | APT-03 |
| TSK-27 | Testes unitários cálculo horas xUnit | 8 | 4 | 4 | U-50 | ✅ | APT-08 |
| TSK-28 | Medição avanço físico e lote | 4 | 4 | 4 | U-46 | ✅ | APT-04 |
| TSK-29 | Upload fotos medição S3 | 4 | 4 | 4 | U-46 | ✅ | APT-05 |
| TSK-30 | Indicadores químicos piscina | 2 | 4 | 4 | U-47 | ✅ | APT-06 |
| TSK-31 | Agrupador diário RDO (clima, efetivo…) | 12 | 5 | 4–5 | U-48 | ✅ | RDO-01 |
| TSK-32 | Assinatura canvas + SHA-256 imutabilidade | 8 | 5 | — | FAPESC | ⚠️ | Projeto **Imutabilidade** (9 meses FAPESC); não bloquear migração |
| TSK-33 | PDF RDO QuestPDF | 12 | 5 | 4–5 | U-48, U-54 | ✅ | RDO-04 / REL-02 |
| TSK-34 | CRUD Laudo + sugestão indicadores | 4 | 5 | 4 | U-49 | ✅ | LAU |
| TSK-35 | Assinatura laudo, fotos S3, PDF | 12 | 5 | 4 | U-49 | ✅ | LAU-04 |
| TSK-36 | Painel listagem laudos React | 2 | 5 | 3 | U-32 | 🔄 | Operador Onda 3 antes de gestor |
| TSK-37 | Queries analíticas Dapper relatórios | 8 | 6 | 5 | U-54 | ✅ | REL |
| TSK-38 | Export Excel e PDF | 4 | 6 | 5 | U-54, U-55 | ✅ | REL-01/02 |
| TSK-39 | Worker migração arquivos → S3 | 12 | 6 | 5–6 | U-17 | 🔄 | Pode antecipar pós-U-09 |
| TSK-40 | Swagger/OpenAPI v1 | 2 | 6 | 0+6 | U-08, U-65 | 🔄 | **Antecipar U-08** na Onda 0 |
| TSK-41 | Mapeamento DDL legado → MySQL | 8 | 6 | 6 | U-60 | 🔄 | **Onda 6** — não mês 4 |
| TSK-42 | ETL cadastros essenciais | 12 | 6 | 6 | U-61 | 🔄 | Onda 6 |
| TSK-43 | ETL apontamentos + histórico RDO | 16 | 6 | 6 | U-62 | 🚫 | **16h subestimado**; só após U-44 + campo OK |
| TSK-44 | ETL usuários → Identity | 4 | 6 | 6 | U-63 | 🔄 | Onda 6 |
| TSK-45 | Validação staging + cutover web | 8 | 6 | 6 | U-64, U-66 | 🔄 | Strangler gradual, não cutover único |
| TSK-46 | Setup RN Expo SDK 51+ TS NativeWind | 4 | 7 | 0 | — | 🚫 | **App já existe** — não greenfield |
| TSK-47 | SecureStore + Axios interceptors | 8 | 7 | 0–2 | U-25 | 🔄 | Evoluir auth existente |
| TSK-48 | Login, recuperação, obra ativa mobile | 4 | 7 | 0 | U-02 | 🚫 | **Já implementado** (Carlos/Dimas) |
| TSK-49 | Apontamento horas/horímetro mobile | 6 | 7 | 0 | U-34 | 🚫 | add-register-screen existe |
| TSK-50 | Câmera/galeria compressão | 8 | 7 | 0 | U-46 | 🔄 | Parcial; evoluir não reescrever |
| TSK-51 | Indicadores químicos mobile | 2 | 7 | 0 | U-47 | 🚫 | piscinas.tsx existe |
| TSK-52 | SQLite offline + Sync Queue | 12 | 8 | — | — | ⚠️ | **Fora MVP**; incremento pós-Core |
| TSK-53 | Assinatura touch mobile | 8 | 8 | — | — | ⚠️ | Avaliar necessidade v1 |
| TSK-54 | Visualizador PDF RDO/Laudo mobile | 2 | 8 | 0 | U-04 | 🔄 | report-print / laudo parcial |
| TSK-55 | EAS Build APK/AAB | 8 | 8 | 0 | — | 🔄 | Pipeline EAS **já usado** |
| TSK-56 | Certificados iOS TestFlight/Store | 8 | 8 | — | — | ⚠️ | Backlog separado publicação |

---

## 5. Itens U sem TSK equivalente (lacunas do PDF)

| ID | Entrega | Onda | Ação |
|----|---------|------|------|
| U-01 | Impressora TaskCard Piscineiro | 0 | Incluir no plano Dimas · **pré-Sprint 1** |
| U-02 | UX Apontador (sem trancar etapa, paridade Sistema) | 0 | Em andamento branch `feature/alteracoes_apontador` |
| U-03 | Página Apontamentos lista + assinar + PDF | 0 | **Não está** no PDF ago |
| U-04 | Impressora Apontador + upsert apontamento | 0 | Parcial TSK-54; falta domínio Apontamento |
| U-05 | ApontamentoController Framework | 0 | Anteceder TSK-24 |
| U-06 | Pacote `@rdoapp/shared` | 0 | Não mencionado no PDF |
| U-07 | Fix salvarLaudo → salvarApontamento | 0 | Bug mobile |
| U-26 | Licença/perfil Operador vs Diretor | 2 | Crítico comercial; PDF omite |
| U-31 | Dashboard operador React strangler | 3 | PDF mistura com CRUD gestor |
| U-33 | Lista Apontamentos React | 3 | Não no PDF |
| U-35 | Modal impressora web | 3 | Não explícito (REL parcial) |
| U-36 | Desligar rotas Angular por rota | 3–6 | PDF = cutover big bang |
| U-51–U-53 | RDO gestor, accordion tarefas, admin | 5 | PDF antecipa CRUDs no Sprint 2–3 |
| U-56–U-57 | Gráficos, efetivo diário | 5 opc. | PDF fora v1 jul — ok |
| U-66 | Desligar AngularJS + Framework | 6 | PDF Sprint 6 cedo demais |

---

## 6. Ref Dimas jul/2020 → TSK ago/2026

| Fase jul (64 hist.) | TSK ago equivalente |
|---------------------|---------------------|
| FND-01…14 | TSK-01…10 |
| USR-01…07 | TSK-07, 11, 12, 13 |
| OBR, ETP, TRF | TSK-17…23 |
| APT-01…08 | TSK-24…30, 27 |
| RDO, LAU | TSK-31…36 |
| REL, S3 | TSK-37…39 |
| MIG-01…06 | TSK-40…45 |
| — (mobile externo) | TSK-46…56 (**novo detalhamento**) |

O PDF ago **condensou** 64 histórias em 56 TSK com estimativa **346h** vs jul **240–448 dias úteis** (~1 920–3 584 h @ 8h/dia).

---

## 7. Cronograma realista mesclado (@ 20 h/semana, 1 dev)

Substitui marco “4 meses” do PDF.

| Fase | Conteúdo | TSK / U | Horas ref. | Semanas @ 20h |
|------|----------|---------|------------|---------------|
| **A** | Onda 0 — apps + API Framework Apontamento + OpenAPI | U-01…U-08 | ~80–120h | 4–6 |
| **B** | Onda 1 — fundação Core | TSK-01…10 | ~56h | 3 |
| **C** | Onda 2 — identity + obra ativa + port API mobile | TSK-07,11,12,19 + U-25 | ~60–80h | 3–4 |
| **D** | Onda 3 — React operador strangler | TSK-36 + U-30…U-35 | ~80–100h | 4–5 |
| **E** | Onda 4 — domínio (obra→apontamento→RDO/laudo) | TSK-15…35 (Core) | ~120–160h | 6–8 |
| **F** | Onda 5 — gestor + relatórios | TSK-14,20,37,38 + U-51…55 | ~60–80h | 3–4 |
| **G** | Onda 6 — ETL + cutover | TSK-41…45 | ~48h+ (**real 80–120h**) | 4–6 |
| **H** | Mobile — integração Core (não rebuild) | TSK-47,50,54,55 adaptados | ~40–60h | 2–3 |
| | **Total MVP operador + Core + cutover** | | **~600–900h** | **30–45 sem (7–11 meses)** |

Com **2 devs** (1 Core/React, 1 mobile): **~15–22 sem (4–6 meses)** para MVP operador + Core base — **ainda não** gestor completo + ETL.

---

## 8. Decisões propostas (reunião Dimas + Lucio)

| # | Decisão | Proposta |
|---|---------|----------|
| 1 | Backlog técnico | Adotar **TSK-01…56** como WBS |
| 2 | Ordem de execução | Seguir **Ondas U**, não Sprints 1→8 lineares |
| 3 | Mobile Sprint 7–8 | **Cancelar greenfield**; evoluir `RDOAppPiscinasMobile` |
| 4 | Marco M3 “web 100%” | Trocar por **paridade operador** (Onda 3 done) |
| 5 | ETL TSK-43 | Mover para **Onda 6**; estimar **80h+**, não 16h |
| 6 | TSK-32 SHA-256 | Tratar no chat **Imutabilidade/FAPESC**, não na migração Core |
| 7 | Pré-requisito Sprint 1 | **Onda 0** concluída ou em paralelo explícito |
| 8 | Prazo comunicado | **7–11 meses** @ 20h/sem 1 dev · **4–6 meses** @ 2 devs (MVP parcial) |

---

## 9. FAPESC × Dimas — o que tem e o que falta

**Projetos distintos, complementares.** A FAPESC 031/2026 financia **PoC de imutabilidade documental** (TRL 3→5, 9 meses, R$ 79.990). O backlog Dimas v20260818 financia **reescrita do produto** (.NET 8 + React + RN). Um **não substitui** o outro.

Docs FAPESC: [`docs/editais-fapesc/`](../editais-fapesc/README.md) · Imutabilidade: [`docs/imutabilidade/`](../imutabilidade/README.md)

### 9.1 Comparativo de escopo

| | **FAPESC 031/2026** | **Dimas migração v20260818** |
|---|---------------------|------------------------------|
| Objetivo | Protocolo hash + registro externo + API verificação | Sistema operacional novo (web + API + mobile + ETL) |
| Prazo | 9 meses | 17,3 sem declaradas @ 20 h/sem (~4 meses) |
| Front-end | **Explicitamente fora** | React 19 + RN Expo (TSK-10…56) |
| Entregável central | PoC backend testnet, 50–100 registros verificáveis | Go-live web + APK/iOS |
| Cutover produção | **Não** — ambiente isolado | TSK-45 cutover web |
| ETL dados legado | **Não** na PoC | TSK-41…43 (Onda 6) |

### 9.2 O que o Dimas **tem** (sinergia com FAPESC)

Itens do backlog Dimas que **preparam terreno** para plugar o módulo FAPESC — mas **não são** o módulo FAPESC:

| Dimas (TSK) | Relação com entregável FAPESC |
|-------------|-------------------------------|
| TSK-31 Agrupador diário RDO | Dados candidatos ao **snapshot** de ancoragem (A5a) |
| TSK-32 Assinatura canvas + SHA-256 | **Gatilho** pós-assinatura (A5/A6) — hash local ≠ protocolo completo |
| TSK-33 PDF RDO QuestPDF | FAPESC ancora **snapshot**, não layout PDF |
| TSK-01…03 Clean Arch + Domain + EF | **Hospedeiro** do módulo A5b–A9 |
| TSK-02 EF + MySQL + Dapper | Leitura schema RDO App (A5a DER) |
| TSK-05 Auditoria EF CreatedBy/UpdatedBy | Auditoria operacional (≠ prova integridade pós-fechamento) |
| TSK-07 JWT | Infra para expor A8 no futuro |
| TSK-09 S3 | Armazenamento **off-chain** do snapshot canonicalizado |
| TSK-41…43 ETL | Migração operacional — **fora** escopo PoC FAPESC |

**Estimativa de overlap:** TSK-32 cobre ~**5–10%** do escopo FAPESC (gatilho + menção SHA-256).

### 9.3 O que **falta** da FAPESC no backlog Dimas

| Entregável FAPESC | No Dimas? | Onde tratar |
|-------------------|-----------|-------------|
| A1 Relatório requisitos normativos (TCE, MP, 14.133…) | ❌ | Projeto FAPESC / coordenador |
| A2 Análise comparativa redes (L2, Polygon, Hedera…) | ❌ | [`docs/imutabilidade/02_REDES_BLOCKCHAIN.md`](../imutabilidade/02_REDES_BLOCKCHAIN.md) |
| A3/A4 DDA arquitetura imutabilidade | ❌ | Chat Imutabilidade |
| A4b Parecer patenteabilidade | ❌ | Contrapartida proponente |
| A5a Mapeamento DER → dataset ancoragem | ❌ | FAPESC Fase 1 |
| A5b **Serialização determinística** | ❌ | **Núcleo FAPESC** — ausente no PDF |
| A6 Módulo hash dedicado pós-fechamento | ⚠️ | TSK-32 parcial |
| A7 **Conector registro externo** (blockchain/testnet) | ❌ | **Ausente totalmente** |
| A8 **API verificação integridade** | ❌ | Não há `GET /integridade/{idRdo}` |
| A9 Integração testnet/homologação | ❌ | |
| A10 Testes carga/stress | ❌ | |
| A11 Auditoria segurança + LGPD (payload) | ❌ | |
| A12 Teste adulteração pós-ancoragem | ❌ | |
| A13 Custo operacional por registro | ❌ | |
| A14 Documentação TRL 5 | ❌ | |
| A15/A16 INPI + relatório final FAPESC | ❌ | |

**Lacunas técnicas concretas (não previstas no Dimas):**

| Componente | Status |
|------------|--------|
| Tabela `rdo_ancoragem` (hash, tx_id, rede, status) | ❌ |
| Fluxo pós-assinatura → snapshot → hash → registro externo | ❌ |
| Política on-chain vs off-chain + LGPD | ❌ |
| 50–100 registros verificáveis em testnet | ❌ |
| Verificação independente (explorer + API) | ❌ |
| PoC **sem alterar pipeline produção** comercial | ❌ — Dimas mira cutover (TSK-45) |

### 9.4 Diagrama — três trilhas paralelas

```
  Trilha 1 — FAPESC (9 meses, PoC backend, chat Imutabilidade)
  ┌────────────────────────────────────────────┐
  │ A5b serialização → A6 hash → A7 registro   │
  │ → A8 API verificação (testnet)             │
  └──────────────────┬─────────────────────────┘
                     │ plug-in (módulo Imutabilidade)
  Trilha 2 — Dimas migração Core
  ┌──────────────────▼─────────────────────────┐
  │ TSK-01…10 Core · TSK-31 RDO · TSK-32 assin.│
  │ TSK-33 PDF · TSK-41…45 ETL go-live         │
  └──────────────────┬─────────────────────────┘
                     │
  Trilha 3 — Onda 0 apps (paralelo)
  ┌──────────────────▼─────────────────────────┐
  │ RN Piscineiro/Apontador · Apontamento API  │
  └────────────────────────────────────────────┘

  Fase 2 (pós-FAPESC): EDI — docs/editais-fapesc/07_EDI_FASE2.md
```

### 9.5 TSK-32 ≠ FAPESC — decisão recomendada

| TSK-32 (Dimas) | FAPESC (A5b–A9) |
|----------------|-----------------|
| SHA-256 na assinatura / documento | Hash do **snapshot determinístico** do grafo RDO |
| Provavelmente no fluxo comercial | PoC em **ambiente isolado** + testnet |
| 8 h estimadas | ~9 meses · entregáveis A1–A16 |
| Sem registro externo | Conector blockchain/ledger (A7) |
| Sem API de verificação para terceiros | A8 explícita |

**Proposta:** criar projeto/módulo **`RdoApp.Imutabilidade`** (ou bounded context) na solution Core, **financiado e reportado à FAPESC**, separado das TSK de produto. TSK-32 implementa **assinatura comercial**; ao fechar RDO, **dispara evento** consumido pelo módulo FAPESC (quando existir).

### 9.6 Cronograma de convivência (1 dev @ 20 h/sem)

| Período | Dimas (migração) | FAPESC (imutabilidade) |
|---------|------------------|------------------------|
| Meses 1–3 | Onda 0 + TSK-01…07 + TSK-31 | A1, A2, A5a (DER + redes) |
| Meses 4–6 | TSK-15…35 domínio + RDO | A5b, A6, A7 spike testnet |
| Meses 7–9 | React strangler + relatórios | A8, A9, A10–A13 validação |
| Meses 10+ | ETL Onda 6 | A14–A16 encerramento FAPESC |

> **Risco:** 1 pessoa @ 20 h/sem **não** cumpre Dimas (346 h) **e** FAPESC (9 meses) em paralelo sem deslocar prazos. Opções: segundo recurso FAPESC (consultoria dev), reduzir escopo Dimas no mesmo período, ou sequenciar (FAPESC PoC primeiro em homolog, migração produto depois).

### 9.7 EDI

EDI (fase 2) **não está** no Dimas nem na FAPESC. Complementa a âncora após fomento — ver [07_EDI_FASE2.md](../editais-fapesc/07_EDI_FASE2.md).

---

## 10. Próximos passos

1. Dimas validar tabela §4 (TSK → U) e ajustar estimativas TSK-43, 46–48.  
2. Exportar TSK para GitHub Issues / Azure DevOps com tag `onda-0`…`onda-6`.  
3. Definir **MVP 90 dias** (Fase A+B parcial): Onda 0 + TSK-01…07 + U-08.  
4. Atualizar [comparativo-e-plano-unificado.md](./comparativo-e-plano-unificado.md) §2.7 com link para este arquivo.  
5. Alinhar com Dimas: **TSK-32 ≠ FAPESC** — módulo `Imutabilidade` separado (§9).

---

## Referências

| Arquivo | Descrição |
|---------|-----------|
| `Backlog_RDO v20260818.pdf` | Dimas · 18/ago/2026 · 56 TSK · 346h |
| `Backlog-Reescrita-RDO-Piscinas.pdf` | Dimas · 15/jul/2026 · 64 hist · 240–448 dias |
| [comparativo-e-plano-unificado.md](./comparativo-e-plano-unificado.md) | Plano mesclado Ondas 0–6 |
| [analise-apontador-dimas-v1.md](./analise-apontador-dimas-v1.md) | Estado App Apontador ago/2026 |
| [docs/editais-fapesc/](../editais-fapesc/README.md) | Proposta FAPESC 031/2026 · entregáveis A1–A16 |
| [docs/imutabilidade/](../imutabilidade/README.md) | Redes blockchain · on-chain/off-chain · EDI fase 2 |
