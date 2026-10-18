# api-client Equipamentos v0 (M0 — histórico)

> **Canônico M1+:** [`api-client-equipamentos-v1.md`](api-client-equipamentos-v1.md) · tipos [`api-client/equipamentos-api.types.ts`](api-client/equipamentos-api.types.ts)

**Fonte:** `EquipamentosMobile` branch **`feature/alteracoes_apontador`** @ **`14cf5d3`** (2026-08-10)  
**Base URL prod (Apontador default):** `https://sistema.rdoapp.com.br` — `API_ENV=prod` em [`appVariant.ts`](https://github.com/RDO-APP/EquipamentosMobile)  
**Homolog mobile (config):** `http://192.168.0.8:58951` — **cenário M0 = A** (operador web homolog; app prod até M5).

**Backend:** **EQ-L** Web API legado (`Equipamentos` / `rdoappProject/Api`) — **não** Core Razor `:5081`.

---

## Serviços × endpoints

| Service | Método | Path | Uso |
|---------|--------|------|-----|
| authService | POST | `/api/login/LoginUser` | Login CPF/senha |
| authService | POST | `/api/colaborador/RecuperarSenha` | Esqueci senha |
| obraService | POST | `/api/obra/ObterObras` | Lista obras |
| obraService | POST | `/api/obra/ObterColaboradoresObra/` | Colaboradores obra |
| obraService | POST | `/api/obra/ObterEquipamentosObra/` | Equipamentos obra |
| obraService | GET | `/api/obra/quantidadeMaximaFotos?id=` | Limite fotos |
| obraService | POST | `/api/Usuario/LoginObra` | Contexto obra ativa |
| tarefaService | GET | `/api/etapa/Get/?idObra=` | Etapas/tarefas cards |
| tarefaService | GET | `/api/etapa/ObterEtapaTarefa/?…` | Filtro etapa/tarefa |
| tarefaService | POST | `/api/tarefa/CarregarHistoricoTarefa/` | Histórico |
| tarefaService | POST | `/api/tarefa/ObterTarefa/` | Detalhe tarefa |
| tarefaService | POST | `/api/tarefa/ObterImagensTarefa/` | Imagens |
| tarefaService | POST | `/api/statusTarefa/ListaStatusTarefaPermitidos/` | Status permitidos |
| tarefaService | POST | `/api/tarefa/AtualizarStatus` | Mudança status |
| tarefaService | GET | `/api/tarefa/paralizacoes/GetCodigosParalizacoes` | Códigos paralização |
| tarefaService | POST | `/api/tarefa/CarregarHorimetroFinalUltimoHistoricoTarefa` | Horímetro |
| tarefaService | POST | `/api/tarefa/Salvar` | Salvar medição/histórico |
| tarefaService | POST | `/api/tarefa/GerarRelatorioControleHorasEquipamentoTarefa/` | PDF/Excel |
| catalogService | POST | `/api/unidadeMedida/Lista/` | Catálogo |
| catalogService | POST | `/api/municipio/ListaUF` | UF/município |
| catalogService | POST | `/api/grupo/ListaPeloGrupo/` | Grupos |
| catalogService | POST | `/api/cargo/Lista/` | Cargos |
| catalogService | GET | `/api/equipamentos/GetTipoEquipamento` | Tipos equipamento |
| laudoService | *(vários)* | `/api/laudo/…` | Escopo Piscinas/laudo — **fora MVP Equipamentos Cards** |

---

## Prioridade EQ-R (M2 Cards)

1. `LoginUser` → equivalente ou BFF Core homolog  
2. `ObterObras` + `LoginObra`  
3. `etapa/Get` (paridade web `cards.html`)

---

## Próximo (M1+)

- Tipos TS espelhando `obraTypes`, `tarefasTypes`  
- OpenAPI manual dos 3 blocos acima  
- Alinhar **EQ-M** imports quando pacote existir  
