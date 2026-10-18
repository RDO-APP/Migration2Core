# M1 — Contrato compartilhado (EQ-R + EQ-M)

**Início:** 2026-10-17 · **Trilhas:** EQ-R, EQ-M (doc); EQ-L (API prod)  
**Pré-requisito:** M0 PARCIAL PASS — [`m0-registro-encerramento.md`](m0-registro-encerramento.md)

---

## Objetivo

Uma fonte de verdade para **base URL**, **endpoints prioritários** e **tipos TS** usados por React web e Apontador.

---

## Checklist

| # | Item | OK | Artefato |
|---|------|:--:|----------|
| M1.1 | Cenário homolog mobile **A** documentado | ☑ | [`api-client-equipamentos-v1.md`](api-client-equipamentos-v1.md) § Cenários |
| M1.2 | Catálogo endpoints (v0 → v1) | ☑ | v1 doc |
| M1.3 | Tipos TS bloco **Auth + Obra + Cards** | ☑ | [`api-client/equipamentos-api.types.ts`](api-client/equipamentos-api.types.ts) |
| M1.4 | Mapeamento Core homolog vs API legado (M2) | ☑ | v1 § Estratégia EQ-R homolog |
| M1.5 | Orquestrador → M1 ativo | ☑ | `ORQUESTRADOR-MIGRACAO.md` |

---

## Fora de M1

- Pacote npm publicado (opcional M2)
- JWT / OpenAPI U-05 (M6)
- Fix EQ-W0.5 (paralelo, não gate M1)

---

## Fechamento M1

**Status:** **FECHADO** 2026-10-17 — M1.1–M1.5 ☑.

### Pendente pós-M1 (não reabre M1)

| Item | Onde |
|------|------|
| Pacote npm `@rdo/api-client` | M2+ (opcional) |
| Mobile importar tipos do mesmo arquivo | M5 / refator EQ-M |
| Tipos só no workspace OneDrive até commit | **Migration2Core** quando Lucio pedir |

**Próximo marco:** **M2** — [`migracao/m2-execucao-checklist.md`](migracao/m2-execucao-checklist.md).
