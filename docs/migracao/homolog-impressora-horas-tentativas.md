# Impressora Controle de Horas · log de tentativas

**Trilha:** EQ-R · Card tarefa → ícone impressora · `HorasEquipamentoReportService`  
**Fuso:** America/Sao_Paulo · **Regra:** tentativa = linha com data/hora.

---

## Tentativas

| # | Data/hora (BR) | Erro / sintoma | Diagnóstico | Correção | Resultado |
|---|---------------|----------------|-------------|----------|-----------|
| **I0** | 2026-11-18 ~08:32 | Excel: Hi/Hf=00:00 · horários em HEi/HEf | **15/11/2026 = domingo** — regra prod `ValidarHoraExtra` fds → tudo em HE | Explicar; smoke dia útil | Lucio lançando dados outro dia |
| **I1** | 2026-11-18 ~08:32 | Relógio: Horas Trabalhadas = 0 | UI lia `horimetroTotal` na coluna errada · DB `tar_nr_horas_trabalhadas` null no save | DTO `horasTrabalhadas` + derive Hi–Hf · save grava horas · modal/cadastro corrigidos | código local |
| **I2** | 2026-11-18 ~08:45 | Excel colunas cortadas · sem totais | SpreadsheetML sem larguras | Excel → HTML.xls + cabeçalhos + linha/faixa **Totais** | código local |
| **I3** | 2026-11-18 ~14:30 | Layout Excel ≈ prod; PDF fraco; logo Excel **rdo**; aviso formato/extensão | PDF sem grupos/totais; HTML.xls ≠ BIFF | PDF = grade Excel; colgroup ####; pendência **M7-REL-HORAS-XLS** (ClosedXML logo+aviso) | código local · smoke pós-deploy |
| **I4** | 2026-11-18 ~17:55 | Smoke **B** relógio + **A** Excel | — | Lucio: Horas Trabalhadas OK · Excel layout/totais OK · logo rdo backlog · **C** dia útil depois | ☑ A+B · seguir checklist 2.1 |

---

## Regras prod (lembrete)

- Seg–Qui: HN ~07–17; fora → split HE  
- Sexta: limite 16h  
- Sáb/Dom: **tudo HE** (Cat.2 → ManutOP)  
- Relógio = horário bruto · Impressora = apropriação HN/HE/Manut  

## Smoke pós-deploy

1. Relógio: **Horas Trabalhadas** = duração Hi–Hf (não 0 se houver intervalo).  
2. Impressora Excel: Data/Equipamento legíveis · faixa Totais · dia útil com HN em Hi/Hf.  
3. Domingo continua HE (paridade).
