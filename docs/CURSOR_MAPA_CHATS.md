# Mapa Cursor-only — chats RDO App (canônico)

**Atualizado:** 16/out/2026  
**Estratégia:** todo **código** no Cursor; **conversas separadas por frente**; contexto compartilhado só via **GitHub + docs** (não existe `@` entre chats).

*(Arquivo antigo `CURSOR_MAPA_3_CHATS.md` — mesmo conteúdo; preferir este nome.)*

---

## Sidebar: `loja_php` vs `Equipamentos`

Projeto Cursor = agrupador de chats, **não** pasta Git.

| Projeto sidebar | Chats |
|-----------------|-------|
| **loja_php** | **Loja RDO App** |
| **Equipamentos** | **Migração** · **FAPESC Execução** · **EDI · Smart contract · Token** |

Chat **não move** entre projetos (confirmado 16/out). Loja fica em `loja_php`.

---

## Os 4 chats oficiais

| Título fixo (renomeie na UI) | ID (transcript) | Workspace | Dono |
|------------------------------|-----------------|-----------|------|
| **Loja RDO App** | `65b6e329-2ae6-4468-9f01-485f21d9d68c` | `Loja_PHP_github` | PHP, Moip, deploy homolog/prod |
| **Edital FAPESC — Execução** | `6a7186f9-e813-4d8e-9720-f096c7eae369` | `Equipamentos` | Termo 031/2026, `rdo-blockchain` PoC M1–M3 |
| **Migração do RDO App para .NET Core** | `ee6f7379-dfb3-4995-a6cd-1c691007e9b0` | `Equipamentos` | Ondas U, Dimas, mobile, legado, ponte Loja×Sistema |
| **EDI · Smart contract · Token (RDO App)** | `9b8c1df2-0447-4c06-b310-8ebab0b1ea02` | `Equipamentos` (+ clone `rdo-blockchain` se codar) | EDI fase 2, contratos/token **pós-FAPESC** |

UUID: pasta `%USERPROFILE%\.cursor\projects\<slug>\agent-transcripts\<UUID>\`

---

## Fronteiras

| Chat | Pode | Não |
|------|------|-----|
| **Loja** | `Loja_PHP` | FAPESC, Migração, EDI/token |
| **FAPESC** | Entregáveis Termo, PoC imutabilidade | Token comercial, EDI como escopo subvencionado, Loja |
| **Migração** | Equipamentos, estudos, mobile coord. | Loja push, FAPESC docs M3, tokenomics |
| **EDI / token** | `docs/edi-token-projeto/`, evolução produto pós-PoC | Reescrever proposta FAPESC; Loja; Dimas backlog |

**Pontes:**  
- Loja×Sistema: `docs/ponte-loja-sistema-assinatura.md`  
- EDI×FAPESC: `docs/edi-token-projeto/README.md`

---

## Abrir o 4º chat (colar na 1ª mensagem)

```text
Chat: EDI · Smart contract · Token (RDO App) — 4º frente RDO.

Leia @docs/CURSOR_MAPA_CHATS.md e @docs/edi-token-projeto/README.md.
Escopo: EDI fase 2, perfil mensagem RDO, adaptadores órgãos; smart contract/token SÓ pós-FAPESC e com fronteira jurídica.
NÃO misturar: entregáveis Termo (chat FAPESC 6a7186f9…), Loja PHP, Migração Dimas.
FAPESC entrega integridade; este chat empacota/troca (EDI) e explora on-chain/token como produto.

Ao criar: renomeie este chat para o título fixo acima e anote o UUID no mapa.
```

---

## Handoff genérico

```text
Mapa: @docs/CURSOR_MAPA_CHATS.md — escopo deste chat only.
```

---

## Repos

| Repo | Chat |
|------|------|
| `Loja_PHP` | Loja |
| `rdo-blockchain` | FAPESC (Termo) · EDI/token (evolução pós-PoC, commits separados por intent) |
| `Equipamentos`, mobile, CleanMigration | Migração |

---

## Changelog

| Data | Mudança |
|------|---------|
| 16/out/2026 | UUID do 4º chat: `9b8c1df2-0447-4c06-b310-8ebab0b1ea02` |
| 16/out/2026 | 4º chat criado · ID `9b8c1df2-0447-4c06-b310-8ebab0b1ea02` |
| 16/out/2026 | Mapa 3→4 chats; EDI/token |
| 16/out/2026 | Cursor-only; Loja não move de projeto |
