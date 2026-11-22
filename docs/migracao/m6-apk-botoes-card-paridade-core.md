# M6 — Card Apontador × Core web (botão a botão)

**Atualizado:** 2026-11-22 · **Trilha:** EQ-M  
**Não confundir:** Bearer A/B/C = Core aceita JWT nos paths legado. **Não** = portar regras de UI do web para o app.

| Controle | Core web (homolog) | App Apontador | API Core JWT | Veredito |
|----------|-------------------|---------------|--------------|----------|
| **⋮ status** | `POST /api/bff/tarefas/{id}/status` → grava linha | Antes: **só pintava** CSS · Agora: `POST /api/tarefa/AtualizarStatus` | ☑ `MobileTarefaLegacyController` | App precisa **rebuild EAS** p/ o wire |
| **Relógio** | modal + query histórico | `CarregarHistoricoTarefa` | ☑ C | Smoke pós-publish Core |
| **+ Nova medição** | modal P4 + BFF Salvar | `ObterTarefa` + `Salvar` (+ horímetro/paralizações) | ☑ C | Smoke; satélites abaixo |
| **Salvar (no form)** | BFF cookie `TarefaCadastroSave` | `POST /api/tarefa/Salvar` (mesmo serviço Save) | ☑ C | Se falhar: ver payload / `ObterColaboradoresObra` |
| **Impressora** | BFF relatório horas | `GerarRelatorioControleHoras…` | ☑ C | Smoke |
| **Olho / Lápis** | cadastro SPA | **não existem** no card (produto campo) | — | OK por desenho · EQ-M-GPA-01 |
| **Gráfico** | — / Chart | atalho dashboard (noop / parcial) | — | residual |
| **Colaboradores obra** | BFF / sessão | `ObterColaboradoresObra` (best-effort no load) | ❌ ainda sem JWT | Soft-fail; Salvar segue |
| **Equipamentos obra** | BFF | `ObterEquipamentosObra` | ❌ | residual se form precisar |

## O que Bearer C **não** fez

- Não ligou o ⋮ no app (era gap de **UI**).
- Não garante Salvar se o Core **não** estiver publicado.
- Não implementa olho/lápis mobile.

## Ordem de aceite

1. Publish Core `62c9b75` (A+B+C).  
2. Smoke APK #10: relógio · + · Salvar · print (sem novo EAS).  
3. EAS novo só após wire ⋮ (este commit mobile) → smoke ⋮ grava no BD.  
