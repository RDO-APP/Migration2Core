# Relatório de Medição · Erro 500 · log de tentativas

**Trilha:** EQ-R · **Homolog:** `POST /api/bff/medicao/relatorio`  
**Prod:** ClosedXML + HTML.xls · **Homolog:** QuestPDF (PDF) + HTML.xls (Excel)  
**Regra:** toda tentativa = **uma linha** abaixo.

---

## Tentativas

| # | Data (BR) | Erro / sintoma | Diagnóstico | Correção | Resultado | Próxima |
|---|-----------|----------------|-------------|----------|-----------|---------|
| **M0** | 2026-11-16 ~manhã | Toast «Relatório de medição — em breve» | Stub `RelatorioPages` pós-merge | Restore `gerarRelatorioMedicao` + `MedicaoRelatorioModal` | Tip `8738a56` | Smoke download |
| **M1** | 2026-11-16 ~23:00 | Toast «Erro 500 ao gerar relatório de medição» | Hipótese: QuestPDF `FontFamily("Arial")` no Linux EC2; bytes logo inválidos → `Image()` throw | Remover Arial; `LooksLikeImage` + try/catch no logo; catch Exception no BFF → `{ message }` | **código local** | Publish/deploy → gerar PDF + Excel |
| **M2** | — | — | Se 500 persistir: mensagem toast deve trazer `ex.Message` | Ler toast / CloudWatch `RdoApp.Core` | — | Linha M2 com causa real |

---

## Smoke pós-deploy

1. Obra com tarefas medidas no período.  
2. Relatórios → Medição → PDF → download.  
3. Mesmo fluxo Excel (`.xls`).  
4. Se falhar: anotar **texto completo** do toast (agora inclui `ex.Message`).
