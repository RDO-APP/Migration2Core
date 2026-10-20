/**
 * Contrato M1 — espelho docs Migration2Core (EQ-R Cards M2).
 */

export interface TarefaCard {
  id: number
  descricao: string
  status: number
  nomeStatus: string
  idEtapa: number
  dataInicio?: string
  dataPrevisaoFim?: string
  percentualConcluido?: number
  percentualExtrapolado?: string
  classeStatusCss?: string
}

export interface EtapaComTarefas {
  id: number
  titulo: string
  ordem: number
  idObra: number
  tituloObra?: string
  tarefas: TarefaCard[]
}

export interface CardsContext {
  obraId: number
  obraNome: string
  usuarioNome?: string
  etapas: EtapaComTarefas[]
}

export interface ObraListItem {
  idObra: number
  idColaborador: number
  descricao: string
  cidadeEstado?: string
  contratanteContratada?: string
  statusBasicaGratuita?: string
  progressoPorcentagem?: number
  classeStatusCss?: string
  obraFinalizada?: boolean
}

export interface EscolherContext {
  colaboradorId: number
  usuarioNome?: string
  obras: ObraListItem[]
}

export interface SelecionarObraResponse {
  success: boolean
  errorMessage?: string
  redirectUrl?: string
}
