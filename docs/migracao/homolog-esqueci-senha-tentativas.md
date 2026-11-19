# Esqueci senha · log de tentativas

**Trilha:** EQ-R · **Rota:** `/Account/EsqueciSenha` · Razor `Views/Account/EsqueciSenha.cshtml`  
**Fuso:** America/Sao_Paulo · **Regra:** tentativa = linha com data/hora.

---

## Tentativas

| # | Data/hora (BR) | Erro / sintoma | Diagnóstico | Correção | Resultado |
|---|---------------|----------------|-------------|----------|-----------|
| **E0** | 2026-11-19 ~10:28 | Card branco sem logo · ≠ prod | Razor sem asset/layout prod | — | Dia 0 B4 |
| **E1** | 2026-11-19 ~10:28 | `Não foi possível enviar o e-mail. Verifique SMTP em homolog…` | SMTP Staging EC2 / Locaweb não configurado (ou inválido) | Config ops — **não** código de tela | ⏸ pós-visual / Linux |
| **E2** | 2026-11-19 ~10:42 | (código) | Espelho visual prod | Fundo azul full-bleed · logo `/images/logo.jpg` · Cancelar vermelho / Enviar azul · e-mail+CPF | código local · smoke pós-deploy |

---

## Smoke pós-E2

1. `/Account/EsqueciSenha` — logo **rdo** visível · layout ≈ prod.  
2. Enviar ainda pode falhar SMTP (**E1**) até config EC2 — aceitável no Dia 0.
