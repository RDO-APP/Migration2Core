# Git push — Migration2Core (agente)

**Repo:** `C:\Dev\Migration2Core` · `RDO-APP/Migration2Core`  
**Canônico orquestrador:** [`../ORQUESTRADOR-MIGRACAO.md`](../ORQUESTRADOR-MIGRACAO.md) § Git push

## Checklist

1. Gravar arquivos no disco do clone **Migration2Core** (não só workspace OneDrive).
2. `git status`
3. `git add` só paths que existem.
4. `git status` → deve listar **Changes to be committed**.
5. `git commit` · `git push origin <branch>`
6. Output do push deve mostrar hash novo (`abc1234..def5678`).

## PowerShell

Usar `;` entre comandos. Evitar `&&`.

## Não fazer

- Commit/push de docs M* / orquestrador no repo **Equipamentos** legado.
- Declarar sucesso se push retornou **Everything up-to-date** sem commit na sessão.

## Incidente registro

**2026-10-18:** `git add` falhou em path de doc ainda inexistente → nada staged → falso “up-to-date”.
