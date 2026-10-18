# EQ-R — Scaffold M0 (React + Vite)

**Decisão M0:** não há branch TSK-10 no Git; criar **`client/`** neste repositório.

## Comando (Lucio — PowerShell)

```powershell
cd C:\Dev\Migration2Core\RDO-CleanMigration-2026
npm create vite@latest client -- --template react-ts
cd client
npm install
npm run build
```

## Integração homolog (M2)

- Output: `client/dist` → copiar ou servir via `RdoApp.Core/wwwroot/app`
- Host: `https://homolog.sistema.rdoapp.com.br` (:5081)
- API Cards fase 1: legado `api/etapa/Get` ou BFF no Core (ver `Equipamentos/docs/api-client-equipamentos-v0.md`)

## Checklist

- [ ] Pasta `client/` commitada (sem `node_modules`)
- [ ] README no client com scripts dev/build
- [ ] Primeira rota: Login → Escolher → Cards stub
