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
| Gráfico GESTÃO | Highcharts barras empilhadas (obras × séries) | **C3** ☑ 5 faixas CSS (Atrasados, Ass. Contratada, Ass. Contratante, Gerados, A Gerar) |
| Legenda séries | **No gráfico** (cobre barras): Atrasados · Gerados · Assinados Contratada · A Gerar | Checkboxes **fora** da caixa + Contratante |
| Export | Hambúrguer Highcharts: Print · PNG · JPEG · PDF · SVG | **C4** ☑ mesmo menu EN (sem Highcharts; SVG local) |
| Título | ACOMPANHAMENTO DE RDOs | **GESTÃO DE RDO's** — **ficar** |

---

## Tentativas

| # | Data/hora (BR) | Problema | Solução empregada | Resultado | Nova solução proposta |
|---|----------------|----------|-------------------|-----------|------------------------|
| **C0** | **2026-11-02 ~18:16** | Abertura da página. Prints ① prod × ② homolog. Datas «não parecem funcionar». Colunas largas. Legenda em cima do gráfico. Sem hambúrguer export. Sem Assinado Contratante na legenda prod | **Só inventário** — sem código | Baseline. Toastr RDO (**A5**) ☑ no mesmo smoke | **C1** datas (provar BFF + botão Filtrar) → **C2** largura das barras → **C3** séries/legenda **fora** da caixa → **C4** export |
| **C1** | **2026-11-02 ~18:25** · smoke Lucio **~18:35** | Datas «não filtram» | `BETWEEN {ini} AND {fim}` + Filtrar | **OK** — Lucio: filtros OK | **C2** |
| **C2** | **2026-11-02 ~18:36** · smoke **~18:51** | Barras largas | `BarList` 8px / max 640px / ellipsis | **Não OK** — print GESTÃO: nome cortado, valores longe, plot estreito demais; «30» em todas = tamanho da janela (C1 `DATEDIFF(ini,fim)`), parece filtro «na memória» | **C2b** |
| **C2b** | **2026-11-02 ~18:52** · smoke Lucio **~20:07** | Datas «na memória» + colunas | sessionStorage + atraso 0 + nome **max 300px** + ellipsis | Datas/números **OK** (print 03/10/2019–02/11/2021). **Nome ainda cortado** («…ger…», «FEIRA DE SANT…») — 300px foi chute, não o tamanho do campo | **C2c** |
| **C2c** | **2026-11-02 ~20:08** · smoke **~20:19** | Nome incompleto | max-content + série à parte | **Nome OK**. Ainda 2 linhas CSS ≠ gráfico prod | **C3** |
| **C3** | **2026-11-02 ~20:27** · smoke Lucio **~21:27** | 5 faixas + valores; legenda fora | 1 obra = 1 grupo; 5 faixas **uma acima da outra** (Atrasados, Ass. Contratada, Ass. Contratante, Gerados, A Gerar). Número **em cada barra**. Checkboxes **fora** da caixa. Tabela embaixo. | **OK** | C4 ☰ |
| **C4** | **2026-11-02 ~21:30** · smoke Lucio **~22:33** | Prints ① menu ☰ Print / PNG / JPEG / PDF / SVG. **Não** é C2. | Hambúrguer no canto do painel (sem Highcharts): Print + PNG/JPEG/PDF/SVG a partir de SVG das barras. Menu EN como prod. | **OK** | C5 dias improdutivos |
| **C5** | **2026-11-02 ~22:45** | `/chart/diaimprodutivo` era 1 barra soma | 10 faixas prod (Clima…Equipamento) + checkboxes fora + tabela + ☰ | **Pendente smoke** | C6/C7 |
| **C6** | **2026-11-02 ~22:48** | `/chart/comentario` 1 barra soma | 4 faixas prod (pos/neg × contratada/contratante) + filtro + tabela + ☰ | **Pendente smoke** | — |
| **C7** | **2026-11-02 ~22:48** · smoke Lucio **03/nov ~05:45** | `/chart/tarefa` 1 barra atraso_inicio | 7 faixas prod (canceladas…finalizada) + statusTarefas + tabela + ☰ | **OK** | C8 números/☰ |
| **C8** | **2026-11-03 ~05:50** | Número **dentro** da faixa larga (73) estica a barra; faixa estreita número à direita; ☰ pequeno | Número **sempre** à direita, altura fixa 14px; ☰ 44×40 | **Pendente smoke** | — |

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
5. **C5** `/chart/diaimprodutivo` · **C6** comentário · **C7** tarefa.

---

## Relacionado

- Lista RDO / toastr: [`homolog-p5-lista-rdo-tentativas.md`](homolog-p5-lista-rdo-tentativas.md) **A5 ☑** 02/nov ~18:15 (print homolog Villa Lobos).  
- Fila M5: [`m5-web-paridade-prod-ordem.md`](m5-web-paridade-prod-ordem.md) #2 Chart.
