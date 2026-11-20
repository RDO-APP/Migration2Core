# M6 Fase 1 — JWT / OpenAPI (Core homolog)

**Trilha:** EQ-M / I · **Repo:** `Migration2Core` · `RdoApp.Core`  
**Atualizado:** 2026-11-20  
**Plano pai:** [`plano-m6-mobile-jwt.md`](plano-m6-mobile-jwt.md)  
**Pré-requisito:** Fase 0 Baseline OK ([`m6-fase0-baseline-apk-prod.md`](m6-fase0-baseline-apk-prod.md))

---

## Status Fase 1

| # | Entrega | Status |
|---|---------|:------:|
| **1.1** | OpenAPI / mapa API mobile v1 (login + obra + medição mínima) | **stub** — mapa markdown abaixo (sem Swagger ainda) |
| **1.2** | JWT no Core homolog — cookie SPA permanece Default* | **PASS** homolog (login + `/me`) |
| **1.3** | Pacote tipos TS compartilhado (residual M1) | **código** — [`m6-1.3-tipos-ts.md`](m6-1.3-tipos-ts.md) (commit pendente) |
| **1.4** | CORS / audience / expiração / refresh (mínimo seguro) | **FECHADO** — [`m6-1.4-seguranca-jwt.md`](m6-1.4-seguranca-jwt.md) · refresh = **não** (re-login) |

**Próxima ação:** commit 1.3+1.4 docs (se Lucio pedir) · **Fase 2** APK homolog.

---

## 1.1 Mapa stub — inventário Fase 0 vs Core BFF (gap)

Fonte APK: inventário 0.3 em [`m6-fase0-baseline-apk-prod.md`](m6-fase0-baseline-apk-prod.md).  
Core hoje: BFF cookie em `/api/bff/*` + slice JWT em `/api/mobile/auth/*`.

| Área | Legado EQ-L (APK) | Core homolog hoje | Gap |
|------|-------------------|-------------------|-----|
| Auth login | `POST /api/login/LoginUser` | `POST /api/mobile/auth/login` (JWT) · cookie SPA `/Account/Login` | Sem paridade surface LoginUser ainda |
| Sessão / me | implícito no app | `GET /api/mobile/auth/me` (Bearer) | OK slice 1.2 |
| Login obra | `POST /api/Usuario/LoginObra` | BFF obras/shell (cookie) | JWT + LoginObra **pending** |
| Obras | `POST /api/obra/ObterObras` | `/api/bff/obras` (cookie) | Bearer mobile **pending** |
| Etapas | `GET /api/etapa/Get` | `/api/bff/etapas` (cookie) | Bearer mobile **pending** |
| Tarefa / medição / foto | vários `/api/tarefa/*` | BFF tarefas/medição (cookie) | Bearer mobile **pending** |
| Recuperar senha | `POST /api/colaborador/RecuperarSenha` | fluxo web Account | Mobile **pending** |

OpenAPI formal / Swagger: **não** nesta fatia (1.1 = este mapa).

---

## 1.2 Rotas JWT (implementadas)

| Método | Rota | Auth |
|--------|------|------|
| `POST` | `/api/mobile/auth/login` | Anonymous · body `{ "cpf", "senha" }` |
| `GET` | `/api/mobile/auth/me` | Bearer JWT |

Login valida como `AccountController`: strip CPF · `Seguranca.EncryptTripleDES` · query `Colaboradores`.  
Claims no token: `NameIdentifier` (col id), `Name`, `cpf`, `email`, `isAdmin` — iguais ao cookie.

Resposta login (200):

```json
{
  "accessToken": "<jwt>",
  "expiresIn": 28800,
  "tokenType": "Bearer",
  "colaborador": { "id": 0, "nome": "", "cpf": "", "email": "" }
}
```

401 (credencial inválida): `{ "message": "Usuário ou senha não existem." }`

---

## Smoke curl (homolog — após publish/deploy)

Sem secrets no doc. Substituir `CPF` / `SENHA` por colaborador de teste em `homol_rdoapp`.

```bash
curl -sS -X POST "https://homolog.sistema.rdoapp.com.br/api/mobile/auth/login" \
  -H "Content-Type: application/json" \
  -d "{\"cpf\":\"CPF\",\"senha\":\"SENHA\"}"
```

```bash
TOKEN="<colar accessToken do login>"

curl -sS "https://homolog.sistema.rdoapp.com.br/api/mobile/auth/me" \
  -H "Authorization: Bearer $TOKEN"
```

Esperado: login 200 + JSON com `accessToken` · me 200 com claims · sem token → 401 JSON (não redirect HTML).

**Ops:** Lucio deve definir `Jwt:SigningKey` forte no EC2 Staging (`appsettings.Staging.json` / env) — o valor no repo é **placeholder**. Não inventar secret de produção neste doc.

---

## Ops SigningKey via SSM

Lucio configura no **PC** (PowerShell) — agente **não** grava secret real no Git nem neste doc.

1. Gerar chave longa (ex. 32+ chars aleatórios) **só no terminal local**.  
2. Aplicar no homolog Linux via SSM / `appsettings.Staging.json` em `/var/www/rdoapp_core` (ou env `Jwt__SigningKey`) — ver roteiro L1 [`roteiro-deploy-homolog-operador.md`](roteiro-deploy-homolog-operador.md) + scripts `publish-homolog-linux.ps1` / `deploy-homolog-linux-ssm.ps1`.  
3. Reiniciar serviço `rdoapp-core-homolog` se necessário.  
4. Smoke curl login + me (acima).  

**Proibido:** commit de SigningKey real · colar secret em issue/chat/doc · reutilizar chave de prod.

---

## 1.4 Nota de segurança — **FECHADA**

Canônico: [`m6-1.4-seguranca-jwt.md`](m6-1.4-seguranca-jwt.md).

| Tema | Decisão |
|------|---------|
| Cookie SPA | **Intacto** — Default* = Cookies |
| Expiry | **480 min** · `expiresIn` no login · ClockSkew 1 min · sem sliding JWT |
| Audience / Issuer | `rdo-apontador` / `https://homolog.sistema.rdoapp.com.br` |
| Refresh | **Não** — app re-login em 401/expiry |
| CORS | `MobileJwt` em `/api/mobile/auth/*` · homolog + localhost/127.0.0.1 |
| SigningKey | Fora do Git · Staging EC2 |

---

## Fora desta fatia

- Publish/deploy (Lucio) · commit (só se pedido)  
- Swagger UI · refresh token (backlog)  
- Prod `:80` · apontar APK para homolog (**Fase 2**)
