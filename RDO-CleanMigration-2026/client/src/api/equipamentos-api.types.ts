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

export interface RdoCadastroBootstrap {
  dataRdoHoje: string
  obraFinalizada: boolean
  obraNome: string
}

export interface RdoCadastroTarefa {
  id: number
  descricao: string
  status: number
  idEtapa: number
  existeRegistroMedicaoDataRequerida: boolean
  existeRegistroMedicaoDiaAnterior: boolean
}

export interface RdoCadastroEtapa {
  id: number
  titulo: string
  ordem: number
  tarefas: RdoCadastroTarefa[]
}

export interface RdoCadastroEtapas {
  etapas: RdoCadastroEtapa[]
}

export type ClimaValor = 'b' | 'r'
export type ChuvaValor = 's' | 'p' | 'm'
export type ClimaChoice = ClimaValor | ''
export type ChuvaChoice = ChuvaValor | ''

export interface RdoCadastroSaveRequest {
  dataRdo: string
  climaManha: ClimaValor
  climaTarde: ClimaValor
  climaNoite: ClimaValor
  chuvaManha: ChuvaValor
  chuvaTarde: ChuvaValor
  chuvaNoite: ChuvaValor
  comentario?: string
  tipoComentarioGeracao?: number
  improdutividadeCondicoesClimaticas?: boolean
  improdutividadeMateriais?: boolean
  improdutividadeParalizacoes?: boolean
  improdutividadeEquipamentos?: boolean
  improdutividadeContratante?: boolean
  improdutividadeFornecedores?: boolean
  improdutividadeMaodeObra?: boolean
  improdutividadeProjeto?: boolean
  improdutividadePlanejamento?: boolean
  improdutividadeAcidente?: boolean
  confirmSubstituir?: boolean
  confirmCopiarDiaAnterior?: boolean
  listaTarefas: { id: number }[]
}

export interface RdoCadastroSaveResult {
  ok: boolean
  idRdo?: number
  errorMessage?: string
  needsConfirm?: 'substituir' | 'copiarDiaAnterior'
  confirmDetail?: string
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
