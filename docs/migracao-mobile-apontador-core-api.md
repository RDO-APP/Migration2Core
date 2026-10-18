# Estudo E3 — Mobile Apontador × Core × legado API

**Data:** 2026-10-17 · Base: `analise-apontador-dimas-v1.md` + estudos Onda 0 (jul–ago/2026).

**Repo:** [RDO-APP/EquipamentosMobile](https://github.com/RDO-APP/EquipamentosMobile)

---

## 1. Resumo executivo

| Pergunta | Resposta (estudo) |
|----------|-------------------|
| Apontador consome Core homolog Razor? | **Não** — consome **HTTP API** do site Equipamentos |
| URL prod hoje | **`https://sistema.rdoapp.com.br`** (`EXPO_PUBLIC_API_ENV=prod` no branch Dimas) |
| Homolog mobile configurado? | **Fraco** — `.env` Dimas forçou prod; PiscinasMobile tinha URLs homolog (Carlos) |
| Core `:5081` serve mobile? | **Não** — sem controllers API REST equivalentes ao `rdoappProject/Api` |
| Branch ativa Dimas | **`feature/alteracoes_apontador`** (`14cf5d3`, 10/ago/2026) — **não** mergeada em `main` |

---

## 2. Arquitetura atual (diagrama)

```text
Apontador (Expo RN)
    → authService / tarefaService / obraService
    → HTTPS sistema.rdoapp.com.br/api/*
    → ASP.NET legado Equipamentos (Web API)
    → RDS novo_rdoapp (prod)

Core homolog (Razor MVC :5081)
    → cookie + sessão MVC
    → RDS homol_rdoapp
    → (sem API mobile)
```

**Implicação:** migrar web operador (Razor) **não** migra Apontador automaticamente.

---

## 3. Fork Piscinas → Equipamentos (94% igual)

| Arquivo chave | Mudança Apontador |
|---------------|-------------------|
| `appVariant.ts` | `appApontador`, `matchesDefaultEtapa("EQUIPAMENTO")` |
| `normal-work-details.tsx` | Filtro etapa equipamentos |
| `app.config.ts` | `com.dimasduarta.rdoapp.apontador` |
| `eas.json` | profiles Apontador |

**Decisão ago/2026:** **não trancar etapa** — accordion com todas etapas; revisar se filtro `matchesDefaultEtapa` ainda necessário.

---

## 4. Onda 0 × backlog Dimas (mobile-first)

Do `storytelling-unificado-dimas-migracao-fapesc.md`:

- **Onda 0** (antes TSK-01): fechar Apps — impressora, Apontamentos, homolog mobile.
- **U-05 / U-08:** API Apontamento Framework + OpenAPI — **Lucio/Carlos**, competem com tempo Core.

**Risco:** Core Razor Cards e **U-05 API** são frentes **diferentes** — JWT (TSK-07) deveria unificar, mas Kiro usou **cookies** no web.

---

## 5. Cenários de evolução (estudo — não decidido)

| Cenário | Prós | Contras |
|---------|------|---------|
| **A — Mobile fica no legado API** até Onda 6 | Zero risco homolog Core | Dupla stack longa |
| **B — Core ganha `/api` espelhando legado** | Mobile troca base URL homolog | Esforço grande; duplicar 28 controllers |
| **C — JWT + API mínima** (login, obras, tarefas) | Alinha TSK-07/ Dimas | Quebra compat auth atual |
| **D — Homolog mobile → RDS homol** via legado homolog site | Teste dados isolados | Precisa IIS homolog **legado** + catálogo — não só Core |

**Para homolog coordenado Equipamentos:** cenário **D** ou **B parcial** merece workshop Dimas×Lucio×Carlos.

---

## 6. Checklist estudo pendente (código vivo)

| # | Item | Onde |
|---|------|------|
| 1 | Clone/`git pull` EquipamentosMobile branch feature | GitHub |
| 2 | Mapear `src/services/*` → paths `api/` | repo mobile |
| 3 | Documentar `EXPO_PUBLIC_*` homolog desejado | `eas.json`, `.env.example` |
| 4 | Comparar OpenAPI se existir (U-08) | Migration2Core / Dimas |
| 5 | EAS homolog build apontando **homolog sistema** (se existir API legado homolog) | ops |

*Este E3 usou documentação jul–set/2026; refresh git é próximo passo operacional.*

---

## 7. FAPESC

PoC imutabilidade (chat FAPESC): **não** exige reescrever Apontador; eventos podem vir de **export legado** ou API futura. Ver `estudo-migracao-fapesc-anexo-2026-q4.md`.

---

## 8. Referências

- `docs/estudos-lucio-apps-plano-migracao-core/analise-apontador-dimas-v1.md`
- `docs/estudos-lucio-apps-plano-migracao-core/especificacao-app-apontador-dimas.md`
- `docs/migracao-matriz-rotas-legado-core.md`
