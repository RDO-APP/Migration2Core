# Relatório de Medição · Erro 500 · log de tentativas

**Trilha:** EQ-R · **Homolog:** `POST /api/bff/medicao/relatorio` · Kestrel `:5081` (Windows EC2)  
**Fuso:** America/Sao_Paulo (UTC−3) · **Regra:** toda tentativa = **uma linha** com **data e hora**.

---

## Tentativas

| # | Data/hora (BR) | Erro / sintoma | Diagnóstico | Correção | Resultado | Próxima |
|---|---------------|----------------|-------------|----------|-----------|---------|
| **M0** | 2026-11-16 ~10:40 | Toast «Relatório de medição — em breve» | Stub `RelatorioPages` | Restore download | tip `8738a56` | — |
| **M1** | 2026-11-16 ~23:00 | Erro 500 genérico | Hipótese Arial Linux | Sem Arial + logo safe | tip `e208632` | — |
| **M2** | 2026-11-17 ~08:15 | Erro 500 genérico | Homolog Windows; toast sem `message` | Toast `Erro {status}: snippet` | tip `a60418c` | — |
| **M3** | 2026-11-17 16:25 | `Erro 500 …: (corpo vazio)` | Corpo vazio; suspeita query/QuestPDF | JSON `Content`; `(string?)`; PDF simples; `medicao-diag.txt` | zip ~17:05 no EC2 (marker no DLL) | Smoke |
| **M4** | 2026-11-17 17:20–17:23 | **Mesmo** `(corpo vazio)` pós-deploy 17:05 | SSM 17:22: DLL tem `medicao-diag` mas **`medicao-diag.txt` MISSING** → action **nunca** rodou. `Program.cs` registra `EfetivoRelatorioService` e **não** `MedicaoRelatorioService` → DI falha ao ativar `BffMedicaoController` → 500 corpo vazio | `AddScoped<MedicaoRelatorioService>()` | **código local** | Commit/push → publish/deploy → smoke PDF+Excel |

---

## Smoke pós-deploy

1. Ctrl+F5 → Medição → PDF e Excel.  
2. Esperado: download **ou** toast com mensagem (não `(corpo vazio)`).  
3. Opcional SSM: `Get-Content ...\logs\medicao-diag.txt -Tail 20` → deve ter linhas `HIT`.
