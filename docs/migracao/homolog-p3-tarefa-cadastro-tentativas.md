# P3 — Cadastro tarefa (olho / lápis / +) · log de tentativas

**Trilha:** EQ-R · **Um GET** para os três botões: `GET /api/bff/tarefas/{id}`  
**Homolog:** obra Fachada Oeste Shopping Barra · tarefa **4934** / REMOÇÃO DE REBOCO  
**Lição 31/out (PDF L11):** `homol_rdoapp.tarefa` **não** é gêmea de `novo_rdoapp.tarefa`. Cards/PDF só quebram quando o SELECT pede coluna que o snapshot homolog não tem.

**Por que não “mapear prod e trazer”:** o Core já espelha o **modelo prod** (EDMX/`tarefa.cs`). O RDS **homol** ficou para trás (horímetro + código). Trazer = `ALTER` no homolog **ou** não mapear essas colunas no EF até o ALTER. Whack-a-mole = materializar a entidade inteira. Diff canônico:

```sql
-- docs/scripts/homol-vs-prod-tarefa-colunas.sql
```

| Prod (`novo_rdoapp`) | Homol (`homol_rdoapp`) | Evidência |
|----------------------|------------------------|-----------|
| `tar_codigo_paralizacao` varchar(3) | **sim** pós-ALTER 11:54 | O0 ~11:00 · T2 |
| `tar_dt_medicao_horimetro_inicial` float | **sim** pós-ALTER 11:54 | PDF **L11** 31/out |
| `tar_dt_medicao_horimetro_final` float | **sim** pós-ALTER 11:54 | O3 ~11:41 |
| `tar_dt_medicao_horimetro_total` float | **sim** pós-ALTER 11:54 | L11 família |

**O que já existia vs o que faltou:** inventário RDS **2026-10-17** comparou **quantidade de tabelas** (47 = 47). PDF L11 (31/out) já apontou horímetro ausente no snapshot. **Não** houve `information_schema` coluna a coluna **antes** do GET cadastro — por isso O0–O3. Script canônico: `docs/scripts/homol-vs-prod-tarefa-colunas.sql`.

---

## Tentativas (olho = lápis = +)

| # | Data/hora (BR) | Problema | Solução empregada | Resultado | Nova solução proposta |
|---|----------------|----------|-------------------|-----------|------------------------|
| **O0** | **2026-11-03 ~11:00** | Olho/lápis 4934 | GET entidade `Tarefa` completa | **500** `t.tar_codigo_paralizacao` | Ignore a coluna |
| **O1** | **~11:05** · deploy **11:11** | Mesmo GET | `Ignore` + tirou `HasColumnName` | **500** `t.TarCodigoParalizacao` — `HasIndex` recolocou a prop | Tirar índice + `[NotMapped]` |
| **O2** | **~11:25** · republish | PascalCase | `[NotMapped]` código + sem `HasIndex` | **500** `t.tar_dt_medicao_horimetro_final` (os 3 botões) | Não mapear **família** horímetro (já vista no PDF L11) · **não** `select tar` |
| **O3** | **2026-11-03 ~11:42** | Horímetro (prod-only), igual L11 | `[NotMapped]`+`Ignore` Hi/Hf/Ht · GET com `Select` só colunas do snapshot | **500 evitado no código; form sem persistir horímetro** | T2 ALTER tipos do prod |
| **O4** | **2026-11-03 11:54** | T2 | Lucio: `ALTER` `homol_rdoapp.tarefa` 4 colunas · 0,393s · **não** `novo_rdoapp` | **DDL OK** (Updated Rows 0 = normal) | Remapear EF (tirar Ignore/NotMapped) + republish |
| **O5** | **2026-11-03 ~16:58** | Olho homolog 4934 vs prod: sem **HISTÓRICO DE MEDIÇÕES**, modal, **Foto**, colaboradores | GET: `listaHistoricoTarefa` por `tar_nr_agrupador` (prod `PreencherHistoricoTarefa`) · `listaImagens` (`imagem.ima_id_tarefa`) · colabs `obra_tarefa_colaborador` + fallback agrupador · SPA botão+modal+galeria | **no ar** pós O8 | Homolog 4934 ≠ prod REBOCO NOVO; lista vazia pode ser snapshot |
| **O6** | **2026-11-03 ~17:40** | Lápis vs prod: chrome MEDIÇÃO, Foto, 3 botões colab/equip, ACIDENTES, rodapé | SPA paridade visual + ADICIONAR MEDIÇÃO (P4) + associar colab/equip da obra no SALVAR · Foto file picker (persistência Uploads ainda não) · NOVO colab/equip/acidente = formulário completo prod ainda não | **smoke OK** (lápis) | persist Foto / NOVO* **depois** |
| **O7** | **2026-11-03 ~17:56** | P4 modal **+** vs prod: falta Foto, hora `--:--`, hi 0 vs Carregando | Modal: Foto escolher/adicionar, hora máscara, hi `Carregando...` até GET, rodapé × CANCELAR | **deploy 18:12 SSM OK** · **smoke OK** (+) | persistir foto **depois** |
| **O8** | **2026-11-03 ~18:16** | Olho = lápis = **+** **500** `CultureInfo` no `ToString` da projeção EF (`ListaAcidentes`) | `ToList` das datas **antes** de formatar pt-BR | **smoke Lucio OK** — lápis, relógio, **+** | impressora / ⋮ · ajustes cadastro depois |

**O4 EF (máquina Lucio, ainda não no EC2):** `HasColumnName` + `varchar(3)` + float; GET volta a ler horímetro/código. Smoke só depois do paste publish.

**Impacto nas telas já no ar (DDL 03/nov — alargar/ADD não quebra SELECT existente):**

| Tela | Query | Efeito |
|------|--------|--------|
| P1 Login / P2 Escolher | `obra` / colaborador | nenhum |
| P3 Cards | `Select` id/agrupador/`tar_ds_tarefa`/datas/status — **sem** horímetro | nome da tarefa cabe (já era ≤300) |
| Chart C1–C8 | SQL `tar_ds_tarefa` / rdo status / comentários like | COUNT/agrupa igual |
| P5a lista RDO | `Select` id/data/status — **sem** texto comentário | nenhum |
| PDF **L16** | `SELECT` Hi/Hf/Ht no `RdoPdfService` (fim do L12) | imprime se a célula MySQL tiver número; NULL → em branco |
| Cadastro RDO 7a | agrupador + `tar_ds_tarefa` | nenhum |
| Dashboard | COUNT status / efetivo | nenhum |

Pacote **EC2** (pós O8): EF mapeia as 4 colunas; GET/POST cadastro usa horímetro/código. **Smoke 03/nov:** lápis, relógio, **+** = OK. Pendente de produto: **impressora** e **⋮**; polish cadastro (Foto Uploads, NOVO*) **depois**.
