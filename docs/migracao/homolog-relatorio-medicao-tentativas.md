# Relatório de Medição · Erro 500 · log de tentativas

**Trilha:** EQ-R · **Homolog:** `POST /api/bff/medicao` · Kestrel `:5081` (Windows EC2)  
**Prod:** ClosedXML + RDLC · **Homolog:** QuestPDF (PDF) + HTML.xls (Excel)  
**Regra:** toda tentativa = **uma linha** abaixo.

---

## Tentativas

| # | Data (BR) | Erro / sintoma | Diagnóstico | Correção | Resultado | Próxima |
|---|-----------|----------------|-------------|----------|-----------|---------|
| **M0** | 2026-11-16 ~manhã | Toast «Relatório de medição — em breve» | Stub `RelatorioPages` pós-merge | Restore `gerarRelatorioMedicao` + modal | Tip `8738a56` | Smoke download |
| **M1** | 2026-11-16 ~23:00 | Toast «Erro 500 ao gerar relatório de medição» | Hipótese Arial Linux / logo | Remover Arial; `LooksLikeImage`; catch BFF | **deployed** tip `e208632` | — |
| **M2** | 2026-11-17 ~08:15 | **Mesmo toast** (sem `ex.Message`) | Homolog = **Windows** (Efetivo PDF c/ Arial OK) → M1 errada; toast = fallback client (corpo 500 vazio / sem `message`) | Toast sempre `Erro {status}: {snippet}`; log `logs/medicao-last-error.txt`; PDF RelativeColumn + fallback `BuildPdfSimple`; soft-fail logo/licença | **código local** | Publish/deploy → PDF **e** Excel; colar toast completo |
| **M3** | — | — | Se ainda 500: ler `C:\inetpub\wwwroot\homologacao\rdoapp_core\logs\medicao-last-error.txt` via SSM | Fix causa real do stack | — | Linha M3 |

---

## Smoke pós-deploy

1. Relatórios → Medição → **PDF** (Ctrl+F5).  
2. Mesmo período → **Excel**.  
3. Se falhar: colar **texto completo** do toast (deve trazer tipo/mensagem).  
4. Opcional: SSM `Get-Content ...\logs\medicao-last-error.txt`.
