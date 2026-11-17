# Efetivo — botão Adicionar Colaborador · log de tentativas

**Trilha:** EQ-R · **Homolog:** `homolog.sistema.rdoapp.com.br` · `/Efetivo/Index`  
**Prod:** `icon-obras` (fontello) · title «Adicionar Colaborador» · modal `#novo-colaborador`  
**Homolog alvo:** ícone visível + click → `/Colaborador/Cadastro` (modal in-page = **M7-EFETIVO-NOVO-MODAL**)  
**Regra:** toda tentativa = **uma linha** abaixo.

---

## Tentativas

| # | Data (BR) | Erro / sintoma | Diagnóstico | Correção | Resultado | Próxima |
|---|-----------|----------------|-------------|----------|-----------|---------|
| **A0** | 2026-11-16 ~10:40 | Ícone invisível; title/tooltip funciona; click OK | `<i class="icon-obras">` sem fontello no SPA | Troca p/ `fa fa-users` | Tip `e2e0fe7`/`8738a56` | Smoke pós-deploy |
| **A1** | 2026-11-16 ~23:05 | Ainda «não aparece» (print: ícone copy + texto Adicionar) | Subset **FA4** homolog **sem** glifo `fa-users` → `<i>` vazio; title vira “link” | SVG inline users + rótulo **Novo** + borda (`efetivo-btn-add-colab`) | **código local** | Publish/deploy → smoke: ao lado de Copiar = botão **Novo** (pessoas) |
| **A2** | — | — | — | — | — | Modal in-page = backlog **M7-EFETIVO-NOVO-MODAL** |

---

## Smoke

1. `/Efetivo/Index` → à direita do título: **Copiar** (dois papéis) + botão bordado **Novo** (ícone pessoas).  
2. Click **Novo** → `/Colaborador/Cadastro`.  
3. Hard refresh (Ctrl+F5) se cache de bundle antigo.
