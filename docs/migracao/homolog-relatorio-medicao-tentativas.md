# Relatório de Medição · Erro 500 · log de tentativas

**Trilha:** EQ-R · **Homolog:** `POST /api/bff/medicao/relatorio` · Kestrel `:5081` (Windows EC2)  
**Fuso:** America/Sao_Paulo (UTC−3) · **Regra:** toda tentativa = **uma linha** com **data e hora**.

---

## Tentativas

| # | Data/hora (BR) | Erro / sintoma | Diagnóstico | Correção | Resultado | Próxima |
|---|---------------|----------------|-------------|----------|-----------|---------|
| **M0** | 2026-11-16 ~10:40 | Toast «em breve» | Stub SPA | Restore download | tip `8738a56` | — |
| **M1** | 2026-11-16 ~23:00 | Erro 500 genérico | Hipótese Arial Linux | Sem Arial + logo safe | tip `e208632` | — |
| **M2** | 2026-11-17 ~08:15 | Erro 500 genérico | Toast sem `message` | Toast detalhado | tip `a60418c` | — |
| **M3** | 2026-11-17 16:25 | `(corpo vazio)` | Suspeita query/PDF | JSON `Content`; PDF simples | zip ~17:05 | — |
| **M4** | 2026-11-17 17:20–17:23 | `(corpo vazio)` pós-deploy | DI: faltava `AddScoped<MedicaoRelatorioService>()` | Registrar no `Program.cs` | **deployed** | — |
| **M5** | 2026-11-17 ~18:11 | `InvalidCastException — DBNull → String` | DI OK (mensagem chegou). Pomelo LINQ + colunas `string` não-nullable (`eta_ds_etapa` / `tar_ds_tarefa` / `emp_ds_razao_social`) = L13 | `SqlQueryRaw` + DTOs `string?` (sem LINQ string) | **código local** | Commit/push → publish/deploy → smoke PDF+Excel |

---

## Smoke pós-deploy

1. Ctrl+F5 → Medição → **PDF** e **Excel**.  
2. Esperado: download.  
3. Se falhar: colar toast completo + hora.
