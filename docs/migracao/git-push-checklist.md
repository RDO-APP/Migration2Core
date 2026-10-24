# Git push — Migration2Core (agente)

**Repo:** `C:\Dev\Migration2Core` · `RDO-APP/Migration2Core`  
**Canônico orquestrador:** [`../ORQUESTRADOR-MIGRACAO.md`](../ORQUESTRADOR-MIGRACAO.md) § Git push

## Regra — OneDrive 100% alinhado ao Git

| Papel | Path |
|-------|------|
| **Fonte da verdade** | `C:\Dev\Migration2Core\docs\` (versionado no Git) |
| **Espelho Cursor** | `…\Equipamentos\Cursor Jun2026\Equipamentos\docs\` (OneDrive) |

Após **cada** `push` (ou `pull` que altere `docs/`): rodar  
[`sync-docs-onedrive-from-git.ps1`](sync-docs-onedrive-from-git.ps1)  
O script copia **só** arquivos rastreados por `git ls-files docs/` — **não** apaga pastas locais extras (Hub, financeiro, etc.).

Se editou no espelho OneDrive: gravar o **mesmo** conteúdo em `C:\Dev\Migration2Core\docs\` **antes** de `git add`.

## Checklist

1. Gravar arquivos no disco do clone **Migration2Core** (não só workspace OneDrive).
2. `git status`
3. `git add` só paths que existem.
4. `git status` → deve listar **Changes to be committed**.
5. `git commit` · `git push origin <branch>`
6. Output do push deve mostrar hash novo (`abc1234..def5678`).
7. **`pwsh -File docs/migracao/sync-docs-onedrive-from-git.ps1`** (a partir de `C:\Dev\Migration2Core` ou path absoluto).

## PowerShell

Usar `;` entre comandos. Evitar `&&`.

## Não fazer

- Commit/push de docs M* / orquestrador no repo **Equipamentos** legado.
- Declarar sucesso se push retornou **Everything up-to-date** sem commit na sessão.
- Fechar sessão de docs **sem** espelho OneDrive sincronizado (passo 7).

## Incidente registro

**2026-10-18:** `git add` falhou em path de doc ainda inexistente → nada staged → falso “up-to-date”.
