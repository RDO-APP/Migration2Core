# O que falta em homolog vs produção (lista completa)

**Trilha:** EQ-R · **Rota:** `/Rdo/Cadastro` · **Prod:** `#/rdo/cadastro` · **Homolog:** React M7 **7a**  
**Referência legado:** `cadastro.html` · CSS `style.css` / `material-kit.css` (`.panel`, `fieldset`, `.Lista-toggle`, `.togglebutton`) · BFF `GET/POST /api/bff/rdos/cadastro/*`  
**Atualizado:** 2026-10-30 (smoke **T7c** + prints prod×homolog Lucio) · **Deploy homolog:** zip `20261029-235613` · Git **7a-P1** `d76dc52` + P0 `3c061b6`

| Coluna | Significado |
|--------|-------------|
| **Bloco** | **1** = caixa branca (data, clima, improd, comentários) · **2** = etapas/tarefas + fotográfico + rodapé |
| **Print** | Par prod/homolog (out/2026) |
| **1) Solução aplicada** | Git / fase |
| **2) Resultado** | Homolog após deploy **235613** |
| **3) Próxima solução** | Fase planejada |

## Lista completa (homolog vs produção)

| # | Bloco | Print | Produção | Homolog (gap) | 1) Solução aplicada | 2) Resultado | 3) Próxima solução |
|---|-------|-------|----------|---------------|---------------------|--------------|-------------------|
| **F0** | **1** | 1–4 | **`div.panel`** branca única envolvendo data + clima + improd + comentários (padding, fundo, largura colunas BS3) | Conteúdo solto em `rdo-cadastro-panel` **sem** paridade da **caixa branca** maior | CSS mínimo **7a** | **T7c** — campos existem; **sem** “moldura” panel prod | **7a-P4** — markup/classes `panel` + CSS legado |
| **B1** | **1** | 1 | Cabeçalho **`panel-heading`** + **`h3` “RDO”** | **`h3` “Gerar RDO”** (fora do mesmo heading prod) | — | **T7c** — **manter “Gerar RDO”** (decisão; prod só “RDO”) | **—** (não trocar para “RDO” salvo nova decisão) |
| **B5** | **1** | 1 | **Data** + **`datepicker-here`** abre calendário | Input + máscara; **calendário não abre** | Máscara **7a** | **T7c** — só digitação | **7a-P4** datepicker legado |
| **B6** | **1** | 2–3 | Tempo/chuva: radios **sem** marcação inicial | Comportamento igual (vazio ao abrir) | **7a-P1** `d76dc52` | **T7c** — **OK funcional** | — |
| **B6a** | **1** | 2–3 | **`h5` Clima** · **`fieldset`** com borda · **2× `col-md-6`**: legend **Tempo:** / **Chuva:** · 3 colunas Manhã/Tarde/Noite · ícones fontello nas labels | **`rdo-fieldset`** genérico; **sem** grid prod; **sem** ícones (**B2**) | **7a** + **P1** | **T7c** — **layout ≠ prod** (falta moldura/grade/legendas) | **7a-P4** copiar estrutura `cadastro.html` L18–150 + CSS |
| **B2** | **1** | 2–3 | **`icon-sunrise` / `icon-sun` / `icon-moon`** nos rótulos | Só texto “Manhã/Tarde/Noite” | — | **T7c** — ícones ausentes | **7a-P4** (fontello M4.7) |
| **B3** | **1** | 4 | **Motivos de improdutividade** — 10 toggles Material | 10 **checkboxes** funcionais | **7a-P1** `d76dc52` | **T7c** — **OK funcional** | — |
| **B3a** | **1** | 4 | **`fieldset.Lista-toggle`** + legend · **2 linhas `bloco`** com **5× `togglebutton col-md-15 col-sm-4`** (5 em cima, 5 em baixo) · switch visual | **Grid flex** simples; **sem** `Lista-toggle` / **sem** toggles Material · **sem** “caixa” do fieldset prod | — | **T7c** — **5+5 sem frame/toggle prod** | **7a-P4** `material-kit.css` `.togglebutton` + HTML legado |
| **B4** | **1** | 5 | **Comentários** + 👍/👎 (FA **`input-group`** + **`input-group-addon`**) | Textarea + botões emoji; **save OK** | **7a-P1** `d76dc52` | **T7c** — **OK funcional** | — |
| **B4a** | **1** | 5 | Textarea **`form-control`** largura total; thumbs **à direita** no addon (fa-thumbs-o-up/down) | **`rdo-comentarios-input`** flex; proporção/ bordas **≠ prod** | — | **T7c** — **formatação “horrível”** vs prod | **7a-P4** markup `cadastro.html` L243–260 |
| **C1** | **2** | 6 | Título **“ETAPAS / TAREFAS”** | Só **“Tarefas”** | — | **T7c** — **sem mudança** pós-P1 | **7a-P4** copy |
| **C2** | **2** | 6 | **“Habilitar relatório fotográfico?”** **Sim / Não** | **Ausente** | — | **T7c** — **sem mudança** | **7a-P3** |
| **C3** | **2** | 6–7 | Accordion cabeçalho faixa azul + **`+`** | **▶/▼** seta | CSS mínimo **7a** | **T7c** — **sem mudança** | **7a-P4** |
| **C4** | **2** | 7–8 | Tabela **DESCRIÇÃO · STATUS · QTD. COLAB. · QTD. EQUIP. · AÇÕES** | Lista descrição + checkbox | Tag **dia anterior** **7a** | **T7c** — **sem mudança** | **7a-P2** |
| **C5** | **2** | 7–8 | **Editar** (lápis) em **AÇÕES** | Ausente | — | **T7c** — **sem mudança** | **7a-P2** |
| **C6** | **2** | — | Fotos / galeria (após C2) | Ausente | — | — | **7a-P3** |
| **C7** | **2** | 7–8 | Marcar etapa: **checkbox** no **`<thead>`** | Botão **Marcar/Desmarcar etapa** | **`498ebc4`** | **T7c** — **sem mudança** | **7a-P2** |
| **A1** | **2** | — | Accordion etapas estilo prod | Accordion/lista simplificada | **7a-P0** `3c061b6` | **T7c** — etapas **200**; visual ≠ prod | **7a-P2** + **P4** |
| **A2** | **2** | — | Checkbox por **linha de tabela** | Checkbox na lista | **7a** `498ebc4` | **T7c** — **sem mudança** | **7a-P2** |
| **D1** | **2** | 8–10 | **VOLTAR** + **GERAR RDO** (ícones) | **Voltar** + **SALVAR** | Voltar **7a** | **T7c** — **sem mudança** | **7a-P4** |
| **D2** | **2** | — | Fluxo substituir / copiar dia anterior | `window.confirm` | **7a** + P0 | SALVAR não revalidado T7c | Reteste pós-**D1** |
| **E1** | — | — | Editar RDO | Listagem **7a** | P5a | — | **7b** |
| **E2** | — | — | PDF | Prod | — | — | **7c** |
| **E3** | — | — | Assinar | Prod | — | — | **7d** |
| **E4** | — | — | Redesign SPA global | Adiado | UI-M3 | — | pós P1–P4 |

