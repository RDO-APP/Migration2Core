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
  showAssinarRdo?: boolean
  showEditarRdo?: boolean
  /** t/d — paridade prod obraColaborador.contratanteContratada */
  contratanteContratada?: string
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
  statusContratanteContratadaDonoRdo?: string
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
  contratanteContratadaUsuario?: string
}

export interface RdoCadastroBootstrap {
  dataRdoHoje: string
  obraFinalizada: boolean
  obraNome: string
}

export interface RdoCadastroImagem {
  idImagem: number
  dsCaminho: string
}

export interface RdoCadastroTarefa {
  id: number
  descricao: string
  status: number
  nomeStatus: string
  idEtapa: number
  quantidadeColaboradores: number
  quantidadeEquipamentos: number
  existeRegistroMedicaoDataRequerida: boolean
  existeRegistroMedicaoDiaAnterior: boolean
  listaImagem: RdoCadastroImagem[]
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
  /** Vazio = prod (relatório "Não Informado"). */
  climaManha: ClimaChoice
  climaTarde: ClimaChoice
  climaNoite: ClimaChoice
  chuvaManha: ChuvaChoice
  chuvaTarde: ChuvaChoice
  chuvaNoite: ChuvaChoice
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
  listaImagems?: { idImagem: number }[]
  gerarRelatorioFotografico?: boolean
}

export interface RdoCadastroSaveResult {
  ok: boolean
  idRdo?: number
  errorMessage?: string
  needsConfirm?: 'substituir' | 'copiarDiaAnterior'
  confirmDetail?: string
}

export interface RdoCadastroEdit {
  idRdo: number
  dataRdo: string
  comentario: string
  statusRdo: number
  climaManha: ClimaChoice
  climaTarde: ClimaChoice
  climaNoite: ClimaChoice
  chuvaManha: ChuvaChoice
  chuvaTarde: ChuvaChoice
  chuvaNoite: ChuvaChoice
  tipoComentarioGeracao: number
  improdutividadeCondicoesClimaticas: boolean
  improdutividadeMateriais: boolean
  improdutividadeParalizacoes: boolean
  improdutividadeEquipamentos: boolean
  improdutividadeContratante: boolean
  improdutividadeFornecedores: boolean
  improdutividadeMaodeObra: boolean
  improdutividadeProjeto: boolean
  improdutividadePlanejamento: boolean
  improdutividadeAcidente: boolean
  listaTarefaIds: number[]
  listaImagemIds: number[]
}

export interface RdoAssinarRequest {
  comentarioAssinatura?: string
  tipoComentarioAssinatura?: number
  ip?: string
}

export interface RdoAssinarResult {
  ok: boolean
  errorMessage?: string
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

export interface GraficoRdoAtrasado {
  obr_ds_obra: string
  dias_atraso: number
  sem_ass_contratante: number
  sem_ass_contratada: number
}

export interface GraficoRdoGerado {
  obr_ds_obra: string
  gerado: number
  assinado_contratante: number
  assinado_contratada: number
  a_gerar: number
}

export interface GraficoDiaImprodutivo {
  obr_ds_obra: string
  imp_clima: number
  imp_falta_material: number
  imp_paralizacao: number
  imp_acidente: number
  imp_contratante: number
  imp_equipamento: number
  imp_fornecedores: number
  imp_maodeobra: number
  imp_projeto: number
  imp_planejamento: number
}

export interface GraficoTarefa {
  obr_ds_obra: string
  atraso_inicio: number
  atraso_fim: number
  pausadas: number
  canceladas: number
}

export interface GraficoStatusTarefa {
  obr_ds_obra: string
  planejada: number
  em_execucao: number
  finalizada: number
  pausada: number
  cancelada: number
}

export interface GraficoComentario {
  obr_ds_obra: string
  positivo_contratante: number
  negativo_contratante: number
  positivo_contratada: number
  negativo_contratada: number
}

export interface GraficoResumo {
  periodoIni: string
  periodoFim: string
  rdosAtrasados: GraficoRdoAtrasado[]
  rdosGerados: GraficoRdoGerado[]
  diasImprodutivos: GraficoDiaImprodutivo[]
  tarefas: GraficoTarefa[]
  statusTarefas: GraficoStatusTarefa[]
  comentarios: GraficoComentario[]
}

export interface DashboardSlice {
  name: string
  y: number
}

export interface DashboardObra {
  pizzaColaboradores: DashboardSlice[]
  barraCategorias: string[]
  barraValores: number[]
  pizzaEfetivo: DashboardSlice[]
}

export interface TarefaLookup {
  id: number
  nome: string
}

export interface TarefaParalizacao {
  codigo: string
  descricao: string
}

export interface TarefaCadastroColaborador {
  id: number
  idObraColaborador: number
  nome: string
  descricaoCargo: string
  telefonePrincipal: string
  email: string
  descricaoGrupo: string
}

export interface TarefaCadastroEquipamento {
  id: number
  idObraEquipamento: number
  tipoEquipamento: string
  descricao: string
  tipoAquisicao: string
  fabricanteFornecedor: string
  contato: string
  telefone: string
}

export interface TarefaCadastroAcidente {
  id: number
  descricao: string
  dataHora: string
  houveAfastamento: boolean
}

export interface TarefaCadastroHistorico {
  idTarefa: number
  data: string
  horaInicial: string
  horaFinal: string
  descricaoStatusTarefa: string
  horimetroInicial?: number | null
  horimetroFinal?: number | null
  horimetroTotal?: number | null
  qtdConstruida: number
  unidadeMedida: string
  nomeColaborador: string
  rdoAssinado: boolean
}

export interface TarefaCadastroImagem {
  id: number
  href: string
}

export interface TarefaCadastro {
  id: number
  descricao: string
  idEtapa: number
  status: number
  nomeStatus: string
  idUnidade: number
  dataInicio: string
  dataPrevisaoFim: string
  qtdPlanejada: number
  valor: number
  qtdConstruida: number
  dataMedicao: string
  horaInicial: string
  horaFinal: string
  horimetroInicial: number
  horimetroFinal: number
  horimetroTotal: number
  comentario: string
  codigoParalizacao?: string | null
  rdoAssinado: boolean
  ultimoHorimetroFinal?: number | null
  listaColaboradores: TarefaCadastroColaborador[]
  listaEquipamentos: TarefaCadastroEquipamento[]
  etapas: TarefaLookup[]
  statusTarefa: TarefaLookup[]
  unidades: TarefaLookup[]
  codigosParalizacao: TarefaParalizacao[]
  listaHistoricoTarefa?: TarefaCadastroHistorico[]
  listaImagens?: TarefaCadastroImagem[]
  listaAcidentes?: TarefaCadastroAcidente[]
  colaboradoresObra?: TarefaCadastroColaborador[]
  equipamentosObra?: TarefaCadastroEquipamento[]
}

export interface TarefaCadastroSaveRequest {
  id: number
  novaMedicao: boolean
  descricao: string
  idEtapa: number
  status: number
  idUnidade: number
  dataInicio: string
  dataPrevisaoFim: string
  qtdPlanejada?: number
  valor?: number
  qtdConstruida?: number
  dataMedicao?: string
  horaInicial?: string
  horaFinal?: string
  horimetroInicial?: number
  horimetroFinal?: number
  horimetroTotal?: number
  comentario?: string
  codigoParalizacao?: string
  listaIdsObraColaborador?: number[]
  listaIdsObraEquipamento?: number[]
}

export interface TarefaCadastroSaveResult {
  ok: boolean
  id?: number
  errorMessage?: string
}
