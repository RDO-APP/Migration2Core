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
  quantidadeColaboradores?: number
  quantidadeEquipamentos?: number
  primeiraExecucao?: string
  ultimaExecucao?: string
  existeExecucao?: boolean
}

export interface ShellNavItem {
  titulo: string
  href: string
  cssClass: string
}

export interface ShellContext {
  usuarioNome?: string
  obraNome?: string
  obraCidadeEstado?: string
  showChart: boolean
  showNovaObra: boolean
  showDashboardObra: boolean
  showGerarRdo: boolean
  showEditarObra: boolean
  showCriarNovoTarefa: boolean
  showCriarNovaEtapa: boolean
  showAlterarStatusEmMassa: boolean
  menuPaginas: ShellNavItem[]
  antiforgeryFieldName?: string
  antiforgeryToken?: string
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

export interface RdoStatusOption {
  id: number
  nome: string
}

export interface RdoListItem {
  idRdo: number
  dataRdo: string
  diaDaSemana: string
  statusRdo: number
  descricaoStatus: string
  qtdTarefas: number
  qtdColaboradores: number
  qtdMaquinas: number
}

export interface RdoListPage {
  currentPage: number
  pageSize: number
  totalPages: number
  totalCount: number
  items: RdoListItem[]
  obraNome: string
  /** Paridade prod Auth.getUser().obra.obraFinalizada — desabilita NOVO. */
  obraFinalizada?: boolean
}

export interface LoginContext {
  antiforgeryFieldName: string
  antiforgeryToken: string
}

export interface SelecionarObraResponse {
  success: boolean
  errorMessage?: string
  redirectUrl?: string
}