### Resumo smoke **T7c** (2026-10-30, deploy `235613`)

| Grupo | Funcional | Visual / paridade |
|-------|-----------|-------------------|
| **Bloco 1** | **B6, B3, B4** OK (**P1**) | **F0, B6a, B3a, B4a, B2, B5** abertos → **P4** |
| **Bloco 2** | Etapas **200** (**P0**) | **C1–C7, A1, A2, D1** **sem mudança** pós-P1 → **P2/P3/P4** |

**Totais:** **26** linhas (F0 + A–E) · **Func OK T7c:** B6, B3, B4 · **Parciais:** F0, B6a, B3a, B4a, A1, A2, C4, D1, … · Detalhe: [`homolog-p5-rdo-tentativas.md`](homolog-p5-rdo-tentativas.md) **T7c**

---

## Fases de entrega (mapa)

| Fase | Escopo | Git |
|------|--------|-----|
| **7a** | SPA + BFF cadastro | `498ebc4` |
| **7a-P0** | Fix **500** etapas | `3c061b6` |
| **7a-P1** | B3, B4, B6 (funcional) | ☑ `d76dc52` |
| **7a-P2** | Bloco **2:** C4, C5, C7, A2 | ☐ |
| **7a-P3** | C2, C6 fotográfico | ☐ |
| **7a-P4** | Bloco **1** visual: **F0, B6a, B3a, B4a, B2, B5** + Bloco **2:** B1?, C1, C3, D1 | ☐ |
| **7b–7d** | E1–E3 | ☐ |

---

## Changelog deste doc

| Data | Nota |
|------|------|
| 2026-10-30 | **T7c** — linhas **F0, B6a, B3a, B4a**; blocos 1/2; **B1** manter Gerar RDO; matriz **26** |
| 2026-10-29 (d) | **7a-P1** `d76dc52` col. 1 — B3/B4/B6 |
| 2026-10-29 (c) | Tabela única + Print |
| 2026-10-28 | P0 |
