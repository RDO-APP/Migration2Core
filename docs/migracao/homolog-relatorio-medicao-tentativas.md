# Relatório de Medição · log de tentativas (+ aprendizado)

**Trilha:** EQ-R · **Homolog:** `POST /api/bff/medicao/relatorio` · Kestrel `:5081`  
**Fuso:** America/Sao_Paulo (UTC−3) · **Regra:** toda tentativa = **uma linha** com **data e hora**.

---

## Tentativas

| # | Data/hora (BR) | Erro / sintoma | Diagnóstico | Correção | Resultado | Próxima |
|---|---------------|----------------|-------------|----------|-----------|---------|
| **M0** | 2026-11-16 ~10:40 | Toast «em breve» | Stub SPA | Restore download | tip `8738a56` | — |
| **M1** | 2026-11-16 ~23:00 | Erro 500 genérico | Hipótese Arial Linux | Sem Arial | tip `e208632` | — |
| **M2** | 2026-11-17 ~08:15 | Erro 500 genérico | Toast sem `message` | Toast detalhado | tip `a60418c` | — |
| **M3** | 2026-11-17 16:25 | `(corpo vazio)` | Suspeita query/PDF | JSON `Content`; **PDF simples** (diagnóstico) | zip ~17:05 | — |
| **M4** | 2026-11-17 17:20–17:23 | `(corpo vazio)` | Falta DI `MedicaoRelatorioService` | `AddScoped` | deployed | — |
| **M5** | 2026-11-17 ~18:11 | `InvalidCastException DBNull→String` | Pomelo LINQ + `string` não-null = L13 | `SqlQueryRaw` + DTO `string?` | deployed | — |
| **M6** | 2026-11-17 ~20:03→22:43 | Excel logo vazio · PDF texto solto → **PDF OK** | M3 `BuildPdfSimple` residual · Excel HTML sem bitmap | `BuildPdf` + `ObrDsFoto` · Excel `bgcolor`/rdo | tip `52ae547` · PDF grade+logo OK (Lucio 22:43) · Excel grade+rdo | Excel bitmap = M7 |
| **M7** | — | Logo Excel = texto **rdo** (Medição + Efetivo) | Placeholder inventado no helper HTML — Excel não embute `data:` URI | ClosedXML + bytes logo (obra/brand) nos **dois** relatórios | ⬜ item Lucio 17/11 | Detalhe depois |

---

## Aprendizado (por que Efetivo não “passou” sozinho)

| Lição Efetivo | O que aconteceu na Medição | Regra para próximos relatórios |
|---------------|----------------------------|--------------------------------|
| **PDF** = QuestPDF header + **Table** + logo `Image` | Em M3 trocamos de propósito para `BuildPdfSimple` (texto) para isolar 500/corpo vazio; **esquecemos de restaurar** após M4/M5 | Ao fechar diagnóstico: **reaplicar layout canônico** no mesmo PR/ciclo |
| **Excel** = HTML.xls + `ExcelHtmlLogoEmbed` (marca, não foto) | Medição já usava o helper, mas célula era `<div style=background>` → Excel ignora → **caixa branca** (print Lucio) | Logo Excel HTML: **`bgcolor` em `<td>`** (ou ClosedXML bitmap) |
| **Dados** = cuidado Pomelo NULL→string | M5 = mesma lição L13 do PDF RDO | Qualquer relatório novo: `SqlQueryRaw` / `(string?)` / sem materializar entidade string non-null |
| **DI** | Serviço novo sem `AddScoped` = 500 vazio | Checklist: service → `Program.cs` → smoke |

### Como reusar na **impressora** (e outros Excel)

1. **Um helper compartilhado** já existe: `ExcelHtmlLogoEmbed` (Efetivo + Medição + futuros).  
2. **PDF:** copiar padrão `EfetivoRelatorioService.BuildPdf` (header Row + Table Relative/Constant estável).  
3. **Impressora P3 (#4):** mesmo pipeline — HTML.xls via `ExcelHtmlLogoEmbed` + QuestPDF tabela; **não** reinventar logo com `<img data:>`.  
4. **Bitmap real no Excel** = marco **ClosedXML** (`M7-REL-*-LAYOUT`) — um PR para todos os relatórios.  
5. Checklist smoke relatório novo: download · PDF com grade · Excel com marca **rdo** (ou logo ClosedXML) · toast com mensagem se 500.

---

## Smoke pós-deploy (M6)

1. Ctrl+F5 → Medição → **PDF** = tabela + cabeçalho (não texto corrido).  
2. **Excel** = célula logo navy com **rdo** (ainda sem foto da obra).  
3. Se PDF cair no simple de novo: anotar toast/`medicao-diag.txt`.
