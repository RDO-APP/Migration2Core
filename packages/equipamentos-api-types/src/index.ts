/**
 * @rdo-app/equipamentos-api-types v0.1 — M6 1.3
 * Contrato compartilhado EQ-R + EQ-M (tipos only).
 * Fonte M1: docs/api-client/equipamentos-api.types.ts
 * JWT: BffMobileAuthController / MobileAuthDtos
 */

export type ApiEnv = 'prod' | 'homolog'

export const API_BASE = {
  prod: 'https://sistema.rdoapp.com.br',
  homologWeb: 'https://homolog.sistema.rdoapp.com.br',
  /** LAN legado appVariant — não usar na web */
  homologLegacyLan: 'http://192.168.0.8:58951',
} as const

export const MOBILE_AUTH_PATHS = {
  login: '/api/mobile/auth/login',
  me: '/api/mobile/auth/me',
} as const

// --- Auth legado (LoginUser / EQ-M cen. A) ---

export interface LoginCredentials {
  cpf: string
  senha: string
  email?: string
  manterLogado?: boolean
}

export interface RoutePermission {
  name: string
  path: string
  permissions: string[]
}

export interface LoginUsuario {
  id: number
  nomeUsuario: string
  email: string
  idGrupo: number
}

export interface LoginResponse {
  usuario: LoginUsuario
  routes: RoutePermission[]
  menu?: unknown
}

// --- Auth JWT Core homolog (M6 1.2) ---

export interface MobileLoginRequest {
  cpf: string
  senha: string
}

export interface MobileColaboradorInfo {
  id: number
  nome: string
  cpf: string
  email: string
}

export interface MobileLoginResponse {
  accessToken: string
  expiresIn: number
  tokenType: string
  colaborador: MobileColaboradorInfo
}

export interface MobileMeResponse {
  id: number
  nome: string
  cpf: string
  email: string
  isAdmin?: boolean
}

// --- Obra ---

export interface ObterObrasInput {
  idColaborador: number
  dataFim?: string
  dataInicio?: string
  dataPrevisaoFim?: string
  descricao?: string
  idContratada?: number
  idContratante?: number
  idMunicipio?: number
  idUf?: number
  setor?: number
  statusObra?: number
}

export interface ObraListItem {
  idColaborador: number
  idObra: number
  descricao: string
  cidadeEstado?: string
  contratanteContratada?: string
  statusBasicaGratuita?: string
  progressoPorcentagem?: number
  classeStatusCss?: string
  obraFinalizada?: boolean
}

export interface LoginObraPayload {
  idObra: number
  idUsuario: number
  obra: unknown
  user: unknown
}

// --- Cards (etapa / tarefa) ---

export interface StatusPermitido {
  id: number
  nome: string
  cssClass: string
}

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
  marcado?: boolean
  rdoAssinado?: boolean
  quantidadeColaboradores?: number
  quantidadeEquipamentos?: number
  primeiraExecucao?: string
  ultimaExecucao?: string
  existeExecucao?: boolean
  listaStatusPermitidos?: StatusPermitido[]
}

export interface EtapaComTarefas {
  id: number
  titulo: string
  ordem: number
  idObra: number
  tituloObra?: string
  tarefas: TarefaCard[]
}

// --- HTTP helpers ---

export type HttpMethod = 'GET' | 'POST'

export interface ApiCallOptions {
  method: HttpMethod
  headers?: Record<string, string>
  body?: unknown
  credentials?: RequestCredentials
}
