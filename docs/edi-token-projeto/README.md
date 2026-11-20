# EDI · Smart contract · Token — visão e fronteiras

**Chat Cursor:** `EDI · Smart contract · Token (RDO App)` — `9b8c1df2-0447-4c06-b310-8ebab0b1ea02` — ver [CURSOR_MAPA_CHATS.md](../CURSOR_MAPA_CHATS.md)  
**Atualizado:** 20/nov/2026  
**Status:** fase **pós-FAPESC / produto** — **não** substitui entregáveis do Termo 031/2026

---

## Objetivo pós-FAPESC (decisão Lucio · 20/nov/2026)

**Buscar depois do Termo 031/2026:** pacote **EDI + tokenização + smart contract** como camada de produto (parte on-chain = Web3; EDI sozinho = integração clássica).

| Ordem | Peça | Nota |
|-------|------|------|
| 1 | **EDI fase 2** | Empacotar/trocar a prova (TCE / MP / CREA / contratante) |
| 2 | **Smart contract (produto)** | Além do PoC `RdoAnchor` — só com PoC FAPESC estável |
| 3 | **Tokenização** | Decisão **D13** (chat FAPESC): default sem token negociável no RDO; se houver, parceiro regulado tokeniza crédito; RDO só atesta |

**Não começar agora.** Dono: este chat (`9b8c1df2-…`). **≠** Migração (JWT/EAS) · **≠** entregáveis M1–M3 do Termo.

---

## Tese em uma linha

**FAPESC** entrega **prova de integridade** (assinatura + hash + registro verificável).  
**Este projeto** desenha **como empacotar e trocar** essa prova (EDI) e, se fizer sentido comercial/jurídico, **camada on-chain ampliada** (contratos / token) — **sem** confundir com o PoC subvencionado.

---

## O que entra neste chat (4º)

| Tema | Exemplos |
|------|----------|
| **EDI fase 2** | Perfil de mensagem RDO (JSON Schema), adaptadores TCE / MP / CREA / contratante, barramento, `RDO_FECHADO` |
| **Smart contract (produto)** | Evolução além do PoC `RdoAnchor.sol` — **só** após PoC FAPESC estável; desenho, não prometer em edital |
| **Token** | Utility/governance/incentivo — **modelo econômico, compliance, whitepaper**; implementação só com parecer jurídico |

**Docs de apoio (histórico):** conversas FAPESC sobre EDI (`docs/editais-fapesc/` se existir `07_EDI_FASE2.md`; senão resumo no chat FAPESC `6a7186f9…`). Tokenização ONR/D13: chat FAPESC · 14/out/2026.

---

## O que **não** entra (outros chats)

| Assunto | Chat |
|---------|------|
| Relatório M3, DDA, matriz A2, órgãos FAPESC, deploy Base Sepolia **do Termo** | **Edital FAPESC — Execução** |
| Loja, Moip, assinatura comercial | **Loja RDO App** + ponte assinatura |
| Migração .NET 8, Dimas, mobile, Ondas U | **Migração .NET Core** |

**Regra FAPESC:** nada que **não** esteja no Plano aprovado entra em commit `rdo-blockchain` **como entregável FAPESC** sem marcar “fora do Termo / pós-projeto”.

---

## Dependências

```
FAPESC PoC (integridade + API verify)
        ↓
JSON Schema / serialização determinística (ponte técnica)
        ↓
EDI adaptadores (contratante → TCE → …)
        ↓
Smart contract / token (opcional, jurídico + produto)  ← objetivo pós-FAPESC
```

---

## Repos

| Repo | Papel neste chat |
|------|------------------|
| `RDO-APP/rdo-blockchain` | Contratos e API existentes — **ler/evoluir com label pós-FAPESC** |
| `Equipamentos/docs/edi-token-projeto/` · espelho Migration2Core `docs/edi-token-projeto/` | Specs, schemas, notas EDI/token **deste chat** |

---

## Changelog

| Data | Nota |
|------|------|
| 20/nov/2026 | Lucio: objetivo explícito pós-FAPESC = EDI + tokenização + smart contract (buscar após Termo) |
| 16/out/2026 | Chat criado; UUID `9b8c1df2-0447-4c06-b310-8ebab0b1ea02` |
| 16/out/2026 | Criação pasta + 4º chat no mapa Cursor |
