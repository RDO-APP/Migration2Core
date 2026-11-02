# P5a — Dashboard geral / GESTÃO DE RDO's (`/Chart/Index`) · log de tentativas

**Trilha:** EQ-R · **Não** misturar com Dashboard da obra (`/Dashboard/Index`).  
**Homolog:** `https://homolog.sistema.rdoapp.com.br/Chart/Index` · detalhe barras `/chart/rdos`  
**Prod:** `#/chart` · título **ACOMPANHAMENTO DE RDOs** (Highcharts)  
**Homolog título (manter):** **GESTÃO DE RDO's** — Lucio 02/nov, **não** voltar ao texto prod.  
**BFF:** `GET /api/bff/grafico/resumo?periodoIni=&periodoFim=`  
**Roteiro deploy:** [`roteiro-deploy-homolog-operador.md`](roteiro-deploy-homolog-operador.md)

**Decisão C0:** tabela antes do código. **C1** 02/nov ~18:25 — datas no BFF + Filtrar.

---

## Escopo desta página (o que o print cobre)

| Bloco | Prod ① | Homolog ② hoje |
|--------|--------|----------------|
| Filtro datas | Data Início / Data Fim (`__/__/____`) + aplica no Highcharts | Inputs `type="date"` + botão **Filtrar** (Lucio gostou — **manter**) |
| Tile RDO´s Atrasados | Lista + ícone filtro no título | Lista + «Ver mais…» |
| Gráfico GESTÃO | Highcharts barras empilhadas (obras × séries) | `BarList` CSS: **só** «gerados» e «atrasados» por obra (duas linhas) |
| Legenda séries | **No gráfico** (cobre barras): Atrasados · Gerados · Assinados Contratada · A Gerar | **Não** há. Falta **Assinatura Contratante** na legenda prod (ver C0-2.2) |
| Export | Hambúrguer Highcharts: Print · PNG · JPEG · PDF · SVG | **Não** há |
| Título | ACOMPANHAMENTO DE RDOs | **GESTÃO DE RDO's** — **ficar** |

---

## Tentativas

| # | Data/hora (BR) | Problema | Solução empregada | Resultado | Nova solução proposta |
|---|----------------|----------|-------------------|-----------|------------------------|
| **C0** | **2026-11-02 ~18:16** | Abertura da página. Prints ① prod × ② homolog. Datas «não parecem funcionar». Colunas largas. Legenda em cima do gráfico. Sem hambúrguer export. Sem Assinado Contratante na legenda prod | **Só inventário** — sem código | Baseline. Toastr RDO (**A5**) ☑ no mesmo smoke | **C1** datas (provar BFF + botão Filtrar) → **C2** largura das barras → **C3** séries/legenda **fora** da caixa → **C4** export |
| **C1** | **2026-11-02 ~18:25** | Datas «não filtram» | Hipótese (a)+(c) **confirmadas**: (a) precisa **Filtrar** (Enter no form também); (c) SQL usava `BETWEEN início da obra AND data Fim` — **Data Início ignorada** (igual prod atual). Solução: `BETWEEN {ini} AND {fim}` nos counts de RDO/improdutivo/comentário; atraso vs **Data Fim** (não `now()`); texto «Período aplicado». Campos **mantidos** | **Pendente smoke** após publish (sem git pull — working tree local) | Smoke: mês 08/2020 → Filtrar → gerados/atrasados **mudam** vs 30 dias. Tarefas **não** usam data (igual prod). Depois **C2** |
| **C2** | _pendente_ | **1 / 2.1** barras ② muito **largas** / afastadas vs ① apertadas | — | — | Estreitar `BarList` (altura da linha, gap, `max-width` da barra). Título **GESTÃO DE RDO's** não mexer |
| **C3** | _pendente_ | **2.2** prod: legenda no gráfico impede leitura. Séries: Atrasados, Gerados, Assinados Contratada, A Gerar. **Não** aparece Assinado Contratante — Lucio pergunta se é porque está **zerado** | — | — | Legenda/filtro **fora** da caixa do gráfico (checkboxes). Incluir **Assinatura Contratante** mesmo se 0 (não esconder por zero). Empilhar as 5 séries (hoje ② só 2) |
| **C4** | _pendente_ | **2.3** prod: menu ☰ Print chart / PNG / JPEG / PDF / SVG | — | — | Botão/☰ **fora** do plot: imprimir + baixar PNG (e PDF se der no mesmo ciclo). Sem Highcharts no C4 se CSV/canvas bastar |

---

## Hipóteses C1 (datas) — antes de codar

1. UI: `useEffect(load, [])` só na **entrada**; mudar a data **sem** Filtrar não recarrega — isso sozinho explica «não funciona».  
2. BFF: query `periodoIni`/`periodoFim` pode não filtrar o SQL (paridade `GraficoModel`).  
3. Máscara: prod usa `__/__/____`; homolog usa date nativo — preencher e **Filtrar**.

Smoke C1: escolher um mês curto (ex. só agosto/2020) → Filtrar → F12 200 + barras/tiles **mudam** vs período de 30 dias.

---

## Hipótese C3 — Assinado Contratante

Prod Highcharts **pode** omitir série sem pontos. Homolog **não** deve omitir: mostrar série com 0. Confirmar no BFF se `assinado_contratante` vem no JSON.

---

## Ordem combinada (não inverter)

1. **C1** datas funcionando (manter campos).  
2. **C2** estreitar colunas/barras.  
3. **C3** filtro de séries fora da caixa + Contratante.  
4. **C4** export.  
5. Só então outras rotas do Dashboard geral (`/chart/diaimprodutivo`, tarefa, comentário, tiles).

---

## Relacionado

- Lista RDO / toastr: [`homolog-p5-lista-rdo-tentativas.md`](homolog-p5-lista-rdo-tentativas.md) **A5 ☑** 02/nov ~18:15 (print homolog Villa Lobos).  
- Fila M5: [`m5-web-paridade-prod-ordem.md`](m5-web-paridade-prod-ordem.md) #2 Chart.
