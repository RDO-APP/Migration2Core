# M4 — Shell + Escolher React (EQ-R)

**Início:** 2026-10-20 · **Pré:** M3 PASS · **Trilha:** EQ-R · **Gate encerramento EQ-W:** M2+M3 OK

---

## Objetivo

Operador vê **mesmo chrome** prod (header, footer, fundo) nas telas React; reduzir investimento Razor de produto.

---

## Checklist

| # | Item | OK | Notas |
|---|------|:--:|-------|
| M4.1 | **OperadorShell** em Cards (logo, obra no header, usuário, ícones) | ☑ | código 2026-10-20 · deploy homolog pendente |
| M4.2 | BFF expõe `usuarioNome` no contexto Cards | ☑ | |
| M4.3 | Build Vite → `wwwroot/app` + deploy homolog | ☑ | SSM **Success** ~1,4 min 2026-10-20 · `CommandId` `fb301c23-379e-48c6-bbd1-a79e84e15811` · zip `rdoapp_core-20261020-100219` · smoke EC2 200 · **browser M4.1** Lucio |
| M4.4 | **Escolher React** + filtros Obra/Município | ☐ | |
| M4.5 | Login React ou último Razor dentro SPA | ☐ | |
| M4.6 | Declarar EQ-W congelado (só bugfix) | ☐ | orquestrador |

**Fora M4:** toolbar Cards (gap #1) · Nova medição (**M7+**).

---

## Critério parcial M4.1

Cards homolog visualmente alinhado ao header da pág. 2 Escolher (mesma nav azul, nome obra, usuário).
