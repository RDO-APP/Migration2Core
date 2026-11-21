# M6 Fase 2 — APK Apontador → homolog Core + JWT

**Trilha:** EQ-M · **Repo:** `EquipamentosMobile` (`C:\Dev\EquipamentosMobile`) + contrato Core  
**Atualizado:** 2026-11-20 ~20:30  
**Pai:** [`plano-m6-mobile-jwt.md`](plano-m6-mobile-jwt.md)

---

## Objetivo

Build/flavor **homolog** do Apontador falando com **`https://homolog.sistema.rdoapp.com.br`** + JWT (`/api/mobile/auth/*`), smoke jornada mínima em `homol_rdoapp`.

---

## Estado atual (inventário)

| Peça | Hoje |
|------|------|
| `EXPO_PUBLIC_API_ENV=homolog` | Já existe (`eas` profile `appApontadorHomolog`, scripts `start:homolog`) |
| Fallback URL homolog | `http://192.168.0.8:58951` (LAN legado) — **não** é Core L1 |
| Override | `EXPO_PUBLIC_API_BASE_URL` |
| Login app | `POST /api/login/LoginUser` (legado EQ-L) |
| JWT Core | `POST /api/mobile/auth/login` + `GET /me` · 1.2 PASS |
| `historico_login` web | ☑ Account + LoginObra |
| `historico_login` JWT | ☑ código (BffMobileAuth → HistoricoLoginWriter) — deploy no próximo publish |

---

## Entregas Fase 2

| # | Entrega | Aceite |
|---|---------|--------|
| **2.1** | Homolog aponta `API_BASE` → `https://homolog.sistema.rdoapp.com.br` (default env homolog) | Sem depender de 192.168.* |
| **2.2** | Auth homolog usa JWT (`/api/mobile/auth/login`) + Bearer nas calls | Login + me OK no device/emulator |
| **2.3** | Profile EAS `appApontadorHomolog` com `EXPO_PUBLIC_API_BASE_URL` Core | APK interno instalável |
| **2.4** | Smoke: login → obra → medição mínima em `homol_rdoapp` | Gaps listados (não big-bang) |

**Prod (`EXPO_PUBLIC_API_ENV=prod`)** permanece cenário **A** → `sistema.rdoapp.com.br` / `LoginUser` — **não** quebrar.

---

## Ordem / status (20/11 ~20:30)

| # | Passo | Status |
|---|--------|:------:|
| 2.1 | URL homolog → Core L1 + `.env.homolog.example` + EAS | ☑ |
| 2.2 | Dual auth + Bearer em `handleCall` + token store | ☑ |
| 2.3 | EAS build `appApontadorHomolog` | ☑ **Homolog #8 PASS** · tip mobile `1226078` (`packager: npm`) |
| 2.4 | Smoke jornada | ☐ após **publish Core** + **EAS Homolog #9** (overlay + ObterObras JWT) |

Arquivos mobile: `appVariant.ts` · `authService.ts` · `mobileTokenStore.ts` · `services/index.ts` · `AuthContext.tsx` · `LoadingContext.tsx` · `eas.json` · `.github/workflows/homolog.yml`.  
CI: [`EquipamentosMobile/docs/m6-fase2-eas-homolog-ci.md`](https://github.com/RDO-APP/EquipamentosMobile/blob/main/docs/m6-fase2-eas-homolog-ci.md).

---

## Gap conhecido (API)

JWT: **login + me** + **`POST /api/obra/ObterObras`** (Bearer · `MobileObraLegacyController` · 21/11).  
Etapa/tarefa/medição ainda **cookie BFF** — jornada completa = Bearer BFF (backlog).

**Homolog #8:** login JWT OK · spinner em ObterObras (cookie HTML / sem endpoint JWT) + overlay bloqueava Home/Sair.  
**#1 código (21/11):** Core ObterObras JWT + cookie `/api`→401 JSON · mobile overlay timeout 20s + `handleCall` AbortSignal.  
**Agora Lucio:** publish/deploy Core → EAS **Homolog #9** → smoke 2.4 (login + lista obras).
