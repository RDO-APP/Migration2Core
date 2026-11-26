# Homolog — bug Cards ⋮ status rápido (horas / Editar)

**Trilha:** EQ-R · **Data:** 2026-11-20  
**Obra teste:** MIGRAÇÃO 15/11 · tarefa “tarefa 15/11 16h”

## Sintoma (Lucio)

1. ⋮ → Pausada, depois ⋮ → Em Execução (mesmo dia 15/11/2026).
2. Histórico MEDIÇÃO: horas `—` nas duas linhas novas; só **Visualizar** (sem lápis).
3. Linha **Planejada** ainda tem Editar.

## Causa

| Sintoma | Causa |
|---------|--------|
| Horas `—` | `TarefaStatusUpdateService` clonava sem preencher hora. |
| Sem Editar | `rdoAssinado` true se a medição está em `rdo_tarefa` de RDO status 2/3. Após assinar RDO do dia, Pausada/Em Execução ligadas ao RDO travam. Planejada **não** entra no sync RDO → continua editável. |

## Correção (Git `c61d366` · smoke no **próximo** publish/deploy)

**⋮:** nova linha com **data + hora do clique** (`HoraInicial` = `HoraFinal` = agora), sem abrir página. Qtd/comentário zerados; horímetro carrega o final da medição anterior.

**Decisão Lucio 20/11 ~17:35:** não bloquear M6 — smoke ⋮ no próximo publish/deploy.

Arquivos: `TarefaStatusUpdateService.cs`.

## Smoke (próximo publish)

1. Cards → ⋮ → Pausada (ou Em Execução).
2. Histórico: linha nova com **Data** + **Hora Inicial/Final** preenchidas (não `—`).
3. Sem RDO assinado naquele id → lápis Editar visível.

## Regressão data D+1 (20/11 ~22h · Lucio)

**Sintoma:** ⋮ gravou **21/11** com horas **01:07** (iguais = OK) enquanto no Brasil era **20/11 ~22h**.  
**Causa:** EC2 Linux `DateTime.Now` = **UTC** → à noite BRT vira dia seguinte.  
**Fix:** `AgoraBrasil()` (`America/Sao_Paulo`) em `TarefaStatusUpdateService` — **publish/deploy** antes de retestar.

## Relacionado

- Fotos: [`homolog-p4-foto-tentativas.md`](homolog-p4-foto-tentativas.md) **F8** (`imagensGravadas`)
- M6/M5 estacionados: [`ORQUESTRADOR-MIGRACAO.md`](../ORQUESTRADOR-MIGRACAO.md) § Parque
